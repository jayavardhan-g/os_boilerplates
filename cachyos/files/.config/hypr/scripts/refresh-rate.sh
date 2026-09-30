#!/usr/bin/env bash
# Set or toggle eDP-1 (laptop panel) refresh rate between 144Hz and 60Hz.
# Usage: refresh-rate.sh {144|60|toggle}
set -euo pipefail

MONITOR="eDP-1"

current_hz() {
    hyprctl monitors -j | jq -r --arg m "$MONITOR" '.[] | select(.name==$m) | .refreshRate'
}

set_hz() {
    # This config uses hyprlua, whose settings aren't reachable via the
    # legacy `hyprctl keyword` path ("keyword can't work with non-legacy
    # parsers") — `eval` runs Lua directly against the same hl.monitor()
    # the config itself uses.
    #
    # Only `mode` is passed: hl.monitor() patches just the fields given, so
    # position and scale stay whatever config/monitors.lua set (verified live:
    # 144 -> 60 -> 144 left eDP-1 at x=0, scale 1.20). This used to also pass
    # position = "auto", scale = "1.25", a stale copy of the layout that re-placed
    # the laptop to the RIGHT of HDMI-A-1 (x = 1650 + 1920 = 3570) every time the
    # battery guard fired, e.g. on unplugging the charger.
    hyprctl eval "hl.monitor({ output = '${MONITOR}', mode = '1920x1080@${1}' })"
}

case "${1:-toggle}" in
    144|60) set_hz "$1" ;;
    toggle)
        cur=$(current_hz)
        if awk -v c="$cur" 'BEGIN{exit !(c > 100)}'; then
            set_hz 60
        else
            set_hz 144
        fi
        ;;
    *) echo "usage: $0 {144|60|toggle}" >&2; exit 1 ;;
esac
