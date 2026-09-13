# Scrolling layout (niri-style column tiling, native to Hyprland)

**Date:** 2026-09-13
**Category:** window-management
**Files touched:** `~/.config/hypr/config/decorations.lua`, `~/.config/hypr/config/binds.lua`

## What
Global tiling layout switched from `master` to Hyprland's native `scrolling` layout —
windows sit as columns on an infinitely growing horizontal tape instead of a fixed grid,
the same tiling model niri uses. This is now a built-in Hyprland layout (`general.layout`
options: `dwindle`/`master`/`scrolling`/`monocle`), not a plugin.

## Why
Curiosity after comparing niri vs. Hyprland — wanted to try niri's scrolling-tiling model
without leaving Hyprland. There used to be a third-party plugin for this
(`hyprscroller`, via `hyprpm`) but it's now archived/abandoned precisely because Hyprland
absorbed the feature natively, which broke the plugin's compatibility. So `hyprpm` is not
involved at all here — just a `general.layout` value like `dwindle`/`master`.

## Change
`~/.config/hypr/config/decorations.lua`:
```lua
general = {
    layout = "scrolling",
    -- ...gaps, borders, colors unchanged...
},
```
No extra `scrolling = {...}` config block was added — defaults were kept as-is
(`column_width = 0.5`, `follow_focus = true`, `fullscreen_on_one_column = true`,
`direction = "right"`). Add a `hl.config({ scrolling = { ... } })` block only if a
default ever needs overriding (see the [Hyprland wiki scrolling-layout
page](https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/) for the full option
table).

`~/.config/hypr/config/binds.lua` — added right after the existing window-manipulation
binds:
```lua
-- Scrolling layout: pan the tape without changing focus, and reorder columns
hl.bind(mainMod .. " + bracketleft",          hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + bracketright",         hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + SHIFT + bracketleft",  hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.layout("swapcol r"))
```
`bracketleft`/`bracketright` were picked because `SUPER+comma`/`SUPER+period` were the
first instinct (mirroring niri conventions) but `SUPER+period` was already bound to the
Noctalia emoji launcher ([[display-mode-menu]] neighbors it — check `binds.lua` for
existing single-key binds before picking new ones).

## Notes
- **Supersedes [[master-layout]]** — that entry's `Change` section is the previous state;
  kept for history since some of its notes (stack-resize gotchas, etc.) were master-only
  and no longer apply.
- `SUPER+M` (`swapwithmaster`) is now **inert** under scrolling, same as `SUPER+CTRL+J`
  (`togglesplit`) has been inert since the dwindle→master move. Left as-is rather than
  removed or repurposed, following the same precedent.
- Generic, layout-agnostic dispatchers continue to work unchanged: `hl.dsp.focus` (vim
  hjkl / arrow keys — [[vim-navigation]]) auto-scrolls the tape to follow focus
  (`follow_focus = true` default), and the `SUPER+R` resize submap ([[resize]]) still
  resizes the active window/column.
- Not bound (available later if wanted, via `hl.dsp.layout(msg)`): `colresize` (resize
  current column, supports cycling preset widths `0.333/0.5/0.667/1.0` with `+conf`/
  `-conf`), `promote`/`expel`/`consume` (move a window into/out of its own column),
  `center`, `fit` (various fit-to-view modes). Skipped for now since the base four binds
  above cover the main new capability (pan + reorder); add more only if actually needed
  in daily use.
- `SUPER+SHIFT+R` (`reset_window_size`, in `binds.lua`) still ends with
  `hl.dsp.layout("mfact exact 0.55")`, which is a **master-only** message — now a
  silent no-op under scrolling. Not fixed since the float-toggle-twice part of that
  function (the part that actually resets a window's size) still works; only the
  master-ratio-reset tail is dead code now. Revisit if `SUPER+SHIFT+R` needs a real
  scrolling-equivalent reset (e.g. `colresize all 0.5`).
