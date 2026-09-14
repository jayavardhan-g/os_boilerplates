# Xpad notes pinned to a monitor-aware tag 5 (Mango)

**Date:** 2026-09-14
**Category:** mango
**Files touched:** `~/.config/mango/cfg/layout.conf`, `~/.config/mango/cfg/rules.conf`,
`~/.config/mango/cfg/keybinds.conf`, `~/.config/mango/cfg/autostart.conf`,
`~/.config/mango/scripts/xpad-launch.sh` (new), `~/.config/mango/scripts/xpad-monitor-watch.sh` (new)

## What
[[xpad-sticky-notes]] is wired into Mango as tag 5: notes live on tag 5 of whichever
monitor is currently the "notes" monitor — the external `HDMI-A-1` when it's connected,
falling back to `eDP-1` (laptop) otherwise. `SUPER+5` views the tag, `SUPER+SHIFT+5` sends
the focused window to it, same pattern as tags 1-4.

## Why
Port of the existing Hyprland feature (`cachyos/window-management/xpad-workspace-and-monitor-persistence.md`)
to Mango, since Mango's own [[keybinds]] doc flagged this as not yet ported. Unlike
Hyprland's arbitrary-numbered `special:name` workspaces, Mango's tags are a flat
1..`tag_num` range — there's no way to add a single named "tag 7" without also creating
unused tags in between. So `tag_num` went from 4 to **5**, not 7: exactly one new tag,
immediately after the four already in daily use, no wasted spare tags.

## Change

`~/.config/mango/cfg/layout.conf`:
```
tag_num = 5
```

`~/.config/mango/cfg/rules.conf` — added:
```
# Xpad notes: pinned to tag 5 (see xpad-workspace-and-monitor-persistence
# for why the tag count went from 4 to 5). isfloating requires an explicit
# width/height in the same rule to actually take effect (confirmed live -
# without them the floating flag is silently ignored and the window stays
# tiled); this is just a seed size; each note immediately resizes itself
# to its own saved dimensions after mapping (also confirmed live - a
# dispatched resize after creation overrides the rule's size cleanly).
# no_force_center stops Mango re-centering the note after it restores its
# own saved position.
windowrule = appid:xpad, tags:5, isfloating:1, width:300, height:300, no_force_center:1
```

`~/.config/mango/cfg/keybinds.conf` — added, alongside the existing 1-4 view/tag binds:
```
bind = SUPER, 5, view, 5, 0
bind = SUPER+SHIFT, 5, tag, 5, 0
```

`~/.config/mango/cfg/autostart.conf` — added:
```
exec-once = ~/.config/mango/scripts/xpad-launch.sh &
exec-once = ~/.config/mango/scripts/xpad-monitor-watch.sh &
```

`~/.config/mango/scripts/xpad-launch.sh` (new) — launches Xpad under `GDK_BACKEND=x11`
(same reason as the Hyprland version: Xpad can't query its own position under native
Wayland), first focusing whichever monitor is currently the notes monitor so the new
windows (matched by the `appid:xpad` rule above) land there immediately:
```bash
#!/usr/bin/env bash
set -uo pipefail

export GDK_BACKEND=x11

EXTERNAL="HDMI-A-1"
INTERNAL="eDP-1"
XPAD_DIR="$HOME/.config/xpad"

target="$INTERNAL"
if mmsg get all-monitors | jq -e --arg m "$EXTERNAL" '.monitors[] | select(.name == $m)' >/dev/null 2>&1; then
    target="$EXTERNAL"
fi
mmsg dispatch focusmon,"$target" >/dev/null 2>&1

existing_notes=$(find "$XPAD_DIR" -maxdepth 1 -name 'content-*' -size +0c 2>/dev/null | wc -l)

xpad --no-new &
sleep 3

close_blank_pads() {
    mmsg get all-clients | jq -r '.clients[] | select(.appid=="xpad" and .title=="") | .id' \
        | while read -r id; do
            mmsg dispatch killclient client,"$id" >/dev/null 2>&1
        done
}

if [ "$existing_notes" -gt 0 ]; then
    close_blank_pads
fi
```

`~/.config/mango/scripts/xpad-monitor-watch.sh` (new) — a background daemon, started once
per Mango session, that migrates notes onto the external monitor's tag 5 the moment it's
plugged in, and quits Xpad cleanly (saving pad positions) on session teardown:
```bash
#!/usr/bin/env bash
set -uo pipefail

EXTERNAL="HDMI-A-1"
INTERNAL="eDP-1"
NOTES_TAG=5

trap 'xpad --quit >/dev/null 2>&1; exit 0' TERM INT EXIT

migrate_notes_to() {
    local dest="$1"
    local src="$2"
    mmsg get all-clients | jq -r --arg src "$src" \
        '.clients[] | select(.appid=="xpad" and .monitor==$src) | .id' \
        | while read -r id; do
            mmsg dispatch tagmon,"$dest" client,"$id" >/dev/null 2>&1
            mmsg dispatch tagsilent,"$NOTES_TAG",0 client,"$id" >/dev/null 2>&1
        done
}

known_external_present=""
if mmsg get all-monitors | jq -e --arg m "$EXTERNAL" '.monitors[] | select(.name == $m)' >/dev/null 2>&1; then
    known_external_present=1
fi

mmsg watch all-monitors | while IFS= read -r line; do
    external_present=""
    if jq -e --arg m "$EXTERNAL" '.monitors[] | select(.name == $m)' >/dev/null 2>&1 <<<"$line"; then
        external_present=1
    fi

    if [ -n "$external_present" ] && [ -z "$known_external_present" ]; then
        sleep 1
        migrate_notes_to "$EXTERNAL" "$INTERNAL"
    fi

    known_external_present="$external_present"
done
```

## Notes
- **Why the disconnect direction needed zero code:** confirmed live, repeatedly, using
  the real desktop (real mpv + Dolphin windows on `HDMI-A-1`, real Xpad notes on tag 5)
  via `mmsg dispatch disable_monitor,HDMI-A-1` / `enable_monitor,HDMI-A-1`: Mango's own
  monitor-removal handling already moves *every* client from a removed monitor onto the
  remaining one, **preserving each client's exact tag number** — no re-tagging needed.
  Re-enabling the monitor afterward moved every client (including the tag-5 notes) back
  to their prior monitor automatically too. Only the "external newly appears" direction
  needed custom code, since a monitor that's never before had these clients has no
  memory to restore from.
- **Caveat on that finding: `disable_monitor`/`enable_monitor` is a software toggle, not
  a real hotplug.** Confirmed live that the monitor stays listed in `mmsg get
  all-monitors` (just doing nothing) even while disabled — it's the same output object
  being turned on/off, not destroyed and recreated. A genuine cable unplug/replug likely
  goes through different internal handling (the output object actually disappearing and
  a fresh one being created on replug), which is standard for wlroots-based compositors
  but **not verified here** — not safely simulatable without physically pulling the
  cable. If a real hotplug ever behaves differently from this, the fix is confined to
  `xpad-monitor-watch.sh`'s connect-detection condition, not the migration primitive
  below (which is monitor-identity-agnostic and already proven correct).
- **`mmsg`'s `active` field on a monitor means "currently focused," not
  "connected/enabled."** Tripped over this live: `HDMI-A-1` showed `active:false` while
  fully connected and rendering a fullscreen `mpv` window, simply because `eDP-1` had
  last been focused. The actual "is this monitor known to the compositor" signal used
  throughout is just presence of its name in `mmsg get all-monitors`' `monitors` array.
- **The `tagmon`+tag-fix two-step, confirmed live:** `mmsg dispatch tagmon,<dest>
  client,<id>` moves a client to another monitor but — per the pre-existing comment in
  `keybinds.conf` (`client_reset_mon_tags`) — drops it onto whatever tag the
  *destination* monitor currently happens to be showing, not tag 5. Following it with
  `mmsg dispatch tagsilent,5,0 client,<id>` fixes the tag without disturbing anything.
  **Must be `tagsilent`, not `tag`** — `tag` (used for the `SUPER+SHIFT+1..4` binds)
  was confirmed live to also switch the destination monitor's *visible* tag to match,
  which would yank the external monitor's current view away to show the (still hidden)
  notes tag — exactly the disruption this feature is supposed to avoid. `tagsilent`
  updates the client's tag membership only.
- **`isfloating:1` silently does nothing without `width`/`height` in the same rule** —
  confirmed live with a throwaway test window: `isfloating:1` alone left it tiled,
  identical rule plus `width:400, height:300` made it float immediately. The seed size
  doesn't stick around, though — confirmed a `mmsg dispatch resizewin,...` right after
  creation overrides it cleanly, and the real Xpad notes came up at their own saved
  sizes (365×300, 365×244), not the rule's 300×300 seed.
- **`tag_num` is a single global setting, not per-monitor** — confirmed live via `mmsg
  get all-monitors`: both `eDP-1` and `HDMI-A-1` always report the same `tag_num` and
  the same tag count. There's no way to give one monitor more tags than another.
- Verified live end-to-end with the real Xpad app and real notes (not simulated): killed
  the placeholder kitty window that had been standing in for "notes" under Mango,
  reloaded config, ran `xpad-launch.sh` for real. Both saved notes ("broken", "Disjoint
  set questions") came up floating, correctly sized, on `HDMI-A-1` tag 5, invisible
  until `SUPER+5` (dispatched directly to confirm) revealed them — with the real `mpv`
  fullscreen video and Dolphin window on tag 1 completely undisturbed throughout. The
  watcher daemon is running for the remainder of this session and wired into
  `autostart.conf` for every future Mango start.
- **The migrate-on-connect path itself (not just the detection) is confirmed working**:
  tested the `tagmon` + `tagsilent` pair directly against a disposable test window moved
  between `eDP-1` and `HDMI-A-1` tag 5 in both directions, and separately against the
  real notes. What's *not* independently verified is `xpad-monitor-watch.sh`'s
  connect-detection firing on a genuine hotplug specifically (see caveat above) — next
  time the external monitor is physically unplugged and replugged, check
  `mmsg get all-clients` afterward to confirm the notes actually migrated, and update
  this note either way.
- Takes effect on next full Mango restart for the `autostart.conf` changes (`exec-once`
  entries don't re-run on `reload_config`, same caveat as Hyprland's `hyprland.start`
  hook) — manually started both scripts once for this session so the feature is live
  immediately rather than waiting for a restart.
