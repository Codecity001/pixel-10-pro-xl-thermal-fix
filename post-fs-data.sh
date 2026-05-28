#!/system/bin/sh
MODDIR=${0%/*}
GUARDDIR="$MODDIR/guard"
mkdir -p "$GUARDDIR"

log_msg() {
  /system/bin/date -Is 2>/dev/null | /system/bin/sed "s/$/ $*/" >> "$GUARDDIR/bootguard.log" 2>/dev/null || true
}

disable_module() {
  reason="$1"
  echo "$reason" > "$GUARDDIR/disabled_reason" 2>/dev/null || true
  touch "$MODDIR/skip_mount" 2>/dev/null || true
  touch "$MODDIR/disable" 2>/dev/null || true
  log_msg "DISABLE reason=${reason}"
}

device="$(getprop ro.product.device 2>/dev/null || true)"
android="$(getprop ro.build.version.release 2>/dev/null || true)"
fingerprint="$(getprop ro.build.fingerprint 2>/dev/null || true)"

if [ "$device" != "mustang" ]; then
  disable_module "unsupported_device_${device}"
  exit 0
fi

case "$android" in
  16|16.*) ;;
  *)
    disable_module "unsupported_android_${android}"
    exit 0
    ;;
esac

case "$fingerprint" in
  google/mustang/mustang:16/*) ;;
  *)
    disable_module "unexpected_fingerprint"
    exit 0
    ;;
esac

if [ -f "$GUARDDIR/pending_boot" ]; then
  disable_module "previous_boot_did_not_reach_sys_boot_completed"
  exit 0
fi

echo "$(getprop ro.boot.bootreason 2>/dev/null || true)" > "$GUARDDIR/pending_boot" 2>/dev/null || true
log_msg "ARM pending_boot device=${device} android=${android}"
exit 0
