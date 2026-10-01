#!/usr/bin/env bash
# Sync the login/lock-screen greeter after a MANUAL wallpaper change, but never
# while Noctalia's automatic wallpaper rotation is on.
#
# Wired up as Noctalia's [hooks] wallpaper_changed in ~/.config/noctalia/config.toml.
# Noctalia's own [shell.greeter_sync] auto_sync stays off: it syncs on every
# wallpaper/colors/theme/font change and has no "skip while rotating" option, and
# each sync asks for the admin password (pkexec, polkit action
# org.noctalia.greeter.sync-appearance) — with 30-min rotation that was a prompt
# every 30 minutes. Here the password is still asked for, but only when the
# wallpaper was actually changed by hand.
#
# The hook fires once per monitor for a single change, so only the first call
# proceeds (flock) and it waits a few seconds first — that also lets the
# wallpaper-derived color palette finish regenerating, so the greeter gets the
# new colors and not the old ones.
#
# Skips when the wallpapers are the same as at the last sync, so a hook event that
# doesn't reflect a real change (e.g. wallpapers being re-created at shell startup)
# can't pop a password prompt.
set -uo pipefail

LOCK="${XDG_RUNTIME_DIR:-/tmp}/greeter-sync-on-wallpaper.lock"
LAST="${XDG_STATE_HOME:-$HOME/.local/state}/noctalia/greeter-sync-last-wallpaper"

exec 9>"$LOCK"
flock -n 9 || exit 0

sleep 3

# "noctalia config export" merges config.toml with the Settings-UI-written
# settings.toml, so it reflects the rotation toggle however it was flipped.
state=$(noctalia config export | python3 -c '
import sys, tomllib
w = tomllib.loads(sys.stdin.read()).get("wallpaper", {})
print("rotating" if w.get("automation", {}).get("enabled") else "manual")
print("default", w.get("default", {}).get("path", ""))
for name, mon in sorted(w.get("monitors", {}).items()):
    print(name, mon.get("path", ""))
') || exit 1

[[ $state == rotating* ]] && exit 0
[[ -f $LAST && $(<"$LAST") == "$state" ]] && exit 0

noctalia msg greeter-sync && printf '%s\n' "$state" > "$LAST"
