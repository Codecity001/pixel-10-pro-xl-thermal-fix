# Pixel 10 Pro XL Thermal Polling Fix

This repository is my Pixel 10 Pro XL (`mustang`) Android 16 fork of the original Pixel thermal polling fix idea.

The fork exists because the broad/original overlay approach was not safe on `mustang`: early full-overlay tests could make `/vendor/bin/hw/android.hardware.thermal-service.pixel` abort during ThermalHAL initialization. This fork keeps the practical goal of the original module, but ports it conservatively for Pixel 10 Pro XL by only changing firmware-verified `VIRTUAL-SKIN*` entries that already had a `PollingDelay` of `300000ms`.

The stable result is `v1.3-mustang.13`: all verified `300000ms -> 5000ms` thermal polling candidates are active, while entries with absent/null `PollingDelay` stay untouched.

## Credits

- Original thermal polling fix idea/module: credited to the upstream project this fork is based on. If an `upstream` remote is configured later, keep that reference here.
- Mustang fork, bisect, runtime verification, packaging and release: `Lycidias93`.
- Bootloop safety during testing: AshLooper remained the primary external bootloop protection.

## Compatibility

Verified target:

```text
Device: Pixel 10 Pro XL
Codename: mustang
Android: 16
Build: CP1A.260505.005 / 15081906
Fingerprint: google/mustang/mustang:16/CP1A.260505.005/15081906:user/release-keys
```

The installer has hard gates for device, Android version and fingerprint. It is not intended as a generic Pixel thermal module.

## Stable runtime scope

Latest stable release: `v1.3-mustang.13`.

Changed values:

```text
thermal_info_config_throttling.json:
- VIRTUAL-SKIN
- VIRTUAL-SKIN-HINT
- VIRTUAL-SKIN-CPU-LIGHT-ODPM
- VIRTUAL-SKIN-CPU-MID
- VIRTUAL-SKIN-CPU-ODPM
- VIRTUAL-SKIN-CPU-HIGH
- VIRTUAL-SKIN-SOC
- VIRTUAL-SKIN-SOC-EXTREME

thermal_info_config.json:
- VIRTUAL-SKIN-SPEAKER

thermal_info_config_charge.json:
- VIRTUAL-SKIN-CHARGE-WIRED
- VIRTUAL-SKIN-CHARGE-PERSIST
```

All listed entries are changed from:

```text
PollingDelay: 300000 -> 5000
```

Entries with absent/null `PollingDelay` are intentionally not modified.

## Safety model

- Install-time target guard checks `mustang`, Android 16 and the expected firmware fingerprint.
- The module mounts only the verified vendor thermal JSON overlays.
- Broad blind overlays are avoided.
- AshLooper should remain enabled and should not whitelist this thermal module.
- Manual Magisk action disables this module by creating both `disable` and `skip_mount`.

## Install

Install the latest ZIP from GitHub Releases:

```text
pixel-10-pro-xl-thermal-fix-v1.3-mustang.13.zip
```

Then reboot and verify the module state.

## Expected successful runtime check

```text
version=1.3-mustang.13
disable=absent
skip_mount=absent
AshLooper loops=0
thermal_info_config_throttling.json mounted
thermal_info_config.json mounted
thermal_info_config_charge.json mounted
fresh_thermalhal_tombstone=absent
```

Expected semantic values:

```text
throttling VIRTUAL-SKIN* targets = 5000
base VIRTUAL-SKIN-SPEAKER = 5000
charge VIRTUAL-SKIN-CHARGE-WIRED = 5000
charge VIRTUAL-SKIN-CHARGE-PERSIST = 5000
absent/null PollingDelay entries remain None
```

## Rollback

From a booted system:

```sh
su -c 'touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/disable'
su -c 'touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/skip_mount'
su -c 'reboot'
```

If the device cannot boot normally, use your existing Magisk/AshLooper recovery path.

## Changelog

Release history belongs in [`CHANGELOG.md`](CHANGELOG.md), not in this README.
