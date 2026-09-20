# bit-unlock: unlock and mount BitLocker partitions from Linux

**Date:** 2026-09-20
**Category:** bitlocker
**Files touched:** `~/.local/bin/bit-unlock`

## What
A bash script that unlocks the two BitLocker-encrypted partitions on this machine's dual
boot (the Windows `C:` system drive, and a second data volume nicknamed "nani") and mounts
them read-write, pulling the passphrase from Bitwarden CLI instead of typing it by hand.

## Why
Needed to read/copy files off the Windows install from Linux (e.g. migrating browser
profiles — see [[windows-profile-migration]] in `zen-browser/`) without booting into
Windows, and without storing the BitLocker passphrase in plaintext anywhere on disk.

## Change
`~/.local/bin/bit-unlock` (executable):
```bash
#!/usr/bin/env bash
# Unlock BitLocker-encrypted partitions and mount them, using a passphrase
# stored in Bitwarden. With no arguments, shows an interactive menu.
# Usage:
#   bit-unlock                     interactive menu
#   bit-unlock all | both          unlock every known drive
#   bit-unlock <name> [<name>...]  unlock one or more specific drives
set -uo pipefail

KNOWN_DRIVES=(nani desktop-c)
# ... full script stored at files/.local/bin/bit-unlock
```

Core mechanism per drive (`unlock_one()`):
```bash
sudo cryptsetup open --type bitlk --key-file=- "$PART" "$MAPPER"   # e.g. bitlocker-desktop-c
sudo mount -o uid="$(id -u)",gid="$(id -g)" "/dev/mapper/$MAPPER" "/mnt/$LABEL"
```

Known drives (hardcoded in the script — add a new `case` arm in `unlock_one()` for another
BitLocker partition):

| name | partition | mount point | Bitwarden item |
|---|---|---|---|
| `desktop-c` | `/dev/nvme0n1p3` | `/mnt/desktop-c` | `BitLocker - DESKTOP-8PKDU07 C:` |
| `nani` | `/dev/nvme0n1p6` | `/mnt/nani-newvolume` | `BitLocker - NANI New Volume` |

Full script: [files/.local/bin/bit-unlock](files/.local/bin/bit-unlock).

## Notes
- **Uses `cryptsetup --type bitlk`, not `dislocker`.** `dislocker` isn't even installed on
  this machine (checked 2026-09-20) — `cryptsetup` has had native BitLocker2 support for
  years and is what's actually doing the unlocking here. An earlier entry
  (`zen-browser/windows-profile-migration.md`, not yet committed to `main` as of this
  writing) describes this same setup as "dislocker + dm-mapper" — that's inaccurate and
  should be corrected to reference this entry once that file lands.
- **Idempotent**: re-running against an already-unlocked/mounted drive just prints
  "already unlocked"/"already mounted" and exits cleanly rather than erroring.
- **Bitwarden session caching**: caches the unlocked `BW_SESSION` at
  `/run/user/$UID/bw-cli-session` (mode 600, tmpfs — never touches disk, cleared on
  logout/reboot) so you're not prompted for the Bitwarden master password on every call,
  only when the cached session has actually expired/locked.
- **No "lock"/"close" counterpart exists** — the script only unlocks. This is intentional,
  not a gap: a normal OS shutdown already unmounts these and deactivates the
  `bitlocker-*` device-mapper mapping automatically as part of systemd's standard shutdown
  teardown (confirmed via this machine's own shutdown journal — both `/mnt/desktop-c` and
  `/mnt/nani-newvolume` show up in the normal `Unmounting ...` sequence even though
  they're not in `/etc/fstab`), and the mapping only exists in kernel memory anyway, so
  there's nothing left "unlocked" once the machine is off. No pre-shutdown step needed.
- **Prerequisite for safe read-write use across the dual boot: Windows Fast Startup must
  be disabled** (confirmed off on this machine, 2026-09-20). With Fast Startup on, a
  Windows "shutdown" actually hibernates rather than fully powering off, leaving the NTFS
  volume in a state Windows expects to resume into unchanged. Writing to that same volume
  from Linux via `bit-unlock` in between would go unnoticed by Windows' stale in-memory
  state on resume — a real corruption risk, unrelated to how Linux itself shuts down. Not
  a concern for read-only access, only read-write.
