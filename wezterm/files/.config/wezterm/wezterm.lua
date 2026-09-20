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
