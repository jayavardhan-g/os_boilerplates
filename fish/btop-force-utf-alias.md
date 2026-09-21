# btop --force-utf alias (and: the login shell here is fish, not bash/zsh)

**Date:** 2026-09-21
**Category:** fish
**Files touched:** `~/.config/fish/config.fish` (stored at [`files/.config/fish/config.fish`](files/.config/fish/config.fish)), plus one-line appends to `~/.zshrc` and `~/.bashrc`

## What
Aliased `btop` to `btop --force-utf` in `~/.config/fish/config.fish`, the config of the
shell this machine actually logs into. The same one-liner was appended to `~/.zshrc` and
`~/.bashrc` so the alias holds in whichever shell a terminal ends up in.

## Why
`btop` auto-detects the UTF locale and falls back to ASCII box-drawing when detection
fails, which makes the graphs look broken; `--force-utf` overrides that detection.

The alias appeared not to work for a while, for two separate reasons worth recording:

1. **The login shell here is fish, not bash or zsh.** `getent passwd jayavardhan` ends in
   `/bin/fish`, and every live shell under kitty is `/bin/fish`. So editing `~/.bashrc` or
   `~/.zshrc` changed a file the terminal never reads. (Note `$SHELL` can still report
   `/usr/bin/zsh` in some spawned environments — `getent passwd` and `ps` are the reliable
   check, not `$SHELL`.)
2. **`source ~/.bashrc` / `source ~/.zshrc` from inside fish always errors.** fish parses
   the file as fish, so bash/zsh-only syntax (`[[ $- != *i* ]] && return`, backtick
   command substitution like ``alias ninja="ninja -j`nproc`"``) is a syntax error. The
   errors meant "wrong interpreter", not "the file is broken".

## Change
`~/.config/fish/config.fish` — final state:
```fish
source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# Custom aliases
alias btop="btop --force-utf"
```

Secondary, appended after the existing `source` line in each (no separate folder — these
are one-line additions, the real artifact is `config.fish` above):
```zsh
# ~/.zshrc
alias btop="btop --force-utf"
```
```bash
# ~/.bashrc
alias btop='btop --force-utf'
```

Verify without opening a new terminal:
```bash
fish -l -c 'type btop'
zsh  -i -c 'alias btop'
bash -i -c 'alias btop'
```

## Notes
- **The alias must go in `~/.config/fish/config.fish`, not in
  `/usr/share/cachyos-fish-config/cachyos-config.fish`** — that one is root-owned and
  pacman-managed, so edits are silently reverted on the next package update. Same trap on
  the zsh side; see [[cachyos-shell-configs-are-package-owned]].
- fish's `alias` builtin is **not** self-recursive here: `alias btop="btop --force-utf"`
  expands to `function btop; command btop --force-utf $argv; end`. The `command` prefix is
  inserted automatically, so no infinite loop and no need to write the function by hand.
- Placement matters: the alias is appended *after* `source ...cachyos-config.fish`, so it
  wins over anything the CachyOS config defines. (It currently defines no `btop` alias,
  but the ordering is what keeps that true.)
- The alias lines are deliberately duplicated across three rc files rather than factored
  into a shared file — each shell has different syntax rules and the payload is one line.
- The existing fish function for the lab VPN lives in `vpn/`, not here — see
  [[fortinet-vpn-client]]. This folder is for fish's own shell config.
