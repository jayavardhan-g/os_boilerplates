#!/usr/bin/env bash
# Keep Noctalia's greeter auto-sync on, except while automatic wallpaper rotation is on.
#
# Greeter auto-sync ([shell.greeter_sync] auto_sync) copies wallpaper/colors/theme/font
# to the login/lock-screen greeter on every such change, and each sync asks for the
# admin password (pkexec, polkit action org.noctalia.greeter.sync-appearance). That's
# wanted for changes made by hand — but with rotation on, every rotation would prompt.
# Noctalia has no "skip while rotating" option, so this flips auto_sync to the opposite
# of [wallpaper.automation] enabled.
#
# Run by rotation-pauses-greeter-sync.path (systemd user unit) whenever Noctalia's
# settings change. The value lives in its own file in the config dir (Noctalia merges
# every *.toml there) so the hand-written config.toml is never rewritten by a script.
# auto_sync must NOT also be set in config.toml or via the Settings UI (which writes
# settings.toml, and that overrides every file here).
set -uo pipefail

OUT="$HOME/.config/noctalia/rotation-pauses-greeter-sync.toml"

apply() {
    # "noctalia config export" merges config.toml with the Settings-UI-written
    # settings.toml, so it reflects the rotation toggle however it was flipped.
    local rotating auto_sync want
    rotating=$(noctalia config export | python3 -c '
import sys, tomllib
c = tomllib.loads(sys.stdin.read())
print("true" if c.get("wallpaper", {}).get("automation", {}).get("enabled") else "false")
') || return 1

    if [[ $rotating == true ]]; then auto_sync=false; else auto_sync=true; fi

    want="# Managed by ~/.config/hypr/scripts/rotation-pauses-greeter-sync.sh — don't edit.
# auto_sync is the opposite of [wallpaper.automation] enabled.
[shell.greeter_sync]
auto_sync = $auto_sync"

    # Rewriting the file makes Noctalia reload its config, so only write on a real change.
    [[ -f $OUT && $(<"$OUT") == "$want" ]] && return 0

    printf '%s\n' "$want" > "$OUT.tmp" && mv "$OUT.tmp" "$OUT"
}

# Apply right away (so pausing wins the race against the wallpaper Noctalia switches
# to the moment rotation is turned on), then once more: systemd drops path events
# that arrive while this service is still running, so a save landing mid-run would
# otherwise go unseen until the next one.
apply
sleep 1
apply
