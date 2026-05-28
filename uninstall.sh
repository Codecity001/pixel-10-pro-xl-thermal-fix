#!/system/bin/sh
MODDIR=${0%/*}
rm -rf "$MODDIR/guard" 2>/dev/null || true
exit 0
