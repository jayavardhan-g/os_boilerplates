# Mango unfocused-window opacity matched to Hyprland

**Date:** 2026-09-14
**Category:** appearance
**Files touched:** `~/.config/mango/cfg/appearance.conf`

## What
Set `unfocused_opacity = 0.85` in Mango, matching Hyprland's `inactive_opacity` (see
`~/.config/hypr/config/decorations.lua`'s `decoration` block).

## Why
Mango's `appearance.conf` never set an opacity value at all, so unfocused windows were
running on Mango's compiled-in default — noticeably more transparent than the Hyprland
side, which explicitly sets `active_opacity = 0.95` / `inactive_opacity = 0.85`. User
wanted the two compositors' look to match rather than have Mango be more see-through by
accident.

## Change
`~/.config/mango/cfg/appearance.conf`:
```
borderpx = 4
border_radius = 10

# Matches Hyprland's inactive_opacity (0.85) - no separate focused_opacity
# knob exists in Mango, focused windows are always fully opaque there.
unfocused_opacity = 0.85
```

## Notes
- **Mango has no `focused_opacity`/`active_opacity` equivalent** — confirmed via
  `strings /usr/bin/mango`: only `unfocused_opacity` exists as a config key
  (`client_set_unfocused_opacity_animation`); the focused window is always rendered fully
  opaque by design. So this can only approximate Hyprland's look (0.95 active / 0.85
  inactive) on the inactive side — Mango's focused windows stay at 1.0 rather than 0.95,
  a difference too small to matter visually.
- Not yet visually confirmed live — this was set from a different session while logged
  into Hyprland, not Mango, so it hasn't been reloaded/viewed yet. Reload Mango
  (`mmsg reload` or a fresh Mango login) to see it take effect.
