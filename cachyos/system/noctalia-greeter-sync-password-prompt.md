# Noctalia greeter-sync password prompt (unresolved, by choice)

**Date:** 2026-08-29
**Category:** system
**Files touched:** none — investigated and reverted, no config kept

## What
Every small settings change in Noctalia (wallpaper, theme, etc.) pops a password prompt.
Investigated the cause and a possible polkit fix; user chose to accept the friction
rather than continue debugging, so nothing was kept. Documenting the dead end so a future
session doesn't repeat the same investigation from scratch.

## Why it happens
`[shell.greeter_sync] auto_sync = true` in `~/.config/noctalia/config.toml` (default)
fires `scheduleGreeterAutoSync()` on basically any settings change, which runs:
```
run0 /usr/bin/noctalia-greeter-apply-appearance /run/user/1000/noctalia-greeter-sync
```
`run0` (systemd's sudo-alternative, authenticates via polkit) elevates this to root by
spinning up a **brand-new, randomly-named transient systemd unit** each time (e.g.
`run-p80513-i95137.service` — confirmed via `journalctl`). The polkit action requested is
the generic `org.freedesktop.systemd1.manage-units`, not anything greeter- or
noctalia-specific, and it is NOT restarting/reloading `greetd.service` (its
`ActiveEnterTimestamp` doesn't change) — it's just the transient-unit-creation check.

## Why the obvious fix doesn't work
A polkit rule that grants `org.freedesktop.systemd1.manage-units` when
`action.lookup("unit") == "greetd.service"` **never matches**, because the unit being
managed is the random transient wrapper unit, not greetd. Since that name is different on
every invocation, there's no stable unit name to key a scoped polkit rule on.

Also: polkit's own `auth_admin_keep` caching (which should avoid re-prompting for ~a few
minutes) never kicks in here either, because the cache is keyed to the *calling process*,
and `run0` creates a fresh short-lived process/subject every single time — there's never a
repeat identity for the cache to recognize.

## What would be needed to actually fix it
Confirming whether polkit exposes any other identifying detail for this action (e.g. a
`description` field, since `run0` defaults the transient unit's description to the command
line per `man run0`) requires enabling polkit's debug-level logging (`polkit.log()` calls
are emitted at GLib DEBUG level, silently dropped at the daemon's default `notice` level).
That means temporarily overriding `polkit.service`'s `ExecStart` to add
`--log-level=debug`, restarting it, reading `journalctl -u polkit`, then reverting the
override — user decided this wasn't worth it for a cosmetic annoyance and stopped here.

## Notes
- If revisiting this later: start from the debug-logging step above rather than
  re-deriving the whole "why doesn't unit==greetd.service work" chain again.
- Workaround in the meantime: just enter the password, or turn off
  `[shell.greeter_sync] auto_sync` entirely and run `noctalia msg greeter-sync` manually
  only when you actually want the login screen updated (not attempted — user prefers
  auto-sync to stay on and just eat the prompts).
