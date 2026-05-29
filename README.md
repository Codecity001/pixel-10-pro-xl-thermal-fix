# Pixel 10 Pro XL Thermal Polling Fix

## Scope

This fork is scoped to Pixel 10 Pro XL (`mustang`) on Android 16 build `CP1A.260505.005/15081906`.

## v1.3-mustang.3 minimal live-stock build

`v1.3-mustang.3` is a recovery/bisect build after full-overlay tests caused native crashes in:

```text
/vendor/bin/hw/android.hardware.thermal-service.pixel
Abort message: ThermalHAL could not be initialized properly.
```

This version intentionally narrows the runtime overlay to one firmware-exact file copied from the live device stock config:

```text
system/vendor/etc/thermal_info_config_throttling.json
```

Only one semantic value is changed:

```text
VIRTUAL-SKIN-CPU-LIGHT-ODPM
PollingDelay: 300000 -> 5000
```

The broader overlays are removed from this build:

```text
system/vendor/etc/thermal_info_config.json
system/vendor/etc/thermal_info_config_charge.json
```

## Safety

- Install-time gate requires `ro.product.device=mustang`.
- Install-time gate requires Android 16.
- Install-time gate requires exact fingerprint `google/mustang/mustang:16/CP1A.260505.005/15081906:user/release-keys`.
- Boot-time guard disables only on wrong target/fingerprint.
- AshLooper remains the primary bootloop protection.
- Manual Magisk action disables this module by creating `disable` and `skip_mount`.

## Expected successful runtime check

```text
disable=absent
skip_mount=absent
last_boot_ok=present
VIRTUAL-SKIN-CPU-LIGHT-ODPM
PollingDelay=5000
```

## Rollback

From a booted system:

```sh
su -c 'touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/disable'
su -c 'touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/skip_mount'
su -c 'reboot'
```


## v1.3-mustang.4 - Pixel 10 Pro XL VIRTUAL-SKIN CPU ODPM bisect

Adds exactly one additional live-stock thermal throttling overlay change on top of v1.3-mustang.3:

- VIRTUAL-SKIN-CPU-LIGHT-ODPM: PollingDelay 300000ms -> 5000ms
- VIRTUAL-SKIN-CPU-ODPM: PollingDelay 300000ms -> 5000ms

No base thermal overlay and no charge overlay are included. AshLooper remains the primary bootloop protection.


## v1.3-mustang.5 - CPU-MID bisect

Adds VIRTUAL-SKIN-CPU-MID to the verified v1.3-mustang.4 baseline. Active target sensors:

- VIRTUAL-SKIN-CPU-LIGHT-ODPM: PollingDelay 300000ms -> 5000ms
- VIRTUAL-SKIN-CPU-ODPM: PollingDelay 300000ms -> 5000ms
- VIRTUAL-SKIN-CPU-MID: PollingDelay 300000ms -> 5000ms

No base thermal overlay and no charge overlay are included. AshLooper remains the primary bootloop protection.
