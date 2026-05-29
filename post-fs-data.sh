#!/system/bin/sh
MODDIR=${0%/*}
GUARDDIR="$MODDIR/guard"
FAILCOUNT="$GUARDDIR/fail_count"
THRESHOLD=2
mkdir -p "$GUARDDIR"

log_msg() {
  /system/bin/date -Is 2>/dev/null | /system/bin/sed "s/$/ $*/" >> "$GUARDDIR/bootguard.log" 2>/dev/null || true
}

num_or_zero() {
  val="$(cat "$1" 2>/dev/null || echo 0)"
  case "$val" in
    ''|*[!0-9]*) echo 0 ;;
    *) echo "$val" ;;
  esac
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
  old_count="$(num_or_zero "$FAILCOUNT")"
  new_count=$((old_count + 1))
  echo "$new_count" > "$FAILCOUNT" 2>/dev/null || true
  log_msg "PENDING previous_boot_incomplete count=${new_count} threshold=${THRESHOLD}"

  if [ "$new_count" -ge "$THRESHOLD" ]; then
    disable_module "previous_boot_did_not_reach_sys_boot_completed_count_${new_count}"
    exit 0
  fi

  echo "$(getprop ro.boot.bootreason 2>/dev/null || true)" > "$GUARDDIR/pending_boot" 2>/dev/null || true
  log_msg "GRACE keep_enabled count=${new_count} threshold=${THRESHOLD}"
  exit 0
fi

echo 0 > "$FAILCOUNT" 2>/dev/null || true
echo "$(getprop ro.boot.bootreason 2>/dev/null || true)" > "$GUARDDIR/pending_boot" 2>/dev/null || true
log_msg "ARM pending_boot device=${device} android=${android} threshold=${THRESHOLD}"
exit 0
