# Verify Pixel 10 Pro XL Thermal Polling Fix

## Target

- Device: Pixel 10 Pro XL
- Codename: `mustang`
- Android: 16
- Build: `CP1A.260505.005/15081906`

## v1.3-mustang.3 expected scope

Only this module overlay should exist:

```text
system/vendor/etc/thermal_info_config_throttling.json
```

Removed from active module scope:

```text
system/vendor/etc/thermal_info_config.json
system/vendor/etc/thermal_info_config_charge.json
```

Only one semantic value is expected to differ from live stock:

```text
VIRTUAL-SKIN-CPU-LIGHT-ODPM
PollingDelay: 300000 -> 5000
```

## Runtime success criteria

```text
disable=absent
skip_mount=absent
pending_boot=absent or missing
fail_count=absent or missing
last_boot_ok=present
PollingDelay=5000 for VIRTUAL-SKIN-CPU-LIGHT-ODPM
AshLooper loops=0
no new android.hardware.thermal-service.pixel tombstones
```

## Failure criteria

```text
/vendor/bin/hw/android.hardware.thermal-service.pixel
Abort message: ThermalHAL could not be initialized properly.
```

If that appears again with v1.3-mustang.3 active, this target sensor overlay is not safe on the current build.


## v1.3-mustang.4 - Pixel 10 Pro XL VIRTUAL-SKIN CPU ODPM bisect

Adds exactly one additional live-stock thermal throttling overlay change on top of v1.3-mustang.3:

- VIRTUAL-SKIN-CPU-LIGHT-ODPM: PollingDelay 300000ms -> 5000ms
- VIRTUAL-SKIN-CPU-ODPM: PollingDelay 300000ms -> 5000ms

No base thermal overlay and no charge overlay are included. AshLooper remains the primary bootloop protection.
