#!/usr/bin/env bash
# Launch Xpad under XWayland, and guard against its spurious extra blank pad.
#
# GDK_BACKEND=x11: Xpad saves each pad's position by querying its own window
# geometry, which native Wayland clients cannot do (Wayland deliberately
# doesn't let a client know its absolute screen position) — confirmed live,
# every pad's saved info file showed "x 0 y 0" under native Wayland. Under
# XWayland the same app correctly saved and restored real coordinates. This
# is the only way pads land back where you left them.
#
# Xpad's own --no-new flag ("don't create a pad if none exist") reliably
# prevents a blank pad in an isolated manual launch, but at real login it's
# racing dbus/gsettings/session startup and intermittently still creates one
# anyway (reproduced live: a single process, launched with --no-new, still
# opened an unwanted blank pad — cause not pinned down, but confirmed
# independent of the once-duplicated autostart entry). Rather than chase that
# race further, this closes whatever blank pad appears shortly after launch,
# regardless of why it appeared.
set -uo pipefail

export GDK_BACKEND=x11

XPAD_DIR="$HOME/.config/xpad"

# Notes that had real content before this launch — used below to tell a
# leftover blank pad from a note the user starts typing into right away.
existing_notes=$(find "$XPAD_DIR" -maxdepth 1 -name 'content-*' -size +0c 2>/dev/null | wc -l)

xpad --no-new &

# Give Xpad a few seconds to map its windows before checking.
sleep 3

close_blank_pads() {
    hyprctl eval '
        local wins = hl.get_windows({})
        for _, w in ipairs(wins) do
            if w.class == "xpad" and w.title == "" then
                hl.dispatch(hl.dsp.focus({ window = w }))
                hl.dispatch(hl.dsp.window.close())
            end
        end
    ' >/dev/null 2>&1
}

# Only step in if there were already real notes — an empty-titled pad on a
# totally fresh install (no notes yet) is legitimate, not the bug.
if [ "$existing_notes" -gt 0 ]; then
    close_blank_pads
fi
