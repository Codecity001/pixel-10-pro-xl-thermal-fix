# Pixel 10 Pro XL Thermal Polling Fix

> [!WARNING]
> This fork is scoped to **Google Pixel 10 Pro XL / mustang / Android 16**. It is not a generic Pixel module. Thermal overlays can affect boot stability. Keep a rollback path ready before flashing.

## Supported target

- Google Pixel 10 Pro XL
- Codename: `mustang`
- Android: `16`
- Local evidence build used for this fork: `CP1A.260505.005 / 15081906`

## Issue

The stock Android 16 thermal configs on the tested Pixel 10 Pro XL expose 300000ms polling intervals for relevant virtual skin thermal entries, including `VIRTUAL-SKIN-CPU-LIGHT-ODPM` in `thermal_info_config_throttling.json`.

A 300000ms polling delay creates a long blind spot for fast heat buildup.

## Fix

This module overlays vendor thermal configs and keeps the intended change narrow:

- `PollingDelay`: `300000` -> `5000` only for `VIRTUAL-SKIN*` thermal entries
- keeps OEM threshold/profile/PID/cdev data unchanged
- does not change physical thermal sensor polling
- does not change `VIRTUAL-USB-THROTTLING`

Overlay paths inside the module:

- `system/vendor/etc/thermal_info_config.json`
- `system/vendor/etc/thermal_info_config_throttling.json`
- `system/vendor/etc/thermal_info_config_charge.json`

## Safety gates

This fork adds:

- `customize.sh`: install-time hardgate for `mustang` + Android 16 + expected thermal marker
- `post-fs-data.sh`: pre-mount guard with grace counter before self-disable
- `service.sh`: clears the boot-pending guard only after `sys.boot_completed=1`
- `action.sh`: manual Magisk action to disable the module
- `update.json`: Magisk online update metadata

## Guard behavior

The same-module guard cannot guarantee protection from the first failed boot. It is designed to catch repeated failed boots:

1. `post-fs-data.sh` arms `guard/pending_boot` before module mount.
2. `service.sh` waits for `sys.boot_completed=1`, then removes `pending_boot` and `fail_count`.
3. If the next boot sees `pending_boot`, it increments `fail_count` and grants one grace boot.
4. If a stale `pending_boot` appears again, it creates `skip_mount` and `disable` before mount.

## Online update

`module.prop` points to:

```text
https://raw.githubusercontent.com/Lycidias93/pixel-10-pro-xl-thermal-fix/main/update.json
```

The update JSON points to the GitHub release asset for this version:

```text
https://github.com/Lycidias93/pixel-10-pro-xl-thermal-fix/releases/download/v1.3-mustang.2/pixel-10-pro-xl-thermal-fix-v1.3-mustang.2.zip
```

## Verification

See `VERIFY_MUSTANG.md`.

Quick after-install check from Termux:

```sh
su -c 'grep -R -n "VIRTUAL-SKIN-CPU-LIGHT-ODPM\|PollingDelay" /vendor/etc/thermal_info_config*.json | head -80'
```

## Rollback

From a root shell:

```sh
touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/disable
touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/skip_mount
reboot
```

Or remove/disable the module in Magisk Manager.
