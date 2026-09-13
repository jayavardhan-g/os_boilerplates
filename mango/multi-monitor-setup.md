# Multi-monitor setup: scale, position, workspace count, and monitor keybinds

**Date:** 2026-09-14
**Category:** mango
**Files touched:** `~/.config/mango/cfg/monitors.conf`, `~/.config/mango/cfg/layout.conf`, `~/.config/mango/cfg/misc.conf`, `~/.config/mango/cfg/keybinds.conf`

## What
UI scale matched to the Hyprland setup, workspace count reduced from the
default 9 to 4, cross-monitor focus-follow enabled to match Hyprland, and a
set of keybinds for focusing/moving windows to a specific monitor by name.

## Why
User wanted parity with the existing two-monitor Hyprland setup (laptop
`eDP-1` + external `HDMI-A-1`, both at 1.25 scale originally, later
adjusted to 1.1) and a smaller, more manageable workspace count.

## Change

`~/.config/mango/cfg/monitors.conf`:
```
monitorrule = name:eDP-1, x:0, y:0, scale:1.1
monitorrule = name:HDMI-A-1, x:1745, y:0, scale:1.1
```

`~/.config/mango/cfg/layout.conf`:
```
tag_num = 4
```
(with `tagrule` trimmed to just `id:1` through `id:4` — see [[keybinds]])

`~/.config/mango/cfg/misc.conf`:
```
focus_cross_monitor = 1
```

`~/.config/mango/cfg/keybinds.conf` — final monitor keybind scheme:
```
# Switch between monitors - bracketleft/right ([ = laptop, ] = monitor,
# matches the physical eDP-1/HDMI-A-1 left-right arrangement) and by
# direction (kept as an alternative)
bind = SUPER, bracketleft, focusmon, eDP-1
bind = SUPER, bracketright, focusmon, HDMI-A-1
bind = SUPER+ALT, Left, focusmon, left
bind = SUPER+ALT, Right, focusmon, right
# Move window to another monitor - lands on whichever tag the destination
# monitor is currently showing (confirmed via source, client_reset_mon_tags)
bind = SUPER+SHIFT, bracketleft, tagmon, eDP-1
bind = SUPER+SHIFT, bracketright, tagmon, HDMI-A-1
bind = SUPER+SHIFT+ALT, Left, tagmon, left
bind = SUPER+SHIFT+ALT, Right, tagmon, right
```
`SUPER+1..4`/`SUPER+SHIFT+1..4` stayed on plain workspace switching/move —
see Notes for why an attempt to match Hyprland's exact `SUPER+1`/`SUPER+2`
monitor-focus convention was tried and abandoned.

## Notes
- **`focusmon`/`tagmon` accept a monitor name directly, not just a
  direction.** Confirmed via the config parser (`src/dispatch/bind.c`):
  the argument is first checked against direction keywords
  (`left`/`right`/etc.); if it doesn't match one, it's used as a literal
  monitor name instead (`match_monitor_spec`). This isn't documented
  anywhere obvious - found by reading the parser directly.
- **Mango's tags are per-monitor, not a shared pool** — unlike Hyprland,
  where workspace numbers are global and get bound to specific monitors.
  Each monitor independently has its own full set of tags 1 through
  `tag_num`, confirmed live via `mmsg get all-tags` (each monitor listed its
  own separate `tags` array with independent `active_tags`/client counts).
  There's no way to "reserve tags 1-5 for the laptop and 6-9 for the
  monitor" the way you could bind Hyprland workspaces to outputs — pressing
  `SUPER+1` on either monitor already only ever affects that monitor's own
  tag 1, they never collide in the first place.
- **Auto monitor-position broke after a live scale change** — after
  changing `scale` from `1.25` to `1.1` via a live edit + reload, the two
  monitors ended up overlapping (`HDMI-A-1` at `x=1920`, `eDP-1` at
  `x=3456` — stale numbers left over from before the scale change, not
  recalculated). Fix was to stop relying on any auto-placement and pin `x`/
  `y` explicitly for both outputs, recomputed for the current scale
  (`physical_width / scale`, confirmed against `mmsg get all-monitors`
  output each time). If scale changes again, position needs recomputing
  too - it does not self-correct.
- **Tried and abandoned: matching Hyprland's exact `SUPER+1`/`SUPER+2` for
  monitor-focus and `SUPER+SHIFT+1`/`2` for move-to-monitor.** This
  collides directly with plain-digit workspace switching in Mango (unlike
  Hyprland, which reserves bare digits for monitor-focus and puts
  workspaces on `ALT`/`CTRL`-modified digits instead). Went through a full
  remap (workspace switching relocated to `SUPER+ALT+1..4` /
  `SUPER+SHIFT+ALT+1..4`) before deciding it wasn't worth the disruption and
  reverting workspace switching back to plain digits, using
  `bracketleft`/`bracketright` for monitor-focus/move instead - confirmed
  free of any conflict, including checked against every Mango layout's
  documented keybindings (none of them reserve bracket keys either).
- **`circle_layout = dwindle,tile,scroller,vertical_scroller`** was added to
  `layout.conf` so the already-bound `SUPER+N` (`switch_layout`) cycles
  through these on the current tag, for trying different layouts live
  before picking one permanently. Not yet settled on a final choice.
- See [[known-bugs]] for a real, currently-unfixed upstream bug that
  surfaced during this testing: moving a window onto a monitor with an
  active fullscreen client leaves keyboard focus stuck.
