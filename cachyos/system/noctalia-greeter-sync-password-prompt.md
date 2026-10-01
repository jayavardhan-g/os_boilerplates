# Noctalia greeter-sync password prompt

**Date:** 2026-08-29 (resolved 2026-09-13, reworked 2026-10-01)
**Category:** system
**Files touched:** `~/.config/noctalia/config.toml` (stored: [files/.config/noctalia/config.toml](../files/.config/noctalia/config.toml)), `~/.config/hypr/scripts/greeter-sync-on-wallpaper.sh` (stored: [files/.config/hypr/scripts/greeter-sync-on-wallpaper.sh](../files/.config/hypr/scripts/greeter-sync-on-wallpaper.sh))

## What
Syncing Noctalia's appearance to the login/lock-screen greeter needs the admin
password every time. Noctalia's built-in `auto_sync` stays **off**; instead a
`wallpaper_changed` hook syncs the greeter after a **manual** wallpaper change (one
password prompt per change), and does nothing while automatic wallpaper rotation is on.

## Why
`auto_sync` syncs on every wallpaper/colors/theme/font change. With 30-min wallpaper
rotation that meant a password prompt every 30 minutes, so it was turned off — but then
the greeter never followed hand-picked wallpapers either. Jayavardhan's rule: rotation on
→ never sync; rotation off → sync on wallpaper change, asking for the password is fine.
Noctalia has no such option, so it's done with a hook.

## How the sync elevates (as of noctalia 5.2.0 / noctalia-greeter 1.5.0)
`pkexec /usr/bin/noctalia-greeter-apply-appearance --sync /run/user/1000/noctalia-greeter-sync`
under its own polkit action `org.noctalia.greeter.sync-appearance`
(`/usr/share/polkit-1/actions/org.noctalia.greeter.apply-appearance.policy`, default
`auth_admin`). Confirmed 2026-10-01 from the journal + Noctalia log on a real
`noctalia msg greeter-sync`.

## Change
`~/.config/noctalia/config.toml`:
```toml
[hooks]
wallpaper_changed = [ "$HOME/.config/hypr/scripts/greeter-sync-on-wallpaper.sh" ]

[shell]
    [shell.greeter_sync]
    auto_sync = false
```

`~/.config/hypr/scripts/greeter-sync-on-wallpaper.sh` (executable) — see the stored copy
for the full commented version. Logic:
1. `flock -n` on `$XDG_RUNTIME_DIR/greeter-sync-on-wallpaper.lock` — the hook fires
   **once per monitor**, so only the first call proceeds.
2. `sleep 3` — lets both monitors' events and the wallpaper-derived palette settle.
3. Read `noctalia config export` (config.toml + Settings-UI settings.toml merged) with
   Python `tomllib`: exit if `wallpaper.automation.enabled` is true.
4. Exit if the default + per-monitor wallpaper paths equal those recorded at the last
   sync (`~/.local/state/noctalia/greeter-sync-last-wallpaper`).
5. `noctalia msg greeter-sync` (password prompt), then record the current paths.

## Notes
- **Verified 2026-10-01:** with rotation temporarily on, switching wallpaper fired the
  hook (lock file created → `$HOME` in the hook command is expanded by a shell) and
  produced no prompt. The manual-change path (prompt once, greeter updated) is the part
  to watch on first real use.
- Re-setting the *same* wallpaper (`noctalia msg wallpaper-set <current path>`) does not
  fire `wallpaper_changed`.
- Step 4 exists so a hook event that isn't a real change (e.g. wallpapers re-created at
  shell startup — not confirmed whether that fires the hook) can't pop a prompt at login.
  If the prompt is cancelled, `greeter-sync` may still exit 0 and the paths get recorded
  anyway; just run `noctalia msg greeter-sync` by hand.
- Only wallpaper changes trigger a sync. A palette/theme/font change on its own doesn't —
  run `noctalia msg greeter-sync` manually for those.
- Hook keys and defaults come from `noctalia config export full`. Noctalia's config is
  TOML only; Lua in Noctalia is just for scripted bar widgets.
- **Password-free alternative (not chosen):** since the sync now has its own polkit
  action, a rule granting `org.noctalia.greeter.sync-appearance` to this user
  (`subject.local && subject.active`) in `/etc/polkit-1/rules.d/` would make every sync
  silent and allow `auto_sync = true` again. It wasn't chosen because any process running
  as the user could then trigger the root helper, and a future helper version would
  inherit the grant.
- **History (2026-08-29, noctalia 5.0 beta / greeter 1.2.1):** back then auto_sync went
  through `run0`, i.e. the generic `org.freedesktop.systemd1.manage-units` action on a
  randomly-named transient unit (`run-pNNN-iNNN.service`). No scoped polkit rule was
  possible (no stable unit name; `auth_admin_keep` never cached because each `run0` is a
  fresh subject), so the only option was `auto_sync = false` plus manual
  `noctalia msg greeter-sync`. Re-triggered by turning on 30-min rotation. The newer
  dedicated polkit action makes that whole investigation obsolete.
- Unrelated to [[greetd-pam-gnome-keyring-unlock]]: that prompt was gnome-keyring
  (decrypting secrets), this one is polkit (authorizing root) — unlocking the keyring
  grants no root authorization.
