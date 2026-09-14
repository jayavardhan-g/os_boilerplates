# CachyOS + Hyprland config index

Reference/runbook of decisions that are specific to *this CachyOS + Hyprland setup* —
things that wouldn't apply if you swapped window managers or distros. Portable,
tool-specific configs (Vim, Neovim, SSH, VPN client, Spotify) live in their own top-level
folders instead — see `../README.md` for the full repo map. See `../CLAUDE.md` for how
this index is maintained. Each row links to an entry with the full rationale and a
copy-pasteable snippet — pick and choose which ones to reapply on a fresh setup.

| Title | Category | Summary | File |
|---|---|---|---|
| Tighter gaps + orange-only active border | appearance | `gaps_in`/`gaps_out` reduced; only the focused window shows a border (orange-to-transparent gradient), unfocused windows borderless | [appearance/window-decorations.md](appearance/window-decorations.md) |
| Mango blur/opacity exactly mirrored to Hyprland's real values | appearance | focused/unfocused_opacity, blur passes/radius/brightness/contrast/noise matched to hyprctl-queried Hyprland defaults; no Mango equivalent for fullscreen_opacity/dim_special/blur.special/vibrancy | [appearance/mango-unfocused-opacity.md](appearance/mango-unfocused-opacity.md) |
| Scroll direction: Windows-style per device type | input | Mouse wheel traditional, touchpad natural — matches Windows defaults for each device | [input/scroll-direction.md](input/scroll-direction.md) |
| Right Alt acts as Super | input | Swaps Right Alt ↔ Right Win via XKB so Right Alt sends Super | [input/right-alt-as-super.md](input/right-alt-as-super.md) |
| Vim-style hjkl window navigation | keybindings | SUPER+hjkl focus, SUPER+SHIFT+hjkl move window | [keybindings/vim-navigation.md](keybindings/vim-navigation.md) |
| hjkl workspace switching | keybindings | SUPER+CTRL+h/l for previous/next workspace | [keybindings/workspace-switching.md](keybindings/workspace-switching.md) |
| Bare SUPER+num for workspaces, SUPER+bracket for monitors | keybindings | SUPER+1-6/SHIFT+1-6 = switch/send-to workspace by number; SUPER+[/] and SHIFT+[/] = focus/send-to monitor (matches the MangoWM trial scheme) | [keybindings/absolute-workspace-and-monitor-binds.md](keybindings/absolute-workspace-and-monitor-binds.md) |
| SUPER+N cycles layout engine | keybindings | Cycles `general:layout` live between master/dwindle/scrolling; discovered this Hyprland build has a built-in scrolling layout, never previously enabled | [keybindings/layout-cycle.md](keybindings/layout-cycle.md) |
| Window resizing: submap, quick combo, and reset | keybindings | SUPER+R resize submap, SUPER+CTRL+SHIFT+hjkl direct resize, SUPER+SHIFT+R reset | [keybindings/resize.md](keybindings/resize.md) |
| Smart special-workspace (scratchpad) toggle | keybindings | SUPER+SHIFT+S sends to special or pulls back out, context-aware | [keybindings/special-workspace-toggle.md](keybindings/special-workspace-toggle.md) |
| Finger mapping for modifier-heavy keybinds | keybindings | Which hand/finger presses what, so the vim-style binds habituate as one consistent pattern | [keybindings/finger-ergonomics.md](keybindings/finger-ergonomics.md) |
| Float toggle rebind: SUPER+ALT+Space → SUPER+SHIFT+F | keybindings | Original combo needed two thumb-modifiers plus a thumb-region key (Space); moved to a clean 3-finger chord | [keybindings/float-toggle.md](keybindings/float-toggle.md) |
| Windows-style display mode menu: SUPER+P | keybindings | fuzzel popup for Extend/Duplicate/PC-only/Second-only via `hl.monitor()` + `hyprctl eval`; bumped hyprpicker to SUPER+SHIFT+P to free the key | [keybindings/display-mode-menu.md](keybindings/display-mode-menu.md) |
| Screenshot keys: Print, SUPER+Print, F6 | keybindings | Print = full screen, SUPER+Print/F6 = region; Fn+F6 is a separate firmware macro, not the F6 key | [keybindings/screenshot-keys.md](keybindings/screenshot-keys.md) |
| Noctalia greeter-sync password prompt (unresolved) | system | Why the password popup on every settings change can't easily be fixed via a scoped polkit rule (run0 uses random transient unit names) | [system/noctalia-greeter-sync-password-prompt.md](system/noctalia-greeter-sync-password-prompt.md) |
| VSCode (official Microsoft build) + keyring | system | `visual-studio-code-bin` via AUR (needed for Remote-SSH/Marketplace) + gnome-keyring so Settings Sync works under Hyprland — kept here (not in a global vscode/ folder) since the actual problem and fix only exist because Hyprland isn't a Chromium-recognized desktop environment | [system/vscode-official-build.md](system/vscode-official-build.md) |
| pacman autoremove took out uwsm, broke uwsm-managed Hyprland login | system | `uwsm` is only referenced by a `.desktop` Exec= line, not any package's deps, so pacman's orphan detector doesn't see it as load-bearing; reinstall via `sudo pacman -S uwsm` | [system/uwsm-orphan-autoremove-breaks-login.md](system/uwsm-orphan-autoremove-breaks-login.md) |
| Installing cachyos-mango-noctalia alongside cachyos-hypr-noctalia | system | Conflict is intentional (remove the old one, safe — nothing Hyprland-owned is touched); `/etc/skel`-only packaging gotcha needs a manual `cp` into `~/.config/mango` on an existing account | [system/cachyos-mango-noctalia-setup.md](system/cachyos-mango-noctalia-setup.md) |
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
