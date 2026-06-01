# Pixel 10 Pro XL Thermal Polling Fix

Stable Magisk module for Pixel 10 Pro XL (`mustang`) on Android 16.

Project: <https://github.com/Lycidias93/pixel-10-pro-xl-thermal-fix>
Releases: <https://github.com/Lycidias93/pixel-10-pro-xl-thermal-fix/releases>
Issues / compatibility reports: <https://github.com/Lycidias93/pixel-10-pro-xl-thermal-fix/issues>

## Why this fork exists

This fork exists because the original thermal polling idea was useful, but the first direct Pixel 10 Pro XL port was too broad for `mustang` and caused the native Pixel ThermalHAL to abort during boot.

The goal of this fork is therefore not to blindly patch every thermal file. It provides a verified, device-specific Mustang port that changes only the proven `PollingDelay=300000` `VIRTUAL-SKIN*` candidates that survived install, reboot and post-boot ThermalHAL checks.

## Credits

- Original thermal polling fix idea and upstream inspiration: original module author / upstream project.
- Mustang fork, controlled bisect, runtime verification and stable release packaging: Lycidias93.
- External bootloop protection used during testing: AshLooper by RipperHybrid, <https://github.com/RipperHybrid/AshLooper>.

AshLooper is not bundled with this module. It remains an external safety layer and should not whitelist this thermal module during testing.

## Supported device

This release is intentionally narrow.

```text
Device: Pixel 10 Pro XL
Codename: mustang
Android: 16
Verified build: CP1A.260505.005 / 15081906
Stable release: v1.3-mustang.14
```

The installer checks the device and Android target before installing.

## Main features

- Magisk module for Pixel 10 Pro XL / `mustang`.
- Stable `v1.3-mustang.14` release with the same runtime thermal scope as `v1.3-mustang.13`.
- Reduces verified `VIRTUAL-SKIN*` thermal polling delays from `300000ms` to `5000ms`.
- Uses stock-derived live-device thermal JSON overlays.
- Keeps entries with missing/null `PollingDelay` untouched.
- Includes install-time target guard.
- Includes passive boot-time sanity guard.
- Keeps AshLooper as the recommended external bootloop protection during testing.
- Bundles a sanitized compatibility debug report tool for new Mustang firmwares or other Pixel 10-series devices.
- Keeps changelog and historical bisect details out of the README; see `CHANGELOG.md`.

## Runtime scope

`v1.3-mustang.14` changes only proven `PollingDelay=300000` candidates. The runtime thermal scope is unchanged from `v1.3-mustang.13`.

### `thermal_info_config_throttling.json`

```text
VIRTUAL-SKIN
VIRTUAL-SKIN-HINT
VIRTUAL-SKIN-CPU-LIGHT-ODPM
VIRTUAL-SKIN-CPU-MID
VIRTUAL-SKIN-CPU-ODPM
VIRTUAL-SKIN-CPU-HIGH
VIRTUAL-SKIN-SOC
VIRTUAL-SKIN-SOC-EXTREME
```

### `thermal_info_config.json`

```text
VIRTUAL-SKIN-SPEAKER
```

### `thermal_info_config_charge.json`

```text
VIRTUAL-SKIN-CHARGE-WIRED
VIRTUAL-SKIN-CHARGE-PERSIST
```

All listed targets are set to:

```text
PollingDelay: 300000 -> 5000
```

## What is intentionally not changed

The module does not set missing/null `PollingDelay` entries to `5000`.

Examples intentionally left untouched:

```text
VIRTUAL-SKIN-PREDICTION-MODEL
VIRTUAL-SKIN-SPEAKER-SUB-0
VIRTUAL-SKIN-SPEAKER-SUB-1
VIRTUAL-SKIN-SUB-0..7
VIRTUAL-SKIN-LEGACY
VIRTUAL-SKIN-MODEL
VIRTUAL-SKIN-CHARGE
```

These entries are likely derived/model/formula sensors or helper sensors. Changing them without a real existing `PollingDelay` value would be a different and much riskier modification.

## How it works

The module overlays selected vendor thermal configuration JSON files through Magisk:

```text
/vendor/etc/thermal_info_config_throttling.json
/vendor/etc/thermal_info_config.json
/vendor/etc/thermal_info_config_charge.json
```

The files are copied from the live stock device baseline and only the verified target sensor `PollingDelay` values are changed. This avoids mixing incompatible thermal configs from another device, build or firmware generation.

At boot, Android ThermalHAL reads the overlaid JSON files. The expected result is that the selected `VIRTUAL-SKIN*` sensors are polled more frequently while the rest of the thermal model stays stock.

## Safety model

- The installer is device/build scoped.
- The runtime scope was built through controlled bisecting.
- ThermalHAL crash checks were used after reboot.
- AshLooper is recommended as external bootloop protection during testing.
- This module should not be added to the AshLooper whitelist.
- `disable` and `skip_mount` must remain absent for normal operation.

Expected healthy state:

```text
version=1.3-mustang.14
disable=absent
skip_mount=absent
AshLooper loops=0
fresh_thermalhal_tombstone=absent
```

## Install

Download the latest stable release ZIP from GitHub Releases and install it in Magisk.

Latest stable:

```text
v1.3-mustang.14
```

## Verify

After installing and rebooting, check:

```text
version=1.3-mustang.14
versionCode=101314
disable=absent
skip_mount=absent
```

The three overlay mounts should be present:

```text
/vendor/etc/thermal_info_config_throttling.json
/vendor/etc/thermal_info_config.json
/vendor/etc/thermal_info_config_charge.json
```

The selected `VIRTUAL-SKIN*` targets should show `PollingDelay=5000`, and there should be no fresh ThermalHAL tombstone.

### Simple verify command

Run from a root-capable shell or Termux:

```sh
su -c 'mod=/data/adb/modules/pixel-10-pro-xl-thermal-fix; echo "== module =="; grep -E "^(id|version|versionCode|description)=" "$mod/module.prop"; test ! -e "$mod/disable" && echo "disable=absent" || echo "FAIL disable=present"; test ! -e "$mod/skip_mount" && echo "skip_mount=absent" || echo "FAIL skip_mount=present"; echo "== mounts =="; grep -F "pixel-10-pro-xl-thermal-fix/system/vendor/etc/thermal_info_config_throttling.json" /proc/self/mountinfo >/dev/null && echo "throttling_mount=present" || echo "FAIL throttling_mount=absent"; grep -F "pixel-10-pro-xl-thermal-fix/system/vendor/etc/thermal_info_config.json" /proc/self/mountinfo >/dev/null && echo "base_mount=present" || echo "FAIL base_mount=absent"; grep -F "pixel-10-pro-xl-thermal-fix/system/vendor/etc/thermal_info_config_charge.json" /proc/self/mountinfo >/dev/null && echo "charge_mount=present" || echo "FAIL charge_mount=absent"; echo "== AshLooper =="; grep -E "^loops=|^disable=|^threshold=|^boot=|^whitelist=" /data/adb/modules/AshLooper/settings.prop 2>/dev/null || echo "AshLooper status not readable"; echo "== expected =="; echo "version=1.3-mustang.14"; echo "disable=absent"; echo "skip_mount=absent"; echo "all three mounts present"; echo "AshLooper loops=0"'
```

## Compatibility report for new firmware or other Pixel 10-series devices

Use this before requesting support for a new Pixel 10 Pro XL firmware or another Pixel 10-series device.

This does not patch anything. It only collects a sanitized compatibility report with device identity, build fingerprint, thermal config hashes and the `VIRTUAL-SKIN*` `PollingDelay` map.

```sh
pkg install -y python
mkdir -p "$HOME/pixel-thermal-debug"
cd "$HOME/pixel-thermal-debug"
curl -fsSLO https://raw.githubusercontent.com/Lycidias93/pixel-10-pro-xl-thermal-fix/main/tools/pixel_thermal_debug_report.py
python3 pixel_thermal_debug_report.py
```

Upload the generated `pixel_thermal_debug_*.zip` to a GitHub issue or XDA post.

Do not request support without this report. Device name alone is not enough; thermal configs can change between firmwares.

## Rollback

From a booted system:

```sh
su -c 'touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/disable'
su -c 'touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/skip_mount'
su -c 'reboot'
```

Or remove the module from Magisk and reboot.

## Release policy

- `v1.3-mustang.14` is the current stable release.
- Earlier `v1.3-mustang.*` builds are historical bisect/test releases.
- Historical builds are kept for audit and rollback context, but should not be preferred for normal installation.
- Full release history belongs in `CHANGELOG.md`, not in this README.
