# Wezterm terminal setup

**Date:** 2026-09-20
**Category:** wezterm
**Files touched:** `~/.config/wezterm/wezterm.lua`

## What
Installed Wezterm (`pacman -S wezterm`, official `extra` repo — no AUR helper needed) and
wrote a minimal `wezterm.lua` mirroring the current Kitty config's font/opacity/padding, to
trial it as a possible replacement for Kitty.

## Why
Comparing Kitty vs Wezterm as the daily-driver terminal. Wezterm's draw is Lua
scriptability and a strong built-in multiplexer; trying it side-by-side with Kitty before
committing to a switch. See [[wezterm-noctalia-theme-template]] for the Hyprland/Noctalia
shell-specific wiring (theme integration + trial keybind) that goes with this.

## Change
```bash
sudo pacman -S wezterm
```

`~/.config/wezterm/wezterm.lua`:
```lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font 'MesloLGS Nerd Font Mono'
config.window_background_opacity = 0.6
config.window_padding = {
  left = 25,
  right = 25,
  top = 25,
  bottom = 25,
}

config.color_scheme = "Noctalia"
return config
```

Stored copy: [files/.config/wezterm/wezterm.lua](files/.config/wezterm/wezterm.lua).

## Notes
- Matches Kitty's `~/.config/kitty/kitty.conf`: `MesloLGS Nerd Font Mono`,
  `background_opacity 0.6`, `window_padding_width 25`. Kitty's `cursor_trail 1` has no
  direct Wezterm equivalent — skipped.
- The `config.color_scheme = "Noctalia"` line and the `~/.config/wezterm/colors/
  Noctalia.toml` file it references come from the Noctalia shell integration, not from
  this file directly — see [[wezterm-noctalia-theme-template]] in `cachyos/appearance/`
  for that wiring (including a rendering bug in Noctalia's Wezterm template that required
  a manual workaround).
- Not yet decided whether this replaces Kitty as the default terminal — currently bound to
  `SUPER+SHIFT+Return` as a trial bind alongside Kitty's `SUPER+Return`.
