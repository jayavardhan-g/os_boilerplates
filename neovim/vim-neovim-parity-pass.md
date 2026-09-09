# Vim/Neovim parity pass + leader timeout fix

**Date:** 2026-08-30
**Category:** system
**Files touched:** `~/.vimrc`, `~/.config/nvim/lua/config/options.lua`,
`~/.config/nvim/lua/config/keymaps.lua`, `~/.config/nvim/lua/plugin-list.lua`,
`~/.vim/pack/plugins/start/vim-oscyank/` (new), `~/.vim/pack/plugins/start/auto-pairs/` (new)

## What
Fixed `timeoutlen` (too short to type a `<leader>` sequence comfortably) in both editors,
carried `spelllang` over to Neovim, then did a side-by-side feature audit between
`~/.vimrc` and the Neovim config (see [[vimrc-minimal-visual-config]] and
[[neovim-minimal-ssh-friendly-setup]]) and imported specific items in each direction —
picked interactively, not "import everything."

## Why
"After leader keypress the time to press others is very low" — `timeoutlen` was 300ms in
both configs, too tight for typing e.g. `<leader>ff` or `<leader>to` at a normal pace.
Also wanted the two configs checked for inconsistencies and gaps now that both exist,
since they were built in separate sessions from different starting points.

## Change

### Both editors
```vim
set timeoutlen=1000 " was 300 - more breathing room after <leader>
```
(`~/.vimrc` line; Neovim equivalent is `set.timeoutlen = 1000` in `lua/config/options.lua`.)

```vim
set confirm " Ask (naming the file) instead of silently refusing to close on unsaved changes
```
(`~/.vimrc` line; Neovim equivalent is `set.confirm = true`.) Fixes: closing a modified
buffer (`:q`, `:qa`, `<C-q>`, `<leader>x`) used to just throw a terse `E37` error - easy to
miss entirely since the quit keymaps are `silent`. With `confirm` on, Neovim/Vim instead
shows an interactive dialog naming the exact file and asking whether to save it, and this
happens regardless of `silent` (that keymap option suppresses echoed messages, not
interactive prompts).

### Carried from Vim → Neovim (`lua/config/options.lua` / `lua/config/keymaps.lua`)
```lua
set.spelllang = "en_us,de_de,es_es"
set.showmatch = true -- briefly flash the matching bracket/paren
```
```lua
-- Increment/decrement the number under the cursor
vim.keymap.set("n", "<leader>+", "<C-a>", opts)
vim.keymap.set("n", "<leader>-", "<C-x>", opts)

-- Yank from cursor to end of line via OSC52, like vim's Y = y$
vim.keymap.set("n", "<leader>Y", "<leader>y$", { remap = true, silent = true })
```

### Carried from Neovim → Vim (`~/.vimrc`)
```vim
set incsearch " Highlight search matches as you type the pattern

set undofile " Save undo history
" Without an explicit undodir, undofile scatters hidden .un~ files into
" whatever directory you're editing in - keep them in one place instead.
set undodir=~/.vim/undodir
```
```vim
" Yank via OSC52: lands in your LOCAL machine's clipboard even over a plain
" SSH session with no X/Wayland forwarding (kitty understands OSC52 both
" locally and over SSH), unlike plain "+y which only reaches whatever
" clipboard exists on the box vim is actually running on.
nmap <leader>y <Plug>OSCYankOperator
vmap <leader>y <Plug>OSCYankVisual
nmap <leader>Y <leader>y$
```
This replaced the previous plain-clipboard binds (`noremap <leader>y "+y"` /
`noremap <leader>Y "+Y"`) rather than living alongside them, matching the Neovim config's
choice to make OSC52 the only yank-to-clipboard path (it's a strict superset — also works
locally, not just over SSH).

`vim-oscyank` was installed for classic Vim as a native Vim8/9 package (no plugin manager
needed for this — Vim auto-loads anything under `~/.vim/pack/*/start/*`):
```
git clone --depth=1 https://github.com/ojroques/vim-oscyank ~/.vim/pack/plugins/start/vim-oscyank
```

### Auto-closing brackets/quotes (added 2026-08-31, Neovim swapped 2026-08-31)
Neither editor had this — `showmatch` (already set in both) only flashes the matching
bracket when you type a closing one, it doesn't insert the closing pair for you.

**Vim** (`~/.vim/pack/plugins/start/auto-pairs/`): `jiangmiao/auto-pairs`, installed as a
native Vim8/9 package:
```
git clone --depth=1 https://github.com/jiangmiao/auto-pairs ~/.vim/pack/plugins/start/auto-pairs
```
It's the only real option for classic Vim (pure Vimscript, no Lua). No further config
needed. Last pushed 2024-07-08, ~170 open issues — not abandoned, but low maintenance
velocity for its popularity.

**Neovim** was on the same `jiangmiao/auto-pairs` too at first (added to
`lua/plugin-list.lua`, for identical behavior with Vim), then swapped to
`windwp/nvim-autopairs` after checking both plugins' actual state: `nvim-autopairs` is
**Treesitter-aware** (won't pair brackets inside a string or comment, which matters given
the Treesitter setup this config already has — see
[[neovim-minimal-ssh-friendly-setup]]) and integrates with **nvim-cmp** (already in use
for completion here), and was far more actively maintained (pushed within the past week
vs. `auto-pairs`' mid-2024, ~15 open issues vs. ~170). It's Lua-only, so this is
Neovim-specific — Vim stays on `jiangmiao/auto-pairs`, its only real option anyway. This
is a deliberate, accepted divergence: the two editors no longer behave identically for
this one feature.

`lua/plugin-list.lua`:
```lua
"windwp/nvim-autopairs",
```
`after/plugin/autopairs.lua` (new):
```lua
require("nvim-autopairs").setup({
    disable_filetype = { "TelescopePrompt", "vim" },
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
```
`disable_filetype` and the `cmp` integration snippet are both exactly as documented in
`nvim-autopairs`' own README, not invented.

## Notes
- **Not a real technical conflict**: `~/.vimrc` and `~/.config/nvim/` never load in the
  same process (you run either `vim` or `nvim`), so nothing here can break the other
  editor. The "conflicts" were purely about the same key doing different things depending
  on which editor is running - worth knowing so muscle memory doesn't trip you up, not
  bugs to fix.
- `signcolumn` staying `no` in Vim vs `yes` in Neovim is intentional, not an oversight -
  Neovim needs the gutter for LSP diagnostic icons; plain Vim has no LSP. See
  [[neovim-minimal-ssh-friendly-setup]].
- **Declined, don't re-propose without being asked**: clearing search highlight on `<Esc>`
  (`:noh`) in Neovim - low value since `hlsearch` is already off in both configs; and a
  `<leader>rl` reload-config keybind for Vim - Neovim has one, Vim doesn't, and it was
  explicitly left out.
- `<leader>Y` in both editors is deliberately kept as "yank cursor-to-end-of-line" (vim's
  classic `Y` = `y$` semantics), not "yank whole line" (`yy`) - confirmed this is what was
  wanted before implementing it in Neovim.
- The `<leader>Y` mapping works by re-triggering the already-defined `<leader>y` operator
  mapping with `$` appended, so it needs a **recursive** map (`nmap`/`remap = true`), not
  `noremap` - otherwise `<leader>` + `y` inside the RHS wouldn't resolve back to the
  OSCYank operator.
