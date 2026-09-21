-- Hyprland default apps

TERMINAL              = "kitty"
FILE_MANAGER          = "dolphin"
BROWSER               = "app.zen_browser.zen"
--EDITOR       = "gnome-text-editor --new-window"
-- Terminal editor: SUPER+T wraps this in TERMINAL, so it must NOT be launched
-- as a bare desktop app. `uwsm app -- nvim` would start it with no terminal
-- attached and it would exit immediately with nothing visible.
EDITOR                = "nvim"
CALCULATOR            = "gnome-calculator"

-- Monitors
MONITOR1              = "eDP-1"
MONITOR2              = "HDMI-A-1"
MONITOR3              = ""
PRIMARY_MONITOR       = MONITOR1

-- Workspaces
NUM_WPM               = 3 -- Number of workspaces per monitor (Max 10)

-- Special workspace auto-launch (see config/autostart.lua)
AUTOSTART_HIDDEN_APPS = false -- launch+arrange claude/spotify/labvpn/home into the special workspace on every Hyprland start
