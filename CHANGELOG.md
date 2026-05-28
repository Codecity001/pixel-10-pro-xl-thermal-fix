# Changelog

## 1.3-mustang.1 - Pixel 10 Pro XL / mustang guarded release

- Scopes module metadata to Pixel 10 Pro XL / mustang.
- Adds Magisk online update metadata via update.json.
- Moves thermal overlays to Magisk-documented system/vendor layout.
- Adds install-time device/build hardgate through customize.sh.
- Adds same-module bootloop guard:
  - post-fs-data.sh creates a pending boot marker before module mount.
  - service.sh clears the marker after sys.boot_completed=1.
  - if the previous boot did not reach boot_completed, the next boot touches skip_mount and disable before mount.
- Adds Magisk action button helper to disable the module manually.
- Keeps the original intent: VIRTUAL-SKIN* thermal PollingDelay 300000ms -> 5000ms only.
