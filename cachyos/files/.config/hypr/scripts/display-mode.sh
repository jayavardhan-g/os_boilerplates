#!/usr/bin/env bash
# SUPER+P display mode menu (Windows Win+P equivalent): Extend / Duplicate /
# PC screen only / Second screen only.
#
# Every mode starts from config/monitors.lua rather than hard-coding its own
# positions and scales. This script used to carry its own copy (scale 1.25,
# external at position "auto"), which drifted from monitors.lua (1.20, external
# at a fixed x) and left the laptop auto-placed to the RIGHT of the external —
# found live 2026-09-25 with eDP-1 at x=3570 = 1650 + 1920.
#
# hl.monitor() patches fields incrementally rather than replacing the whole
# monitor rule, and monitors.lua never sets disabled/mirror, so a reload alone
# would not undo a previous Duplicate or "only" mode. Hence reset() clears
# those two fields explicitly, then reloads to re-apply everything else.
set -euo pipefail

INTERNAL="eDP-1"
EXTERNAL="HDMI-A-1"

reset() {
    hyprctl eval "
        hl.monitor({output=\"$INTERNAL\", disabled=false, mirror=\"\"})
        hl.monitor({output=\"$EXTERNAL\", disabled=false, mirror=\"\"})
    " >/dev/null
    hyprctl reload >/dev/null
}

choice=$(printf '%s\n' "Extend" "Duplicate" "PC screen only" "Second screen only" \
    | fuzzel --dmenu --prompt "Display mode: ")

[ -z "$choice" ] && exit 0

case "$choice" in
"Extend")
    reset
    ;;
"Duplicate")
    reset
    hyprctl eval "hl.monitor({output=\"$EXTERNAL\", mirror=\"$INTERNAL\"})"
    ;;
"PC screen only")
    reset
    hyprctl eval "hl.monitor({output=\"$EXTERNAL\", disabled=true})"
    ;;
"Second screen only")
    reset
    hyprctl eval "
        hl.monitor({output=\"$EXTERNAL\", position=\"0x0\"})
        hl.monitor({output=\"$INTERNAL\", disabled=true})
    "
    ;;
esac
