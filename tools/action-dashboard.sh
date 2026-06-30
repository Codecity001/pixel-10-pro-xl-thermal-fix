#!/system/bin/sh
ID="${ID:-pixel-10-pro-xl-thermal-fix}"
MODDIR="${MODDIR:-/data/adb/modules/$ID}"
CONFIG_DIR="/data/adb/$ID"
CONFIG_FILE="$CONFIG_DIR/config.env"

[ -s "$MODDIR/tools/menu-cycle.sh" ] && . "$MODDIR/tools/menu-cycle.sh"

msg() {
  if command -v ui_print >/dev/null 2>&1; then ui_print "$*"; else echo "$*"; fi
}

cfg_get() {
  k="$1"
  [ -r "$CONFIG_FILE" ] || return 0
  grep -E "^${k}=" "$CONFIG_FILE" 2>/dev/null | tail -n 1 | sed "s/^${k}=//" | tr -d '\r'
}

cfg_set() {
  k="$1"
  v="$2"
  mkdir -p "$CONFIG_DIR" 2>/dev/null || true
  touch "$CONFIG_FILE" 2>/dev/null || true
  tmp="$CONFIG_FILE.tmp.$$"
  grep -v "^${k}=" "$CONFIG_FILE" 2>/dev/null > "$tmp" || true
  printf '%s=%s\n' "$k" "$v" >> "$tmp"
  mv "$tmp" "$CONFIG_FILE"
  chmod 0600 "$CONFIG_FILE" 2>/dev/null || true
}

strip_outdoor_suffix() {
  p="$1"
  case "$p" in
    *-outdoor-extended) echo "${p%-outdoor-extended}" ;;
    *-outdoor-plus) echo "${p%-outdoor-plus}" ;;
    *-outdoor-safe) echo "${p%-outdoor-safe}" ;;
    *) echo "$p" ;;
  esac
}

current_base_profile() {
  p="$(sed -n 's/^profile=//p' "$MODDIR/install-state.txt" 2>/dev/null | tail -n 1)"
  [ -n "$p" ] || p="$(cat "$MODDIR/guard/selected_profile" 2>/dev/null | head -n 1)"
  [ -n "$p" ] || p="unknown"
  strip_outdoor_suffix "$p"
}

selected_variant_profile() {
  base="$1"
  choice="$(cfg_get THERMAL_OUTDOOR_PROFILE)"
  case "$choice" in
    outdoor-safe|outdoor-plus|outdoor-extended)
      if [ -s "$MODDIR/profiles/$base-$choice/system/vendor/etc/thermal_info_config_throttling.json" ]; then
        echo "$base-$choice"
      else
        echo "$base"
      fi
    ;;
    *) echo "$base" ;;
  esac
}

rematerialize_thermal_overlay() {
  base="$(current_base_profile)"
  if [ "$base" = "unknown" ] || [ ! -d "$MODDIR/profiles/$base/system/vendor/etc" ]; then
    msg "! Cannot determine base profile."
    msg "! Reinstall or collect debug ZIP."
    return 1
  fi

  selected="$(selected_variant_profile "$base")"
  profile_dir="$MODDIR/profiles/$selected/system/vendor/etc"
  active_dir="$MODDIR/system/vendor/etc"

  for f in thermal_info_config.json thermal_info_config_charge.json thermal_info_config_throttling.json; do
    if [ ! -s "$profile_dir/$f" ]; then
      msg "! Missing profile file: $profile_dir/$f"
      return 1
    fi
  done

  mkdir -p "$active_dir" "$MODDIR/guard" 2>/dev/null || true
  rm -f "$active_dir"/thermal_info_config*.json 2>/dev/null || true
  cp -fp "$profile_dir"/thermal_info_config*.json "$active_dir"/ || return 1
  chmod 0644 "$active_dir"/thermal_info_config*.json 2>/dev/null || true

  if [ -s "$MODDIR/tools/apply-polling-mode.sh" ]; then
    BASE_PROFILE="$base" ACTIVE_DIR="$active_dir" MODDIR="$MODDIR" CONFIG_FILE="$CONFIG_FILE" sh "$MODDIR/tools/apply-polling-mode.sh" action 2>/dev/null || true
  fi

  printf '%s\n' "$selected" > "$MODDIR/guard/selected_profile" 2>/dev/null || true
  printf '%s\n' "yes" > "$MODDIR/guard/action_cycle_pending_reboot" 2>/dev/null || true
  msg "- Profile materialized in module overlay: $selected"
  msg "- Reboot recommended for mount/vendor activation."
  return 0
}

refresh_status() {
  if [ -s "$MODDIR/tools/status-lib.sh" ]; then
    sh "$MODDIR/tools/status-lib.sh" update >/dev/null 2>&1 || true
  fi
}

show_status() {
  msg ""
  msg "----------------------------------------"
  msg "Pixel 10 Thermal & Memory Control"
  msg "----------------------------------------"
  if [ -s "$MODDIR/tools/status-lib.sh" ]; then
    sh "$MODDIR/tools/status-lib.sh" print
  else
    msg "! status-lib missing"
  fi
  msg "----------------------------------------"
}

full_diagnostics() {
  show_status
  msg ""
  msg "== compat-check =="
  if [ -s "$MODDIR/tools/compat-check.sh" ]; then
    sh "$MODDIR/tools/compat-check.sh" 2>/dev/null || true
  else
    msg "compat-check missing"
  fi
  msg ""
  msg "== config =="
  cat "$CONFIG_FILE" 2>/dev/null || true
  msg ""
  msg "== health =="
  tail -n 120 "$MODDIR/health.log" 2>/dev/null || true
  msg ""
  msg "== zram props =="
  for k in mmd.zram.enabled mmd.zram.size vendor.zram.size persist.vendor.boot.zram.size persist.device_config.vendor_system_native_boot.zram_size; do
    msg "$k=$(getprop "$k" 2>/dev/null || true)"
  done
}

cycle_polling() {
  cur="$(cfg_get THERMAL_POLLING_MODE)"
  case "$cur" in stock) idx=1 ;; *) idx=0 ;; esac
  mc_cycle2 "Polling Fix" "Mod values" "Stock values" "$idx"
  if [ "$MC_INDEX" = "1" ]; then
    cfg_set THERMAL_POLLING_MODE stock
    cfg_set LAST_THERMAL_POLLING_MODE stock
    msg "- Polling selected: stock"
  else
    cfg_set THERMAL_POLLING_MODE mod
    cfg_set LAST_THERMAL_POLLING_MODE mod
    msg "- Polling selected: mod"
  fi
  rematerialize_thermal_overlay || true
  refresh_status
  show_status
}

cycle_thermal() {
  base="$(current_base_profile)"
  if [ "$base" = "unknown" ]; then
    msg "! Base profile unknown. Run debug ZIP."
    return 1
  fi
  cfg_set THERMAL_SETTINGS_MODE action_cycle
  if [ -s "$MODDIR/tools/thermal-outdoor-menu.sh" ]; then
    BASE_PROFILE="$base" MODDIR="$MODDIR" CONFIG_FILE="$CONFIG_FILE" sh "$MODDIR/tools/thermal-outdoor-menu.sh" action || true
  else
    msg "! Thermal outdoor menu missing."
    return 1
  fi
  rematerialize_thermal_overlay || true
  refresh_status
  show_status
}

cycle_zram() {
  if [ -s "$MODDIR/tools/zram-menu.sh" ]; then
    MODDIR="$MODDIR" sh "$MODDIR/tools/zram-menu.sh" action || true
  else
    msg "! ZRAM menu missing."
    return 1
  fi

  if [ "$(cfg_get ENABLE_ZRAM_100P)" = "1" ] && [ -s "$MODDIR/tools/apply-zram-100p.sh" ]; then
    msg ""
    msg "- Applying ZRAM runtime props now..."
    MODDIR="$MODDIR" sh "$MODDIR/tools/apply-zram-100p.sh" manual || true
  else
    msg ""
    msg "- ZRAM disabled or helper missing."
    msg "- Reboot recommended to return fully to stock ZRAM behavior."
  fi
  refresh_status
  show_status
}

debug_zip() {
  if [ -s "$MODDIR/tools/collect-debug.sh" ]; then
    sh "$MODDIR/tools/collect-debug.sh" || true
  else
    msg "! collect-debug missing"
  fi
}

cycle_menu() {
  mc_cycle4 "Cycle / Reconfigure" "Polling" "Thermal" "ZRAM" "Back" 0
  case "$MC_INDEX" in
    0) cycle_polling ;;
    1) cycle_thermal ;;
    2) cycle_zram ;;
    *) msg "Back." ;;
  esac
}

refresh_status
show_status

if ! command -v getevent >/dev/null 2>&1; then
  full_diagnostics
  exit 0
fi

mc_cycle4 "Action" "Status" "Cycle" "Debug ZIP" "Exit" 0
case "$MC_INDEX" in
  0) full_diagnostics ;;
  1) cycle_menu ;;
  2) debug_zip ;;
  *) msg "Exit." ;;
esac

refresh_status
exit 0
