-- Look and feel configuration

hl.config({
    general = {
        layout = "master",
        gaps_in = 1,
        gaps_out = 3,
        extend_border_grab_area = 10,
        resize_on_border = true,
        border_size = 2,
        col = {
            active_border = {
                -- colors = { "rgba(ffffffcc)", "rgba(444444cc)" },
                colors = { CACHYLGREEN, CACHYDGREEN },
                -- colors = { "rgba(bd93f9cc)", "rgba(6272a4cc)" },
                -- colors = { "rgba(ff00ffaa)", "rgba(00ffffaa)" },
                -- colors = { "rgba(ff5e00cc)", "rgba(ff5e00cc)", "rgba(00000000)" },
                -- colors = { "rgba(ff5e00cc)", "rgba(00000000)" },
                -- blue, for cool/blue-toned wallpapers:
                -- colors = { "rgba(3ea6ffcc)", "rgba(3ea6ffcc)", "rgba(00000000)" },
                -- teal/cyan:
                -- colors = { "rgba(00e5ffcc)", "rgba(00e5ffcc)", "rgba(00000000)" },
                -- green, for nature/forest wallpapers:
                -- colors = { "rgba(4ade80cc)", "rgba(4ade80cc)", "rgba(00000000)" },
                -- pink/rose, for sunset-toned wallpapers:
                -- colors = { "rgba(ff5ea6cc)", "rgba(ff5ea6cc)", "rgba(00000000)" },
                -- purple:
                -- colors = { "rgba(a855f7cc)", "rgba(a855f7cc)", "rgba(00000000)" },
                -- gold/amber:
                -- colors = { "rgba(ffb800cc)", "rgba(ffb800cc)", "rgba(00000000)" },
                -- red:
                -- colors = { "rgba(ff3b3bcc)", "rgba(ff3b3bcc)", "rgba(00000000)" },
                angle = 45,
            },
            inactive_border = {
                colors = { "rgba(00000000)" },
            }
        },
    },
    group = {
        col = {
            border_active = CACHYLBLUE,
            border_inactive = CACHYGRAY,
            border_locked_active = CACHYDBLUE,
            border_locked_inactive = CACHYGRAY,
        },
        groupbar = {
            col = {
                active = CACHYLGREEN,
                inactive = CACHYGRAY,
                locked_active = CACHYDBLUE,
                locked_inactive = CACHYGRAY,
            },
        },
    },
    decoration = {
        dim_special = 0.3,
        rounding = 10,
        active_opacity = 0.95,
        inactive_opacity = 0.85,
        fullscreen_opacity = 1,
        blur = {
            size = 5,
            passes = 4,
            special = true,
        },
    },
})
