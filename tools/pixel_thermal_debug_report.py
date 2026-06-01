#!/usr/bin/env python3
import csv
import datetime as _dt
import hashlib
import json
import re
import shutil
import subprocess
import zipfile
from pathlib import Path

TARGET_FILES = [
    "/vendor/etc/thermal_info_config_throttling.json",
    "/vendor/etc/thermal_info_config.json",
    "/vendor/etc/thermal_info_config_charge.json",
]

PROP_KEYS = [
    "ro.product.device",
    "ro.product.model",
    "ro.product.name",
    "ro.product.vendor.device",
    "ro.build.fingerprint",
    "ro.build.version.release",
    "ro.build.version.sdk",
    "ro.build.version.incremental",
    "ro.build.version.security_patch",
    "ro.bootloader",
    "ro.boot.verifiedbootstate",
    "ro.boot.vbmeta.device_state",
]


def run(cmd, timeout=8):
    try:
        p = subprocess.run(cmd, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=timeout)
        return {"rc": p.returncode, "stdout": p.stdout.strip(), "stderr": p.stderr.strip()}
    except Exception as exc:
        return {"rc": 127, "stdout": "", "stderr": str(exc)}


def getprop(key):
    return run(["getprop", key])["stdout"].strip()


def safe_name(value):
    value = value or "unknown"
    return re.sub(r"[^A-Za-z0-9._-]+", "_", value)[:80]


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def collect_files():
    seen = []
    for item in TARGET_FILES:
        p = Path(item)
        if p.exists() and p.is_file():
            seen.append(p)
    vendor = Path("/vendor/etc")
    if vendor.exists():
        for p in sorted(vendor.glob("thermal*.json")):
            if p.is_file() and p not in seen:
                seen.append(p)
    return seen[:30]


def sensor_rows(path):
    rows = []
    try:
        data = json.loads(Path(path).read_text(encoding="utf-8"))
    except Exception as exc:
        return [{"source_file": str(path), "index": None, "name": None, "polling_delay": None, "candidate_300000": False, "parse_error": str(exc)}]
    sensors = data.get("Sensors")
    if not isinstance(sensors, list):
        return rows
    for idx, sensor in enumerate(sensors):
        if not isinstance(sensor, dict):
            continue
        name = sensor.get("Name")
        if not isinstance(name, str) or not name.startswith("VIRTUAL-SKIN"):
            continue
        polling = sensor.get("PollingDelay")
        rows.append({
            "source_file": str(path),
            "index": idx,
            "name": name,
            "polling_delay": polling,
            "candidate_300000": polling == 300000,
            "parse_error": "",
        })
    return rows


def optional_su(cmd):
    return run(["su", "-c", cmd], timeout=8)


def write_report(outdir, metadata, file_inventory, rows):
    lines = [
        "# Pixel Thermal Compatibility Debug Report",
        "",
        "This report is sanitized and intended for GitHub/XDA compatibility requests.",
        "It does not include serial numbers, IMEI, accounts, full getprop, app lists or logcat.",
        "",
        "## Device",
    ]
    for k, v in metadata["props"].items():
        lines.append(f"- `{k}`: `{v}`")
    lines.extend(["", "## Module / safety state"])
    for k, v in metadata["module_state"].items():
        if isinstance(v, str):
            lines.append(f"- `{k}`: `{v}`")
    lines.extend(["", "## Thermal files"])
    for item in file_inventory:
        lines.append(f"- `{item['path']}` bytes={item.get('bytes')} sha256={item.get('sha256')}")
    lines.extend(["", "## VIRTUAL-SKIN candidates"])
    if not rows:
        lines.append("No VIRTUAL-SKIN sensors found or files were not readable.")
    else:
        for row in rows:
            lines.append(f"- `{row.get('source_file')}` index={row.get('index')} name=`{row.get('name')}` PollingDelay=`{row.get('polling_delay')}` candidate_300000={row.get('candidate_300000')}")
    lines.extend(["", "## Upload target", "Attach the generated ZIP to the GitHub issue or XDA post."])
    (outdir / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def main():
    timestamp = _dt.datetime.now().strftime("%Y%m%d_%H%M%S")
    props = {key: getprop(key) for key in PROP_KEYS}
    device = safe_name(props.get("ro.product.device"))
    incremental = safe_name(props.get("ro.build.version.incremental"))
    outdir = Path.cwd() / f"pixel_thermal_debug_{device}_{incremental}_{timestamp}"
    outdir.mkdir(parents=True, exist_ok=True)
    thermal_dir = outdir / "thermal_configs"
    thermal_dir.mkdir(parents=True, exist_ok=True)

    files = collect_files()
    inventory = []
    rows = []

    for src in files:
        try:
            dst = thermal_dir / src.name
            shutil.copy2(src, dst)
            inventory.append({
                "path": str(src),
                "copied_as": str(dst.relative_to(outdir)),
                "bytes": src.stat().st_size,
                "sha256": sha256_file(src),
            })
            rows.extend(sensor_rows(src))
        except Exception as exc:
            inventory.append({"path": str(src), "copied_as": None, "bytes": None, "sha256": None, "error": str(exc)})

    module_state = {
        "module_prop": optional_su("cat /data/adb/modules/pixel-10-pro-xl-thermal-fix/module.prop 2>/dev/null || true")["stdout"],
        "disable": optional_su("test -e /data/adb/modules/pixel-10-pro-xl-thermal-fix/disable && echo present || echo absent")["stdout"],
        "skip_mount": optional_su("test -e /data/adb/modules/pixel-10-pro-xl-thermal-fix/skip_mount && echo present || echo absent")["stdout"],
        "ashlooper": optional_su("grep -E '^loops=|^disable=|^threshold=|^boot=|^whitelist=' /data/adb/modules/AshLooper/settings.prop 2>/dev/null || true")["stdout"],
    }

    metadata = {
        "generated_at": _dt.datetime.now().isoformat(),
        "tool": "pixel_thermal_debug_report.py",
        "tool_scope": "sanitized compatibility report only; no patching",
        "props": props,
        "module_state": module_state,
        "privacy": {
            "full_getprop": False,
            "serial": False,
            "imei": False,
            "accounts": False,
            "logcat": False,
            "app_list": False,
        },
    }

    (outdir / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8", newline="\n")
    (outdir / "thermal_file_inventory.json").write_text(json.dumps(inventory, indent=2) + "\n", encoding="utf-8", newline="\n")
    (outdir / "virtual_skin_map.json").write_text(json.dumps(rows, indent=2) + "\n", encoding="utf-8", newline="\n")

    with open(outdir / "virtual_skin_map.csv", "w", newline="", encoding="utf-8") as fh:
        fieldnames = ["source_file", "index", "name", "polling_delay", "candidate_300000", "parse_error"]
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({k: row.get(k) for k in fieldnames})

    write_report(outdir, metadata, inventory, rows)

    zip_path = outdir.with_suffix(".zip")
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for p in sorted(outdir.rglob("*")):
            zf.write(p, p.relative_to(outdir.parent))

    print("")
    print("RESULT: PIXEL_THERMAL_DEBUG_REPORT_CREATED")
    print(f"zip={zip_path}")
    print(f"device={props.get('ro.product.device')}")
    print(f"fingerprint={props.get('ro.build.fingerprint')}")
    print(f"virtual_skin_rows={len(rows)}")
    print("Upload the ZIP to GitHub/XDA. Do not paste full private logs unless asked.")


if __name__ == "__main__":
    main()
