# Wezterm: Noctalia theme template + trial keybind

**Date:** 2026-09-20
**Category:** appearance
**Files touched:** `~/.config/noctalia/config.toml`, `~/.config/mango/cfg/keybinds.conf`,
`~/.config/wezterm/colors/Noctalia.toml`

## What
Enabled Noctalia's built-in Wezterm theme template (so Wezterm re-colors along with every
other themed app on wallpaper/theme change) and added a trial keybind
(`SUPER+SHIFT, Return`) to launch Wezterm alongside Kitty's existing `SUPER, Return` bind,
without replacing the default terminal.

## Why
Trialing Wezterm as a possible Kitty replacement (see [[wezterm-terminal-setup]] for the
portable install/config). This half is Hyprland/Mango/Noctalia-shell-specific: the
`[theme.templates]` toggle only exists because this machine runs the Noctalia
quickshell-based shell, and the keybind lives in Mango's own `keybinds.conf` (this system
currently runs Mango, not Hyprland, as the actual compositor — Hyprland's
`~/.config/hypr/config/binds.lua` still has `TERMINAL = "kitty"` but is not the active
compositor's bind source; `~/.config/mango/cfg/keybinds.conf` is).

## Change
`~/.config/noctalia/config.toml`, `[theme.templates]` block:
```toml
    [theme.templates]
    builtin_ids = [ "btop", "gtk3", "gtk4", "kcolorscheme", "kitty", "qt", "alacritty", "wezterm" ]
```

`~/.config/mango/cfg/keybinds.conf`, "Your favorite applications" section:
```
bind = SUPER, Return, spawn, kitty 
# Trying wezterm as a possible replacement for kitty - trial bind, remove
# once decided (see configs/wezterm/wezterm-terminal-setup.md).
bind = SUPER+SHIFT, Return, spawn, wezterm
```

After editing `config.toml`, the running Noctalia daemon must be restarted for it to
re-read `builtin_ids` (a plain `noctalia msg config-reload` was NOT enough — see Notes),
then re-apply templates:
```bash
pkill -x noctalia
nohup noctalia >/tmp/noctalia.log 2>&1 & disown
noctalia msg templates-apply
```
Reload Mango's keybinds with `SUPER+F5` (bound to `reload_config`).

Stored copies:
[files/.config/noctalia/config.toml](../files/.config/noctalia/config.toml),
[files/.config/mango/cfg/keybinds.conf](../files/.config/mango/cfg/keybinds.conf),
[files/.config/wezterm/colors/Noctalia.toml](../files/.config/wezterm/colors/Noctalia.toml).

## Notes
- **Noctalia silently skips a template if the target app isn't installed.** Its binary
  contains the literal message `"skipping template {} -> {} (client not installed)"`. So
  adding `"wezterm"` to `builtin_ids` and running `templates-apply` does nothing — no log
  output at all, even at debug log level — until Wezterm is actually installed via
  `pacman`. Don't waste time debugging "template not applying" without checking `which
  <app>` first.
- `noctalia msg config-reload` did NOT pick up the new `builtin_ids` entry even though it
  did trigger a visible internal config re-parse (bar/idle-behavior counts re-logged).
  Only a full daemon restart (`pkill -x noctalia` + relaunch, matching the `exec-once =
  noctalia &` autostart line in `~/.config/mango/cfg/autostart.conf`) made the new
  template id take effect. Kitty/Alacritty's already-enabled templates DID get touched by
  `config-reload` + `templates-apply` — only a newly-added `builtin_ids` entry needs the
  restart.
- **The `wezterm.lua` half of Noctalia's template (inserting `config.color_scheme =
  "Noctalia"`) applied fine via its `apply.sh` hook, but the actual color rendering
  (`wezterm.toml` → `~/.config/wezterm/colors/Noctalia.toml`) never fired** — not even
  after installing Wezterm and a second full daemon restart, with no error at any log
  level. Kitty/Alacritty's templates (using the same underlying palette tokens) rendered
  correctly throughout, so this looks specific to the Wezterm template in this Noctalia
  build (`noctalia`/`noctalia-greeter` packages, checked 2026-09-20). Worked around by
  hand-deriving `colors/Noctalia.toml` from the already-correctly-rendered
  `~/.config/alacritty/themes/noctalia.toml` and `~/.config/kitty/themes/noctalia.conf`
  (same M3 palette tokens, just different file syntax — see
  `/usr/share/noctalia/assets/templates/wezterm/wezterm.toml` for the exact token→field
  mapping used). **If a future Noctalia update fixes the auto-render, running `noctalia
  msg templates-apply` again will simply overwrite this hand-built file with a real one —
  safe to just try that first before repeating the manual derivation.**
