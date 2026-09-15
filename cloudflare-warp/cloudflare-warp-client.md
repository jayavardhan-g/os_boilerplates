# Cloudflare WARP client (1.1.1.1)

**Date:** 2026-09-14
**Category:** cloudflare-warp
**Files touched:** none (no local dotfile — state lives in the package + systemd + WARP's own registration)

## What
Installed the Cloudflare WARP client (`warp-cli`/`warp-svc`, the Linux equivalent of the
"1.1.1.1" app) and connected it.

## Why
User wanted Cloudflare WARP as a VPN/DNS client.

## Change
Not in the official repos or as Flatpak — only on the AUR, and no AUR helper (`yay`/
`paru`) was installed, so built manually with `makepkg` (only needs `git` + `base-devel`,
both already present):

```bash
git clone https://aur.archlinux.org/cloudflare-warp-bin.git ~/build/cloudflare-warp-bin
cd ~/build/cloudflare-warp-bin
makepkg -si

sudo systemctl enable --now warp-svc

warp-cli registration new
warp-cli mode warp          # or "warp+doh" to also use 1.1.1.1 for DNS
warp-cli connect
warp-cli status              # should show "Connected"
```

During `makepkg -si`, pacman prompts to pick optional deps for `webkit2gtk-4.1` (a hard
dependency of this package, used only by its GUI tray app — see Notes): `geoclue`,
`gst-libav`, `gst-plugins-bad`, `gst-plugins-good`. Skipped all of them — none are needed
for `warp-cli`/`warp-svc` to work, they only matter if something renders web content or
plays media inside WebKit.

## Notes
- The package also ships a tray GUI, `warp-taskbar` (Flutter-based, not a plain script —
  that's why the package pulls in `libayatana-appindicator`/`webkit2gtk-4.1`). It's a
  separate **user** systemd service, not enabled by default install:
  `systemctl --user enable --now warp-taskbar`. Left disabled for now — CLI (`warp-cli`)
  is enough day to day.
- If the taskbar app is enabled later: Hyprland has no built-in tray, and Noctalia's own
  `tray` widget (already in the bar's `end` row per `~/.config/noctalia/config.toml`)
  only exposes styling options (`capsule`, `capsule_fill`) — no overflow/grouping, icons
  just show flat. No extra wiring needed beyond enabling the service; the icon will just
  appear alongside whatever else is in the tray.
- `Installed From: None` in `pacman -Qi` is expected for anything built locally via
  `makepkg` rather than pulled from a repo — not a sign anything went wrong.
