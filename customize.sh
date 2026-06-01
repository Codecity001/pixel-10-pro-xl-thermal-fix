SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=true
LATESTARTSERVICE=true
REPLACE=""

print_modname() {
  ui_print "***************************************"
  ui_print " Pixel 10 Thermal Polling Fix"
  ui_print " v1.4.0-universal-test.1"
  ui_print "***************************************"
}

on_install() {
  device="$(getprop ro.product.device 2>/dev/null | tr 'A-Z' 'a-z')"
  model="$(getprop ro.product.model 2>/dev/null)"
  android="$(getprop ro.build.version.release 2>/dev/null)"
  incremental="$(getprop ro.build.version.incremental 2>/dev/null)"
  fingerprint="$(getprop ro.build.fingerprint 2>/dev/null)"

  ui_print "== Target guard =="
  ui_print "model=$model"
  ui_print "device=$device"
  ui_print "android=$android"
  ui_print "incremental=$incremental"

  profile=""
  channel=""
  live_verified="no"

  case "$device" in
    mustang)
      profile="mustang"
      channel="stable-verified"
      live_verified="yes"
      if [ "$android" != "16" ]; then
        abort "Unsupported Android for mustang: $android"
      fi
      if [ "$incremental" != "15081906" ]; then
        abort "Unsupported mustang build: $incremental. Create a compatibility report first."
      fi
      ;;
    blazer)
      profile="blazer"
      channel="beta-unverified"
      live_verified="no"
      if [ "$android" != "16" ]; then
        abort "Unsupported Android for blazer beta profile: $android"
      fi
      ;;
    *)
      abort "Unsupported device: $device. Supported test profiles: mustang, blazer."
      ;;
  esac

  profile_dir="$MODPATH/profiles/$profile"
  if [ ! -d "$profile_dir/system/vendor/etc" ]; then
    abort "Missing profile payload: $profile"
  fi

  rm -rf "$MODPATH/system"
  mkdir -p "$MODPATH/system"
  cp -R "$profile_dir/system/." "$MODPATH/system/"

  ui_print "== Selected profile =="
  ui_print "profile=$profile"
  ui_print "release_channel=$channel"
  ui_print "live_verified=$live_verified"
  ui_print "module_id=pixel-10-pro-xl-thermal-fix"
  ui_print "update_channel=stable-main-updateJson"

  if [ "$profile" = "mustang" ]; then
    ui_print "Mustang profile is runtime-identical to v1.3-mustang.15."
  fi

  if [ "$profile" = "blazer" ]; then
    ui_print "WARNING: Blazer / Pixel 10 Pro profile is a public beta test profile."
    ui_print "WARNING: This fork has not live-boot verified blazer yet."
    ui_print "WARNING: Use AshLooper or equivalent bootloop protection."
    ui_print "WARNING: Do not add this thermal module to the AshLooper whitelist."
  fi

  ui_print "Changed sensor policy: selected stock/profile VIRTUAL-SKIN polling inputs use 5000ms where profile data provides it."
  ui_print "None/null PollingDelay entries remain untouched by profile policy."
}

set_permissions() {
  set_perm_recursive "$MODPATH/system" 0 0 0755 0644
  set_perm_recursive "$MODPATH/tools" 0 0 0755 0755
  set_perm_recursive "$MODPATH/profiles" 0 0 0755 0644
}
