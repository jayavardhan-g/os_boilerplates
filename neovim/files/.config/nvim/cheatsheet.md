# Cheatsheet

Personal reference for this setup. Open with `g?`, then type to fuzzy-search - the
match's surrounding section shows as a live preview so you get the context, not just
the bare key.

## Buffers

A buffer is a file loaded into memory - not the same thing as a window or a tab.

- `:e {path}` - open a file into a new buffer
- `:enew` - open a blank new buffer
- `<leader>,` or `<leader>fb` - fuzzy-pick any open buffer (Snacks picker)
- `<leader>bj` - pick a buffer by on-screen letter label
- `H` / `L` (or `[b` / `]b`) - previous/next buffer
- `<leader>bb` (or `` <leader>` ``) - switch to the previously-used buffer
- `<leader>bd` - close current buffer, keep the window/split open
- `<leader>bD` - close current buffer AND its window
- `<leader>bo` - close every buffer except the current one
- `<leader>bl` / `<leader>br` - close all buffers to the left/right of current
- `:ls` or `:buffers` - list all open buffers with numbers
- `<leader>?` - show which-key's list of buffer-local keymaps for whatever you're
  currently in (handy inside a plugin's own buffer, e.g. grug-far, to see what's special
  there)

## Tabs

Rarely needed in this setup - buffers + splits cover most of what tabs are for in other
editors. A "tab" here is really a whole separate layout of windows, not a single file.

- `<leader><Tab><Tab>` - new tab
- `<leader><Tab>]` / `<leader><Tab>[` - next/previous tab
- `<leader><Tab>d` - close current tab
- `<leader><Tab>o` - close every other tab
- `<leader><Tab>f` / `<leader><Tab>l` - first/last tab
- Native equivalents if you prefer: `:tabnew`, `gt`/`gT`, `:tabclose`

## Windows / splits

- `:sp` / `<leader>-` - horizontal split
- `:vsp` / `<leader>\|` - vertical split
- `<C-h/j/k/l>` - move focus between splits
- `<C-arrow keys>` - resize the current split
- `<leader>wd` - close current window (keeps the buffer open elsewhere)

## Search & replace

Two genuinely different tools depending on scope:

- `:%s/old/new/g` - substitute in the **current file only**. Add `c` (`:%s/old/new/gc`)
  to confirm each replacement one at a time. This is Vim's native command, always
  available, no plugin needed.
- `<leader>sr` (grug-far.nvim) - search & replace across **multiple files** in the
  project, with a live preview of every match before you commit anything. Pre-fills the
  file filter to the current file's extension. This is the one to reach for when a
  change spans more than one file.
- No-plugin multi-file alternative: `:grep <pattern>` (uses ripgrep) populates the
  quickfix list, then `:cfdo s/old/new/g \| update` replaces across every file in that
  list and saves - faster to type, but no preview before it runs (still fully undoable
  per-file with `u`, nothing saved until `update`).
- `/pattern` / `g?pattern` - search forward / backward in the current buffer (`g?` is
  this setup's rebind - native Vim uses bare `?` for backward search, which this
  cheatsheet keymap took over)
- `n` / `N` - repeat last search, same/opposite direction
- `*` / `#` - search the word under the cursor, forward/backward

## Git (gitsigns.nvim)

Gutter markers (colored bar in the left margin) appear automatically on any changed
line, before you even save.

- `]h` / `[h` - jump to next/previous changed hunk
- `<leader>ghs` / `<leader>ghr` - stage / reset (discard) the hunk under cursor
- `<leader>ghp` - inline diff preview (can't wrap long lines or survive cursor
  movement - see below)
- `<leader>ghP` - popup diff preview instead (this setup's addition) - auto-widens to
  fit long lines, and focuses into the window in one keypress so `j`/`k` scroll it
  without closing
- `<leader>ghb` - blame the current line
- `<leader>ghd` - full diff split for the current file

## Comments

- `gcc` - toggle comment on the current line
- `gc{motion}` (e.g. `gcap`) - comment a motion/paragraph; in visual mode, `gc` comments
  the selection
- `Ctrl+/` - this setup's shortcut for the same thing (`gcc`/`gc`), VSCode-style -
  overrides LazyVim's default terminal-toggle on this key (`<leader>ft` still opens a
  terminal)

## Jump anywhere (flash.nvim)

- `gs` then 2 characters - jump to any visible location on screen matching those
  characters (labels appear on every match)
- `gS` - same idea, but jump between treesitter-aware code structures
- (This setup moved these off the default `s`/`S` to keep native substitute-char/
  substitute-line intact)

## Autocomplete (blink.cmp)

- Type normally in insert mode - a completion menu appears automatically
- `<Tab>` / `<CR>` - accept the selected completion
- `<C-n>` / `<C-p>` - move through completion candidates
- `<leader>ac` - toggle the whole autocomplete engine on/off (this setup's addition,
  for when it gets in the way)

## Formatting (conform.nvim)

- `<leader>cf` - format the current buffer (`clang-format` for C/C++, `ruff format` for
  Python - wired up specifically for this setup, not a LazyVim default)
- Format-on-save is on by default
- `<leader>uf` / `<leader>uF` - toggle auto-format for this buffer / globally

## Autopairs (mini.pairs)

- Typing an opening bracket/quote auto-inserts the closing one
- `<leader>up` - toggle autopairs on/off (LazyVim built-in - useful if it ever gets in
  the way, same spirit as the autocomplete toggle above)

## Find/search anything (Snacks picker)

- `<leader><leader>` or `<leader>ff` - find files by name
- `<leader>sg` - live grep across the project
- `<leader>st` / `<leader>sT` - search for `TODO`/`FIX`/`FIXME`/etc. comments (this
  setup's rerouted version, since the original Telescope-based binding doesn't work
  here - this setup uses Snacks, not Telescope)
- `<leader>sh` - search Neovim's own `:help` pages

## LSP (per-language code intelligence)

- `gd` - go to definition
- `gr` - find references
- `K` - hover docs
- `<leader>ca` - code actions
- `]d` / `[d` - next/previous diagnostic
- **Note**: Python has this via `ruff` (attached automatically). C/C++ currently has
  **no LSP attached at all** - none of the above works for `.cpp`/`.c` files yet
  (`clangd` was never set up in this setup).

## Sessions (persistence.nvim)

- `<leader>qs` - restore the session for the current directory
- `<leader>ql` - restore your most recent session, whatever directory it was in
- `<leader>qS` - pick from all saved sessions
- `<leader>qd` - don't save this session on exit

## Discoverability

- Press `<leader>` and pause - a popup (which-key) shows every available continuation
- `g?` - this cheatsheet
