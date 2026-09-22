# Migrated Neovim to LazyVim

**Date:** 2026-09-15
**Category:** system
**Files touched:** `~/.config/nvim` (replaced), `~/.local/share/nvim`, `~/.local/state/nvim`,
`~/.cache/nvim`

## What
Replaced the entire hand-rolled Neovim config (see [[neovim-minimal-ssh-friendly-setup]]
and [[vim-neovim-parity-pass]]) with the official [LazyVim](https://www.lazyvim.org)
starter template. **Neovim only** — `~/.vimrc` (plain Vim) is untouched and still the
hand-rolled setup described in [[vimrc-minimal-visual-config]].

## Why
After several sessions hand-rolling Neovim-specific behavior (a buffer-based tabline, a
multi-file "smart quit" flow, sidebar/quit interactions), kept hitting real bugs in that
custom glue code - netrw's `modifiable` default, neo-tree's `close_if_last_window` quit
guard silently replacing the confirm dialog, `BufModifiedSet` not existing in plain Vim,
duplicate sidebars per real tabpage, `:bdelete` collapsing windows. Decided the actual
priority had shifted from "hand-declare and understand every piece" (the original
rationale for the manual git-clone loader and no-Mason setup) to "fewer bugs, less
personal maintenance, lean on a tried-and-tested community config instead."

Compared LazyVim, AstroNvim, and NvChad first rather than assuming - see the chat history
around 2026-09-15 for the full comparison. LazyVim won on: largest community (most
already-solved issues to find), its "extras" system (one line pulls in a whole language's
LSP+formatter+treesitter+debugger, pre-integrated, instead of hand-declaring each piece -
directly addresses where this session's bugs kept coming from), and being the most
actively developed of the three. NvChad's one philosophical similarity (no Mason by
default) was explicitly *not* a deciding factor once "match our old preferences" stopped
being the goal - no Mason would have meant continuing to hand-install every LSP server,
recreating the exact problem this migration is meant to solve.

## Change
Backed up the previous setup rather than deleting it (per LazyVim's own documented install
steps):
```bash
mv ~/.config/nvim      ~/.config/nvim.bak-pre-lazyvim-20260915-005052
mv ~/.local/share/nvim ~/.local/share/nvim.bak-pre-lazyvim-20260915-005052
mv ~/.local/state/nvim ~/.local/state/nvim.bak-pre-lazyvim-20260915-005052
mv ~/.cache/nvim       ~/.cache/nvim.bak-pre-lazyvim-20260915-005052
```
Installed the starter template:
```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```
First launch bootstraps `lazy.nvim` and syncs all default plugins automatically - no
further steps needed. Opening a file of a given language (e.g. a `.lua` file) auto-installs
its LSP server via Mason on the spot (confirmed live: `lua_ls` installed and attached
within ~20s of opening a `.lua` file, no manual config).

## Reproducing this exact setup on a fresh machine

All the personal customizations from the follow-ups below (themes, disabled plugins,
language list, keybinds, OSC52) are stored as **actual files**, not just described in
prose - see [`files/`](files/) next to this entry, which mirrors real paths under `$HOME`
(per `CLAUDE.md`'s file-storage convention). To reproduce:

```bash
# 1. Install the bare LazyVim starter
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# 2. Overlay this repo's customizations on top
cp -r files/.config/nvim/* ~/.config/nvim/
cp files/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf  # only if you also want the Nerd Font + this exact kitty setup

# 3. First launch bootstraps everything else automatically
nvim
```
That's the whole thing - no manual `:TSInstall`/`:TSUninstall`/Mason cleanup steps needed
on a *fresh* machine (those were only needed in this session because plugins/parsers were
already installed before the customization was decided; `disabled.lua` and
`languages.lua` being in place *before* the first `:Lazy sync` means the excluded
plugins/parsers are simply never installed in the first place).

**One real prerequisite**: `colors/kitty.lua` reads `~/.config/kitty/kitty.conf`'s
`include` line and the theme file it points to (currently Noctalia-managed - see
`cachyos/system/noctalia-greeter-sync-password-prompt.md` for context on that shell) - on
a machine without that same kitty+Noctalia setup, it falls back to Neovim's built-in
`habamax` colorscheme automatically rather than erroring, so this is safe to copy
anywhere, it just won't match a different machine's terminal theme unless the same kitty
theming exists there too.

## Notes
- **Rollback**: if LazyVim doesn't work out, the entire previous hand-rolled setup is
  intact at the `*.bak-pre-lazyvim-20260915-005052` paths above - `mv` them back over the
  live `nvim`/`.local`/`.cache` paths to restore it exactly as it was.
- **`neovim-minimal-ssh-friendly-setup.md` and `vim-neovim-parity-pass.md` (Neovim parts
  only) are now historical** - kept for the reasoning trail (LSP/plugin philosophy,
  keybind decisions) but no longer describe the live Neovim config. Their Vim-side content
  (`~/.vimrc`) is still current and unaffected by this migration.
- `stylua`/`shfmt` (Mason-managed formatters for `.lua`/`.sh` files) failed to finish
  installing during setup - Neovim was killed mid-download once, and scripted retries
  afterward (`:MasonInstall stylua shfmt` via both headless `nvim --headless "+cmd" +qa`
  and a driven interactive session) didn't visibly complete either, likely a timing quirk
  specific to non-interactive/scripted driving rather than a real problem - everything
  else (LSP, treesitter, all plugins) installed and verified working. Fix by opening
  `:Mason` normally and retrying those two by hand; doesn't block anything else.
- Personal customizations from the old setup (OSC52 clipboard yank over SSH, `<leader>`
  keybind choices, no-Mason/system-LSP preference, minimal chrome) were **not** ported
  over - starting from LazyVim's defaults deliberately, to actually get the "tried and
  tested, not fighting my own overrides" benefit before deciding what (if anything) to
  layer back on top. Revisit and add back only what's actually missed after using it.

## Follow-up: trimmed to the languages actually used (2026-09-15)

**What**: only language actually used is C++, Python, C, Markdown, and plain text - so
removed everything LazyVim's defaults ship for HTML/JSX/Lua-editing specifically, dropped
both bundled themes, and fixed a gap (C++ wasn't actually in the default treesitter list).

**Change** - `~/.config/nvim/lua/plugins/disabled.lua` (new):
```lua
return {
  -- Themes: no extra theme plugin - use Neovim's own built-in "habamax"
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
  { "LazyVim/LazyVim", opts = { colorscheme = "habamax" } },

  -- HTML/JSX-specific - not used
  { "windwp/nvim-ts-autotag", enabled = false },
  { "folke/ts-comments.nvim", enabled = false },

  -- Lua-specific dev helper - not customizing via Lua
  { "folke/lazydev.nvim", enabled = false },
}
```
`~/.config/nvim/lua/plugins/languages.lua` (new) - `ensure_installed` is an
`opts_extend` list (LazyVim concatenates overrides, it doesn't replace them), so removing
entries needs a function-form `opts` that filters the already-merged list rather than just
passing a shorter one:
```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local remove = { html = true, javascript = true, jsdoc = true, tsx = true, typescript = true }
      opts.ensure_installed = vim.tbl_filter(function(lang)
        return not remove[lang]
      end, opts.ensure_installed)
      table.insert(opts.ensure_installed, "cpp") -- wasn't in the default list, only bare "c" was
      return opts
    end,
  },
}
```
Then applied directly rather than waiting for the next launch: `:Lazy sync` + `:Lazy
clean` removed the 5 disabled plugins from disk; `:TSInstall cpp` +
`:TSUninstall html javascript jsdoc tsx typescript` (confirmed "Uninstalled 5/5
languages") updated the compiled parsers to match; `lua-language-server` (auto-installed
by Mason during earlier testing, before this trim was decided) was removed by deleting
`~/.local/share/nvim/mason/packages/lua-language-server` directly, since `:MasonUninstall`
wasn't registering reliably when driven non-interactively.

**Verified live**: clean launch, `vim.g.colors_name` reads `habamax` (later replaced, see
next follow-up), no tokyonight/catppuccin references anywhere, no errors, dashboard
renders correctly, `cpp.so` present under the treesitter parser dir. 27 plugins remain
(down from 32).

**Kept on purpose, not removed**: the `lua`/`luadoc`/`luap`/`vim`/`vimdoc` treesitter
parsers - these are what let Neovim render its own `:help` pages and any `.lua`/`.vim`
files correctly; tiny footprint, not really "a Lua plugin" in the sense that was asked to
go. Flagged to the user rather than silently kept.

## Follow-up: colorscheme now matches kitty's actual theme (2026-09-15)

**What**: `habamax` (the built-in fallback from the previous follow-up) didn't look good.
Rather than pick another bundled colorscheme plugin, built one that reads kitty's *live*
theme file and matches it exactly - same spirit as the pre-LazyVim Vim/Neovim setups'
"no colorscheme, follow the terminal" preference, adapted for the fact that
`termguicolors` has to stay on for LazyVim's UI plugins (bufferline, blink.cmp, noice,
etc.) to render correctly - true ANSI-passthrough like the old Vim/Neovim configs used
isn't viable here, so this reads kitty's actual hex values instead of relying on the
terminal to reinterpret 16 ANSI slots.

Kitty's colors are dynamically managed by Noctalia, not a static file:
`~/.config/kitty/kitty.conf` has `include themes/noctalia.conf`, which
`~/.config/kitty/themes/noctalia.conf` provides (dark background `#0b0e14`, gold accent
`#e6b450`, full 16-color palette). Since Noctalia can regenerate this file later (e.g. on
a wallpaper change), the colorscheme reads it **live at load time** rather than
hardcoding a snapshot of today's values - it'll track future Noctalia theme changes
automatically.

**Change** - new `~/.config/nvim/colors/kitty.lua`: a standalone Neovim colorscheme file
(the standard `colors/<name>.lua` runtime convention, found automatically by
`:colorscheme kitty`). Parses kitty.conf's `include` line to locate the actual theme file
(so it keeps working if Noctalia ever renames it), reads `colorN #hex`/`background`/
`foreground`/`cursor`/`selection_*` lines, and maps them onto Neovim's highlight groups
using a base16-style convention (comments → color8, strings → color2, keywords → color5,
functions → color4, etc.) - full mapping in the file itself. Falls back to `habamax` if
the theme file can't be found/read, rather than erroring.

`~/.config/nvim/lua/plugins/disabled.lua` - `colorscheme` opts changed from `"habamax"`
to `"kitty"`.

**Verified live**: `vim.g.colors_name` reads `kitty`; `Normal`'s background highlight
resolves to `0x0B0E14` - byte-for-byte kitty's actual `background #0b0e14` - confirming
the file was read and applied correctly, not just falling back silently.

## Follow-up: comparing old keybinds against LazyVim's, adding back what's missing (2026-09-15)

**What**: the old hand-rolled `lua/config/keymaps.lua` (see [[vim-neovim-parity-pass]] and
[[neovim-minimal-ssh-friendly-setup]]) wasn't ported over at all - diffed it directly
against LazyVim's actual default keymaps
(`~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua`) to see what's really
gone versus just remapped to a different key. Findings:
- Same key survived by coincidence: `<C-s>` save, `<C-h/j/k/l>` window nav, `[d`/`]d`.
- Same idea under a different LazyVim key: buffer cycle (`<S-h>`/`<S-l>` not
  `<Tab>`/`<S-Tab>`), splits (`<leader>\|`/`<leader>-` not `<leader>v`/`<leader>h`),
  resize (`<C-arrows>` not bare arrows), tabs (`<leader><tab>` prefix), wrap toggle
  (`<leader>uw`), close window (`<leader>wd`), line diagnostics (`<leader>cd`).
- **`<leader>bd` (LazyVim default) already does exactly what `mini.bufremove` was
  installed for** - delete a buffer without closing its window. That whole plugin
  install (see the "leader-x was collapsing the file window" follow-up in
  [[vim-neovim-parity-pass]]) turned out to duplicate something LazyVim ships natively,
  just under a different key than the old `<leader>x`.
- Gone entirely, no LazyVim equivalent: `jk`/`kj` to exit insert, OSC52 clipboard yank,
  the custom multi-file "smart quit" (Skip option), `<leader>sn`, `x` deleting into the
  unnamed register (see below), `<C-d>`/`<C-u>` scroll-and-center, visual-paste-without-
  clobbering-register.

**Change** - added the one thing asked for so far, `~/.config/nvim/lua/config/keymaps.lua`
(LazyVim's documented user-keymap extension point, auto-loaded after its own defaults):
```lua
-- Delete a character without yanking it (plain x overwrites the unnamed
-- register, clobbering whatever you last copied with y)
vim.keymap.set("n", "x", '"_x', { noremap = true, silent = true })
```
**Verified live**: yanked a word (`yiw`), pressed `x` elsewhere, pasted (`p`) - the
yanked word came back intact rather than the deleted character, confirming `x` no longer
clobbers the unnamed register.

**Not yet added, offered but no decision made**: `jk`/`kj` to exit insert mode - flagged
as a loss with no LazyVim substitute; add if/when asked.

## Follow-up: OSC52 clipboard yank, SSH-only (2026-09-15)

**What LazyVim actually does by default** (checked its source before changing anything,
per the request to explain the default first): `lazyvim/config/options.lua` sets
`opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"` - locally, *every* yank
already syncs to the system clipboard automatically via Neovim's built-in provider
auto-detection (confirmed `wl-copy`/`wl-paste` installed and used) - broader than the old
`<leader>y`-only design. Over SSH, clipboard is deliberately left empty - nothing syncs
anywhere, no OSC52 fallback is actually wired up despite the comment implying room for it.

**A real bug caught before it shipped**: the first attempt registered `vim.g.clipboard` as
an OSC52 provider unconditionally. Since local `unnamedplus` routes through the `"+"`
register, this would have made OSC52 fire on *every* local yank too, replacing the
already-working `wl-copy` path with terminal escape codes even when sitting at the
machine directly - not just "adding" SSH support, actively regressing the local case.
Caught by explaining the default behavior back before implementing, per request - fixed
by gating the whole block on `vim.env.SSH_CONNECTION`, mirroring LazyVim's own conditional
exactly.

**Change** - `~/.config/nvim/lua/config/options.lua`:
```lua
if vim.env.SSH_CONNECTION then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end
```
`~/.config/nvim/lua/config/keymaps.lua` - same scoped-to-`<leader>y` design as the
pre-LazyVim setup (plain `y`/`yy` untouched):
```lua
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', yank_opts)
vim.keymap.set("n", "<leader>Y", '"+y$', yank_opts)
```
No plugin needed - Neovim 0.10+ ships this OSC52 provider built in
(`vim.ui.clipboard.osc52`), unlike the old setup's `ojroques/vim-oscyank`.

**Verified live, both branches**: with `SSH_CONNECTION` unset, `<leader>yiw` produced no
OSC52 escape sequence and `wl-paste` confirmed the word actually landed in the real
Wayland clipboard (untouched local path). With `SSH_CONNECTION` set, the same command
correctly emitted `\x1b]52;c;aGVsbG8=` (`hello`, base64-encoded) instead.

## Follow-up: `Ctrl+/` toggles comment, VSCode-style (2026-09-22)

**What**: `Ctrl+/` was opening a terminal (LazyVim default) instead of toggling a
comment, which is the muscle memory carried over from VSCode. Remapped it to comment
toggle; terminal access is unaffected since it was never *only* on this key.

**Why**: LazyVim binds `<c-/>` and `<c-_>` (terminal emulators send one or the other for
the same physical key depending on keyboard protocol support - see Notes) to
`Snacks.terminal.focus(...)` (root-dir terminal), per
`~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua`. That's a duplicate of
`<leader>ft` (same action, "Terminal (Root Dir)") and `<leader>fT` ("Terminal (cwd)"),
both of which stay untouched - so reclaiming `<c-/>`/`<c-_>` loses no functionality, just
a faster alias for something still reachable via leader.

Comment toggling itself (`gcc`/`gc`) is Neovim's own built-in feature (native since 0.10,
confirmed present as core Lua-backed keymaps independent of any plugin - not from the
disabled `ts-comments.nvim`), and already produces the correct `commentstring` per
filetype (`// %s` for C/C++/JS, `# %s` for Python/sh, `<!-- %s -->` for Markdown, `-- %s`
for Lua) via Neovim's built-in ftplugin system - verified directly with a headless
`:set filetype=X` + print `commentstring` check across all languages this setup uses.

**Change** - `~/.config/nvim/lua/config/keymaps.lua`, appended:
```lua
-- VSCode-style comment toggle. Overrides LazyVim's default terminal-toggle
-- binding on this key (<leader>ft/<leader>fT still open a terminal).
-- remap=true is required: "gcc"/"gc" are themselves keymaps (Neovim's
-- built-in comment support, not a raw command), so noremap would try to
-- interpret g/c/c literally instead of dispatching through them.
local comment_opts = { remap = true, silent = true, desc = "Toggle comment" }
vim.keymap.set("n", "<C-/>", "gcc", comment_opts)
vim.keymap.set("n", "<C-_>", "gcc", comment_opts)
vim.keymap.set("v", "<C-/>", "gc", comment_opts)
vim.keymap.set("v", "<C-_>", "gc", comment_opts)
```

**Verified live**: headless Neovim, forced `VeryLazy` to fire (needed in headless mode -
LazyVim's own `<c-/>` binding and this override both live in `config/keymaps.lua` files
that only load on that event, which never fires without a real UI attaching). Confirmed
via `nvim_get_keymap` that both `<C-/>`/`<C-_>` now resolve to `desc = "Toggle comment"`
(not "Terminal (Root Dir)") in both normal and visual mode. End-to-end keypress
simulation on a `.cpp` file: normal-mode `Ctrl+/` on `int main() {` produced
`// int main() {`; visual-mode `Ctrl+/` over the whole 3-line file commented every line
with `//`, confirming both the line-toggle and selection-toggle paths work correctly.

**Notes**:
- Both `<C-/>` and `<C-_>` are mapped (not just `<C-/>`) because terminal keyboard
  encoding for this physical key isn't uniform: legacy encoding sends the literal control
  byte `0x1f` (`<C-_>`), while terminals supporting the newer Kitty keyboard protocol
  (kitty itself, this setup's terminal, included) can send `<C-/>` as a distinct code.
  Mapping only one would leave the binding flaky depending on which code Neovim's TUI
  actually receives - this mirrors LazyVim's own default, which maps both for the same
  reason.
- `<leader>ft` (Terminal, Root Dir) and `<leader>fT` (Terminal, cwd) remain the way to
  open a terminal - nothing was moved to replace the reclaimed key, since these already
  existed and cover the same use case.

## Follow-up: 4-space indent everywhere, disabled completion ghost text (2026-09-22)

**What**: two separate complaints about editing feel - "auto brackets and indentation
... very bad" and, later, "the autofill suggestions ... distracting". Addressed the parts
that were unambiguous; autopairs (`mini.pairs`) specifics were never pinned down (asked
for a concrete example, none given yet) so left untouched pending that.

**Why**:
- **Indentation**: LazyVim sets a **global** `shiftwidth=2`/`tabstop=2` for every
  filetype - confirmed no per-language override existed anywhere in this config. Asked
  directly what width was wanted (options: 4 for C-family only, 4 everywhere, tabs for
  C-family, or custom) - answer was **4 everywhere**. Note this only changes indent
  *width*; the indent *logic* was already treesitter-based
  (`indentexpr = v:lua.LazyVim.treesitter.indentexpr()`, wired automatically whenever a
  parser is installed - confirmed in `lazyvim/plugins/treesitter.lua`), not the naive
  `smartindent` fallback, so no separate fix was needed there.
- **Ghost text**: "autofill suggestions" is blink.cmp's `ghost_text` - the greyed-out
  inline preview of the top completion candidate shown ahead of the cursor as you type,
  distinct from the dropdown completion menu itself (which was not reported as a problem
  and stays on). Confirmed via `lazyvim/plugins/extras/coding/blink.lua`:
  `ghost_text.enabled = vim.g.ai_cmp`, and `vim.g.ai_cmp = true` by default - so it was on
  by default with no explicit user opt-in.

**Change** - `~/.config/nvim/lua/config/options.lua`, appended:
```lua
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
```
`~/.config/nvim/lua/plugins/completion.lua` (new - LazyVim plugin-spec override, same
pattern as `languages.lua`/`disabled.lua`):
```lua
return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        ghost_text = { enabled = false },
      },
    },
  },
}
```

**Verified live**: headless Neovim, forced `VeryLazy`. `.cpp` and `.py` buffers both
report `shiftwidth=4 tabstop=4 expandtab=true` (was 2/2 before). For ghost text,
`require('blink.cmp.config').completion.ghost_text.enabled` is a function (blink.cmp
normalizes bool opts into closures internally) - called it directly, returns `false`
(was `true`/on before the override).

**Not yet done**: autopairs (`mini.pairs`) behavior - user's original complaint bundled
"auto brackets ... very bad" with indentation, but never specified what's actually wrong
(not closing when expected? closing when not wanted? bad interaction on Enter inside
`{}`?). Revisit once a concrete repro is given - LazyVim's current `mini.pairs` defaults
are documented in `lazyvim/plugins/coding.lua` (`skip_next`, `skip_ts = {"string"}`,
`skip_unbalanced`) as the starting point.

## Follow-up: root-caused indent/autopairs complaint, added an autocomplete toggle (2026-09-22)

**What**:
1. The original "auto brackets and indentation ... very bad" turned out to be **unnamed
   buffers only** (`:enew`/no file opened) - no filetype means no filetype-specific
   `commentstring`/indent/treesitter-parser context. `.cpp`/`.py` files were already fine.
   No fix needed - behavior is correct, just hadn't been noticed that the bad case never
   happened on a real file.
2. Autocomplete (blink.cmp) "gets in my way" - added a runtime on/off toggle rather than
   disabling anything permanently.

**Why**: (1) is standard Neovim behavior, not a bug - flagging it here mainly so a future
session doesn't re-investigate the same non-issue. (2) - a full toggle (not just muting
ghost text, already handled in the previous follow-up) covers wanting the LSP dropdown
gone entirely sometimes (e.g. fast typing in prose-like contexts) while keeping it
available on demand elsewhere, without editing config every time.

**Change** - `~/.config/nvim/lua/config/keymaps.lua`, appended:
```lua
vim.g.blink_cmp_enabled = true
Snacks.toggle({
  name = "Autocomplete",
  get = function() return vim.g.blink_cmp_enabled ~= false end,
  set = function(state)
    vim.g.blink_cmp_enabled = state
    if not state then
      pcall(function() require("blink.cmp").hide() end)
    end
  end,
}):map("<leader>uo")
```
`~/.config/nvim/lua/plugins/completion.lua` - added alongside the existing `ghost_text`
override:
```lua
enabled = function()
  return vim.g.blink_cmp_enabled ~= false
end,
```

**A real gotcha hit while building this**: first attempt bound the toggle to
`<leader>uC` - looked free from grepping `lazyvim/config/keymaps.lua` alone, but that
file doesn't contain every default keymap. `<leader>uC` was already LazyVim's
colorscheme-picker keymap, registered elsewhere (plugin `keys` spec, not the imperative
keymaps.lua file) - `vim.keymap.set` silently overwrites on collision, no error, so this
only surfaced by checking the **live**, fully-merged keymap table
(`nvim_get_keymap`) rather than trusting a static grep. Moved to `<leader>uo`, confirmed
free the same way. General lesson: always verify a new leader-key binding against
`nvim_get_keymap('n')` after `VeryLazy`, not just against `keymaps.lua`'s own contents.

**Also discovered while auditing `<leader>u*`**: `<leader>up` is already a LazyVim
built-in - "Toggle Mini Pairs" (autopairs on/off). Relevant if the still-open autopairs
complaint above turns out to just be "I want it off sometimes" rather than a real
misbehavior - that's already one keypress away, no config change needed.

**Verified live**: headless Neovim, forced `VeryLazy`. Confirmed `<leader>uo` registers
with `desc = "Toggle Autocomplete"` (not colliding with anything, per the live keymap
dump). Simulated the keypress: `require('blink.cmp.config').enabled()` flips `true` ->
`false`, notification `Disabled **Autocomplete**` fires, `vim.g.blink_cmp_enabled`
matches. Re-pressing flips it back to `true`.

**Moved to `<leader>ac` (2026-09-22)**: user asked for a say in the actual key rather
than have one picked unilaterally - fair, a keybinding is a pure preference call, not
something to decide alone. Proposed `<leader>ac` ("autocomplete"); confirmed live that
nothing at all is bound under `<leader>a`, so no collision risk. Re-verified the same way
as the original binding - registers correctly, toggle behavior unchanged.

## Follow-up: freed s/S from flash.nvim, moved it to gs/gS (2026-09-22)

**What**: began going through LazyVim's optional plugins one at a time (test live, then
decide keep/remove) as a review process - `flash.nvim` (jump-to-visible-location) was
first. It works well, but its default LazyVim binding is `s`/`S` in normal/visual/
operator-pending mode, which steals Vim's native substitute-char (`s`) and
substitute-line (`S`) - both muscle memory in daily use. Moved flash to `gs`/`gS`
instead, freeing `s`/`S` back to native.

**Why gs/gS specifically**: `<leader>s` was considered first, but it's not a free key -
it's LazyVim's "Search" group prefix with 30+ sub-bindings (`<leader>sg` grep, `<leader>sq`
quickfix, `<leader>su` undotree, `<leader>sh` help, etc. - confirmed live via
`nvim_get_keymap`). Making `<leader>s` itself a complete flash binding would force a
timeout-based disambiguation delay on every single one of those existing search
commands - not worth it for this. `gs`/`gS` confirmed genuinely free (native `gs` is an
obscure, essentially-unused "sleep N seconds" command) - same 2-keystroke-then-target
feel as the original binding, no leader delay.

**Change** - `~/.config/nvim/lua/plugins/flash.lua` (new):
```lua
return {
  {
    "folke/flash.nvim",
    -- stylua: ignore
    keys = {
      { "s", false, mode = { "n", "x", "o" } },
      { "S", false, mode = { "n", "o", "x" } },
      { "gs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "gS", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },
}
```
`false` as the second positional element of a `keys` entry is lazy.nvim's documented way
to disable one specific default-provided keymap without touching the rest of the spec
(confirmed in `lazy.nvim`'s own `core/handler/keys.lua`) - `r`/`R` (operator-pending
remote flash) and `<c-s>`/`<c-space>` (cmdline toggle, treesitter incremental selection)
are untouched since they don't collide with anything.

**Verified live**: headless Neovim, forced `VeryLazy`. `nvim_get_keymap` confirms `s`/`S`
are no longer registered at all (native Vim behavior applies) and `gs`/`gS` resolve to
`Flash`/`Flash Treesitter`. End-to-end: normal-mode `s` on `hello world` correctly
deletes the character under cursor and enters insert mode (produced `XXello world` after
typing `XX`) - exactly native substitute-char behavior.

**Process note**: this is the first of a plugin-by-plugin review pass (test live -> keep
or remove/adjust -> next plugin) - more follow-ups in this vein will land here as they're
decided. Core infrastructure plugins that can't be meaningfully tested standalone
(`lazy.nvim`, `LazyVim`, `plenary.nvim`, `nui.nvim`, `mini.icons`, `mason.nvim`/
`mason-lspconfig.nvim`, `nvim-lspconfig`, `nvim-treesitter` core) are being skipped in
this review; `blink.cmp` and `mini.pairs` already have their own runtime toggles
(`<leader>ac`, `<leader>up`) so don't need a keep/remove decision here.

## Follow-up: gitsigns popup hunk preview on <leader>ghP (2026-09-22)

**What**: second plugin in the one-by-one review - `gitsigns.nvim`. LazyVim's default
`<leader>ghp` (`preview_hunk_inline`) hit two real limits while testing: long lines get
cut off with no way to wrap (confirmed against Neovim's own extmark API - `virt_lines`
only supports `trunc`/`scroll`, `wrap` is rejected outright:
`Invalid 'virt_lines_overflow': 'wrap'`), and the preview closes on *any* cursor
movement (`CursorMoved` autocmd in gitsigns' own source), so you can't scroll through a
tall hunk either. Added `<leader>ghP` for the non-inline `preview_hunk` (floating popup)
instead of replacing the inline one, and called a second time while already open it moves
focus into the window so `j`/`k` scroll freely without closing it (confirmed this works
after initially looking like the same closing bug - the first call only opens the popup,
cursor stays in the original window; the second call is what actually focuses in).

**Correction (still 2026-09-22, caught same day)**: initially described the popup as
"real wrapping" - checked directly and that's wrong, **the popup doesn't wrap either**
(`vim.wo[winid].wrap` is `false`, confirmed live; no wrap-related option is ever set
anywhere in `gitsigns/popup.lua`). What it actually does: auto-**widens** the floating
window to fit the hunk's longest line (verified live - a ~250-char test line produced a
266-column-wide popup), so on a normal terminal most long lines just fit without any
extra step. For a line wider than the actual terminal, the popup is a real window/buffer
(unlike inline's virtual-lines overlay), so once focused into it (the 2nd-call trick
above), ordinary `nowrap`-window horizontal scrolling (`$`, `zl`, etc.) reaches the rest
of the line - same net result (you can always see 100% of a line) but via width-then-
scroll, not word-wrap.

**Change** - `~/.config/nvim/lua/plugins/gitsigns.lua` (new):
```lua
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      local on_attach = opts.on_attach
      opts.on_attach = function(buffer)
        if on_attach then
          on_attach(buffer)
        end
        vim.keymap.set(
          "n",
          "<leader>ghP",
          function() require("gitsigns").preview_hunk() end,
          { buffer = buffer, desc = "Preview Hunk (Popup)" }
        )
      end
      return opts
    end,
  },
}
```
Wraps (doesn't replace) the default `on_attach` so LazyVim's other 10 `gh*` bindings
stay intact - kept buffer-local (`buffer = buffer`) rather than global, matching how the
rest of gitsigns' keymaps behave (only present in buffers gitsigns actually attaches to,
i.e. git-tracked files).

**Verified live**: headless Neovim, opened a real file inside this git repo, forced
`VeryLazy` + `LazyFile`. Confirmed `<leader>ghP` registers as a **buffer-local** keymap
(not global) with `desc = "Preview Hunk (Popup)"`, and all 10 of LazyVim's original
`gh*` mappings (`s`, `r`, `S`, `u`, `R`, `p`, `b`, `B`, `d`, `D`) are still present
alongside it - the `on_attach` wrap didn't drop anything.

**`flash.nvim` decision**: kept, no changes beyond the `gs`/`gS` rebind from the
previous follow-up.

## Follow-up: <leader>ghP now auto-focuses in one keypress (2026-09-22)

**What**: previously `<leader>ghP` opened the popup but left focus in the original
window - needed pressing it a second time to actually move focus in for scrolling.
Changed it to call `gs.preview_hunk()` twice within the single keymap callback, so one
keypress does both (open, then focus) instead of requiring a second manual press.

**Why this is safe to call twice back-to-back with no delay**: `preview_hunk()`'s own
first lines are `if popup.is_open('hunk') then popup.focus_open('hunk'); return end` -
i.e. calling it while already open is the officially-intended way to focus in, not a
workaround. Tested whether the two calls needed a `vim.schedule`/delay between them in
case window creation is async - checked directly (headless, two synchronous calls with
no `vim.wait` in between): current window ends up being the popup, not the original,
confirming no delay is needed - hunk data is already cached from gitsigns' background
tracking, so window creation completes synchronously within the same call.

**Change** - `~/.config/nvim/lua/plugins/gitsigns.lua`:
```lua
vim.keymap.set("n", "<leader>ghP", function()
  local gs = require("gitsigns")
  gs.preview_hunk()
  gs.preview_hunk()
end, { buffer = buffer, desc = "Preview Hunk (Popup, focused)" })
```

**Verified live**: headless Neovim, real git repo, simulated the actual `<leader>ghP`
keypress (not just calling the Lua function directly). Confirmed via
`nvim_get_current_win()` that focus ends up on the floating popup window
(`relative = "win"`), not the original file window, after a single keypress.

## Follow-up: plugin review results so far (2026-09-22)

Continuing the one-by-one review pass:
- `persistence.nvim` (session save/restore per project) - tested live, **kept**, no
  changes - already just LazyVim's default.
- `nvim-treesitter-textobjects` (`]f`/`[f`/`]c`/`[c`/`]a`/`[a` - jump between
  function/class/parameter boundaries) - tested live, **not useful, disabled**. Note
  this is unrelated to `mini.ai` (the `af`/`if`/`daf`/etc. select-a-function plugin),
  which stays - LazyVim splits "jump between" and "select" into two separate plugins.

**Change** - `~/.config/nvim/lua/plugins/disabled.lua`, appended:
```lua
{ "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },
```

**Verified live**: headless Neovim, forced `VeryLazy`. Confirmed the plugin no longer
appears in `require('lazy').plugins()` at all, and `]f` has no buffer-local keymap in a
`.cpp` buffer (previously bound by this plugin).

## Follow-up: mini.ai disabled (2026-09-22)

**What**: `mini.ai` (`af`/`if`/`daf`/`diu`/`dae` etc. - select function/class/call/
camelCase-segment as a text object) - tested live, decided not needed. Unrelated to
`mini.pairs` (autopairs), a separate mini.nvim module - stays enabled.

**Change** - `~/.config/nvim/lua/plugins/disabled.lua`, appended:
```lua
{ "nvim-mini/mini.ai", enabled = false },
```

**Verified live**: headless Neovim, forced `VeryLazy`. Confirmed `mini.ai` no longer
appears in `require('lazy').plugins()`.

## Follow-up: wired up real formatters for C/C++/Python (2026-09-22)

**What**: testing `conform.nvim` revealed LazyVim's defaults only configure formatters
for `lua`/`fish`/`sh` - zero for C/C++/Python/Markdown, since those come from
language "extras" this setup deliberately skipped. `<leader>cf`/format-on-save were
silently no-ops for every language actually in use. Installed and wired up real
formatters rather than leaving the plugin as dead weight.

**Decisions** (asked rather than picked unilaterally, per the standing "ask before
subjective calls" rule):
- Python: **ruff format** over black - fast (Rust), black-compatible output, and since
  `nvim-lint` also has zero Python linters configured, ruff can cover both jobs later
  from one already-installed tool instead of adding two.
- Markdown: **skipped** - the standard tool (prettier) needs npm/Node, which this setup
  has deliberately avoided pulling in (HTML/JS/TS treesitter parsers were already
  removed for the same reason - see the very first follow-up above).
- C/C++: `clang-format` - not really a decision, it's the standard tool and was **already
  installed system-wide** (`/usr/bin/clang-format`, part of the `clang` package) -
  nothing new to install, just wire it up.

**Change** - `~/.config/nvim/lua/plugins/formatting.lua` (new):
```lua
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cpp = { "clang-format" },
        c = { "clang-format" },
        python = { "ruff_format" },
      },
    },
  },
}
```

**Installed**: `ruff` via Mason (`require('mason-registry'):get_package('ruff'):install()`,
driven directly through the Lua API rather than the `:MasonInstall` ex-command - that
command isn't registered yet right after forcing `VeryLazy` in a scripted headless
session, same class of headless-Mason friction noted in the original migration entry
above). Confirmed installed: `ruff 0.16.8` at
`~/.local/share/nvim/mason/bin/ruff`.

**Not auto-installed on a fresh machine**: unlike LSP servers (auto-installed by
`mason-lspconfig.nvim` when a matching filetype is opened), conform's formatters have no
such auto-install bridge in this setup (would need `mason-tool-installer.nvim`, not
installed - one tool didn't justify adding a whole plugin for it). Reproducing this on a
fresh machine needs one extra manual step: `:MasonInstall ruff` (or the Lua snippet
above) after the initial `:Lazy sync`. `clang-format` has no such gap since it's a
system package, not Mason-managed.

**Verified live**: headless Neovim, real messy files. C++: `int main(){int x=1;return
x;}` -> properly braced/indented/spaced 4-line output via `clang-format`. Python:
`x=1` / `y =2` -> `x = 1` / `y = 2` via `ruff_format`. `list_formatters()` confirms
exactly one formatter resolves per filetype as configured, no unexpected fallbacks.

## Follow-up: nvim-lint disabled (2026-09-22)

**What**: `nvim-lint` - decided not needed after discussing what linters actually add on
top of formatters/LSP diagnostics. Concretely checked this setup's actual state first:
**C++ has no LSP attached at all** (not clangd, nothing - confirmed live, a bigger gap
than "no linter"), and **Python's `ruff` already attaches as an LSP** (side effect of
installing it as a conform.nvim formatter in the previous follow-up) and surfaces its own
lint diagnostics inline already - making a separate `nvim-lint` + ruff wiring redundant
for Python specifically. No linter was ever configured for any language in use anyway
(`linters_by_ft` only had `fish` by default).

**Change** - `~/.config/nvim/lua/plugins/disabled.lua`, appended:
```lua
{ "mfussenegger/nvim-lint", enabled = false },
```

**Verified live**: headless Neovim, forced `VeryLazy`. Confirmed `nvim-lint` no longer
appears in `require('lazy').plugins()`.

**Flagged, not yet acted on**: C++ has zero LSP (`clangd`) set up - no diagnostics,
go-to-definition, or hover for C/C++ at all currently. This is a separate, bigger
decision than the linter question - revisit if/when C++ tooling depth becomes a priority.

## Follow-up: plugin review - noice/bufferline kept, trouble.nvim disabled (2026-09-22)

- `bufferline.nvim` (tab-style open-buffers bar) - tested live, **kept**, no changes.
- `noice.nvim` (floating cmdline/messages/popup UI) - tested live, **kept**, no changes.
- `grug-far.nvim` (project-wide search/replace UI) - discussed the built-in
  quickfix-based alternative (`:grep` + `:cfdo s///g | update` - `rg` already installed
  and wired as `grepprg`, confirmed live), which needs no plugin but has no live preview.
  **Kept** grug-far for the preview.
- `trouble.nvim` (diagnostics/symbols/references panel) - tested live, **not needed,
  disabled**.

**Change** - `~/.config/nvim/lua/plugins/disabled.lua`, appended:
```lua
{ "folke/trouble.nvim", enabled = false },
```

**Verified live**: headless Neovim, forced `VeryLazy`. Confirmed `trouble.nvim` no
longer appears in `require('lazy').plugins()`.

## Follow-up: todo-comments.nvim kept, fixed its 4 dead keymaps (2026-09-22)

**What**: `todo-comments.nvim` tested live and kept. Its LazyVim default keymaps include
2 that depend on `trouble.nvim` (disabled in the previous follow-up) and 2 that depend on
Telescope - which isn't installed in this setup **at all** (picker is `snacks`, confirmed
via `lazyvim_picker`/the actual installed plugin list) - so all 4 would error if pressed.
Confirmed live before deciding what to do: `TodoTelescope` and `TodoTrouble` both fail.

**Decision** (asked, since this had real options): `<leader>xt`/`<leader>xT`
(Trouble-dependent) dropped outright - no working replacement without Trouble.
`<leader>st`/`<leader>sT` (Telescope-dependent) rerouted to Snacks' grep picker instead,
pre-filled with the todo keywords as a regex search.

**Change** - `~/.config/nvim/lua/plugins/todo-comments.lua` (new):
```lua
return {
  {
    "folke/todo-comments.nvim",
    -- stylua: ignore
    keys = {
      { "<leader>xt", false },
      { "<leader>xT", false },
      { "<leader>st", function() Snacks.picker.grep({ search = "TODO|FIX|FIXME|HACK|WARN|PERF|NOTE" }) end, desc = "Todo" },
      { "<leader>sT", function() Snacks.picker.grep({ search = "TODO|FIX|FIXME" }) end, desc = "Todo/Fix/Fixme" },
    },
  },
}
```

**Verified live**: headless Neovim. `<leader>xt`/`<leader>xT` are now simply unbound
(harmless "no mapping" instead of a Lua error). `<leader>st`/`<leader>sT` resolve to the
new `desc`s ("Todo"/"Todo/Fix/Fixme"), confirming they're overridden, not just
coexisting with the old broken ones. Functional test: simulated the actual `<leader>st`
keypress on a file containing a `// TODO:` comment - window count jumped from 1 to 5
(Snacks picker's input/results/preview windows), confirming the picker genuinely opens
with no error, not just that the keymap resolves.

## Follow-up: plugin review pass complete (2026-09-22)

`which-key.nvim` (keybinding popup) and `lualine.nvim` (statusline) - both kept, no
changes. This closes out the one-by-one review started earlier this session.

**Final results, 14 plugins reviewed** (core infra like `lazy.nvim`/`LazyVim`/
`plenary.nvim`/`nui.nvim`/`mini.icons`/`mason.nvim`/`mason-lspconfig.nvim`/
`nvim-lspconfig`/`nvim-treesitter` core excluded - not practical to test standalone):

| Plugin | Verdict |
|---|---|
| `flash.nvim` | kept - rebound off `s`/`S` to `gs`/`gS` |
| `gitsigns.nvim` | kept - added `<leader>ghP` popup preview |
| `persistence.nvim` | kept, unchanged |
| `nvim-treesitter-textobjects` | **disabled** |
| `mini.ai` | **disabled** |
| `conform.nvim` | kept - wired up `clang-format` (C/C++) + `ruff format` (Python), installed `ruff` |
| `nvim-lint` | **disabled** |
| `grug-far.nvim` | kept |
| `bufferline.nvim` | kept, unchanged |
| `noice.nvim` | kept, unchanged |
| `trouble.nvim` | **disabled** |
| `todo-comments.nvim` | kept - fixed 4 keymaps broken by the trouble.nvim/no-telescope situation |
| `which-key.nvim` | kept, unchanged |
| `lualine.nvim` | kept, unchanged |

`blink.cmp` and `mini.pairs` were excluded from the keep/remove decision since they
already have runtime toggles (`<leader>ac`, `<leader>up`) instead.

**Still flagged, not addressed**: C++ has no LSP (`clangd`) attached at all - no
diagnostics/go-to-def/hover for C/C++. Bigger, separate decision from anything in this
review pass.

## Follow-up: personal cheatsheet on g? (2026-09-22/23)

**What**: built a searchable personal cheatsheet - `g?` opens `~/.config/nvim/
cheatsheet.md` in a centered floating window and immediately launches a live
fuzzy-search-with-preview over its lines, so typing e.g. "buffer" filters straight to
the relevant section.

**Why not an existing plugin**: researched `cheatsheet.nvim` and `legendary.nvim` first
rather than assuming nothing existed. Neither actually fit: `cheatsheet.nvim`'s
no-Telescope fallback just dumps every bundled sheet concatenated into one static
floating window with no live fuzzy filter (this setup uses Snacks, not Telescope), and
its bundled content wouldn't cover this setup's own customizations (grug-far, the
`gs`/`gS` rebind, `<leader>ghP`, etc.) regardless. `legendary.nvim`/`which-key.nvim`
(already installed) surface keymap -> one-line-description pairs, not the prose
"how does `:%s` relate to grug-far" explanations actually being asked for. That gap
needed real curated content either way, so built it directly on what's already
installed (`Snacks.picker.lines()`) instead of adding a new dependency for a UI shell
that wouldn't add anything Snacks doesn't already do here.

**Also compared Telescope vs Snacks broadly** before settling on Snacks (the user asked
directly) - Snacks is confirmed to be LazyVim's own current default (its internal
`checks.picker` order is `snacks -> fzf -> telescope`), everything built this session
already assumes it, and it already has the frecency/live-search capability needed here
built in. Telescope's edge is a larger/older extension ecosystem, not a fit for this
specific need.

**Keybinding decision** (3 rounds of live-checking before landing on one - worth
recording since it's a good example of why "verify live, not by assumption" matters):
1. Bare `?` considered first - rejected without discussion needed, it's native
   backward-search, used constantly, no simple substitute the way `s`/`S` had `cl`/`cc`.
2. `<leader>?` recommended next, assumed free by analogy to the earlier `<leader>a`
   check - **wrong**, confirmed live it's already LazyVim's "Buffer Keymaps (which-key)"
   binding, a genuinely useful existing feature (shows buffer-local keymaps for
   whatever you're currently in). Caught only because the user pointed at checking
   before proceeding, not because it was checked proactively first this time - a real
   process miss.
3. `<F1>` and `g?` both confirmed free via `nvim_get_keymap`. `<F1>` was the first
   instinct (universal "help" convention), but user raised that a terminal emulator or
   window manager could intercept a function key before Neovim ever sees it - checked
   `~/.config/kitty/kitty.conf` and `~/.config/hypr/` directly, no F1 binding at either
   layer *today*, but function keys are structurally the class most likely to get
   grabbed by a lower layer, a risk plain letter-combos like `g?` don't have at all.
   Landed on **`g?`** - native `g?` is ROT13-encode-a-motion, essentially unused, and it
   keeps a `?` in the key, closest to the original ask.

**Change** - `~/.config/nvim/cheatsheet.md` (new, ~150 lines): topic sections covering
Buffers, Tabs, Windows/Splits, Search & Replace (both `:%s` and grug-far, as asked),
Git, Comments, Flash navigation, Autocomplete, Formatting, Autopairs, Snacks
find/search, LSP (including the still-open C++-has-no-LSP gap), Sessions, and
Discoverability - each entry covers the actual keys wired up in *this* setup, not
generic Vim defaults.

`~/.config/nvim/lua/config/keymaps.lua`, appended:
```lua
vim.keymap.set("n", "g?", function()
  local path = vim.fn.stdpath("config") .. "/cheatsheet.md"
  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " Cheatsheet ",
  })
  vim.wo[win].wrap = true
  vim.wo[win].conceallevel = 2
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  Snacks.picker.lines({ buf = buf })
end, { desc = "Cheatsheet" })
```

**Verified live**: headless Neovim. `g?` registers with `desc = "Cheatsheet"`.
Simulated the actual keypress: window count jumps from 1 to 6 (base + centered floating
cheatsheet window with a title + Snacks picker's own input/list/preview windows),
confirmed the cheatsheet buffer loaded with all 150 lines. Full close lifecycle also
verified: `<Esc>` drops back to 2 windows (picker closes, cheatsheet stays open), `q`
drops back to 1 (cheatsheet closes cleanly too).

## Follow-up: cheatsheet UX rewrite - dropped the double-window, made confirm just close (2026-09-23)

**What**: real usability problems with the first cut, reported directly: "both line
search and entire file are opening" (the separate pre-opened floating window plus the
picker's own UI showing at once was visually cluttered) and selecting a result "directed
[to] the complete buffer at that line" (jarring - dumped into a raw scrollable file
instead of just answering the lookup), making it barely better than just using `:help`.

**Fix**: removed the separate `nvim_open_win` floating window entirely - the picker's
own preview pane already renders the matched section with context, so pre-opening a
second window showing the same file was pure duplication. Overrode the default
`confirm` action (which is `jump` - Snacks' own source confirms this at
`snacks/picker/actions.lua:197`) to `"close"` (a built-in action, confirmed present in
the same file) instead, since this is a reference lookup, not somewhere to go edit -
selecting a result now just closes the picker and returns you to whatever you were
doing, rather than navigating anywhere.

**Change** - `~/.config/nvim/lua/config/keymaps.lua`, `g?` handler simplified to:
```lua
vim.keymap.set("n", "g?", function()
  local path = vim.fn.stdpath("config") .. "/cheatsheet.md"
  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  Snacks.picker.lines({
    buf = buf,
    confirm = "close",
  })
end, { desc = "Cheatsheet" })
```

**Verified live**: tested against a throwaway copy of the file (a live interactive
`nvim --embed` session had the real `cheatsheet.md` open with a swap lock at the time -
correctly left that alone rather than touching its swap file, tested against a copy
instead). Confirmed: opening the picker now shows exactly 5 windows (base + Snacks'
input/list/preview - no extra duplicate floating window), stays at 5 while typing a
filter, and drops straight back to 1 window on `<CR>` (picker closes cleanly, no jump).
Also confirmed the preview pane genuinely renders matching content live - filtering for
"grug" surfaced the actual grug-far section text in one of the picker's windows, not a
blank/broken preview.

## Follow-up: cheatsheet rebuilt as a clean floating window instead of a picker (2026-09-23)

**What**: asked to make it "look similar to noice" after the Snacks-picker rewrite still
wasn't good. Spent real effort trying to reshape `Snacks.picker.lines()`'s layout first
- tried the `vscode` and `select` layout presets (both are single-box designs, closer to
noice's aesthetic than the default `ivy` 3-pane bottom dock), and tried forcing
`preview = "preview"` to get an embedded preview pane. Neither held up: the `lines`
source ties its preview to the "main" window in a way that doesn't cleanly relocate into
a custom layout's preview slot, and after reshaping, filtering for "grug" no longer
reliably surfaced matching content anywhere on screen (verified live, confirmed
empty/not-found rather than assuming). Rather than keep fighting an opaque layout
system, dropped Snacks' picker entirely for this and built a fully self-contained
floating window instead.

**New design**: a single centered floating window with a rounded border and a
" Cheatsheet " title - the same visual recipe noice.nvim itself uses for its own popups
(confirmed via `nvim_win_get_config`: real border table, correct title, 70%-of-screen
sizing). `filetype = "markdown"` for real syntax highlighting of the content. Search is
native Vim `/` (real incremental search + match-count indicator, e.g. `[1/2]`) rather
than a picker - `/` is fed automatically the moment it opens, so you can start typing a
search term immediately. `q` and `<Esc>` both close it.

**Change** - `~/.config/nvim/lua/config/keymaps.lua`, `g?` handler replaced:
```lua
vim.keymap.set("n", "g?", function()
  local path = vim.fn.stdpath("config") .. "/cheatsheet.md"
  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.7)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " Cheatsheet ",
    title_pos = "center",
  })
  vim.wo[win].wrap = true
  vim.wo[win].conceallevel = 2
  vim.wo[win].cursorline = true
  vim.bo[buf].filetype = "markdown"
  local close_opts = { buffer = buf, silent = true }
  vim.keymap.set("n", "q", "<cmd>close<cr>", close_opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", close_opts)
  vim.api.nvim_feedkeys("/", "n", false)
end, { desc = "Cheatsheet" })
```

**Verified live**: tested against a throwaway copy again (the real file still had a live
`nvim --embed` session's swap lock). Confirmed the floating window has a real border
table, title text " Cheatsheet ", and correct dimensions. Confirmed real `/grug<CR>`
search jumps straight to the actual line mentioning grug-far, with Neovim's native
`[1/2]` match-count indicator showing - genuine incremental search, not a simulation.
`q` closes back to a single window cleanly.

**Lesson for later**: two failed iterations before this (the pre-opened-window-plus-
picker version, then the bare `Snacks.picker.lines()` version) both under-verified the
*visual/UX* result even though the underlying mechanics were confirmed working -
"the keymap registers and doesn't error" isn't the same bar as "the actual on-screen
result is good," and this one needed direct user feedback twice to get right.

## Follow-up: cheatsheet rebuilt as a section picker (2026-09-23)

**What**: third and final shape for this. Previous versions searched *lines* of one
markdown file, which meant results were fragments and selecting one dumped you into the
raw document. Rebuilt around **entries**: the markdown is parsed into one entry per
`### Title` block (grouped by the `## Category` above it), the picker fuzzy-matches
entry titles + category, the right pane previews the selected entry, and `<CR>` opens
**only that entry** in its own centered float.

This is what was actually asked for: typing `find` yields "Find text in the current
line" / "Find text in the current file" / "Find text across the whole project" /
"Find files by name" etc. as distinct selectable sections, rather than raw line hits.

**Content**: rewritten and expanded from ~150 lines to **525 lines / 80 entries**
covering find, replace, buffers, windows, tabs, motions, editing, text objects,
registers/clipboard, macros, comments, autocomplete, autopairs, formatting, LSP,
diagnostics, git, sessions, terminal, explorer, UI toggles, scratch buffers - plus a
dedicated "Customizations: default vs current" category listing every key changed from
stock LazyVim, options changed (`shiftwidth`/`tabstop` 2 -> 4), plugins disabled,
plugins added and formatters wired up. Entries that differ from stock LazyVim are
tagged **[custom]** with the default called out.

Content was grounded in a **full dump of the live keymap table** (`nvim_get_keymap` for
global maps, `nvim_buf_get_keymap` in an LSP-attached Python buffer for buffer-local
ones) rather than written from memory - which caught that this setup uses Neovim 0.11+
native LSP bindings (`grn`, `gra`, `grr`, `gri`, `grt`, `gO`, `<C-w>d`) alongside
LazyVim's buffer-local `K`/`gr`/`gD`/`gI`/`gy`, not the older `gd`/`gr`/`K` trio I'd
otherwise have written down.

**Why a custom Snacks source this time**: the two earlier attempts used
`Snacks.picker.lines()`, a built-in source whose preview is wired to the "main" window
and which fought every attempt to reshape its layout. A *custom* source sidesteps all
of that - `Snacks.picker({ items = ..., preview = "preview", format = ... })` takes
arbitrary items, and each item carries its own `preview = { text = ..., ft = ... }`
which the generic `"preview"` previewer renders directly
(`snacks/picker/preview.lua:57`). Layout is the stock `default` preset: centered,
two-pane, list left / preview right.

**Change** - `~/.config/nvim/lua/cheatsheet.lua` (new, 136 lines): markdown parser
(`M.entries()`), single-entry float (`M.show()`), picker (`M.open()`).
`~/.config/nvim/cheatsheet.md` rewritten (525 lines).
`~/.config/nvim/lua/config/keymaps.lua`: `g?` now just calls
`require("cheatsheet").open()`.

In the single-entry float: `q` / `<Esc>` close, `<BS>` goes back to the search list.

**Verified live**: parser yields 80 entries with correct category grouping. Fuzzy
matching verified by driving the picker's `pattern` field programmatically (feedkeys
does **not** reach the picker's floating input in headless mode - an earlier check
showing "80 items, unfiltered" was a test-harness artifact, not a real filtering
failure, and was re-tested properly rather than assumed): `"clipboard"` -> 3 matches
(all genuinely clipboard-related), `"find"` -> 15, `"replace"` -> 5 (exactly the five
Replace entries). Picker opens with a 7-window two-pane layout and the preview pane was
confirmed to render the selected entry's **body** (matched on distinctive content,
`f{char}`, not just the title). `<CR>` confirmed to close the picker and open a single
float titled with the entry name, sized to content (`w=64 h=9`), containing only that
entry's text.

## Follow-up: cheatsheet polish - no backdrop dimming, wrapped preview (2026-09-23)

**What**: reported that "the entire theme is changing" when the cheatsheet opens. Root
cause: Snacks' `default` layout preset doesn't disable the **backdrop** - a full-screen
overlay window at 60% opacity black (`snacks/win.lua:108`, `bg = "#000000"`) drawn
behind the picker, which dims the whole editor and reads as a theme change. Several
other presets (`sidebar`, `vertical`, `select`, `vscode`) set `backdrop = false`
explicitly; `default` doesn't.

Also fixed while in there: the preview pane had `wrap = false` (Snacks' default, which
suits code previews), so prose body lines longer than the pane were cut off at the edge.

**Change** - `~/.config/nvim/lua/cheatsheet.lua`:
```lua
layout = {
  preset = "default",
  layout = { backdrop = false },
},
win = {
  preview = { wo = { wrap = true, linebreak = true } },
},
```
The override survives preset resolution because Snacks only skips preset merging when
your layout already defines a positional box (`layout.layout[1]`), which this doesn't -
so the preset is merged first and these overrides land on top
(`snacks/picker/config/init.lua:225-240`).

**Verified live**: window count dropped 7 -> 6 and the full-screen `rel=editor w=80
h=24` overlay is gone (explicit check for fullscreen editor-relative windows now
returns 0). Preview window confirmed `wrap=true linebreak=true`. Borders were already
rounded (`╭`) so they already matched the single-entry float - no change needed there,
confirmed rather than assumed.

## Follow-up: cheatsheet content deepened, with UI sketches (2026-09-23)

**What**: content expanded 525 -> **949 lines, 85 entries across 24 categories**. Every
entry that produces visible UI now carries a "What you see" sketch - what the screen
actually looks like when you press the key - rather than just naming the binding.
Examples: the `<lead>ghP` hunk popup (with its real `Hunk 1 of 3` header, taken from
gitsigns' own format string rather than invented), flash labels appearing over matches
for `gs`, the grep picker's two-pane layout, the completion menu, the bufferline, split
layouts, `:%s///gc`'s confirm prompt with what each key does, grug-far's before/after
list, gutter signs, `K` hover docs, which-key's popup, and before/after pairs for
`cw` vs `ciw`, autopairs, comments, formatting and `<C-a>`.

Sketches are labelled in the file header as representative, not pixel-exact, so nothing
here overclaims to be a literal screenshot.

**Parser hardening**: bodies now contain many fenced code blocks, and a `#` at the start
of a line inside one would previously have been parsed as a heading, silently splitting
or swallowing entries. The parser now tracks fence state and ignores headings inside
fenced blocks.

**Search quality fix (found by testing, not assumed)**: matching ran against
`title .. category` only, so searching **"hunk" returned zero results** - the git entries
were titled "Preview a change - popup", "Move between changes" etc. and never contained
the word. Tried including the whole body in the match text: that fixed "hunk" but
wrecked "find" (69 hits, wrong entry ranked first). Landed on matching
`title + category + the backtick-quoted key/command spans from the body` - keys become
searchable without dragging in prose noise - **and** renamed the vague git/autopairs
titles to contain the nouns people actually search for.

Measured before vs after:
```text
  query        before            after
  "hunk"       0 matches         6, top = Preview a hunk inline
  "ghP"        0 matches         1, exactly the right entry
  "gutter"     (n/a)             5, top = See changed lines in the gutter
  "ciw"        -                 12, top = cw vs ciw
  "replace"    5                 8, all Replace entries
  "find"       15                23, still all Find-ish at the top
```

**Change** - `~/.config/nvim/cheatsheet.md` rewritten;
`~/.config/nvim/lua/cheatsheet.lua` gains fence-aware parsing and a `key_terms()`
helper that extracts backtick spans for the match text.

**Verified live**: 85 entries / 24 categories parse correctly with the fenced blocks
intact (spot-checked the `<lead>ghP` entry's body end-to-end - mockup preserved
verbatim). Preview pane confirmed to render the sketch content. Backdrop still absent
(0 fullscreen windows) and preview wrap still on - checked for regressions rather than
assuming the earlier fixes survived the rewrite.

## Follow-up: cheatsheet completeness audited to 279/283 keymaps (2026-09-23)

**What**: asked whether the cheatsheet really covers everything. Rather than assert it
did, wrote a **coverage audit**: extract every backtick-quoted key from the doc, dump
every described keymap from the live editor (`nvim_get_keymap` across normal, visual,
insert and operator-pending), and diff them. Result went **205 -> 279 of 283** described
keymaps documented (98.6%) after filling the gaps it found.

**Two real bugs the audit exposed** (both were shipping, not just audit-side):

1. **Backtick-span extraction was corrupt.** Pairing backticks left-to-right breaks on
   any odd-count construct. The file has 70 ```` ``` ```` fence lines plus four
   double-backtick spans (used to write a literal backtick, e.g. the leader-backtick
   buffer switch). Each one shifts the pairing of every span after it - so
   `documented["<lead>bd"]` came back nil despite being in the file twice. The same
   flaw was in the shipped `key_terms()` in `cheatsheet.lua`, meaning the picker's
   search keywords were partly garbage. Fixed by stripping fenced blocks before
   extraction, and rewriting the four nested-backtick constructs to avoid nesting.
2. **Keys buried in fenced blocks aren't searchable.** A fenced ASCII table of
   `grn / gra / grr / ...` looks fine to a reader but is invisible to `key_terms()`, so
   typing `grr` found nothing. Converted those to inline bullet spans. Same treatment
   for the `[`/`]` bracket-pair targets.

**Content gaps it found and filled** (whole feature areas that were simply absent):
quickfix list, location list, the `[`/`]` paired-jump convention, treesitter
incremental selection (`<C-Space>`, `an`/`in`, `]n`/`[n`), flash in operator-pending
mode (`r`/`R`), `<C-s>` save, `gx` open-link-under-cursor, `<lead>K` keywordprg,
Lazy/Mason (`<lead>l`, `<lead>L`, `<lead>cm`), the profiler (`<lead>dp*`), highlight and
treesitter inspectors (`<lead>ui`, `<lead>uI`, `<lead>uT`, `<lead>sH`), the icons picker,
the full noice group, snippet jumping (`<Tab>`/`<S-Tab>`), Neovim 0.11+'s native LSP
family (`grn`/`gra`/`grr`/`gri`/`grt`/`grx`/`gO`), and the Vim defaults LazyVim keeps
(screen-line `j`/`k`, `&`, `Y`, visual `@`).

Content is now **1108 lines / 101 entries / 27 categories**.

**The 4 remaining are not real gaps**:
- `)` and a backtick in insert mode - mini.pairs' internal open/close actions, not keys
  you press deliberately; the Autopairs entry covers the behaviour
- `<lead>sn` - a which-key *group prefix* ("+noice"), not a command
- leader-then-backtick (Switch to Other Buffer) - documented in prose, but a key
  containing a literal backtick can't be written as a backtick span, so the audit can
  never match it

**Audit method, for repeating it later**: strip fenced blocks from the doc (fences
break span pairing), collect `` `spans` `` into a set, then for each described keymap
try several normalisations of its lhs - literal spaces are the leader, and the leader
can appear leading *or trailing* (`<C-W><space>` is the window hydra, `[<space>` adds a
blank line). Skipping the trailing case is what made the first run falsely report
`<C-w>`, `[`, `]` and `<lead><lead>` as undocumented.
