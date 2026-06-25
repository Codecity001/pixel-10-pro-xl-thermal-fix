#!/system/bin/sh
# Pixel 10 Thermal Fix - ZRAM 100% Apply Helper (Bare Minimum Debug Version)

CONFIG_FILE="/data/adb/pixel-10-pro-xl-thermal-fix/config.env"
if [ -f "$CONFIG_FILE" ]; then
  . "$CONFIG_FILE" 2>/dev/null || true
fi

prop_set() { resetprop -n "$1" "$2" 2>/dev/null || setprop "$1" "$2" 2>/dev/null; }

echo "=== Apply ZRAM Start ==="
echo "Time: $(date -Is 2>/dev/null || date)"

# Set ZRAM properties in-memory only (-n flag)
echo "Setting properties..."
prop_set mm.zram.maintenance.first_delay_seconds "2147483647"
prop_set mm.zram.maintenance.periodic_delay_seconds "2147483647"
prop_set mmd.zram.writeback.max_idle_seconds "2147483647"
prop_set mmd.zram.comp_algorithm "lz77eh"
prop_set mmd.zram.enabled "true"
prop_set mmd.zram.size "100%"
prop_set vendor.zram.size "100p"
prop_set persist.device_config.vendor_system_native_boot.zram_size "100p"
prop_set persist.vendor.boot.zram.size "100p"

# Restart mmd daemon if requested
if [ "${ZRAM_RESTART_MMD:-1}" = "1" ]; then
  echo "Restarting mmd daemon..."
  stop mmd && start mmd
fi

# Diagnostic prints
echo "== active swaps =="
cat /proc/swaps 2>/dev/null || true
echo "== zram info =="
for f in disksize comp_algorithm mm_stat; do
  if [ -r "/sys/block/zram0/$f" ]; then
    echo "zram0/$f: $(cat "/sys/block/zram0/$f")"
  fi
done
echo "=== Apply ZRAM Complete ==="
