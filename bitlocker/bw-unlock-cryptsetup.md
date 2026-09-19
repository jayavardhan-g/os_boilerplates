# Unlock BitLocker drives via Bitwarden + cryptsetup, no retyped passwords

**Date:** 2026-09-20 (updated 2026-09-20 — `laptop` drive permanently decrypted)
**Category:** bitlocker (portable — works on any Linux distro/WM, `cryptsetup` + `bw` CLI only)
**Files touched:** `~/.local/bin/bw-unlock`, `~/.local/bin/bw-lock`, `~/.local/bin/bw-unlock-all`

## What
Three scripts to unlock and mount BitLocker-encrypted NTFS partitions from Linux using a
passphrase pulled live from Bitwarden, instead of retyping the BitLocker password/recovery
key every time or storing it in a plaintext keyfile on disk.

- `bw-unlock <known-drive>` or `bw-unlock <partition> <label> <bitwarden-item-name>` —
  unlocks + mounts one drive.
- `bw-lock <label>` — cleanly unmounts and closes it.
- `bw-unlock-all` — runs `bw-unlock` for every known drive in turn.

Known drives (hardcoded in `bw-unlock`'s lookup table):

| Name | Partition | Bitwarden item | Mount point |
|---|---|---|---|
| `laptop` | `/dev/nvme0n1p5` | *(none — unencrypted, plain mount)* | `/mnt/laptop-newvolume` |
| `nani` | `/dev/nvme0n1p6` | `BitLocker - NANI New Volume` | `/mnt/nani-newvolume` |
| `desktop-c` | `/dev/nvme0n1p3` | `BitLocker - DESKTOP-8PKDU07 C:` | `/mnt/desktop-c` |

`nani`/`nani-newvolume` is internally labeled `Study` (NTFS volume label) — the BitLocker
container's outer label (`NANI New Volume`) is just a legacy hostname from whenever it was
originally encrypted, unrelated to what the volume is actually used for.

`desktop-c` is the actual live dual-booted Windows OS partition (`DESKTOP-8PKDU07`), not a
data-only drive like the other two — worth being more deliberate about writes there.

## Why
Wanted to stop retyping BitLocker passwords/recovery keys by hand every time, since all of
them are already stored in Bitwarden. Considered and rejected two other approaches first:

1. A plaintext keyfile on disk (`/etc/bitlocker-keys/*.key`) — rejected because this
   machine's root filesystem (`nvme0n1p9`, btrfs) is itself unencrypted, so a keyfile would
   be readable by anyone with physical access via a live USB, indefinitely, no
   re-authentication ever required.
2. Autofill into the GUI unlock dialog via `wtype` (Wayland keystroke injection), triggered
   from the Bitwarden CLI — worked in principle (Mango supports the needed
   `wlr_virtual_keyboard_manager_v1` protocol) but is unnecessarily complex and carries a
   focus-hijack risk (types into whatever window happens to be focused). Realized
   `cryptsetup open --key-file=-` can read the passphrase straight from stdin, so it can be
   piped directly from `bw get password` with no GUI interaction, no keystroke injection,
   and no extra `wtype` dependency at all.

The `BW_SESSION` caching (see Notes) exists so the master password isn't needed on every
single unlock, without ever writing the vault's session key to persistent disk.

## Change

`~/.local/bin/bw-unlock`:
```bash
#!/usr/bin/env bash
# Unlock a BitLocker-encrypted partition using a passphrase stored in Bitwarden,
# and mount it read-write as the invoking user (not root).
set -euo pipefail

ENCRYPTED=1

if [ "$#" -eq 1 ]; then
    case "$1" in
        laptop)
            # Decrypted 2026-09-20 — Windows 10 Home can't re-enable BitLocker
            # on a data volume (full BitLocker is Pro/Enterprise/Education
            # only; Home only has TPM-gated Device Encryption for the OS
            # drive). Left unencrypted on purpose. Plain mount, no bw/cryptsetup.
            PART="/dev/nvme0n1p5"
            LABEL="laptop-newvolume"
            ENCRYPTED=0
            ;;
        nani)
            PART="/dev/nvme0n1p6"
            LABEL="nani-newvolume"
            ITEM="BitLocker - NANI New Volume"
            ;;
        desktop-c)
            PART="/dev/nvme0n1p3"
            LABEL="desktop-c"
            ITEM="BitLocker - DESKTOP-8PKDU07 C:"
            ;;
        *)
            echo "unknown drive '$1' — known: laptop, nani, desktop-c" >&2
            echo "or use the explicit form: bw-unlock <partition> <label> <bitwarden-item-name>" >&2
            exit 1
            ;;
    esac
elif [ "$#" -eq 3 ]; then
    PART="$1"
    LABEL="$2"
    ITEM="$3"
else
    echo "usage: bw-unlock <known-drive>  (laptop | nani | desktop-c)" >&2
    echo "   or: bw-unlock <partition> <label> <bitwarden-item-name>" >&2
    exit 1
fi
MOUNTPOINT="/mnt/$LABEL"

if [ "$ENCRYPTED" -eq 0 ]; then
    MOUNTDEV="$PART"
else
    MAPPER="bitlocker-$LABEL"
    MOUNTDEV="/dev/mapper/$MAPPER"
    SESSION_FILE="/run/user/$(id -u)/bw-cli-session"

    if [ -e "$MOUNTDEV" ]; then
        echo "already unlocked at $MOUNTDEV" >&2
    else
        # Reuse a cached session (tmpfs only, never touches disk, cleared on
        # logout/reboot) if it's still valid; otherwise unlock fresh and cache it.
        if [ -z "${BW_SESSION:-}" ] && [ -f "$SESSION_FILE" ]; then
            BW_SESSION="$(cat "$SESSION_FILE")"
        fi
        if [ -z "${BW_SESSION:-}" ] || [ "$(bw status --session "$BW_SESSION" 2>/dev/null | jq -r '.status')" != "unlocked" ]; then
            BW_SESSION="$(bw unlock --raw)"
            install -m 600 /dev/null "$SESSION_FILE"
            printf '%s' "$BW_SESSION" > "$SESSION_FILE"
        fi
        export BW_SESSION

        PASSWORD="$(bw get password "$ITEM" --session "$BW_SESSION")"
        printf '%s' "$PASSWORD" | sudo cryptsetup open --type bitlk --key-file=- "$PART" "$MAPPER"
        unset PASSWORD
    fi
fi

sudo mkdir -p "$MOUNTPOINT"
if mountpoint -q "$MOUNTPOINT"; then
    echo "already mounted at $MOUNTPOINT" >&2
else
    sudo mount -o uid="$(id -u)",gid="$(id -g)" "$MOUNTDEV" "$MOUNTPOINT"
    echo "mounted at $MOUNTPOINT"
fi
```

`~/.local/bin/bw-lock`:
```bash
#!/usr/bin/env bash
# Cleanly unmount and close a partition previously opened with bw-unlock.
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "usage: bw-lock <label>" >&2
    echo "  e.g. bw-lock laptop-newvolume" >&2
    exit 1
fi

LABEL="$1"
MAPPER="bitlocker-$LABEL"
MOUNTPOINT="/mnt/$LABEL"

if mountpoint -q "$MOUNTPOINT" 2>/dev/null; then
    sudo umount "$MOUNTPOINT"
fi

if [ -e "/dev/mapper/$MAPPER" ]; then
    sudo cryptsetup close "$MAPPER"
fi

echo "closed $LABEL"
```

`~/.local/bin/bw-unlock-all`:
```bash
#!/usr/bin/env bash
# Run bw-unlock for every known drive in turn.
set -uo pipefail

DRIVES=(laptop nani desktop-c)

for drive in "${DRIVES[@]}"; do
    echo "=== $drive ==="
    bw-unlock "$drive"
    echo
done
```

Both scripts are `chmod 755`; `~/.local/bin` is already on `PATH`.

Setup performed once: `sudo pacman -S bitwarden-cli`, then `bw login` (interactive, one
time), then `bw unlock` the first time any script runs (subsequent runs reuse the cached
session — see Notes).

Each BitLocker password is stored as a Bitwarden **Login**-type item (not a Secure Note —
`bw get password` specifically reads a Login item's password field) with the key pasted
into the password field, named to match the table above.

## Notes
- **Session caching is memory-only, by design.** The vault session key is cached to
  `/run/user/<uid>/bw-cli-session` (mode `600`), which is tmpfs — RAM-backed, never
  written to actual disk, wiped on logout/reboot. Storing it persistently would be worse
  than the plaintext-keyfile approach that was rejected, since a live `BW_SESSION` can
  decrypt the *entire* vault, not just one drive's key.
- **`--key-file=-` doesn't strip trailing newlines** (per `cryptsetup`'s own man page) — the
  script deliberately captures the password into a shell variable first (which strips the
  trailing newline via normal command substitution) rather than piping `bw get password`
  straight into `cryptsetup`, to avoid a silent passphrase mismatch.
- **Mount uses `-o uid=,gid=`** so the mounted NTFS tree is owned by the invoking user, not
  root — otherwise every `cp`/`mv` afterward would need `sudo` too.
- **Corruption-safety checklist confirmed before using this regularly:** Fast Startup and
  Hibernate are both off on `DESKTOP-8PKDU07` (the only actual bootable Windows install
  among the three BitLocker partitions — `laptop`/`nani` are just old data drives from
  other machines, no OS ever boots from them so their hibernation state is irrelevant).
  Without Fast Startup off, resuming Windows after writing to shared NTFS partitions from
  Linux risks corruption from Windows' stale in-memory filesystem cache overwriting
  on-disk changes.
- **Superseded — `laptop` drive is now permanently unencrypted, not just size-mismatched.**
  Originally this drive (`/dev/nvme0n1p5`) threw `WARNING: BitLocker volume size
  269481934848 does not match the underlying device size 216046501888` on every unlock
  (BitLocker's header remembering an original ~251GiB size from before this partition was
  resized/migrated down to its current 201.2GiB). `cryptsetup`/`ntfs3` handled it fine at
  the time (confirmed via `df` — correctly clamped to the real 201.2GiB, existing 85G of
  data mounted and read fine) and the plan was to leave it as cosmetic-only unless it ever
  needed fixing.
  Attempted the fix anyway on 2026-09-20 by decrypting (turning off BitLocker) in Windows,
  intending to immediately re-encrypt to get fresh, correct size metadata. **Turned out
  Windows 10 Home cannot re-enable BitLocker on a data volume at all** — full BitLocker
  (the "Turn on BitLocker" wizard for arbitrary volumes) is Pro/Enterprise/Education only;
  Home edition only has TPM-gated "Device Encryption" for the OS drive, which doesn't apply
  here. The drive is now plain NTFS, decrypted, permanently — decided to keep it that way
  rather than pursue a Windows edition upgrade just to re-encrypt one data volume.
  `bw-unlock`'s `laptop` case now does a plain `mount`, no `bw`/`cryptsetup` involved at
  all — see the `ENCRYPTED` flag in the script above. The old Bitwarden item
  (`BitLocker - LAPTOP-ADN3BT6B New Volume`) is no longer used by this script; left in the
  vault as a historical record rather than deleted, but its password is meaningless now.
- **Dolphin can't unlock these via its own GUI prompt** — no polkit authentication agent is
  installed on this machine (only bare `polkitd`, no `polkit-kde-agent`/`polkit-gnome`/etc.),
  so udisks2's encrypted-unlock authorization request has nothing to render a dialog with
  and just fails silently. Not fixed — these scripts bypass udisks2/polkit entirely by
  calling `cryptsetup` directly via `sudo`. (Separately, `nvme0n1p7`/`p8`, `RECOVERY` and
  `RESTORE`, mount fine via Dolphin — they're plain NTFS, not BitLocker at all, and the
  password prompt Dolphin does show for them is just the Linux account password, a
  system-partition mount authorization check, not a BitLocker key — that one path does work
  without an agent, for reasons not fully resolved.)
