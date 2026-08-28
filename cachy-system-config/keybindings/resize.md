# Window resizing: submap, quick combo, and reset

**Date:** 2026-08-28
**Category:** keybindings
**Files touched:** `~/.config/hypr/config/binds.lua`

## What
Three ways to resize the focused window, plus a way to reset a window back to its
default tiled size:

1. `SUPER+R` enters a vim-style resize **submap** — while active, `h/j/k/l` resizes in
   20px steps (hold to repeat), `Esc`/`Enter` exits back to normal.
2. `SUPER+CTRL+SHIFT+h/j/k/l` resizes directly in 40px steps (hold to repeat) — no mode
   to enter/exit, for quick one-off resizes.
3. `SUPER+SHIFT+R` resets the focused window's size back to its default tiled share, and
   resets the master/stack ratio back to Hyprland's default (`0.55`).

## Why
User wanted vim-key resizing. The submap alone needed 3 modifiers + hold to exit each
time for a single quick resize, so a direct-hold alternative was added too. The reset
bind was added after manual resize testing left two windows uneven — see Notes.

## Change
```lua
-- Submap: SUPER+R to enter, hjkl to resize, Esc/Enter to exit
hl.define_submap("resize", "reset", function()
    hl.bind("H",      hl.dsp.window.resize({ x = -20, y = 0,  relative = true }), { repeating = true })
    hl.bind("L",      hl.dsp.window.resize({ x = 20,  y = 0,  relative = true }), { repeating = true })
    hl.bind("K",      hl.dsp.window.resize({ x = 0,   y = -20, relative = true }), { repeating = true })
    hl.bind("J",      hl.dsp.window.resize({ x = 0,   y = 20, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

-- Direct resize, no submap
hl.bind(mainMod .. " + CONTROL + SHIFT + H", hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + SHIFT + L", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + SHIFT + K", hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + SHIFT + J", hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

-- Reset focused window's size + master ratio
local function reset_window_size()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.layout("mfact exact 0.55"))
end
hl.bind(mainMod .. " + SHIFT + R", reset_window_size)
```

## Notes
- **API detail:** a dispatcher built inside a custom Lua function (as opposed to passed
  directly as `hl.bind`'s second argument) must be wrapped in `hl.dispatch(...)` to
  actually fire — `hl.dsp.window.move({...})` alone just constructs the dispatcher object,
  it doesn't run it.
- **How the reset works:** toggling a tiled window to floating and back reinserts it into
  the layout tree, which forces Hyprland to recompute sizes for the *whole* tiling tree on
  that workspace — so resetting one window's focus is enough to fix every window's size on
  that workspace, not just the focused one. Verified live: two windows drifted to
  `805px`/`765px` from manual testing, one `SUPER+SHIFT+R` press brought both back to the
  correct default `864px`/`706px` split.
- `mfact exact 0.55` is Hyprland's compiled-in default master ratio — confirmed via
  `hyprctl getoption master:mfact`.
- **Known quirk (2026-08-29): grow/shrink is asymmetric for the last window in a stack.**
  Under [[master-layout]], a stack window's height is a shared boundary with its neighbor,
  not an independent size. For the **bottom-most** window in a vertical stack (nothing
  below it but the screen/dock edge):
  - `K` (shrink, `y = -40`) always works — it just reduces that window's own share, and the
    freed space goes to the window above. This is why shrinking the bottom window visibly
    *grows the window above it* — expected, not a bug.
  - `J` (grow, `y = +40`) does **nothing** — growing requires physical room to expand into,
    and the bottom-most window has none below it (screen/reserved-dock edge). There's no
    window below to take space from, so the grow is a dead end.
  - **Workaround:** to make the bottom window bigger, focus the window *above* it instead
    and shrink that one with `K` — shrinking a neighbor is always well-defined, unlike
    growing into empty space. Dragging the shared border directly with
    `SUPER + right-click drag` also works in both directions, since it manipulates the
    boundary itself rather than issuing a directional grow/shrink command.
  - This is inherent to how tiling-window resize works (a shared-boundary operation), not
    something fixable by remapping keys — the same asymmetry would apply to whichever key
    means "grow" for the edge-most window in any stack.
- See [[finger-ergonomics]] for the recommended fingering on the submap and direct-resize
  binds.
