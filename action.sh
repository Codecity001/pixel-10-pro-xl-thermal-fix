#!/system/bin/sh
MODDIR=${0%/*}
GUARDDIR="$MODDIR/guard"
mkdir -p "$GUARDDIR"
echo "$(date -Is 2>/dev/null || date) manual_action_disable" >> "$GUARDDIR/bootguard.log"
echo "manual_action_disable" > "$GUARDDIR/disabled_reason"
touch "$MODDIR/disable" "$MODDIR/skip_mount"
sync
echo "Module disabled. Reboot to apply."
