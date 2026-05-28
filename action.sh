#!/system/bin/sh
MODDIR=${0%/*}
mkdir -p "$MODDIR/guard" 2>/dev/null || true
echo "manual_action_disable" > "$MODDIR/guard/disabled_reason" 2>/dev/null || true
touch "$MODDIR/skip_mount" 2>/dev/null || true
touch "$MODDIR/disable" 2>/dev/null || true
echo "Pixel 10 Pro XL Thermal Fix: disabled. Reboot required."
exit 0
