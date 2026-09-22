# Cheatsheet

Searchable reference for this exact setup. `<lead>` = Space (the leader key).
Entries marked **[custom]** differ from stock LazyVim - the default is noted too.

## Find & Search

### Find text in the current line
- `f{char}` / `F{char}` - jump to next / previous `{char}` on this line
- `t{char}` / `T{char}` - jump just before next / after previous `{char}`
- `;` / `,` - repeat that jump forward / backward
- `0`, `^`, `$` - start of line, first non-blank, end of line
Only ever acts on the line the cursor is on - never moves you to another line.

### Find text in the current file
- `/pattern` then `<CR>` - search forward from the cursor
- `n` / `N` - next / previous match
- `*` / `#` - search the word under the cursor forward / backward
- `<lead>sb` - fuzzy-search the current buffer's lines in a picker
Search is case-smart: all-lowercase matches any case, adding a capital makes it
case-sensitive.

### Find text across the whole project
- `<lead>sg` - live grep from the project root (ripgrep, fuzzy picker)
- `<lead>/` - same thing, shorter key
- `<lead>sG` - grep from the current working directory instead of project root
- `<lead>sw` / `<lead>sW` - grep the word under the cursor (root / cwd)
Type to filter live; `<CR>` jumps to the match.

### Find text in open buffers only
- `<lead>sB` - grep across all currently open buffers
Useful when you only care about files you already have loaded, not the whole tree.

### Find files by name
- `<lead><lead>` or `<lead>ff` - find files from the project root
- `<lead>fF` - find files from the current working directory
- `<lead>fg` - find only git-tracked files
- `<lead>fc` - jump straight to a Neovim config file
- `<lead>fn` - create a new file

### Find recently used files
- `<lead>fr` - recent files (project root)
- `<lead>fR` - recent files (cwd)
- `<lead>fp` - switch between projects

### Find help, keymaps and commands
- `<lead>sh` - search Neovim's own `:help` pages
- `<lead>sk` - search every keymap currently bound (great for "what was that key?")
- `<lead>sC` - search available commands
- `<lead>sa` - search autocommands
- `<lead>sM` - search man pages
- `<lead>sp` - search plugin specs

### Find TODO / FIXME comments
- `<lead>st` - find all todo-style comments **[custom]**
- `<lead>sT` - find only `TODO` / `FIX` / `FIXME` **[custom]**
- `]t` / `[t` - jump to next / previous todo comment in this file
Default LazyVim binds these to a Telescope command, which errors here because this
setup uses the Snacks picker and has no Telescope. Rerouted to a Snacks grep
pre-filled with the todo keywords.

### Find history (searches, commands, notifications)
- `<lead>s/` - previous searches
- `<lead>sc` or `<lead>:` - command history
- `<lead>n` - notification history
- `<lead>snh` - message history (noice)
- `<lead>snl` - show the last message again

### Find marks, jumps, registers
- `<lead>sm` - list marks
- `<lead>sj` - list the jump list
- `<lead>s"` - list register contents
- `<lead>su` - browse the undo tree

### Clear search highlighting
- `<Esc>` - clear the highlight from the last search
- `<lead>ur` - redraw, clear highlight and refresh diff

## Replace

### Replace inside the current file
- `:%s/old/new/g` - replace every occurrence in the file
- `:s/old/new/g` - replace only on the current line
- `:%s/old/new/gc` - same, but asks for confirmation at each match
`%` means "whole file", `g` means "every match on each line", `c` means "confirm".

### Replace only within a selection
- Select lines in visual mode (`V`), then `:s/old/new/g`
Vim pre-fills `:'<,'>` for you - the range is just the selection.

### Replace the word under the cursor
- `*` to search it, then `:%s//new/g`
Leaving the search pattern empty reuses your last search, so you don't retype it.

### Replace across the whole project
- `<lead>sr` - open grug-far: a full search & replace UI across many files
Shows every match with a live preview of the replacement before anything changes.
Pre-fills the file filter with the current file's extension. This is the one to use
when the change spans more than one file.

### Replace across files without a plugin
- `:grep <pattern>` - populate the quickfix list (uses ripgrep)
- `:cfdo s/old/new/g | update` - run the substitute on every file in that list and save
Faster to type than grug-far, but no preview before it runs. Still undoable per file
with `u`, and nothing is written until `update`.

## Buffers

### What a buffer is
A file loaded into memory. Not the same as a window (a viewport) or a tab (a layout).
One buffer can show in many windows; closing a window doesn't close the buffer.

### Open a file
- `:e {path}` - open a file into a new buffer
- `:enew` - blank new buffer
- `<lead><lead>` - find a file by name and open it

### Switch between buffers
- `H` / `L` - previous / next buffer
- `[b` / `]b` - same thing
- `<lead>bb` or ``<lead>` `` - jump back to the buffer you were just in
- `<lead>,` or `<lead>fb` - fuzzy-pick from open buffers
- `<lead>fB` - include unlisted/hidden buffers too
- `<lead>bj` - pick a buffer by an on-screen letter label

### Close buffers
- `<lead>bd` - close this buffer, keep the window open
- `<lead>bD` - close this buffer and its window
- `<lead>bo` - close every buffer except this one
- `<lead>bl` / `<lead>br` - close all buffers left / right of this one
- `<lead>bP` - close all buffers that aren't pinned
- `<lead>bi` - close buffers that aren't visible anywhere

### Pin and reorder buffers
- `<lead>bp` - pin the current buffer (protects it from `<lead>bP`)
- `[B` / `]B` - move this buffer left / right in the bufferline

### List buffers
- `:ls` or `:buffers` - plain text list with buffer numbers
- `:b {number}` or `:b {name}` - switch directly to one

## Windows & Splits

### Split the window
- `<lead>-` - split below (horizontal)
- `<lead>|` - split right (vertical)
- `:sp {file}` / `:vsp {file}` - split and open a specific file

### Move between splits
- `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` - move focus left / down / up / right
- `<C-w>` then `<lead>` - "window hydra" mode: repeatable window commands

### Resize splits
- `<C-Left>` / `<C-Right>` - narrower / wider
- `<C-Up>` / `<C-Down>` - taller / shorter

### Close or zoom a split
- `<lead>wd` - close this window (buffer stays open elsewhere)
- `<lead>wm` - zoom this split to fill the screen, press again to restore

## Tabs

### What a tab is here
A whole saved layout of windows, not a single file. Most day-to-day switching is
buffers (`H`/`L`), not tabs - tabs are for keeping separate workspaces.

### Create, close, switch tabs
- `<lead><Tab><Tab>` - new tab
- `<lead><Tab>]` / `<lead><Tab>[` - next / previous tab
- `<lead><Tab>f` / `<lead><Tab>l` - first / last tab
- `<lead><Tab>d` - close this tab
- `<lead><Tab>o` - close all other tabs
- Native equivalents: `:tabnew`, `gt` / `gT`, `:tabclose`

## Moving around

### Basic motions
- `h` `j` `k` `l` - left, down, up, right
- `w` / `b` - start of next / previous word; `e` - end of word
- `W` / `B` / `E` - same but whitespace-separated (ignores punctuation)
- `{` / `}` - previous / next paragraph
- `%` - jump to the matching bracket

### Jump to a line or file position
- `gg` / `G` - top / bottom of file
- `{n}G` or `:{n}` - go to line n
- ```` `` ``` - jump back to where you just were

### Jump to any visible spot on screen
- `gs` then 2 characters - labels appear on every match, press the label to jump **[custom]**
- `gS` - same, but jumps between code structures (treesitter)
Default LazyVim binds these to `s` / `S`, which steals Vim's substitute-char and
substitute-line. Moved to `gs` / `gS` so `s` / `S` keep working normally.

### Scroll the view
- `<C-d>` / `<C-u>` - half page down / up
- `<C-f>` / `<C-b>` - full page forward / backward
- `zz` / `zt` / `zb` - center / top / bottom the cursor line on screen

### Jump list (go back and forward)
- `<C-o>` - go back to where you were
- `<C-i>` - go forward again
- `<lead>sj` - browse the whole jump list

### Marks
- `m{a-z}` - set a mark at the cursor
- `` `{a-z} `` - jump to that mark
- `<lead>sm` - list all marks

## Editing

### Enter insert mode
- `i` / `a` - insert before / after the cursor
- `I` / `A` - insert at first non-blank / end of line
- `o` / `O` - open a new line below / above
- `<Esc>` - back to normal mode

### Delete, change, yank
- `d{motion}` - delete (e.g. `dw` word, `dd` line, `d$` to end of line)
- `c{motion}` - change: delete then enter insert (e.g. `cw`, `cc`, `C`)
- `y{motion}` - yank/copy (e.g. `yw`, `yy`, `Y`)
- `p` / `P` - paste after / before the cursor
- `x` - delete the character under the cursor **[custom: doesn't touch your clipboard]**

### `cw` vs `ciw`
- `cw` changes from the cursor to the *end* of the word (really `ce`)
- `ciw` changes the *entire* word regardless of where the cursor sits in it
`ciw` is almost always what you actually want.

### Undo and redo
- `u` - undo
- `<C-r>` - redo
- `<lead>su` - browse the full undo tree

### Repeat and shortcuts
- `.` - repeat the last change
- `J` - join this line with the one below
- `~` - toggle the case of a character
- `<C-a>` / `<C-x>` - increment / decrement the number under the cursor

### Indent and move lines
- `>>` / `<<` - indent / unindent the line
- In visual mode `>` / `<` - indent the selection (reselect with `gv`)
- `<M-j>` / `<M-k>` - move the current line down / up
- `]<lead>` / `[<lead>` - add an empty line below / above without leaving normal mode

## Text objects

### Inside vs around
- `i` = inside (contents only), `a` = around (contents plus delimiters)
- `di"` deletes what's inside the quotes; `da"` deletes the quotes too
Works with any operator: `d`, `c`, `y`, `v`.

### Common text objects
- `iw` / `aw` - word
- `i"` `i'` `` i` `` - quoted string
- `i(` `i[` `i{` - bracket contents (also `ib` / `iB`)
- `ip` / `ap` - paragraph
- `it` / `at` - HTML/XML tag
Note: the extra "smart" objects (`af` function, `ac` class, `au` call) came from
mini.ai, which is disabled in this setup.

## Registers & Clipboard

### How registers work
- `"{reg}y` - yank into a named register, e.g. `"ayy`
- `"{reg}p` - paste from it, e.g. `"ap`
- `"0` holds your last yank; `""` holds the last delete
- `<lead>s"` - browse all register contents

### Copy to the system clipboard
- `<lead>y` - yank selection/motion to the system clipboard **[custom]**
- `<lead>Y` - yank to end of line to the system clipboard **[custom]**
Plain `y` / `yy` stay internal on purpose, so normal yanks don't overwrite what you
copied from the browser. Over SSH this routes through OSC 52, so it reaches your
*local* machine's clipboard with no X/Wayland forwarding.

### Delete without clobbering the clipboard
- `x` deletes into the black-hole register **[custom]**
Stock Vim's `x` overwrites the unnamed register, which quietly destroys whatever you
last yanked. This version doesn't.

## Macros

### Record and replay
- `q{a-z}` - start recording into that register; `q` again to stop
- `@{a-z}` - replay it
- `@@` - replay the last macro again
- `{n}@{a-z}` - replay it n times

## Comments

### Toggle comments
- `gcc` - toggle the current line
- `gc{motion}` - toggle a motion (e.g. `gcap` a paragraph); in visual mode `gc`
- `<C-/>` (or `<C-_>`) - same as `gcc` / `gc`, VSCode-style **[custom]**
Default LazyVim uses `<C-/>` to toggle a terminal. That moved aside - terminal is
still on `<lead>ft`. Comment syntax per language comes from Neovim itself, so it's
correct in C, C++, Python, Markdown, etc.

### Add a comment line
- `gco` - add a comment on a new line below
- `gcO` - add one above

## Autocomplete

### Using the completion menu
- Just type - the menu appears automatically in insert mode
- `<CR>` or `<Tab>` - accept the selected item
- `<C-n>` / `<C-p>` - next / previous candidate
Sources: LSP, snippets, file paths, and words from open buffers.

### Turn autocomplete on or off
- `<lead>ac` - toggle the whole completion engine **[custom]**
Added because it gets in the way when writing prose or moving fast. Shows an
on/off notification and remembers the state until you flip it back.

### Inline "ghost text" is off
Stock LazyVim shows a greyed-out preview of the top candidate ahead of your cursor
(`ghost_text` follows `vim.g.ai_cmp`, which defaults on). That's disabled here
**[custom]** - the dropdown menu still works normally.

## Autopairs

### Behaviour
Typing `(`, `[`, `{`, `"` or `'` inserts the closing half automatically. It skips
auto-closing when the next character is a word character, and inside strings.

### Turn it off
- `<lead>up` - toggle autopairs (this is a stock LazyVim toggle, not custom)

## Formatting

### Format the current file
- `<lead>cf` - format the whole buffer
- `<lead>cF` - format injected languages (e.g. code blocks inside markdown)

### Format on save
On by default. Toggles:
- `<lead>uf` - toggle auto-format for this buffer
- `<lead>uF` - toggle auto-format globally

### Which formatter runs
- C and C++ -> `clang-format` **[custom]** (already installed system-wide via the
  `clang` package)
- Python -> `ruff format` **[custom]** (installed through Mason)
- Lua / fish / sh -> `stylua` / `fish_indent` / `shfmt` (LazyVim defaults)
- Markdown -> nothing, deliberately (the usual tool, prettier, needs npm/Node)
Stock LazyVim configures **no** formatter for C, C++ or Python at all - those come
from language "extras" that this setup skips - so `<lead>cf` silently did nothing on
those files until this was wired up.

## LSP (code intelligence)

### Go to things
- `gd` - go to definition (when the attached server supports it)
- `gD` - go to declaration
- `gr` - list references
- `gI` - go to implementation
- `gy` - go to type definition
- `gO` - document symbols
- `<C-o>` - jump back after any of these

### Read and change code
- `K` - hover documentation for the symbol under the cursor
- `<lead>ca` - code actions (quick fixes, refactors)
- `<lead>cA` - source-level actions
- `grn` - rename the symbol everywhere (Neovim native binding)
- `<lead>cl` - LSP info: which servers are attached to this buffer
- `<lead>cm` - open Mason to install/manage servers

### C and C++ have no LSP (known gap)
Nothing is attached for `.c` / `.cpp` files - no definitions, references, hover or
diagnostics. `clangd` was never set up. Python works (`ruff` attaches automatically).
Formatting still works for C/C++ because `clang-format` runs independently of any LSP.

## Diagnostics

### Move between problems
- `]d` / `[d` - next / previous diagnostic
- `]e` / `[e` - next / previous error only
- `]w` / `[w` - next / previous warning only
- `]D` / `[D` - last / first diagnostic in the file

### See the details
- `<lead>cd` - show the diagnostic for the current line
- `<C-w>d` - show the diagnostic under the cursor in a float
- `<lead>sd` - searchable list of all diagnostics
- `<lead>sD` - diagnostics for this buffer only
- `<lead>ud` - toggle diagnostics display on/off

## Git

### See what changed
Changed lines get a colored bar in the left gutter automatically, before you save.
- `<lead>gs` - git status picker
- `<lead>gd` - diff of current hunks
- `<lead>gD` - diff against origin
- `<lead>gl` / `<lead>gL` - git log (project / cwd)
- `<lead>gf` - history of just the current file

### Move between changes
- `]h` / `[h` - next / previous changed hunk

### Stage and undo changes
- `<lead>ghs` - stage the hunk under the cursor
- `<lead>ghr` - reset (discard) that hunk
- `<lead>ghS` - stage the whole file
- `<lead>ghu` - undo the last stage
- `<lead>ghR` - reset the whole file

### Preview a change
- `<lead>ghp` - inline preview, drawn into the buffer
- `<lead>ghP` - popup preview, focused immediately **[custom]**
The inline one can't wrap long lines (Neovim's virtual-line API has no wrap mode) and
closes the moment the cursor moves, so wide or tall hunks are unreadable. The popup
version auto-widens to fit, and this custom binding focuses it in a single keypress so
`j`/`k` scroll it without closing. Press `q` to close.

### Blame
- `<lead>ghb` - blame the current line (gitsigns)
- `<lead>gb` - blame line (Snacks)
- `<lead>ghB` - blame the whole file

### GitHub
- `<lead>gi` / `<lead>gI` - open issues / all issues
- `<lead>gp` / `<lead>gP` - open pull requests / all
- `<lead>gB` - open the current file on GitHub in a browser
- `<lead>gY` - copy that link instead

## Sessions

### Restore your layout
- `<lead>qs` - restore the session for this directory
- `<lead>ql` - restore the most recent session, whatever directory
- `<lead>qS` - pick from all saved sessions
Sessions save open buffers and window layout per project, automatically on exit.

### Skip saving
- `<lead>qd` - don't save this session when quitting
- `<lead>qq` - quit everything

## Terminal

### Open a terminal
- `<lead>ft` - terminal at the project root
- `<lead>fT` - terminal at the current working directory
- `<C-/>` used to do this in stock LazyVim, but that key is the comment toggle here.

## File explorer

### Browse files in a tree
- `<lead>e` - explorer from the project root
- `<lead>E` - explorer from the current working directory
- `<lead>fe` / `<lead>fE` - same pair, alternate keys

## UI toggles

### Common toggles (`<lead>u` prefix)
- `<lead>uw` - wrap long lines
- `<lead>ul` - line numbers, `<lead>uL` - relative numbers
- `<lead>us` - spell check
- `<lead>ud` - diagnostics
- `<lead>uh` - inlay hints
- `<lead>uc` - conceal level
- `<lead>ug` - indent guides
- `<lead>uz` - zen mode, `<lead>uZ` - zoom
- `<lead>ub` - dark/light background
- `<lead>uC` - pick a colorscheme
- `<lead>un` - dismiss all notifications
- `<lead>ua` - animations, `<lead>uS` - smooth scroll, `<lead>uD` - dimming
- `<lead>ac` - autocomplete **[custom, not under the `u` prefix]**

## Scratch buffers

### Quick throwaway notes
- `<lead>.` - toggle a scratch buffer
- `<lead>S` - pick from existing scratch buffers
Scratch buffers persist per project, useful for notes or trying snippets.

## Customizations: default vs current

### Keys changed from stock LazyVim
- `s` / `S` -> flash jump ............ now `gs` / `gS`, `s`/`S` are native substitute
- `<C-/>` -> terminal ................ now toggle comment (terminal on `<lead>ft`)
- `x` -> delete into unnamed register  now deletes into black hole
- `<lead>st` / `<lead>sT` -> Telescope  now Snacks grep (no Telescope installed)
- `<lead>xt` / `<lead>xT` -> Trouble ... removed (Trouble is disabled)
- new: `<lead>ac` toggle autocomplete
- new: `<lead>ghP` focused hunk popup
- new: `<lead>y` / `<lead>Y` clipboard yank (OSC 52 over SSH)
- new: `g?` this cheatsheet (native `g?` is ROT13, unused)

### Options changed
- `shiftwidth` / `tabstop`: LazyVim default `2` -> **`4`** everywhere
- `expandtab`: stays `true` (spaces, not tabs)
- Indent *logic* is treesitter-based already; only the width changed.

### Plugins disabled
- `nvim-treesitter-textobjects` - `]f`/`[f` structural jumps, not useful
- `mini.ai` - `af`/`if` smart text objects, not needed
- `nvim-lint` - no linters were configured; ruff's LSP already reports Python lint
- `trouble.nvim` - diagnostics panel, not needed
- `tokyonight` / `catppuccin` - colors come from `colors/kitty.lua` instead
- `nvim-ts-autotag`, `ts-comments.nvim`, `lazydev.nvim` - HTML/JSX/Lua-specific

### Plugins added
- `nvim-ghost.nvim` - edit browser textareas in Neovim

### Formatters added
- `clang-format` for C/C++ (system package), `ruff format` for Python (Mason)
- On a fresh machine these need `:MasonInstall ruff`; clang-format ships with `clang`

## This cheatsheet

### How to use it
- `g?` - open it
- Type to fuzzy-search entry titles; the right pane previews the selected entry
- `<CR>` - open that one entry full-screen on its own
- `<Esc>` - close

### How to edit it
Lives at `~/.config/nvim/cheatsheet.md`. Format is `## Category` then `### Entry
title` followed by body lines. Add a new `###` block and it shows up immediately -
no restart, it's re-read each time you open it.
