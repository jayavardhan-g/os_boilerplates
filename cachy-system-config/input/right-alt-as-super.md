# Right Alt acts as Super

**Date:** 2026-08-28
**Category:** input
**Files touched:** `~/.config/hypr/config/inputs.lua`

## What
The physical Right Alt key sends the Super/Meta keysym instead of Alt.

## Why
User wanted to be able to trigger `SUPER+...` binds one-handed / without stretching to
the physical Super key, since Alt and Super are close together on the keyboard. Standard
XKB doesn't have an "add Super to a key while keeping its other function" option — only
swap options exist.

## Change
```lua
kb_options = "caps:swapescape,altwin:swap_ralt_rwin",
```

## Notes
- `altwin:swap_ralt_rwin` is a stock XKB rule (`/usr/share/X11/xkb/rules/base.lst`) — no
  extra packages needed. It **swaps** Right Alt and Right Win, it doesn't duplicate Super
  onto Alt. If this laptop/keyboard has a physical Right Win key, that key now sends Alt
  instead. No downside if there's no separate Right Win key in use.
- Side effect: combos meant to include "Alt" (e.g. `SUPER+ALT+Space` for float toggle)
  now need the **left** Alt key — Right Alt can't supply the Alt half of a combo anymore
  since it emits Super.
