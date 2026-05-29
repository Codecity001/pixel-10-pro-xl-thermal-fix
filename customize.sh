#!/system/bin/sh
# Sourced by Magisk module installer. Do not call exit here.
ui_print "- Pixel 10 Pro XL Thermal Polling Fix"
ui_print "- Running install-time target guard"

device="$(getprop ro.product.device 2>/dev/null || true)"
model="$(getprop ro.product.model 2>/dev/null || true)"
android="$(getprop ro.build.version.release 2>/dev/null || true)"
fingerprint="$(getprop ro.build.fingerprint 2>/dev/null || true)"

ui_print "- model=${model}"
ui_print "- device=${device}"
ui_print "- android=${android}"

if [ "$device" != "mustang" ]; then
  abort "! Unsupported device: ${device}. Expected mustang / Pixel 10 Pro XL."
fi

case "$android" in
  16|16.*) ;;
  *) abort "! Unsupported Android version: ${android}. Expected Android 16." ;;
esac

case "$fingerprint" in
  google/mustang/mustang:16/*) ;;
  *) abort "! Unexpected fingerprint for mustang Android 16: ${fingerprint}" ;;
esac

if [ ! -r /vendor/etc/thermal_info_config_throttling.json ]; then
  abort "! Missing readable /vendor/etc/thermal_info_config_throttling.json"
fi

if ! grep -q "VIRTUAL-SKIN-CPU-LIGHT-ODPM" /vendor/etc/thermal_info_config_throttling.json 2>/dev/null; then
  abort "! Expected VIRTUAL-SKIN-CPU-LIGHT-ODPM marker not found in stock throttling config"
fi

if [ -n "${MODPATH:-}" ]; then
  ui_print "- Resetting stale guard flags for this intentional install/update"
  rm -f "$MODPATH/disable" "$MODPATH/skip_mount" "$MODPATH/remove" 2>/dev/null || true
  rm -f "$MODPATH/guard/pending_boot" "$MODPATH/guard/fail_count" "$MODPATH/guard/disabled_reason" 2>/dev/null || true
fi

ui_print "- Target guard PASS"
ui_print "- Boot guard uses grace_count=2 before self-disable"
ui_print "- Bootloop guard will arm on next boot and clear after sys.boot_completed=1"
