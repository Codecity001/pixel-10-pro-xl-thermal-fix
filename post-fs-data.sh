#!/system/bin/sh
MODDIR=${0%/*}
GUARDDIR="$MODDIR/guard"
LOG="$GUARDDIR/bootguard.log"

mkdir -p "$GUARDDIR"

log_line() {
  echo "$(date -Is 2>/dev/null || date) $*" >> "$LOG"
}

disable_wrong_target() {
  reason="$1"
  log_line "DISABLE wrong_target reason=$reason"
  echo "$reason" > "$GUARDDIR/disabled_reason"
  touch "$MODDIR/disable" "$MODDIR/skip_mount"
  sync
}

device="$(getprop ro.product.device 2>/dev/null)"
android="$(getprop ro.build.version.release 2>/dev/null)"
fingerprint="$(getprop ro.build.fingerprint 2>/dev/null)"

if [ "$device" != "mustang" ]; then
  disable_wrong_target "unsupported_device_$device"
  exit 0
fi

case "$android" in
  16|16.*) ;;
  *) disable_wrong_target "unsupported_android_$android"; exit 0 ;;
esac

case "$fingerprint" in
  google/mustang/mustang:16/CP1A.260505.005/15081906:user/release-keys) ;;
  *) disable_wrong_target "unsupported_fingerprint"; exit 0 ;;
esac

log_line "PASSIVE_ARM device=$device android=$android scope=stable_throttling_base_charge_vskin_polling ashlooper_primary=true"
