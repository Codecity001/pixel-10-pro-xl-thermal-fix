#!/system/bin/sh
SKIPUNZIP=0

ui_print "Pixel 10 Thermal Polling Fix"
ui_print "Running universal-test profile selector"

device="$(getprop ro.product.device 2>/dev/null | tr 'A-Z' 'a-z')"
model="$(getprop ro.product.model 2>/dev/null)"
android="$(getprop ro.build.version.release 2>/dev/null)"
incremental="$(getprop ro.build.version.incremental 2>/dev/null)"
fingerprint="$(getprop ro.build.fingerprint 2>/dev/null)"

ui_print "model=$model"
ui_print "device=$device"
ui_print "android=$android"
ui_print "incremental=$incremental"

profile=""
release_channel=""
live_verified="no"

case "$device" in
  mustang)
    profile="mustang"
    release_channel="stable-verified"
    live_verified="yes"
    case "$android" in
      16|16.*) ;;
      *) abort "! Unsupported Android for mustang: $android" ;;
    esac
    case "$fingerprint" in
      google/mustang/mustang:16/CP1A.260505.005/15081906:user/release-keys) ;;
      *) abort "! Unsupported mustang build fingerprint: $fingerprint" ;;
    esac
    ;;
  blazer)
    profile="blazer"
    release_channel="beta-unverified"
    live_verified="no"
    case "$android" in
      16|16.*) ;;
      *) abort "! Unsupported Android for blazer beta profile: $android" ;;
    esac
    ;;
  *)
    abort "! Unsupported device: $device. Supported universal-test profiles: mustang, blazer."
    ;;
esac

profile_dir="$MODPATH/profiles/$profile"
profile_etc="$profile_dir/system/vendor/etc"

if [ ! -s "$profile_etc/thermal_info_config_throttling.json" ]; then
  abort "! Missing selected profile throttling config: $profile"
fi
if [ ! -s "$profile_etc/thermal_info_config.json" ]; then
  abort "! Missing selected profile base config: $profile"
fi
if [ ! -s "$profile_etc/thermal_info_config_charge.json" ]; then
  abort "! Missing selected profile charge config: $profile"
fi

rm -rf "$MODPATH/system"
mkdir -p "$MODPATH/system"
cp -R "$profile_dir/system/." "$MODPATH/system/" || abort "! Failed to stage selected profile: $profile"

if [ ! -s "$MODPATH/system/vendor/etc/thermal_info_config_throttling.json" ]; then
  abort "! Selected profile did not materialize into system/vendor/etc: $profile"
fi
if [ ! -s "$MODPATH/system/vendor/etc/thermal_info_config.json" ]; then
  abort "! Selected base profile did not materialize into system/vendor/etc: $profile"
fi
if [ ! -s "$MODPATH/system/vendor/etc/thermal_info_config_charge.json" ]; then
  abort "! Selected charge profile did not materialize into system/vendor/etc: $profile"
fi

rm -f "$MODPATH/disable" "$MODPATH/skip_mount" "$MODPATH/remove"
mkdir -p "$MODPATH/guard"
rm -f "$MODPATH/guard/pending_boot" "$MODPATH/guard/fail_count" "$MODPATH/guard/disabled_reason"

ui_print "== Selected profile =="
ui_print "profile=$profile"
ui_print "release_channel=$release_channel"
ui_print "live_verified=$live_verified"
ui_print "module_id=pixel-10-pro-xl-thermal-fix"
ui_print "update_channel=stable-main-updateJson"
ui_print "profile_materialized=yes"
ui_print "active_system_vendor_etc=yes"

if [ "$profile" = "mustang" ]; then
  ui_print "Mustang profile is runtime-identical to v1.3-mustang.15."
fi

if [ "$profile" = "blazer" ]; then
  ui_print "WARNING: Blazer / Pixel 10 Pro profile is a public beta test profile."
  ui_print "WARNING: This fork has not live-boot verified blazer yet."
  ui_print "WARNING: Use AshLooper or equivalent bootloop protection."
  ui_print "WARNING: Do not add this thermal module to the AshLooper whitelist."
fi

ui_print "Target guard PASS"
ui_print "Universal-test selector PASS"
ui_print "Changed sensor policy: selected profile VIRTUAL-SKIN polling inputs use 5000ms where profile data provides it."
ui_print "None/null PollingDelay entries remain untouched by profile policy."
