# Pixel 10 Pro XL Thermal Polling Fix

Stable Magisk module for Pixel 10 Pro XL (`mustang`) on Android 16.

## Why this fork exists

This fork exists because the original thermal polling idea was useful, but the first direct Pixel 10 Pro XL port was too broad for `mustang` and caused the native Pixel ThermalHAL to abort during boot.

The goal of this fork is therefore not to blindly patch every thermal file. It provides a verified, device-specific Mustang port that changes only the proven `PollingDelay=300000` `VIRTUAL-SKIN*` candidates that survived install, reboot and post-boot ThermalHAL checks.

## Credits

- Original thermal polling fix idea and upstream inspiration: upstream project (`error: No such remote 'upstream'`).
- Mustang fork, controlled bisect, runtime verification and stable release packaging: Lycidias93.
- Bootloop safety during testing: AshLooper remains the primary external bootloop protection.

## Supported device

This release is intentionally narrow.

```text
Device: Pixel 10 Pro XL
Codename: mustang
Android: 16
Verified build: CP1A.260505.005 / 15081906
Stable release: v1.3-mustang.13
```

The installer checks the device and Android target before installing.

## Main features

- Magisk module for Pixel 10 Pro XL / `mustang`.
- Stable `v1.3-mustang.13` runtime scope verified after reboot.
- Reduces verified `VIRTUAL-SKIN*` thermal polling delays from `300000ms` to `5000ms`.
- Uses stock-derived live-device thermal JSON overlays.
- Keeps entries with missing/null `PollingDelay` untouched.
- Includes install-time target guard.
- Includes passive boot-time sanity guard.
- Keeps AshLooper as the primary bootloop protection.
- Provides manual disable action through Magisk action script.
- Keeps detailed release history in `CHANGELOG.md`, not in this README.

## Runtime scope

`v1.3-mustang.13` changes only proven `PollingDelay=300000` candidates.

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
- AshLooper is expected to remain installed and active during testing.
- This module should not be added to the AshLooper whitelist.
- `disable` and `skip_mount` must remain absent for normal operation.

Expected healthy state:

```text
version=1.3-mustang.13
disable=absent
skip_mount=absent
AshLooper loops=0
fresh_thermalhal_tombstone=absent
```

## Install

Download the latest stable release ZIP from GitHub Releases and install it in Magisk.

Latest stable:

```text
v1.3-mustang.13
```

## Verify

After installing and rebooting, check:

```text
version=1.3-mustang.13
versionCode=101313
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

## Rollback

From a booted system:

```sh
su -c 'touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/disable'
su -c 'touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/skip_mount'
su -c 'reboot'
```

Or remove the module from Magisk and reboot.

## Release policy

- `v1.3-mustang.13` is the current stable release.
- Earlier `v1.3-mustang.*` builds are historical bisect/test releases.
- Historical builds are kept for audit and rollback context, but should not be preferred for normal installation.
- Full release history belongs in `CHANGELOG.md`, not in this README.
