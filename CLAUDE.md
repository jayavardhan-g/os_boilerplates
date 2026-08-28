# Purpose of this folder

This is Jayavardhan's changelog/runbook for setting up **CachyOS** — Hyprland config, but also any other CachyOS-related system setup (VPN clients, package installs, shell tooling, anything else done while getting this machine configured). The actual record lives in `cachy-cachy-system-config/`, named for that full scope rather than just Hyprland — anything CachyOS-related belongs in this one repo/folder, not split across several. Most of what gets recorded touches files *outside* this folder (mainly `~/.config/hypr/`, but not only that).

This folder itself holds no code to run. It's a durable record so that:
- Jayavardhan can look back and remember *why* a setting is the way it is.
- If he reinstalls or sets up a new machine, he can replay some or all of these changes instead of starting from scratch.
- The whole thing can be committed to git as a personal dotfiles/decisions log.

**Don't commit `.claude/`** — it holds session-local Claude Code settings (e.g. `settings.local.json`, a permission allowlist), not part of the CachyOS setup record. Keep a `.gitignore` at the repo root with `.claude/` in it.

## What you (Claude) must do in this folder

**1. Before making changes**, skim `cachy-system-config/README.md` (the index) and the relevant category folder. If today's task modifies or extends something already recorded there, update that existing entry rather than writing a near-duplicate.

**2. Whenever a session makes an actual system/config change** — edits a file under `~/.config/hypr/` (or any other dotfile/system config), changes a setting via `hyprctl`/similar that the user wants kept, installs a package, or makes any other decision the user would want to reproduce later — record it before the conversation ends. Ephemeral diagnostics (`hyprctl getoption` to check a value, one-off `ls`/`grep` to investigate) are NOT recorded — only the actual persisted decision/change.

**Never record secrets.** This folder is meant for git, possibly a remote/shared one. Never write usernames, passwords, API keys/tokens, Wi-Fi credentials, private IPs/hostnames tied to a specific person, license keys, or any other credential into an entry — not even inside a config snippet. If a change necessarily involves one (e.g. setting up a login for some service), describe the step in words ("prompted for the account password during setup") and use a placeholder like `<password>` in any snippet, never the real value. If you're about to paste a command or config block into an entry, scan it for anything that looks like a secret first.

**3. File location and naming**: create/update a file at:

```
cachy-system-config/<category>/<kebab-case-slug>.md
```

Categories in use so far (add a new one if nothing fits — update this list when you do):
- `input/` — keyboard, mouse, touchpad, scroll behavior
- `keybindings/` — Hyprland binds, submaps, dispatchers
- `window-management/` — layouts, tiling behavior, workspaces
- `appearance/` — theming, decorations, colors
- `system/` — packages, services, anything outside `~/.config/hypr`

**4. Entry template** — use this structure for every file:

```markdown
# <Short title>

**Date:** YYYY-MM-DD
**Category:** <input|keybindings|window-management|appearance|system>
**Files touched:** `~/.config/hypr/config/whatever.lua` (or other paths)

## What
One or two sentences: what changed, in plain terms.

## Why
The actual reasoning/motivation — what problem this solved or what the user asked for.

## Change
The exact, copy-pasteable snippet(s) or commands needed to reproduce this from a fresh
config. Prefer showing the final state of the relevant block over a diff, so it can be
pasted directly into a fresh setup.

## Notes
Gotchas, conflicts with other binds/settings, things that didn't work and why, or
follow-up decisions that superseded this one (link to that file instead of duplicating).
```

**5. After writing/updating entries**, also update `cachy-system-config/README.md`'s index table (one row per entry file: title, category, one-line summary, path) so it stays a usable table of contents. Keep the README table sorted by category, then roughly chronological within category.

**6. Superseded decisions**: if a later session changes something already recorded (e.g. a keybind gets moved again), update the existing entry's `Change` section to the new final state, and add a line under `Notes` describing what it used to be and why it changed, rather than leaving stale/contradictory info across two files.

Keep entries factual and terse — this is a reference for reproducing setup, not a narrative. No need to record failed experiments unless the failure itself is the useful lesson (e.g. "X doesn't work because Y" is worth keeping so it isn't retried).
