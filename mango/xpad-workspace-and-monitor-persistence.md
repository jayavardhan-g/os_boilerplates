# Xpad notes on a dedicated tag 5 (Mango)

**Date:** 2026-09-14
**Category:** mango
**Files touched:** `~/.config/mango/cfg/layout.conf`, `~/.config/mango/cfg/rules.conf`,
`~/.config/mango/cfg/keybinds.conf`

## What
Tag 5 is dedicated to [[xpad-sticky-notes]]: `SUPER+5` views it, `SUPER+SHIFT+5` sends the
focused window to it (same pattern as tags 1-4), and any Xpad window that opens lands there,
floating, without being force-centered. Usage is manual: switch to tag 5 (`SUPER+5`), launch
Xpad there yourself, and it restores its own last-saved position — no auto-launch on
startup, no auto-migration between monitors.

## Why
Started as a full port of the Hyprland feature (`cachyos/window-management/xpad-workspace-and-monitor-persistence.md`)
— auto-launch on startup, auto-migrate onto whichever monitor is external via a background
watcher daemon. **That automation was built, live-verified working, and then deliberately
reverted** (see Notes) after it triggered a real Xpad startup-race bug that briefly
corrupted saved note positions. User's call: keep this to the static minimum — tag 5 exists
and behaves correctly for notes — and handle placement manually instead of automating it.

Unlike Hyprland's arbitrary-numbered `special:name` workspaces, Mango's tags are a flat
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
# Xpad notes: pinned to tag 5. isfloating requires an explicit width/height
# in the same rule to actually take effect (confirmed live - without them
# the floating flag is silently ignored and the window stays tiled); this
# is just a seed size, each note immediately resizes itself to its own
# saved dimensions after mapping (also confirmed live - a dispatched
# resize after creation overrides the rule's size cleanly). no_force_center
# stops Mango re-centering the note after it restores its own saved
# position.
windowrule = appid:xpad, tags:5, isfloating:1, width:300, height:300, no_force_center:1
```

`~/.config/mango/cfg/keybinds.conf` — added, alongside the existing 1-4 view/tag binds:
```
bind = SUPER, 5, view, 5, 0
bind = SUPER+SHIFT, 5, tag, 5, 0
```

## Notes
- **Reverted: auto-launch on startup + auto-migrate-to-external-monitor via a background
  watcher daemon.** Originally built as `~/.config/mango/scripts/xpad-launch.sh` (focused
  the right monitor before launching Xpad, cleaned up its spurious blank pad) plus
  `xpad-monitor-watch.sh` (a persistent `mmsg watch all-monitors` loop that moved notes
  onto the external monitor's tag 5 the moment it connected, using `tagmon` + `tagsilent`
  — see the mechanics below, which are still accurate and reusable if this is ever
  revisited). Both were live-verified working end to end with the real Xpad app and real
  notes, including a real external-monitor disable/enable round trip.
- **Why it was reverted:** repeatedly restarting Xpad during testing (to reproduce and
  fix an unrelated race, see below) revealed Xpad **autosaves its position on its own,
  not just on a clean `--quit` as previously documented** — and during its own internal
  startup race (see next point) it sometimes wrote the *broken transient* position to
  disk. This happened twice live, overwriting both notes' real saved positions with
  garbage (`x:2 y:2`, `x:2524 y:420` instead of their real `x:2920 y:418` /
  `x:2900 y:325`). Both times it was caught and fixed by restoring the exact values
  already captured earlier in that session's own tool output — no permanent data loss,
  but a close call. User decided the automation wasn't worth this risk and asked to keep
  things manual instead.
- **The underlying Xpad bug this exposed (still present, not fixed, not Mango-specific
  to fix):** when multiple notes are restored at once under `GDK_BACKEND=x11`, one can
  lose an internal Xpad race and either (a) never map at all (vanishes from `mmsg get
  all-clients` while the process keeps running), or (b) map but get stuck at whatever
  the windowrule's seed geometry was (`x:0 y:0`, seed height) instead of its own saved
  position. Confirmed live, reproducible across several relaunches, not tied to a
  specific note — whichever one loses the race that run. A same-session attempt to
  auto-correct a stuck note via `mmsg dispatch movewin`/`resizewin` using the saved
  info-file coordinates directly was itself wrong and abandoned: Xpad's saved coordinates
  turned out to be in a different coordinate space than what `mmsg` reports/accepts
  (confirmed live — a *correctly* self-restored note's saved `x` differed from its live
  `mmsg` `x` by ~400px, with no consistent scale/offset relating the two notes' numbers).
  **Do not attempt an `mmsg movewin`/`resizewin`-based fix for this without first working
  out the actual XWayland↔compositor coordinate mapping.** If a note ends up stuck or
  missing, the safe fix is closing and reopening just that note from Xpad's own UI, or
  dragging it back into place with the mouse — not scripted `killclient`/`movewin`.
- **`mmsg`'s `active` field on a monitor means "currently focused," not
  "connected/enabled."** Tripped over this live: `HDMI-A-1` showed `active:false` while
  fully connected and rendering a fullscreen `mpv` window, simply because `eDP-1` had
  last been focused. The real "is this monitor known to the compositor" signal is
  presence of its name in `mmsg get all-monitors`' `monitors` array.
- **The `tagmon`+tag-fix two-step (from the reverted automation, still correct if ever
  revisited):** `mmsg dispatch tagmon,<dest> client,<id>` moves a client to another
  monitor but — per the pre-existing comment in `keybinds.conf`
  (`client_reset_mon_tags`) — drops it onto whatever tag the *destination* monitor
  currently happens to be showing, not the tag it came from. Following it with `mmsg
  dispatch tagsilent,5,0 client,<id>` fixes the tag without disturbing anything. Must be
  `tagsilent`, not `tag` — `tag` (used for the `SUPER+SHIFT+1..4` binds) was confirmed
  live to also switch the destination monitor's *visible* tag to match, yanking its
  current view away to show the (still-hidden) notes tag.
- **Mango's own monitor-removal handling already moves every client from a removed
  monitor onto the remaining one, preserving each client's exact tag number** —
  confirmed live via `mmsg dispatch disable_monitor,HDMI-A-1` with real windows present.
  Re-enabling moved everything back automatically too. Caveat: this was tested via the
  software `disable_monitor`/`enable_monitor` toggle, which keeps the same output object
  alive (confirmed it stays listed in `mmsg get all-monitors` even while disabled) —
  a genuine cable unplug/replug likely destroys and recreates the output object instead,
  which is standard for wlroots-based compositors but was not independently verified
  here.
- **`tag_num` is a single global setting, not per-monitor** — confirmed live via `mmsg
  get all-monitors`: both `eDP-1` and `HDMI-A-1` always report the same `tag_num`.
  There's no way to give one monitor more tags than another.
