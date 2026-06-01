# Pixel 10 Thermal Polling Fix v1.4.0-universal-test.1

Public universal test prerelease.

## Module identity and update channel

The Magisk module ID is intentionally unchanged and should remain stable:

```text
id=pixel-10-pro-xl-thermal-fix
```

The stable update channel is intentionally unchanged:

```text
https://raw.githubusercontent.com/Lycidias93/pixel-10-pro-xl-thermal-fix/main/update.json
```

This prerelease is for manual installation/testing. The normal stable update channel remains conservative.

## Profiles

### Mustang / Pixel 10 Pro XL

- Status: stable verified profile.
- Runtime scope: unchanged from `v1.3-mustang.15`.
- Verified build: Android 16 / CP1A.260505.005 / 15081906.

### Blazer / Pixel 10 Pro

- Status: beta test profile.
- Source: `dir:/storage/emulated/0/Download/pixel-10-pro-xl-thermal-fix/originals`.
- Fork-side live boot verification: not done yet.
- Use AshLooper or equivalent bootloop protection.
- Do not whitelist this thermal module in AshLooper.

## Mustang virtual-skin map

```json
{
  "system/vendor/etc/thermal_info_config.json": {
    "VIRTUAL-SKIN-PREDICTION-MODEL": null,
    "VIRTUAL-SKIN-SPEAKER": 5000,
    "VIRTUAL-SKIN-SPEAKER-SUB-0": null,
    "VIRTUAL-SKIN-SPEAKER-SUB-1": null
  },
  "system/vendor/etc/thermal_info_config_charge.json": {
    "VIRTUAL-SKIN-CHARGE": null,
    "VIRTUAL-SKIN-CHARGE-PERSIST": 5000,
    "VIRTUAL-SKIN-CHARGE-WIRED": 5000,
    "VIRTUAL-SKIN-LEGACY": null,
    "VIRTUAL-SKIN-MODEL": null,
    "VIRTUAL-SKIN-SUB-0": null,
    "VIRTUAL-SKIN-SUB-1": null,
    "VIRTUAL-SKIN-SUB-2": null,
    "VIRTUAL-SKIN-SUB-3": null,
    "VIRTUAL-SKIN-SUB-4": null,
    "VIRTUAL-SKIN-SUB-5": null,
    "VIRTUAL-SKIN-SUB-6": null,
    "VIRTUAL-SKIN-SUB-7": null
  },
  "system/vendor/etc/thermal_info_config_throttling.json": {
    "VIRTUAL-SKIN": 5000,
    "VIRTUAL-SKIN-CPU-HIGH": 5000,
    "VIRTUAL-SKIN-CPU-LIGHT-ODPM": 5000,
    "VIRTUAL-SKIN-CPU-MID": 5000,
    "VIRTUAL-SKIN-CPU-ODPM": 5000,
    "VIRTUAL-SKIN-HINT": 5000,
    "VIRTUAL-SKIN-SOC": 5000,
    "VIRTUAL-SKIN-SOC-EXTREME": 5000
  }
}
```

## Blazer virtual-skin map

```json
{
  "system/vendor/etc/thermal_info_config.json": {
    "VIRTUAL-SKIN-CPU-LIGHT-ODPM": 300000,
    "VIRTUAL-SKIN-PREDICTION-MODEL": null,
    "VIRTUAL-SKIN-SPEAKER": 300000,
    "VIRTUAL-SKIN-SPEAKER-LEGACY": null,
    "VIRTUAL-SKIN-SPEAKER-LEGACY-MODEL-DIFF": null,
    "VIRTUAL-SKIN-SPEAKER-MODEL": null,
    "VIRTUAL-SKIN-SPEAKER-MODEL-CLAMPED": null,
    "VIRTUAL-SKIN-SPEAKER-MODEL-LEGACY-DIFF": null,
    "VIRTUAL-SKIN-SPEAKER-MODEL-UPPER-CLAMPED": null,
    "VIRTUAL-SKIN-SPEAKER-SUB-0": null
  },
  "system/vendor/etc/thermal_info_config_charge.json": {
    "VIRTUAL-SKIN-CHARGE": null,
    "VIRTUAL-SKIN-CHARGE-PERSIST": 300000,
    "VIRTUAL-SKIN-CHARGE-WIRED": 300000,
    "VIRTUAL-SKIN-LEGACY": null,
    "VIRTUAL-SKIN-MODEL": null,
    "VIRTUAL-SKIN-SUB-0": null,
    "VIRTUAL-SKIN-SUB-1": null,
    "VIRTUAL-SKIN-SUB-2": null,
    "VIRTUAL-SKIN-SUB-3": null,
    "VIRTUAL-SKIN-SUB-4": null
  },
  "system/vendor/etc/thermal_info_config_throttling.json": {
    "VIRTUAL-SKIN": 300000,
    "VIRTUAL-SKIN-CPU-HIGH": 300000,
    "VIRTUAL-SKIN-CPU-LIGHT-ODPM": 300000,
    "VIRTUAL-SKIN-CPU-MID": 300000,
    "VIRTUAL-SKIN-CPU-ODPM": 300000,
    "VIRTUAL-SKIN-HINT": 300000,
    "VIRTUAL-SKIN-SOC": 300000,
    "VIRTUAL-SKIN-SOC-EXTREME": 300000
  }
}
```

## Rollback

From a booted system, disable the module in Magisk or create `disable` and `skip_mount` in the module directory, then reboot.
