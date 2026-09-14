# Config & decisions log

See **[`KEYBINDS.md`](KEYBINDS.md)** for a single searchable list of every keybind on
this machine (Hyprland, Mango, Vim, Neovim) — that file is a live reference of *what's
currently bound*, kept in sync with the actual configs; everything else in this repo
explains *why*/*when* a decision was made.

Personal runbook of system/config decisions, split by scope:

- **[`cachyos/`](cachyos/README.md)** — anything specific to *this* CachyOS + Hyprland
  setup: window manager binds, workspace/layout behavior, input device quirks, and any
  fix that only exists because of Hyprland or this distro's packaging. Wouldn't apply if
  the window manager or distro changed.
- Everything else is a **portable, tool-specific config** — a real dotfile or setup
  decision that would work identically on any Linux box (or macOS, for some), regardless
  of window manager or distro. Each such tool gets its own top-level folder:

| Folder | What's in it |
|---|---|
| [`vim/`](vim/vimrc-minimal-visual-config.md) | `~/.vimrc` — minimal chrome, terminal-native colors |
| [`neovim/`](neovim/neovim-minimal-ssh-friendly-setup.md) | `~/.config/nvim/` setup, plus the Vim/Neovim parity pass |
| [`ssh/`](ssh/ssh-term-mismatch-fix.md) | `~/.ssh/config` fixes |
| [`vpn/`](vpn/fortinet-vpn-client.md) | Fortinet SSL-VPN client (`openfortivpn` + a fish function) |
| [`spotify/`](spotify/spotify-and-spotx.md) | Spotify (Flatpak) + SpotX ad-block patch |
| [`limine/`](limine/windows-dual-boot-order-and-bitlocker.md) | Limine bootloader — Windows dual-boot NVRAM order + BitLocker chainload fix |
| [`xpad/`](xpad/xpad-sticky-notes.md) | Xpad desktop sticky notes — install, `--no-new`/`--quit` flags, why `sticky` (x-apps) doesn't work here |
| [`noctalia/`](noctalia/theme-mode-pinned-dark.md) | Noctalia shell settings — Theme Mode pinned to Dark instead of time-of-day `Auto` |
| [`mango/`](mango/keybinds.md) | MangoWM (tried alongside Hyprland) — keybinds/appearance/input matched to the Hyprland setup, the 0.16.1→0.17.0 AUR upgrade story |

See `CLAUDE.md` for the full rules on how entries are written and — critically — how a
change gets classified into `cachyos/` vs. a tool folder, including how to split a change
that has both a portable part and a Hyprland-specific part (e.g. installing a
cross-platform tool but also wiring it into Hyprland's autostart or keybinds).

Never commit `.claude/` (session-local Claude Code settings) — see `.gitignore`.
