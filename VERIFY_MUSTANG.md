# Pixel 10 Pro XL / mustang verification

## Supported target

- Model: Pixel 10 Pro XL
- Codename: mustang
- Android: 16
- Verified local evidence build: CP1A.260505.005 / 15081906

This is not a generic Pixel thermal module.

## Expected stock evidence before install

```text
getprop ro.product.model  -> Pixel 10 Pro XL
getprop ro.product.device -> mustang
getprop ro.build.version.release -> 16
/vendor/etc/thermal_info_config_throttling.json contains VIRTUAL-SKIN-CPU-LIGHT-ODPM
PollingDelay values are 300000 before install
```

## Expected after install

Relevant VIRTUAL-SKIN* PollingDelay entries should be 5000.

Do not intentionally change:

- HotThreshold
- HotHysteresis
- PassiveDelay
- CdevCeilingFrequency
- Profile

## Bootloop guard behavior

The same-module guard cannot guarantee protection from the first failed boot. It is designed to catch a failed previous boot on the next boot:

1. post-fs-data.sh runs before module mount and writes guard/pending_boot.
2. service.sh waits for sys.boot_completed=1 and removes guard/pending_boot.
3. If the next boot sees guard/pending_boot still present, it creates skip_mount and disable, then exits before mount.

Manual rollback path from root shell:

```sh
touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/disable
touch /data/adb/modules/pixel-10-pro-xl-thermal-fix/skip_mount
reboot
```
