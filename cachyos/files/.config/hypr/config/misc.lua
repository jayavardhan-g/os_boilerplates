hl.config({
    -- With a window maximized/fullscreened (SUPER+D), directional focus used to
    -- escape to the other monitor instead of moving to the next window on the
    -- workspace: a fullscreen window covers its whole monitor, so "right" of it
    -- is the monitor edge, and binds:window_direction_monitor_fallback (true by
    -- default) then carries focus across to the next output.
    --
    -- Reproduced on a horizontal scrolling workspace with three columns: from
    -- either dd1 or dd2 fullscreen, focus-right landed on ws4 / HDMI-A-1. With
    -- this option on, the same keypress goes dd1 -> dd2 -> dd3 and the window
    -- STAYS fullscreen (fs=1), which is the Mango behaviour — you stay in
    -- maximized mode and flip between windows.
    --
    -- Note this is the fix, NOT window_direction_monitor_fallback.
    --
    -- window_direction_monitor_fallback = false (was left at its default, true,
    -- until 2026-09-26). With the dead zone in monitors.lua it could never reach
    -- a real neighbour anyway (see [[monitor-gap-blocks-directional-focus]]),
    -- but it DID do something wrong: SUPER+H on the laptop's leftmost window
    -- jumped to the external's workspace 4. Scrolling-layout columns scrolled
    -- off-screen keep global coordinates outside their monitor (ws4's Zen sat at
    -- x=-1222, left of the laptop), so the fallback's search found a hidden
    -- column "to the left". Measured live: fallback true -> focus lands on ws4;
    -- false -> focus stays put. Window moves (SUPER+SHIFT+hjkl) didn't cross
    -- monitors either way, so nothing is lost. If the gap is ever closed
    -- (x = 1600), re-test before turning this back on.
    binds = {
        movefocus_cycles_fullscreen = true,
        window_direction_monitor_fallback = false,
    },
    dwindle = {
        preserve_split = true,
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
    misc = {
        col = {
            splash = CACHYLGREEN,
        },
        middle_click_paste = false,
        enable_swallow = true,
        swallow_regex = "(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)",
        vrr = 3,
    },
    -- Scrolling layout: make hovering an inactive column ALWAYS bring it into
    -- view, instead of only sometimes.
    --
    -- The inconsistency was three options interacting:
    --   input:follow_mouse = 1        hovering an inactive window focuses it
    --   scrolling:follow_focus = true a newly focused window is scrolled into view
    --   scrolling:follow_min_visible  "require that at least a given fraction of
    --                                 it is visible for focus to follow"
    --
    -- That last one defaults to 0.4, so hovering a column that was >=40% visible
    -- scrolled it into view while hovering one less visible than that moved focus
    -- but left the layout put. Same gesture, two outcomes, depending purely on how
    -- much of the column happened to be on screen.
    --
    -- 0.0 removes the gate entirely: any sliver you hover gets focused and
    -- scrolled in. KNOWN TRADE-OFF, chosen deliberately — the 0.4 default exists
    -- to stop the layout lurching when the pointer merely grazes the edge of a
    -- barely-visible column. If that turns out to be annoying in practice, raise
    -- this toward 0.4 rather than assuming it is a bug; the alternative fix was
    -- input:follow_mouse = 2 ("detached"), which stops hover driving the layout at
    -- all and makes it click-to-focus instead.
    scrolling = {
        follow_min_visible = 0.0,
    },
    render = {
        direct_scanout = 2,
    },
    xwayland = {
        force_zero_scaling = true
    },
})
