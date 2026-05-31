#!/system/bin/sh
SKIPUNZIP=0

ui_print "Pixel 10 Pro XL Thermal Polling Fix"
ui_print "Running install-time target guard"

model="$(getprop ro.product.model)"
device="$(getprop ro.product.device)"
android="$(getprop ro.build.version.release)"
fingerprint="$(getprop ro.build.fingerprint)"
incremental="$(getprop ro.build.version.incremental)"

ui_print "model=$model"
ui_print "device=$device"
ui_print "android=$android"
ui_print "incremental=$incremental"

[ "$device" = "mustang" ] || abort "! Unsupported device: $device"
case "$android" in
  16|16.*) ;;
  *) abort "! Unsupported Android version: $android" ;;
esac

case "$fingerprint" in
  google/mustang/mustang:16/CP1A.260505.005/15081906:user/release-keys) ;;
  *) abort "! Unsupported build fingerprint: $fingerprint" ;;
esac

if [ ! -r /vendor/etc/thermal_info_config_throttling.json ]; then
  abort "! Stock thermal throttling config not readable"
fi

if ! grep -q "VIRTUAL-SKIN-CPU-LIGHT-ODPM" /vendor/etc/thermal_info_config_throttling.json; then
  abort "! Expected mustang thermal marker missing"
fi

ui_print "Resetting stale module flags for this intentional install/update"
rm -f "$MODPATH/disable" "$MODPATH/skip_mount" "$MODPATH/remove"
mkdir -p "$MODPATH/guard"
rm -f "$MODPATH/guard/pending_boot" "$MODPATH/guard/fail_count" "$MODPATH/guard/disabled_reason"

ui_print "Target guard PASS"
ui_print "Bisect v9 scope: live-stock thermal_info_config_throttling.json only"
ui_print "Changed sensor: VIRTUAL-SKIN + VIRTUAL-SKIN-HINT + VIRTUAL-SKIN-CPU-LIGHT-ODPM + VIRTUAL-SKIN-CPU-ODPM + VIRTUAL-SKIN-CPU-MID + VIRTUAL-SKIN-CPU-HIGH + VIRTUAL-SKIN-SOC PollingDelay 300000ms -> 5000ms"
ui_print "Passive guard: AshLooper remains primary bootloop protection"
