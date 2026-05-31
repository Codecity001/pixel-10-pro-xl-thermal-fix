#!/system/bin/sh
MODDIR=${0%/*}
GUARDDIR="$MODDIR/guard"
LOG="$GUARDDIR/bootguard.log"
mkdir -p "$GUARDDIR"

log_line() {
  echo "$(date -Is 2>/dev/null || date) $*" >> "$LOG"
}

i=0
while [ "$i" -lt 240 ]; do
  if [ "$(getprop sys.boot_completed 2>/dev/null)" = "1" ]; then
    rm -f "$GUARDDIR/pending_boot" "$GUARDDIR/fail_count"
    date -Is > "$GUARDDIR/last_boot_ok" 2>/dev/null || date > "$GUARDDIR/last_boot_ok"
    log_line "BOOT_COMPLETED passive_guard_ok"
    break
  fi
  i=$((i + 1))
  sleep 1
done

if [ "$(getprop sys.boot_completed 2>/dev/null)" != "1" ]; then
  log_line "BOOT_COMPLETED_TIMEOUT passive_no_self_disable waited=${i}s"
fi

{
  echo "timestamp=$(date -Is 2>/dev/null || date)"
  echo "device=$(getprop ro.product.device 2>/dev/null)"
  echo "android=$(getprop ro.build.version.release 2>/dev/null)"
  echo "fingerprint=$(getprop ro.build.fingerprint 2>/dev/null)"
  echo "scope=thermal_info_config_throttling.json:VIRTUAL-SKIN,VIRTUAL-SKIN-CPU-LIGHT-ODPM,VIRTUAL-SKIN-CPU-ODPM,VIRTUAL-SKIN-CPU-MID,VIRTUAL-SKIN-CPU-HIGH"
  grep -A20 -B5 "VIRTUAL-SKIN-CPU-LIGHT-ODPM" /vendor/etc/thermal_info_config_throttling.json 2>/dev/null | grep -E "Name|PollingDelay" || true
} > "$GUARDDIR/last_verify.txt"
