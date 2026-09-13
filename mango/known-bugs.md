# Known bug: moving a window onto a monitor with a fullscreen client leaves focus stuck

**Date:** 2026-09-14
**Category:** mango (upstream bug, not a config issue)
**Version confirmed on:** 0.17.0 (also present, unfixed, on the `main` branch as of this date)

## What
Moving a window from one monitor to another (`tagmon`, see [[keybinds]]) while
the destination monitor has an active **fullscreen** client causes keyboard
focus to get stuck on neither the moved window nor the fullscreen one.
`SUPER+D`, unfullscreen, and any other focus-dependent action stop working
until the fullscreen window is manually re-focused with a mouse click.

## Why it happens
Confirmed directly in `src/dispatch/bind.c`, `tag_monitor()` (same in the
0.17.0 tag and the current `main` branch — genuinely unfixed upstream, not
something an upgrade would resolve):

```c
client_set_monitor(c, m, newtags, true);   // internally re-focuses using
                                            // server.selected_monitor, which
                                            // is STILL the OLD/source
                                            // monitor at this point
...
server.selected_monitor = c->mon;          // updated too late - after the
                                            // focus-restore call above
...
if (c->isfloating) {                       // explicit re-focus only exists
    ...                                     // for FLOATING windows
    client_focus(c, 1);
}
```
For a normal **tiled** window (the common case), there's no equivalent
explicit re-focus step at all once `selected_monitor` is finally corrected —
the only focus assignment that happened targeted the wrong (source) monitor.

## Why the obvious fix doesn't work
A same-monitor `focusmon` call right after `tagmon` (to force a correct
re-focus) doesn't help either — `focus_monitor()` early-returns if the
target is already `server.selected_monitor`, which `tag_monitor()` has
already (incorrectly, per above) set to the destination by the time such a
follow-up call would run.

## What would fix it (not implemented)
A "bounce" workaround is possible in principle — `tagmon` to the
destination, then `focusmon` to the *source* (forces a real switch, which
does correctly refocus), then `focusmon` back to the destination (now a real
switch again, correctly refocuses there) — chained via a spawned shell
script calling `mmsg dispatch` three times instead of a single clean bind.
**Not implemented**: `warpcursor` is on by default, so this would make the
mouse cursor visibly jump to the other monitor and back on every
cross-monitor window move, not just the ones that hit this bug. Decided the
side effect wasn't worth it for an edge case (fullscreen + cross-monitor
move at the same time) - just click the fullscreen window to refocus it
manually when this happens.

## Notes
- No GitHub milestones or roadmap exist for this project (checked
  `/repos/mangowm/mango/milestones` and the README) - no way to know if or
  when this gets fixed upstream. Worth re-checking release notes
  (`https://github.com/mangowm/mango/releases`) after future updates.
- This is unrelated to the [[version-bug-upgrade]] issues (those were
  missing-feature/stale-behavior bugs fixed by upgrading past 0.16.1) - this
  one is a genuine, currently-live logic bug in the latest code.
