# Trying niri as a third session (alongside Hyprland and Mango)

**Date:** 2026-09-23
**Category:** system
**Files touched:** `~/.config/niri/config.kdl` (new)

## What
Installed niri (scrollable-tiling Wayland compositor) plus `xwayland-satellite`, and wrote
a starter config that ports the existing Hyprland/Mango setup, so niri can be picked as a
separate session at the Noctalia greeter login screen. Hyprland stays the default; nothing
in the Hyprland or Mango configs was touched.

## Why
Already using scrolling layouts on both Mango (tags 1/3/4) and Hyprland, which is niri's
entire model. niri also has a built-in Overview (zoomed-out workspaces with live windows)
— the closest thing to the "Alt+Tab with real window previews" that isn't available on
Hyprland without building a custom tool (see the switcher research on 2026-09-23:
Noctalia's switcher, hyprshell and hyprswitch all show icons only).

## Change
```bash
sudo pacman -S niri xwayland-satellite    # niri 26.04, xwayland-satellite 0.8.2
```
Then log out and pick **niri** at the greeter (the package installs
`/usr/share/wayland-sessions/niri.desktop`, which runs `niri-session`).

Full config: [files/.config/niri/config.kdl](../files/.config/niri/config.kdl). Checked
with `niri validate`. What it carries over:
- Keyboard `caps:swapescape,altwin:swap_ralt_rwin`; flat mouse accel; mouse wheel
  traditional, touchpad natural + tap.
- `focus-follows-mouse` on (matches Hyprland `follow_mouse = 1`).
- Outputs: eDP-1 1920x1080@144 scale 1.2 at 0,0; HDMI-A-1 1920x1080@60 at x=1600
  (1920/1.2 = 1600, directly adjacent — Hyprland has 1650, a 50px gap).
- Look: gaps 4, orange→transparent focus ring on the focused window only, rounding 10,
  opacity 0.95 active / 0.90 inactive, 1.0 for media players and terminals,
  Bibata-Modern-Ice cursor.
- Startup: stale-Claude-daemon cleanup, dbus env, gnome-keyring, Noctalia, and the
  limine snapshot-restore notice (same set as Hyprland's `autostart.lua`).
- Binds: the Hyprland/Mango set where niri has an equivalent (apps, Noctalia panels,
  hjkl/arrow focus and move, 1–7 workspaces, `[`/`]` monitors, media keys, screenshots).
  `Mod+Tab` = Noctalia switcher (Hyprland's mapping), `Alt+Tab` = niri overview (Mango's
  overview mapping), `Mod+Shift+V` = jump between floating and tiled windows (niri
  default), `Mod+Shift+/` = niri's keybind cheat sheet, `Ctrl+Alt+Delete` = log out.

## Notes
- **Watch the NVIDIA side first.** HDMI-A-1 is hardwired to the GTX 1660 Ti; that's what
  broke Mango (compositor thread busy-looping in `libnvidia-eglcore`, and some boots
  missing one monitor — see [[mango-nvidia-cpu-spin-switched-to-hyprland]]). niri is
  Smithay-based, not wlroots, so it may not have the same bug, but check CPU/temps and
  that both monitors come up. If it busy-loops, the likely fix is pinning niri's render
  device to the Intel GPU (`debug { render-drm-device "/dev/dri/by-path/pci-...-render" }`
  — use `by-path`, since `/dev/dri/card*` numbering swaps between boots).
- Not ported (no niri equivalent): the special workspace / hidden autostart apps
  (claude, Spotify, labvpn, home), `SUPER+R` resize submap, master layout and
  `SUPER+M` swap-with-master, `SUPER+P` display-mode script, gap toggles.
- The physical Print key only ever sends a key *release* (Mango needed `bindr`); niri
  binds fire on press, so `Print` may do nothing. `F6` (region) and `Mod+Shift+P`
  (fullscreen) cover screenshots.
- niri stacks workspaces vertically per monitor, so "previous/next workspace"
  (`Mod+Ctrl+H/L`) maps to up/down.
- niri reloads `config.kdl` automatically on save — no reload bind needed.
