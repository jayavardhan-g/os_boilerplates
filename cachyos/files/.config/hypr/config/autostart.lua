-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("gnome-keyring-daemon --start --components=pkcs11,secrets")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("xhost +SI:localuser:root")
    -- See scripts/xpad-launch.sh: forces XWayland (needed for Xpad to
    -- actually persist pad positions) and cleans up its occasional spurious
    -- blank pad on login.
    hl.exec_cmd("~/.config/hypr/scripts/xpad-launch.sh")

    -- Xpad notes are floating and keep an absolute global-space position
    -- that doesn't get re-projected when their workspace moves monitors (see
    -- windowrules.lua's monitor.added hook, which repairs that after a real
    -- runtime hotplug). But monitor.added also fires for monitors that are
    -- already connected at this initial boot, and running the same repair
    -- then races Xpad's own startup — it can catch each note's window before
    -- Xpad has applied its saved x/y, "fixing" a note that was never
    -- actually broken by force-centering it. XPAD_HOTPLUG_ARMED gates the
    -- repair out until boot has had time to settle, so it only ever runs for
    -- genuine post-boot reconnects.
    XPAD_HOTPLUG_ARMED = false
    hl.timer(function() XPAD_HOTPLUG_ARMED = true end, { timeout = 8000, type = "oneshot" })

    -- Auto-hidden apps: routed straight into the special workspace by matching
    -- window_rules in windowrules.lua (titles below must match those rules
    -- exactly). Launched sequentially — each one only after the previous
    -- window has actually mapped — rather than all at once, because Hyprland
    -- assigns master-layout master/stack-order to whichever window's surface
    -- maps *first*, not whichever hl.exec_cmd call fired first. Firing all
    -- four back-to-back races them against each app's own startup latency:
    -- confirmed on a real restart that claude (kitty -> fish -> the Claude
    -- CLI booting) lost that race and ended up in a stack slot instead of
    -- master. wait_then polls for a window (hl.get_windows) every 200ms and
    -- gives up after ~10s (falling through with a nil window rather than
    -- blocking the rest of the chain forever), so one unusually slow app
    -- can't stop the others from launching.
    --
    -- Toggle via AUTOSTART_HIDDEN_APPS in config/variables.lua; takes effect
    -- on the next full Hyprland restart (this hook doesn't rerun on a plain
    -- `hyprctl reload`).
    if AUTOSTART_HIDDEN_APPS then
    local function wait_then(filter, tries_left, fn)
        local w = hl.get_windows(filter)[1]
        if w or tries_left <= 0 then
            fn(w)
        else
            hl.timer(function() wait_then(filter, tries_left - 1, fn) end, { timeout = 200, type = "oneshot" })
        end
    end

    hl.exec_cmd("kitty --title special-claude --directory ~/claude -e fish -c claude")
    wait_then({ title = "special-claude" }, 50, function(claude)
        -- Force master explicitly too, as a safety net — cheap no-op if
        -- claude is already master (expected, since it should be the only
        -- window in the freshly-emptied special workspace at this point).
        if claude then
            hl.dispatch(hl.dsp.focus({ window = claude }))
            hl.dispatch(hl.dsp.layout("swapwithmaster"))
            hl.dispatch(hl.dsp.layout("mfact exact 0.45"))
        end

        hl.exec_cmd("flatpak run com.spotify.Client")
        wait_then({ class = "^(spotify)$" }, 50, function(spotify)
            hl.exec_cmd("kitty --title special-labvpn -e fish -c labvpn")
            wait_then({ title = "special-labvpn" }, 50, function(labvpn)
                hl.exec_cmd("kitty --title special-home")
                wait_then({ title = "special-home" }, 50, function(home)
                    -- spotify (biggest) > home (medium) > labvpn (smallest).
                    -- Master layout's stack is a nested split (spotify vs
                    -- {labvpn, home}, then labvpn vs home within that):
                    -- resizing the *top* stack window (spotify) rescales the
                    -- labvpn/home pair proportionally while preserving
                    -- whatever ratio they already had, but resizing a
                    -- *middle* window (labvpn) only moves its own boundary
                    -- with the window below it (home), leaving spotify
                    -- untouched. So order matters — set the labvpn/home
                    -- ratio first, then grow spotify (which shrinks both
                    -- proportionally without disturbing that ratio):
                    if labvpn then
                        hl.dispatch(hl.dsp.focus({ window = labvpn }))
                        hl.dispatch(hl.dsp.window.resize({ x = 0, y = -80, relative = true }))
                    end
                    if spotify then
                        hl.dispatch(hl.dsp.focus({ window = spotify }))
                        hl.dispatch(hl.dsp.window.resize({ x = 0, y = 150, relative = true }))
                    end
                end)
            end)
        end)
    end)
    end
end)

-- Xpad only writes each pad's position to disk on a clean quit — confirmed
-- live: killing it (SIGTERM/pkill) leaves every pad's saved position at
-- "x 0 y 0" no matter what, while `xpad --quit` (its own IPC shutdown
-- command) correctly saves the real coordinates. A logout/shutdown that just
-- kills the process would silently lose position every time, so ask it to
-- quit cleanly first, before whatever normally kills app processes on
-- session teardown gets to it.
hl.on("hyprland.shutdown", function ()
    hl.exec_cmd("xpad --quit")
end)
