# Pixel 10 Pro XL Thermal Polling Fix

Project: <https://github.com/Lycidias93/pixel-10-pro-xl-thermal-fix>
Releases: <https://github.com/Lycidias93/pixel-10-pro-xl-thermal-fix/releases>
Issues / compatibility requests: <https://github.com/Lycidias93/pixel-10-pro-xl-thermal-fix/issues>

Stable Magisk module for Pixel 10 Pro XL (`mustang`) on Android 16.

## Why this fork exists

This fork exists because the original thermal polling idea is useful, but the first direct Pixel 10 Pro XL port was too broad for `mustang` and caused the native Pixel ThermalHAL to abort during boot.

The goal of this fork is therefore not to blindly patch every thermal file. It provides a verified, device-specific Mustang port that changes only the proven `PollingDelay=300000` `VIRTUAL-SKIN*` candidates that survived install, reboot and post-boot ThermalHAL checks.

In daily use, the intended difference is more responsive thermal skin-sensor polling. The selected `VIRTUAL-SKIN*` sensors are checked every `5000ms` instead of every `300000ms`, so Android can notice relevant skin/thermal changes sooner during charging, navigation, camera use, gaming, hotspot use or other sustained loads. This is not an overclock, benchmark unlock, cooling bypass or guaranteed FPS tweak. The stock thermal policy remains in charge; this fork only makes the verified skin-related polling inputs update more frequently.


## What changes in daily use

This module does not overclock the device, disable thermal protection or bypass the stock cooling policy. Android ThermalHAL remains in control.

What it changes is the update rate for the verified skin-related thermal input sensors. On the verified Pixel 10 Pro XL firmware, selected `VIRTUAL-SKIN*` sensors that normally use `PollingDelay=300000ms` are polled at `5000ms` instead.

In practical daily use, this is meant to make the thermal model react sooner during workloads where skin temperature matters, for example:

- charging while using the phone
- Android Auto / navigation
- camera or video recording
- gaming or emulation
- hotspot or sustained mobile data
- long screen-on sessions under load

Expected effect: more responsive thermal awareness and smoother thermal decision timing. It is not a guaranteed FPS, benchmark or battery-life tweak, and it does not make the phone ignore safety limits.

## Credits

- Original thermal polling fix idea and upstream inspiration: `marx161` / original upstream author credit kept from installer metadata.
- Mustang fork, controlled bisect, runtime verification and stable release packaging: [Lycidias93](https://github.com/Lycidias93/pixel-10-pro-xl-thermal-fix).
- Bootloop safety during testing: [AshLooper](https://github.com/RipperHybrid/AshLooper) by RipperHybrid. AshLooper is not bundled and not required by the ZIP itself, but it is strongly recommended as an external bootloop protection layer while testing ports or new firmware.


<!-- UNIVERSAL_TEST_V1401_START -->
## Universal test release policy

`v1.4.0-universal-test.1` is a public universal test release, not a new universal stable baseline.

Stable verified profile:

```text
mustang / Pixel 10 Pro XL / Android 16 / CP1A.260505.005 / 15081906
```

Beta test profile:

```text
blazer / Pixel 10 Pro / Android 16
```

The Magisk module ID intentionally remains:

```text
id=pixel-10-pro-xl-thermal-fix
```

The stable update channel intentionally remains:

```text
https://raw.githubusercontent.com/Lycidias93/pixel-10-pro-xl-thermal-fix/main/update.json
```

That means this test ZIP can be installed manually, while the normal update channel stays conservative. Unknown devices abort during install. The `blazer` profile is not live-boot verified by this fork yet; use AshLooper or equivalent bootloop protection and do not whitelist this thermal module in AshLooper.
<!-- UNIVERSAL_TEST_V1401_END -->

## Supported device

This release is intentionally narrow.

```text
Device: Pixel 10 Pro XL
Codename: mustang
Android: 16
Verified build: CP1A.260505.005 / 15081906
Stable release: v1.3-mustang.15
```

The installer checks the device and Android target before installing.

## Main features

- Magisk module for Pixel 10 Pro XL / `mustang`.
- Stable `v1.3-mustang.15` runtime scope verified after reboot.
- Reduces verified `VIRTUAL-SKIN*` thermal polling delays from `300000ms` to `5000ms`.
- Uses stock-derived live-device thermal JSON overlays.
- Keeps entries with missing/null `PollingDelay` untouched.
- Includes install-time target guard.
- Includes passive boot-time sanity guard.
- Keeps AshLooper as the recommended external bootloop protection during testing.
- Provides manual disable action through Magisk action script.
- Includes a public compatibility/debug report tool for new Mustang firmware and other Pixel 10-series adaptation requests.
- Keeps changelog and historical bisect details out of the README; see `CHANGELOG.md`.

## Runtime scope

`v1.3-mustang.15` changes only proven `PollingDelay=300000` candidates.

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
version=1.3-mustang.15
disable=absent
skip_mount=absent
AshLooper loops=0
fresh_thermalhal_tombstone=absent
```

## Install

Download the latest stable release ZIP from GitHub Releases and install it in Magisk.

Latest stable:

```text
v1.3-mustang.15
```

## Verify

After installing and rebooting, check:

```text
version=1.3-mustang.15
versionCode=101315
disable=absent
skip_mount=absent
```

The three overlay mounts should be present:

```text
/vendor/etc/thermal_info_config_throttling.json
/vendor/etc/thermal_info_config.json
/vendor/etc/thermal_info_config_charge.json
```

Public Termux verify command:

```sh
su -c 'mod=/data/adb/modules/pixel-10-pro-xl-thermal-fix; echo "== module =="; grep -E "^(id|version|versionCode|description)=" "$mod/module.prop"; test ! -e "$mod/disable" && echo "disable=absent" || echo "FAIL disable=present"; test ! -e "$mod/skip_mount" && echo "skip_mount=absent" || echo "FAIL skip_mount=present"; echo "== mounts =="; grep -F "pixel-10-pro-xl-thermal-fix/system/vendor/etc/thermal_info_config_throttling.json" /proc/self/mountinfo >/dev/null && echo "throttling_mount=present" || echo "FAIL throttling_mount=absent"; grep -F "pixel-10-pro-xl-thermal-fix/system/vendor/etc/thermal_info_config.json" /proc/self/mountinfo >/dev/null && echo "base_mount=present" || echo "FAIL base_mount=absent"; grep -F "pixel-10-pro-xl-thermal-fix/system/vendor/etc/thermal_info_config_charge.json" /proc/self/mountinfo >/dev/null && echo "charge_mount=present" || echo "FAIL charge_mount=absent"; echo "== AshLooper =="; grep -E "^loops=|^disable=|^threshold=|^boot=|^whitelist=" /data/adb/modules/AshLooper/settings.prop 2>/dev/null || echo "AshLooper status not readable"'
```

The selected `VIRTUAL-SKIN*` targets should show `PollingDelay=5000`, and there should be no fresh ThermalHAL tombstone.

## Compatibility report for new firmware or other Pixel 10 devices

Use this before requesting support for a newer Pixel 10 Pro XL firmware or another Pixel 10-series device.

The command does not patch anything. It creates a sanitized ZIP with selected device identity, build fingerprint, thermal config hashes and the `VIRTUAL-SKIN*` `PollingDelay` map.

Run it from Termux:

```sh
pkg install -y python
curl -fsSLO https://raw.githubusercontent.com/Lycidias93/pixel-10-pro-xl-thermal-fix/main/tools/pixel_thermal_debug_report.py
python3 pixel_thermal_debug_report.py
```

Default output:

```text
/storage/emulated/0/Download/pixel_thermal_debug_<device>_<incremental>_<timestamp>.zip
```

Custom output directory:

```sh
python3 pixel_thermal_debug_report.py --out-dir "$HOME/pixel-thermal-debug"
```

Upload the generated ZIP to the GitHub issue or XDA post.

Do not request support with only a marketing device name. Device codename, fingerprint and thermal files can change between firmwares.

If this module is installed and active, disable/remove it and reboot before creating an adaptation report. Otherwise `/vendor` may show Magisk overlays instead of stock thermal files.

## Support matrix

```text
Supported stable:
- Pixel 10 Pro XL / mustang / Android 16 / CP1A.260505.005 / 15081906

Needs compatibility report first:
- newer mustang firmware
- Pixel 10
- Pixel 10 Pro
- Pixel 10 Pro Fold
- Pixel 10a
- any other Pixel 10-series codename/fingerprint
```

## Rollback

From a booted system:

```sh
su -c 'touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/disable'
su -c 'touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/skip_mount'
su -c 'reboot'
```

Or remove the module from Magisk and reboot.

## Release policy

- `v1.3-mustang.15` is the current stable release.
- Earlier `v1.3-mustang.*` builds are historical bisect/test releases.
- Historical builds are kept for audit and rollback context, but should not be preferred for normal installation.
- Full release history belongs in `CHANGELOG.md`, not in this README.
