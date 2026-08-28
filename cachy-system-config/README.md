# System config index

Reference/runbook of CachyOS + Hyprland configuration decisions. See `../CLAUDE.md` for
how this is maintained. Each row links to an entry with the full rationale and a
copy-pasteable snippet — pick and choose which ones to reapply on a fresh setup.

| Title | Category | Summary | File |
|---|---|---|---|
| Scroll direction: Windows-style per device type | input | Mouse wheel traditional, touchpad natural — matches Windows defaults for each device | [input/scroll-direction.md](input/scroll-direction.md) |
| Right Alt acts as Super | input | Swaps Right Alt ↔ Right Win via XKB so Right Alt sends Super | [input/right-alt-as-super.md](input/right-alt-as-super.md) |
| Vim-style hjkl window navigation | keybindings | SUPER+hjkl focus, SUPER+SHIFT+hjkl move window | [keybindings/vim-navigation.md](keybindings/vim-navigation.md) |
| hjkl workspace switching | keybindings | SUPER+CTRL+h/l for previous/next workspace | [keybindings/workspace-switching.md](keybindings/workspace-switching.md) |
| Window resizing: submap, quick combo, and reset | keybindings | SUPER+R resize submap, SUPER+CTRL+SHIFT+hjkl direct resize, SUPER+SHIFT+R reset | [keybindings/resize.md](keybindings/resize.md) |
| Smart special-workspace (scratchpad) toggle | keybindings | SUPER+SHIFT+S sends to special or pulls back out, context-aware | [keybindings/special-workspace-toggle.md](keybindings/special-workspace-toggle.md) |
| Finger mapping for modifier-heavy keybinds | keybindings | Which hand/finger presses what, so the vim-style binds habituate as one consistent pattern | [keybindings/finger-ergonomics.md](keybindings/finger-ergonomics.md) |
| Fortinet SSL-VPN client (openfortivpn) | system | `labvpn` fish command (start/stop/status/log) wraps openfortivpn for the lab GPU server VPN | [system/fortinet-vpn-client.md](system/fortinet-vpn-client.md) |
| Spotify (Flatpak, user-scope) + SpotX patch | system | User-scope Flatpak install (no sudo needed) patched with the official SpotX-Bash ad-block/feature script | [system/spotify-and-spotx.md](system/spotify-and-spotx.md) |
| SSH TERM mismatch fix (kitty terminfo not on remote) | system | `SetEnv TERM=xterm-256color` in `~/.ssh/config` fixes broken `clear`/`vim` over SSH from kitty | [system/ssh-term-mismatch-fix.md](system/ssh-term-mismatch-fix.md) |
| Master layout | window-management | One window takes half the screen, rest share the remainder; SUPER+M to swap master | [window-management/master-layout.md](window-management/master-layout.md) |

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
