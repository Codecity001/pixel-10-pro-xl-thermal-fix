## Release archive note

- `v1.3-mustang.13` is the current stable Mustang release.
- Earlier `v1.3-mustang.*` releases are historical bisect/test builds and are kept for audit, rollback context and troubleshooting.
- Do not prefer older bisect builds for normal installation unless explicitly debugging a regression.


## Documentation cleanup - README intro and changelog placement

- Reworked README to start with a short explanation of why this Mustang fork exists.
- Added credits section.
- Removed per-version changelog-style sections from README.
- Kept release history in CHANGELOG.md.


## v1.3-mustang.13

- Stable cleanup release for Pixel 10 Pro XL / mustang.
- No runtime thermal scope change versus v1.3-mustang.12.
- Keeps all verified 300000ms -> 5000ms PollingDelay targets across throttling, base and charge configs.
- Fixes stale installer text that still said thermal_info_config_throttling.json only.
- Keeps VIRTUAL-SKIN entries with absent/null PollingDelay untouched.


## v1.3-mustang.12

- Adds both remaining true 300000ms charge thermal config candidates to the stable v1.3-mustang.11 baseline: thermal_info_config_charge.json VIRTUAL-SKIN-CHARGE-WIRED and VIRTUAL-SKIN-CHARGE-PERSIST PollingDelay 300000ms -> 5000ms.
- Keeps all eight throttling-only VIRTUAL-SKIN targets from v1.3-mustang.10.
- Keeps thermal_info_config.json VIRTUAL-SKIN-SPEAKER from v1.3-mustang.11.
- Does not alter VIRTUAL-SKIN entries with absent/null PollingDelay.
- Requires post-reboot runtime verification for fresh ThermalHAL tombstones.

## v1.3-mustang.11

- Adds the first base thermal config candidate to the stable v1.3-mustang.10 throttling baseline: thermal_info_config.json VIRTUAL-SKIN-SPEAKER PollingDelay 300000ms -> 5000ms.
- Keeps all eight throttling-only VIRTUAL-SKIN targets from v1.3-mustang.10.
- Does not add thermal_info_config_charge.json.
- Does not alter VIRTUAL-SKIN entries with absent/null PollingDelay.
- Requires post-reboot runtime verification for fresh ThermalHAL tombstones.

## v1.3-mustang.10

- Adds the final remaining throttling-only VIRTUAL-SKIN sensor to the stable v1.3-mustang.9 baseline: VIRTUAL-SKIN-SOC-EXTREME PollingDelay 300000ms -> 5000ms.
- Active targets: VIRTUAL-SKIN, VIRTUAL-SKIN-HINT, VIRTUAL-SKIN-CPU-LIGHT-ODPM, VIRTUAL-SKIN-CPU-ODPM, VIRTUAL-SKIN-CPU-MID, VIRTUAL-SKIN-CPU-HIGH, VIRTUAL-SKIN-SOC, VIRTUAL-SKIN-SOC-EXTREME.
- Keeps overlay scope limited to system/vendor/etc/thermal_info_config_throttling.json.
- Does not restore thermal_info_config.json or thermal_info_config_charge.json.
- Requires post-reboot runtime verification for fresh ThermalHAL tombstones.

## v1.3-mustang.9

- Adds one additional SOC-adjacent VIRTUAL-SKIN throttling sensor to the stable v1.3-mustang.8 baseline: VIRTUAL-SKIN-SOC PollingDelay 300000ms -> 5000ms.
- Active targets: VIRTUAL-SKIN, VIRTUAL-SKIN-HINT, VIRTUAL-SKIN-CPU-LIGHT-ODPM, VIRTUAL-SKIN-CPU-ODPM, VIRTUAL-SKIN-CPU-MID, VIRTUAL-SKIN-CPU-HIGH, VIRTUAL-SKIN-SOC.
- Keeps overlay scope limited to system/vendor/etc/thermal_info_config_throttling.json.
- Does not restore thermal_info_config.json or thermal_info_config_charge.json.
- Requires post-reboot runtime verification for fresh ThermalHAL tombstones.

## v1.3-mustang.8

- Adds one additional VIRTUAL-SKIN throttling sensor to the stable v1.3-mustang.7 baseline: VIRTUAL-SKIN-HINT PollingDelay 300000ms -> 5000ms.
- Active targets: VIRTUAL-SKIN, VIRTUAL-SKIN-HINT, VIRTUAL-SKIN-CPU-LIGHT-ODPM, VIRTUAL-SKIN-CPU-ODPM, VIRTUAL-SKIN-CPU-MID, VIRTUAL-SKIN-CPU-HIGH.
- Keeps overlay scope limited to system/vendor/etc/thermal_info_config_throttling.json.
- Does not restore thermal_info_config.json or thermal_info_config_charge.json.
- Requires post-reboot runtime verification for fresh ThermalHAL tombstones.

## v1.3-mustang.7

- Adds one additional generic VIRTUAL-SKIN throttling sensor to the stable v1.3-mustang.6 baseline: VIRTUAL-SKIN PollingDelay 300000ms -> 5000ms.
- Active targets: VIRTUAL-SKIN, VIRTUAL-SKIN-CPU-LIGHT-ODPM, VIRTUAL-SKIN-CPU-ODPM, VIRTUAL-SKIN-CPU-MID, VIRTUAL-SKIN-CPU-HIGH.
- Keeps overlay scope limited to system/vendor/etc/thermal_info_config_throttling.json.
- Does not restore thermal_info_config.json or thermal_info_config_charge.json.
- Requires post-reboot runtime verification for fresh ThermalHAL tombstones.

## v1.3-mustang.6

- Adds one additional CPU-adjacent VIRTUAL-SKIN throttling sensor to the stable v1.3-mustang.5 baseline: VIRTUAL-SKIN-CPU-HIGH PollingDelay 300000ms -> 5000ms.
- Active targets: VIRTUAL-SKIN-CPU-LIGHT-ODPM, VIRTUAL-SKIN-CPU-ODPM, VIRTUAL-SKIN-CPU-MID, VIRTUAL-SKIN-CPU-HIGH.
- Keeps overlay scope limited to system/vendor/etc/thermal_info_config_throttling.json.
- Does not restore thermal_info_config.json or thermal_info_config_charge.json.
- Requires post-reboot runtime verification for fresh ThermalHAL tombstones.

## v1.3-mustang.5

- Adds one additional CPU-adjacent VIRTUAL-SKIN throttling sensor to the stable v1.3-mustang.4 baseline: VIRTUAL-SKIN-CPU-MID PollingDelay 300000ms -> 5000ms.
- Active targets: VIRTUAL-SKIN-CPU-LIGHT-ODPM, VIRTUAL-SKIN-CPU-ODPM, VIRTUAL-SKIN-CPU-MID.
- Keeps overlay scope limited to system/vendor/etc/thermal_info_config_throttling.json.
- Does not restore thermal_info_config.json or thermal_info_config_charge.json.
- Requires post-reboot runtime verification for fresh ThermalHAL tombstones.

## v1.3-mustang.4

- Adds one additional VIRTUAL-SKIN throttling sensor to the stable v1.3-mustang.3 baseline: VIRTUAL-SKIN-CPU-ODPM PollingDelay 300000ms -> 5000ms.
- Keeps overlay scope limited to system/vendor/etc/thermal_info_config_throttling.json.
- Does not restore thermal_info_config.json or thermal_info_config_charge.json.
- Requires post-reboot runtime verification for fresh ThermalHAL tombstones.
# Changelog

## v1.3-mustang.3

- Rebuilt as a minimal live-stock-derived bisect release after ThermalHAL tombstones were observed with the broader overlay.
- Uses the live stock `thermal_info_config_throttling.json` from Pixel 10 Pro XL build `CP1A.260505.005/15081906` as base.
- Removes broad overlays for:
  - `thermal_info_config.json`
  - `thermal_info_config_charge.json`
- Changes only:
  - `VIRTUAL-SKIN-CPU-LIGHT-ODPM` `PollingDelay: 300000 -> 5000`
- Replaces self-disable loop counter with passive guard logging while AshLooper remains the primary bootloop protector.
- Keeps wrong-target boot-time disable for non-`mustang`/wrong fingerprint cases.

## v1.3-mustang.2

- Added guard grace counter.
- Still failed runtime validation on this device with ThermalHAL tombstones.

## v1.3-mustang.1

- Initial Pixel 10 Pro XL / `mustang` port.
- Narrowed to `VIRTUAL-SKIN*` semantic changes.
