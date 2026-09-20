# CachyOS + Hyprland config index

Reference/runbook of decisions that are specific to *this CachyOS + Hyprland setup* —
things that wouldn't apply if you swapped window managers or distros. Portable,
tool-specific configs (Vim, Neovim, SSH, VPN client, Spotify) live in their own top-level
folders instead — see `../README.md` for the full repo map. See `../CLAUDE.md` for how
this index is maintained. Each row links to an entry with the full rationale and a
copy-pasteable snippet — pick and choose which ones to reapply on a fresh setup.

Actual copies of the real files these entries touch live under
[`files/`](files/.config/hypr/), mirroring their real path under `$HOME` (e.g.
`~/.config/hypr/config/binds.lua` → `files/.config/hypr/config/binds.lua`) — not just the
inline snippets in each entry, so a fresh machine can overlay-copy them directly.

| Title | Category | Summary | File |
|---|---|---|---|
| Tighter gaps + orange-only active border | appearance | `gaps_in`/`gaps_out` reduced; only the focused window shows a border (orange-to-transparent gradient), unfocused windows borderless | [appearance/window-decorations.md](appearance/window-decorations.md) |
| Mango cursor theme matched to Hyprland's | appearance | Mango shipped with the stock `capitaine-cursors` default; switched to `Bibata-Modern-Ice` size 24 to match Hyprland's real cursor (`~/.config/uwsm/env`) | [appearance/mango-cursor-theme.md](appearance/mango-cursor-theme.md) |
| Scroll direction: Windows-style per device type | input | Mouse wheel traditional, touchpad natural — matches Windows defaults for each device | [input/scroll-direction.md](input/scroll-direction.md) |
| Right Alt acts as Super | input | Swaps Right Alt ↔ Right Win via XKB so Right Alt sends Super | [input/right-alt-as-super.md](input/right-alt-as-super.md) |
| Vim-style hjkl window navigation | keybindings | SUPER+hjkl focus, SUPER+SHIFT+hjkl move window | [keybindings/vim-navigation.md](keybindings/vim-navigation.md) |
| hjkl workspace switching | keybindings | SUPER+CTRL+h/l for previous/next workspace | [keybindings/workspace-switching.md](keybindings/workspace-switching.md) |
| Window resizing: submap, quick combo, and reset | keybindings | SUPER+R resize submap, SUPER+CTRL+SHIFT+hjkl direct resize, SUPER+SHIFT+R reset | [keybindings/resize.md](keybindings/resize.md) |
| Smart special-workspace (scratchpad) toggle | keybindings | SUPER+SHIFT+S sends to special or pulls back out, context-aware | [keybindings/special-workspace-toggle.md](keybindings/special-workspace-toggle.md) |
| Finger mapping for modifier-heavy keybinds | keybindings | Which hand/finger presses what, so the vim-style binds habituate as one consistent pattern | [keybindings/finger-ergonomics.md](keybindings/finger-ergonomics.md) |
| Float toggle rebind: SUPER+ALT+Space → SUPER+SHIFT+F | keybindings | Original combo needed two thumb-modifiers plus a thumb-region key (Space); moved to a clean 3-finger chord | [keybindings/float-toggle.md](keybindings/float-toggle.md) |
| Freed bare middle-click from Mango's fullscreen toggle | keybindings | Removed Mango's unmodified `btn_middle` → `togglemaximizescreen` bind, which stole middle-click from apps (e.g. browser); `SUPER+D` still does the same toggle | [keybindings/mango-middle-click-freed.md](keybindings/mango-middle-click-freed.md) |
| Noctalia greeter-sync password prompt | system | Disabled `greeter_sync.auto_sync` to stop the password popup on every wallpaper/settings change (a scoped polkit rule isn't feasible — run0 uses random transient unit names) | [system/noctalia-greeter-sync-password-prompt.md](system/noctalia-greeter-sync-password-prompt.md) |
| Noctalia shell chrome shifting to light mode | system | Pinned `theme.shell_mode` (separate from `theme.mode`, wasn't in config.toml at all and had drifted to "follow") to `"dark"` — the bar/panels flipping light while apps stayed dark | [system/noctalia-shell-mode-vs-theme-mode.md](system/noctalia-shell-mode-vs-theme-mode.md) |
| VSCode (official Microsoft build) + keyring | system | `visual-studio-code-bin` via AUR (needed for Remote-SSH/Marketplace) + gnome-keyring so Settings Sync works under Hyprland — kept here (not in a global vscode/ folder) since the actual problem and fix only exist because Hyprland isn't a Chromium-recognized desktop environment | [system/vscode-official-build.md](system/vscode-official-build.md) |
| Disable focus-follows-mouse (sloppyfocus) | window-management | Mango's dwm-family default steals focus just from moving the pointer over a window; switched to click-to-focus | [window-management/disable-focus-follows-mouse.md](window-management/disable-focus-follows-mouse.md) |
| Master layout | window-management | One window takes half the screen, rest share the remainder; SUPER+M to swap master | [window-management/master-layout.md](window-management/master-layout.md) |
| Auto-relaunch apps into the special workspace on every start | window-management | Spotify + 3 kitty terminals (claude, labvpn, home) autostart and route straight into the hidden scratchpad workspace | [window-management/persistent-special-workspace-apps.md](window-management/persistent-special-workspace-apps.md) |
| Xpad notes pinned to a monitor-aware workspace 7 | window-management | Workspace 7 follows the external monitor when connected, falls back to the laptop otherwise; notes float unpinned-to-center, survive reboot, and stay put through monitor reconnects | [window-management/xpad-workspace-and-monitor-persistence.md](window-management/xpad-workspace-and-monitor-persistence.md) |

## Quick setup from scratch

To reproduce all of the above on a fresh CachyOS + Hyprland (noctalia) install:
1. Copy the `input = {...}` block from `input/scroll-direction.md` and
   `input/right-alt-as-super.md` into `~/.config/hypr/config/inputs.lua`.
2. Copy the `general = { layout = "master" }` line from `window-management/master-layout.md`
   into `~/.config/hypr/config/decorations.lua`.
3. Copy all the `hl.bind(...)` snippets from the `keybindings/` entries into
   `~/.config/hypr/config/binds.lua`, watching for the modifier-relocation notes in each
   file (some binds moved keys to avoid collisions with the vim hjkl binds).
4. `hyprctl reload` (or just save — Hyprland's Lua config auto-reloads on file change).

To reapply only some of these, just copy the individual entries you want — they're
independent of each other except where a "Notes" section says otherwise.
