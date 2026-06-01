#!/usr/bin/env python3
import argparse
import csv
import hashlib
import json
import re
import shutil
import subprocess
import zipfile
from datetime import datetime, timezone
from pathlib import Path

SCHEMA_VERSION = 2
THERMAL_FILES = [
    "/vendor/etc/thermal_info_config_throttling.json",
    "/vendor/etc/thermal_info_config.json",
    "/vendor/etc/thermal_info_config_charge.json",
]
PROP_KEYS = [
    "ro.product.device",
    "ro.product.model",
    "ro.product.manufacturer",
    "ro.build.fingerprint",
    "ro.build.version.release",
    "ro.build.version.incremental",
    "ro.build.version.security_patch",
    "ro.bootloader",
]
PRIVATE_PATTERNS = [
    re.compile(r"\b[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}\b"),
    re.compile(r"\b\d{15,17}\b"),
    re.compile(r"@gmail\.com", re.I),
    re.compile(r"@googlemail\.com", re.I),
    re.compile(r"account", re.I),
    re.compile(r"android_id", re.I),
    re.compile(r"serialno", re.I),
    re.compile(r"password", re.I),
    re.compile(r"private_key", re.I),
]

def run_cmd(args):
    try:
        return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""

def getprop(key):
    return run_cmd(["getprop", key])

def sha256_path(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def safe_name(value):
    value = value or "unknown"
    value = re.sub(r"[^A-Za-z0-9._-]+", "_", value)
    return value[:80] or "unknown"

def choose_out_dir(cli_out_dir):
    candidates = []
    if cli_out_dir:
        candidates.append(Path(cli_out_dir).expanduser())
    candidates.append(Path("/storage/emulated/0/Download"))
    candidates.append(Path.cwd())
    for c in candidates:
        try:
            c.mkdir(parents=True, exist_ok=True)
            probe = c / ".pixel_thermal_debug_write_test"
            probe.write_text("ok\n", encoding="utf-8")
            probe.unlink(missing_ok=True)
            return c.resolve()
        except Exception:
            continue
    raise SystemExit("No writable output directory found")

def module_state():
    mod = Path("/data/adb/modules/pixel-10-pro-xl-thermal-fix")
    state = {
        "module_path": str(mod),
        "installed": mod.exists(),
        "disable_present": (mod / "disable").exists(),
        "skip_mount_present": (mod / "skip_mount").exists(),
        "module_prop": {},
        "warning": None,
    }
    prop = mod / "module.prop"
    if prop.exists():
        for line in prop.read_text(errors="replace").splitlines():
            if "=" in line:
                k, v = line.split("=", 1)
                if k in {"id", "version", "versionCode", "description"}:
                    state["module_prop"][k] = v
    if state["installed"] and not state["disable_present"] and not state["skip_mount_present"]:
        state["warning"] = "The module appears active. /vendor thermal files may be Magisk overlays. For adaptation, disable/remove the module and reboot before creating a stock report."
    return state

def ashlooper_state():
    lines = []
    for p in [Path("/data/adb/modules/AshLooper/settings.prop"), Path("/data/adb/modules/AshLooper/module.prop")]:
        if not p.exists():
            continue
        for line in p.read_text(errors="replace").splitlines():
            if re.match(r"^(loops|disable|threshold|boot|whitelist|id|version|versionCode)=", line):
                lines.append(f"{p}: {line}")
    return lines

def collect_thermal(workdir):
    thermal_dir = workdir / "thermal_files"
    thermal_dir.mkdir(parents=True, exist_ok=True)
    infos = []
    rows = []
    for src in THERMAL_FILES:
        p = Path(src)
        info = {"path": src, "exists": p.exists()}
        if not p.exists():
            infos.append(info)
            continue
        dst = thermal_dir / p.name
        shutil.copy2(p, dst)
        st = p.stat()
        info.update({"bytes": st.st_size, "mtime_epoch": int(st.st_mtime), "sha256": sha256_path(p), "copied_as": str(Path("thermal_files") / dst.name)})
        try:
            data = json.loads(p.read_text(errors="replace"))
            for idx, sensor in enumerate(data.get("Sensors", [])):
                if isinstance(sensor, dict) and isinstance(sensor.get("Name"), str) and sensor["Name"].startswith("VIRTUAL-SKIN"):
                    polling = sensor.get("PollingDelay")
                    rows.append({"file": src, "sensor_index": idx, "name": sensor["Name"], "polling_delay": polling, "candidate_300000": polling == 300000, "currently_5000": polling == 5000})
            info["json_parse"] = "pass"
        except Exception as exc:
            info["json_parse"] = f"fail: {exc}"
        infos.append(info)
    return infos, rows

def sanitizer(paths):
    hits = []
    for path in paths:
        if not path.exists() or path.suffix.lower() not in {".json", ".csv", ".txt", ".md"}:
            continue
        text = path.read_text(errors="replace")
        for pat in PRIVATE_PATTERNS:
            if pat.search(text):
                hits.append({"file": path.name, "pattern": pat.pattern})
    return hits

def main():
    ap = argparse.ArgumentParser(description="Create a sanitized Pixel thermal compatibility debug report.")
    ap.add_argument("--out-dir", help="Output directory. Defaults to /storage/emulated/0/Download with cwd fallback.")
    args = ap.parse_args()
    out_dir = choose_out_dir(args.out_dir)
    props = {k: getprop(k) for k in PROP_KEYS}
    device = safe_name(props.get("ro.product.device"))
    incremental = safe_name(props.get("ro.build.version.incremental"))
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    base = f"pixel_thermal_debug_{device}_{incremental}_{stamp}"
    workdir = out_dir / base
    zip_path = out_dir / f"{base}.zip"
    if workdir.exists():
        shutil.rmtree(workdir)
    workdir.mkdir(parents=True)
    mod = module_state()
    ash = ashlooper_state()
    files, rows = collect_thermal(workdir)
    manifest = {
        "report_schema_version": SCHEMA_VERSION,
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "tool": "pixel_thermal_debug_report.py",
        "tool_purpose": "sanitized compatibility report for new Pixel 10 firmware/device adaptation",
        "output_zip": str(zip_path),
        "props": props,
        "module_state": mod,
        "ashlooper_state_lines": ash,
        "thermal_files": files,
        "virtual_skin_rows": len(rows),
        "privacy": {"full_getprop_collected": False, "logcat_collected": False, "app_list_collected": False, "accounts_collected": False, "denylist_collected": False},
    }
    (workdir / "props.json").write_text(json.dumps(props, indent=2) + "\n", encoding="utf-8")
    (workdir / "module_state.json").write_text(json.dumps(mod, indent=2) + "\n", encoding="utf-8")
    (workdir / "ashlooper_state.txt").write_text("\n".join(ash) + ("\n" if ash else ""), encoding="utf-8")
    (workdir / "virtual_skin_map.json").write_text(json.dumps(rows, indent=2) + "\n", encoding="utf-8")
    with open(workdir / "virtual_skin_map.csv", "w", newline="", encoding="utf-8") as f:
        fieldnames = ["file", "sensor_index", "name", "polling_delay", "candidate_300000", "currently_5000"]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)
    report_readme = (
        "# Pixel Thermal Debug Report\n\n"
        "Upload this ZIP to the GitHub issue or XDA post when requesting support for a new Pixel 10 Pro XL firmware or another Pixel 10-series device.\n\n"
        "This report is intentionally narrow. It does not include logcat, full getprop, accounts, app lists, DenyList data, IMEI, serial number, Wi-Fi MACs or Bluetooth MACs.\n\n"
        "If module_state.json says the module appears active, disable/remove the module and reboot before creating an adaptation report, because /vendor thermal files may be Magisk overlays instead of stock files.\n"
    )
    (workdir / "README_REPORT.md").write_text(report_readme, encoding="utf-8")
    manifest_path = workdir / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    scan_paths = [manifest_path, workdir / "props.json", workdir / "module_state.json", workdir / "ashlooper_state.txt", workdir / "virtual_skin_map.json", workdir / "virtual_skin_map.csv", workdir / "README_REPORT.md"]
    hits = sanitizer(scan_paths)
    manifest["sanitizer_status"] = "pass" if not hits else "fail"
    manifest["sanitizer_hits"] = hits
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    if hits:
        print("RESULT: REFUSED_UNSANITIZED_REPORT")
        print(json.dumps(hits, indent=2))
        raise SystemExit(2)
    if zip_path.exists():
        zip_path.unlink()
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as z:
        for p in sorted(workdir.rglob("*")):
            if p.is_file():
                z.write(p, p.relative_to(workdir.parent))
    print("RESULT: PIXEL_THERMAL_DEBUG_REPORT_CREATED")
    print(f"zip={zip_path}")
    print(f"device={props.get('ro.product.device')}")
    print(f"fingerprint={props.get('ro.build.fingerprint')}")
    print(f"virtual_skin_rows={len(rows)}")
    print("sanitizer_status=pass")
    if mod.get("warning"):
        print("warning=" + mod["warning"])
    print("Upload the ZIP to GitHub/XDA. Do not paste full private logs unless asked.")

if __name__ == "__main__":
    main()
