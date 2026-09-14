# SUPER+N cycles layout engine: master → dwindle → scrolling

**Date:** 2026-09-14
**Category:** keybindings
**Files touched:** `~/.config/hypr/config/binds.lua`

## What
`SUPER+N` cycles Hyprland's live `general:layout` between `master` (the current default,
see [[master-layout]]), `dwindle`, and `scrolling`.

## Why
Wanted a Mango-style "switch layout" key (Mango's `SUPER+N` cycles its own
`circle_layout` list of layout engines). While implementing it, confirmed this Hyprland
build actually ships a built-in horizontal-scrolling layout engine —
`Layout::Tiled::CScrollingAlgorithm` in `/usr/bin/Hyprland`, with `scrolling:column_width`
/ `scrolling:direction` / `scrolling:explicit_column_widths` config keys — that had never
been turned on in this config before. `master` and `dwindle` were the only two layouts
actually configured (`general.layout = "master"` in `decorations.lua`, plus a
`dwindle = { preserve_split = true }` block in `misc.lua`), so this bind also gives
`dwindle` a way to be reached live without editing `decorations.lua` by hand.

## Change
```lua
-- Cycle the active layout engine: master -> dwindle -> scrolling -> master
local LAYOUTS = { "master", "dwindle", "scrolling" }
local function cycle_layout()
    local current = hl.get_config("general:layout")
    local idx = 1
    for i, name in ipairs(LAYOUTS) do
        if name == current then idx = i end
    end
    hl.config({ general = { layout = LAYOUTS[(idx % #LAYOUTS) + 1] } })
end
hl.bind(mainMod .. " + N", cycle_layout)
```

## Notes
- `scrolling` is untested/untuned territory — no `scrolling:*` options have been set, so
  it runs on whatever Hyprland's built-in defaults are. Revisit `scrolling:column_width`
  etc. once it's actually been used for a while.
- The cycle reads the *current* live value via `hl.get_config` each press (same pattern
  as the existing `zoomfunction` in this file) rather than tracking its own index
  variable, so it stays correct even if the layout is changed some other way (e.g. a
  per-workspace `hl.workspace_rule(..., layout = ...)` override) between presses.
- Startup default is still `master`, set in `decorations.lua` — this bind only changes the
  layout for the running session, not what you boot into.
