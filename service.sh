#!/system/bin/sh
MODDIR=${0%/*}
GUARDDIR="$MODDIR/guard"
mkdir -p "$GUARDDIR"

log_msg() {
  /system/bin/date -Is 2>/dev/null | /system/bin/sed "s/$/ $*/" >> "$GUARDDIR/bootguard.log" 2>/dev/null || true
}

i=0
while [ "$i" -lt 120 ]; do
  boot_completed="$(getprop sys.boot_completed 2>/dev/null || true)"
  if [ "$boot_completed" = "1" ]; then
    rm -f "$GUARDDIR/pending_boot" 2>/dev/null || true
    echo "$(date -Is 2>/dev/null || true)" > "$GUARDDIR/last_boot_ok" 2>/dev/null || true
    log_msg "BOOT_COMPLETED clear_pending"
    break
  fi
  i=$((i + 1))
  sleep 1
done

if [ "$(getprop sys.boot_completed 2>/dev/null || true)" != "1" ]; then
  log_msg "WARN boot_completed_timeout pending_boot_left_for_next_boot_guard"
  exit 0
fi

{
  echo "== device =="
  getprop ro.product.model
  getprop ro.product.device
  getprop ro.build.version.release
  getprop ro.build.fingerprint
  echo
  echo "== thermal overlay sample =="
  grep -R -n "VIRTUAL-SKIN-CPU-LIGHT-ODPM\|PollingDelay" /vendor/etc/thermal_info_config*.json 2>/dev/null | head -80 || true
} > "$GUARDDIR/last_verify.txt" 2>/dev/null || true

exit 0
