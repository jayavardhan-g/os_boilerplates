-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Example: output can be found with hyprctl monitors. Edit variables.lua for the monitor outputs instead of here directly
-- hl.monitor({
--     output    = "MONITOR1",
--     mode      = "1920x1080@60",
--     position  = "0x0",
--     scale     = "1",
-- })

hl.monitor({
    output   = MONITOR1,
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = "1.20",
})

-- Deliberate 100px dead zone between the two screens, carried over in spirit
-- from Mango (monitors.conf had `monitorrule = name:HDMI-A-1, x:1750`, a 150px
-- gap) but dialled back to a round 100px by preference.
--
-- THE ARITHMETIC — re-derive this if either scale ever changes:
--   eDP-1 logical width = 1920 / 1.20 = 1600
--   so x = 1600  -> screens butt together, pointer slides across freely
--      x = 1700  -> 100px of empty coordinate space between them  <- current
--      x = 1750  -> 150px, the value Mango actually ran
--
-- That gap isn't reachable by the pointer, so crossing between monitors needs
-- a deliberate flick instead of a slow drift — the cursor "stops when moved
-- slowly, jumps through when flicked fast". It stops you wandering onto the
-- external by accident.
--
-- Note this originally happened by mistake in Mango: x was computed for
-- scale 1.1, then the scale was bumped to 1.2 without redoing the sum, leaving
-- an accidental 146px gap that turned out to be worth keeping. Mango's own
-- comment claimed x:1670 (a 70px gap) while the live value was 1750 (150px) —
-- the comment had gone stale. 100px was picked here deliberately rather than
-- inheriting either number.
--
-- eDP-1's position is pinned to 0x0 above (was "auto") so this offset is
-- measured from a fixed origin rather than from wherever auto-placement
-- happened to land it.
hl.monitor({
    output   = MONITOR2,
    mode     = "preferred",
    position = "1700x0",
    scale    = "1",
})
