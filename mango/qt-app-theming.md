# Qt apps (Dolphin) not picking up the dark theme

**Date:** 2026-09-14
**Category:** mango
**Files touched:** `~/.config/mango/cfg/env.conf`

## What
Dolphin (and any other Qt6 app) now renders with the dark "noctalia" color scheme and
breeze icons instead of the default light/unthemed Fusion look.

## Why
`qt6ct` was already fully configured (`~/.config/qt6ct/qt6ct.conf` — `style=Fusion`,
`color_scheme_path=.../colors/noctalia.conf`, `icon_theme=breeze`) but never actually
activated: Qt only consults `qt6ct` when `QT_QPA_PLATFORMTHEME` tells it to, and that
line was present in `env.conf` but commented out. GTK apps were unaffected since they
theme separately via `~/.config/gtk-3.0/settings.ini` (`adw-gtk3-dark`, already working).
Confirmed Dolphin links Qt6 specifically (`ldd /usr/bin/dolphin`), so the `_QT6` variant
of the variable matters here, not `QT_QPA_PLATFORMTHEME_QT5`.

## Change

`~/.config/mango/cfg/env.conf`:
```
env = QT_QPA_PLATFORMTHEME,qt6ct
env = QT_QPA_PLATFORMTHEME_QT6,qt6ct
```
(previously present but commented out)

## Notes
- **`env =` directives only apply at Mango's actual startup, not on `reload_config`** —
  confirmed live: after uncommenting and reloading, a freshly-launched Dolphin still had
  no `QT_QPA_PLATFORMTHEME` in its `/proc/<pid>/environ`. Verified the fix itself was
  correct by launching Dolphin with the same variables set directly in the shell instead
  (visually confirmed working, dark theme applied) before concluding a full Mango
  restart is needed to pick this up for real — not yet done as of this entry, do on next
  convenient restart.
- If a Qt5 app ever shows the same problem, add `env = QT_QPA_PLATFORMTHEME_QT5,qt6ct`
  too — a `qt5ct` color config already exists at `~/.config/qt5ct/colors/noctalia.conf`
  but no `qt5ct.conf` itself, so that path isn't fully wired up yet.
