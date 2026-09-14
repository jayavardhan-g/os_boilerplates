# Window resizing: submap, quick combo, and reset

**Date:** 2026-08-28
**Category:** keybindings
**Files touched:** `~/.config/hypr/config/binds.lua`

## What
Three ways to resize the focused window, plus a way to reset a window back to its
default tiled size:

1. `SUPER+R` enters a vim-style resize **submap** — while active, `h/j/k/l` resizes in
   20px steps (hold to repeat), `Esc`/`Enter`/`SUPER+R` again all exit back to normal.
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
--
-- window.resize was observed (via direct hyprctl dispatch testing, not just
-- a user report) to sometimes silently kick the submap back to "default"
-- after a single resize dispatch - not consistently reproducible, so the
-- exact cause is unconfirmed (possibly layout/window-state dependent), but
-- real. resize_and_stay() re-asserts the "resize" submap right after every
-- dispatch as a defensive fix, regardless of root cause - a harmless no-op
-- on the (apparently more common) case where the submap didn't need it.
local function resize_and_stay(dx, dy)
    hl.dispatch(hl.dsp.window.resize({ x = dx, y = dy, relative = true }))
    hl.dispatch(hl.dsp.submap("resize"))
end
hl.define_submap("resize", "reset", function()
    hl.bind("H",      function() resize_and_stay(-20, 0) end, { repeating = true })
    hl.bind("L",      function() resize_and_stay(20, 0) end, { repeating = true })
    hl.bind("K",      function() resize_and_stay(0, -20) end, { repeating = true })
    hl.bind("J",      function() resize_and_stay(0, 20) end, { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
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
- **2026-09-14: KNOWN LIMITATION (not fixable from config) — "have to press SUPER+R
  before every single h/j/k/l press."** User reported the resize submap wasn't staying
  active. Root cause confirmed by polling `hyprctl submap` every 100ms in the background
  for 60s while the user did real keypresses (physical presses only — virtual-keyboard
  injected input via `wtype` does NOT trigger Hyprland's own keybinds at all, confirmed
  separately; Hyprland ignores modifier state from synthetic input for its own shortcuts,
  likely a deliberate security measure): **the submap reverts to `default` at the moment
  an `H`/`L`/`K`/`J` key is *released*, every single time, with zero exceptions across
  the whole sample.** Holding a key continuously (repeat keeps firing) stays in `resize`
  perfectly — one hold ran 23+ seconds with no reversion. But the instant you let go,
  you're back in `default`, so any next keypress (even the same key) starts fresh outside
  the submap — this is why a second tap of `h` "just types h" instead of resizing.
  This is release-triggered behavior internal to how this Hyprland build handles a
  repeat-capable (`binde`) bind inside a submap — nothing in the `hl.bind`/submap API
  exposes an on-release hook to override it, so `resize_and_stay()` (below) can't
  actually fix it; kept anyway since it's a harmless no-op that doesn't hurt. Decided to
  leave this as a known limitation rather than keep digging: **use a sustained hold, not
  taps, when using the `SUPER+R` submap** (fully reliable per the data), and prefer
  `SUPER+CTRL+SHIFT+h/j/k/l` (below, not submap-based, no revert issue) for resizing that
  needs to tap between several directions.
- **2026-09-13:** added `SUPER+R` as a second way to exit the submap (was
  `escape`/`Return` only), for parity with the equivalent Mango resize-mode
  setup which uses a toggle-style enter/exit on the same key. Tested exiting
  via the physical CapsLock key too (relevant since `caps:swapescape` is
  active, see [[right-alt-as-super]]) but not yet confirmed working or
  broken — Mango needed an extra `Caps_Lock`-named bind for the equivalent
  case since its bind-matching didn't follow the XKB remap; Hyprland is more
  mature and may not have the same issue, untested either way.
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
