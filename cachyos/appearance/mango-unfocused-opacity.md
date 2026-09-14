# Mango transparency reduced to match Hyprland's more solid look

**Date:** 2026-09-14
**Category:** appearance
**Files touched:** `~/.config/mango/cfg/appearance.conf`

## What
Set `unfocused_opacity = 0.95` in Mango (no separate `focused_opacity` exists there —
focused windows are always fully opaque by design), and neutralized the blur's
brightness/contrast/saturation multipliers to `1.0` each so the blur doesn't exaggerate
what's visible behind a window.

## Why
Mango's `appearance.conf` never set an opacity value at all, so unfocused windows ran on
Mango's compiled-in default — noticeably more transparent than the Hyprland side, which
explicitly sets `active_opacity = 0.95` / `inactive_opacity = 0.85`. First pass matched
Mango's `unfocused_opacity` to Hyprland's `inactive_opacity` (0.85) directly, but that
still read as too transparent on the Mango side — confirmed by the user after actually
trying it. Pushed opacity higher than Hyprland's own value, and separately identified
`blur_params_saturation = 1.2` (boosting the vividness of whatever's blurred behind a
window) as a second contributor to the "see-through" feel, independent of alpha opacity.

## Change
`~/.config/mango/cfg/appearance.conf`:
```
# Deliberately more solid than Hyprland's own inactive_opacity (0.85) - that
# value still read as too transparent on the Mango side, so pushed higher.
# No separate focused_opacity knob exists in Mango; focused windows are
# always fully opaque there.
unfocused_opacity = 0.95

blur = 1
blur_layer = 0
blur_optimized = 1
blur_params_num_passes = 2
blur_params_radius = 4
blur_params_noise = 0.04
# brightness/contrast/saturation neutralized (were 0.9/0.9/1.2) - the boosted
# saturation was making whatever's behind a blurred window look more vivid
# and "present", reading as more see-through than Hyprland's own blur
# (size=5, passes=4) despite Mango's blur technically being weaker here.
blur_params_brightness = 1.0
blur_params_contrast = 1.0
blur_params_saturation = 1.0
```

## Notes
- **Superseded:** first attempt set `unfocused_opacity = 0.85` (a literal match to
  Hyprland's `inactive_opacity`) — not solid enough once actually seen live, raised to
  `0.95`.
- **Mango has no `focused_opacity`/`active_opacity` equivalent** — confirmed via
  `strings /usr/bin/mango`: only `unfocused_opacity` exists as a config key
  (`client_set_unfocused_opacity_animation`); the focused window is always rendered fully
  opaque by design.
- `blur_params_num_passes`/`blur_params_radius` were left unchanged (2 / 4) — already
  numerically weaker than Hyprland's `blur.passes = 4` / `blur.size = 5`, so the
  saturation/brightness/contrast multipliers (which had no Hyprland equivalent to compare
  against at all) were the more likely culprit for the extra see-through feel, not the
  blur strength itself.
- Not yet visually re-confirmed after this second pass — set from a session in Hyprland,
  not Mango. Reload Mango (`mmsg reload` or a fresh Mango login) to see it take effect,
  and iterate further if `0.95` still isn't solid enough.
