-- Window rules wiki https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Generic floating position
hl.window_rule({ match = { float = true }, center = true, persistent_size = true })

-- Picture-in-Picture
hl.window_rule({
    match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float             = true,
    keep_aspect_ratio = true,
    size              = { "max(monitor_w, monitor_h)*0.25", "min(monitor_w, monitor_h)*0.25" },
    pin               = true,
})

-- Gaming
local gamingApps = "^(steam_app.*|gamescope)$"
local gamingWorkspace = "name:gaming"

hl.window_rule({ match = { content = "game" }, workspace = gamingWorkspace })
hl.window_rule({ match = { xdg_tag = "^(.*game.*)$" }, workspace = gamingWorkspace, fullscreen_state = 2, content = "game", sync_fullscreen = true })
hl.window_rule({ match = { class = gamingApps }, workspace = gamingWorkspace })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Launching\\.{3})$" }, float = true, center = true, workspace = gamingWorkspace })
hl.window_rule({
    match = {
        class         = gamingApps,
        title         = "^(.+)$",
        initial_title = "negative:^(.*\\\\home\\\\.*)$",
    },
    content          = "game",
    decorate         = false,
    fullscreen_state = 2,
    size             = { "monitor_w", "monitor_h" },
    sync_fullscreen  = true,
})
hl.window_rule({
    match = {
        class         = "^(steam_app.*)$",
        initial_title = "^$",
    },
    center           = true,
    float            = true,
    fullscreen       = false,
    fullscreen_state = 0,
    workspace        = gamingWorkspace,
})

-- Apps
hl.window_rule({ match = { class = "^(.*\\.exe)$", float = true }, monitor = PRIMARY_MONITOR, center = true, fullscreen_state = 0 })
hl.window_rule({ match = { class = "^(.*[Ll]auncher.*)$" }, float = true, monitor = PRIMARY_MONITOR })
hl.window_rule({ match = { class = "^(vesktop|discord)$" }, monitor = PRIMARY_MONITOR })
hl.window_rule({ match = { class = "^(.*[Cc]alc.*)$" }, float = true, size = { "max(monitor_w, monitor_h)*0.17", "min(monitor_w, monitor_h)*0.43" } })
hl.window_rule({ match = { class = "^(org\\.kde\\.keditfiletype)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.kde\\.ark)$" }, size = { "max(monitor_w, monitor_h)*0.40", "min(monitor_w, monitor_h)*0.40" } })
hl.window_rule({ match = { class = "^(.*satty.*)$", title = "^(Satty)$" }, min_size = { "max(monitor_w, monitor_h)*0.35", "min(monitor_w, monitor_h)*0.35" }, float = true })
hl.window_rule({ match = { class = "^(dev\\.)?(noctalia\\.Noctalia(\\.Settings)?)$" }, float = true, size = { "monitor_w*0.70", "monitor_h*0.70" } })
hl.window_rule({
    match = {
        class = "^(org\\.kde\\.dolphin)$",
        title = "negative:^(Moving.*|Create New.*|Extract.*|Compress.*|Copying.*|Progress.*|Configure.*|Properties.*|Choose\\sApplication.*)$",
    },
    float = true,
    size = { "max(monitor_w, monitor_h)*0.50", "min(monitor_w, monitor_h)*0.55" },
    move = {
        "max(20, min(cursor_x - (window_w*0.50), monitor_w - window_w + 20))", -- X axis clamping
        "max(20, min(cursor_y - 50, monitor_h - window_h + 20))" -- Y axis clamping
    },
})

-- Opacity Overrides
local terminals = "^(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)$"

hl.window_rule({ match = { class = "^(firefox|zen)$" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = terminals }, opacity = "1.0 override" }) -- Override opacity in favor of terminal settings for opacity. If your terminal doesn't support transparency, you can remove this rule.
hl.window_rule({ match = { class = "^(mpv|org.kde.haruna|.*plex.*|org\\.kde\\.gwenview|.*vlc.*)$" }, opacity = "1.0 override" })

-- Float Utility Windows
local floatApps = {
    { class = "^(kvantummanager|qt[56]ct|nwg-look)$" },
    { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$" },
    { title = "^(Winetricks.*|Protontricks.*)$" },
}
for _, m in ipairs(floatApps) do hl.window_rule({ match = m, float = true }) end

-- Float Common Modals
local modalMatches = {
    { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
    { initial_title = "^(Open File)$" },
    { class = "^([Xx]dg-desktop-portal-gtk)$" },
    { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
    { class = "^(.*dialog.*)$" },
    { title = "^(.*dialog.*)$" },
    { class = "^(hyprland-share-picker)$"},
}
for _, m in ipairs(modalMatches) do hl.window_rule({ match = m, float = true }) end

-- Auto-hidden apps: sent straight into the special workspace on open (paired with
-- autostart.lua launching them at startup). Kitty instances are told apart by the
-- --title flag; initial_title is used so a later shell/program title change (fish,
-- claude, labvpn's prompt) doesn't cause the rule to stop matching.
hl.window_rule({ match = { class = "^(spotify)$" }, workspace = "special" })
hl.window_rule({ match = { class = "^(kitty)$", initial_title = "^(special-claude)$" }, workspace = "special" })
hl.window_rule({ match = { class = "^(kitty)$", initial_title = "^(special-labvpn)$" }, workspace = "special" })
hl.window_rule({ match = { class = "^(kitty)$", initial_title = "^(special-home)$" }, workspace = "special" })

-- Xpad notes: pinned to workspace 7 so they always open in the same place
-- instead of wherever focus happens to be. Floating rather than tiled since
-- workspace 7 holds nothing else to tile against, and notes are meant to be
-- arranged freely at their own size like a corkboard. center = false
-- explicitly overrides the generic "float=true -> center=true" rule above,
-- which every Xpad note also matches (it's floating too) — without this
-- override every note snaps to the same centered spot on open, which is
-- what was actually causing them to stack on top of each other, independent
-- of any position-persistence issue.
hl.window_rule({ match = { class = "^(xpad)$" }, workspace = "7", float = true, center = false })

-- Floating windows keep their absolute global-space position; that position
-- doesn't get re-projected when their workspace's monitor is reassigned. So
-- when workspace 7 was carried on MONITOR1 (because MONITOR2 was absent at
-- boot) and MONITOR2 then connects, the notes' stale coordinates can still
-- land inside MONITOR1's region even though Hyprland now reports them as
-- being on MONITOR2 — they render on the laptop, on top of whatever's there,
-- while MONITOR2 shows an empty workspace 7. The fix used to re-center each
-- misplaced note (hl.dsp.window.center()), which does move it onto the
-- right monitor but collapses every note to the same centered point —
-- confirmed live, that's what was causing them to overlap specifically on
-- reconnect. Translating by the offset between the two monitors' x instead
-- preserves each note's position relative to the others. Gated on
-- XPAD_HOTPLUG_ARMED (set in autostart.lua) so this only runs for a real
-- post-boot reconnect, not for monitor.added firing during Hyprland's own
-- startup — which would otherwise race Xpad restoring its notes' saved
-- positions and wrongly "fix" them.
hl.on("monitor.added", function()
    if not XPAD_HOTPLUG_ARMED then return end
    hl.timer(function()
        local target, source = nil, nil
        for _, m in ipairs(hl.get_monitors()) do
            if m.name == MONITOR2 then target = m end
            if m.name == MONITOR1 then source = m end
        end
        if not target or not source then return end
        local dx = target.x - source.x

        for _, w in ipairs(hl.get_windows({})) do
            if w.class == "xpad" and w.at.x < target.x then
                hl.dispatch(hl.dsp.focus({ window = w }))
                hl.dispatch(hl.dsp.window.move({ x = dx, y = 0, relative = true }))
            end
        end
    end, { timeout = 1000, type = "oneshot" })
end)

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
