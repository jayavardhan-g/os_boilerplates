# Cheatsheet

Searchable reference for this exact setup. `<lead>` = Space (the leader key).
Entries tagged **[custom]** differ from stock LazyVim - the default is noted too.
Boxes labelled "What you see" are sketches of the real UI, not pixel-exact.

## Find & Search

### Find text in the current line
Stays on the line the cursor is on - never moves you elsewhere.

- `f{char}` / `F{char}` - jump to next / previous `{char}` on this line
- `t{char}` / `T{char}` - jump just before next / after previous `{char}`
- `;` / `,` - repeat that jump forward / backward
- `0`, `^`, `$` - start of line, first non-blank, end of line

What you see:

```text
  local timeout = get_timeout(config)
  █                                        press  f(
  local timeout = get_timeout(config)
                             █             cursor lands on the "("

  then  ;  → jumps to the next "(" on the line, if any
```

Combine with operators: `df(` deletes up to and including the `(`, `dt(`
stops just before it.

### Find text in the current file
- `/pattern` then `<CR>` - search forward from the cursor
- `n` / `N` - next / previous match
- `*` / `#` - search the word under the cursor forward / backward
- `<lead>sb` - fuzzy-search this buffer's lines in a picker

What you see:

```text
  every match highlights at once, and the count shows bottom-right:

      local timeout = 30
            ▔▔▔▔▔▔▔
      if timeout > 0 then
         ▔▔▔▔▔▔▔
  /timeout                                          [2/7]
                                                     ▲
                                        you are on match 2 of 7
```

Search is case-smart: an all-lowercase pattern matches any case, but adding
a capital makes it case-sensitive. `<Esc>` clears the highlighting.

### Find text across the whole project
- `<lead>sg` - live grep from the project root (ripgrep)
- `<lead>/` - same thing, shorter key
- `<lead>sG` - grep from the current working directory instead
- `<lead>sw` / `<lead>sW` - grep the word under the cursor (root / cwd)

What you see:

```text
  ╭─ Grep ─────────────────────────╮╭─ Preview ──────────────╮
  │ > timeout                      ││  local timeout = 60    │
  ├────────────────────────────────┤│  if timeout > 0 then   │
  │ config.lua:12   timeout = 60   ││    run(timeout)        │
  │ init.lua:40     timeout_ms=300 ││  end                   │
  │ util.lua:8      -- timeout doc ││                        │
  ╰────────────────────────────────╯╰────────────────────────╯
```

Results update as you type. `<CR>` jumps to the match, `<Esc>` cancels.

### Find text in open buffers only
- `<lead>sB` - grep across buffers you already have open

Narrower than a project grep - useful when you know it's in a file you're
already working in.

### Find files by name
- `<lead><lead>` or `<lead>ff` - find files from the project root
- `<lead>fF` - find files from the current working directory
- `<lead>fg` - only git-tracked files
- `<lead>fc` - jump straight to a Neovim config file
- `<lead>fn` - create a new file

Fuzzy: typing `cfglua` will match `config/keymaps.lua`.

### Find recently used files
- `<lead>fr` - recent files (project root)
- `<lead>fR` - recent files (cwd)
- `<lead>fp` - switch between projects

### Find help, keymaps and commands
- `<lead>sh` - search Neovim's `:help` pages
- `<lead>sk` - search every keymap currently bound
- `<lead>sC` - search available commands
- `<lead>sa` - search autocommands
- `<lead>sM` - man pages
- `<lead>sp` - plugin specs

`<lead>sk` is the fastest way to answer "what was that key again?" - it
lists the live keymap table, including everything custom in this setup.

### Find TODO / FIXME comments
- `<lead>st` - all todo-style comments **[custom]**
- `<lead>sT` - only `TODO` / `FIX` / `FIXME` **[custom]**
- `]t` / `[t` - next / previous todo comment in this file

What you see:

```text
  // TODO: handle the empty case
     ▔▔▔▔  highlighted in a distinct colour, inline

  // FIXME: off-by-one here
     ▔▔▔▔▔
```

Stock LazyVim points these at a Telescope command, which errors here -
this setup uses the Snacks picker and has no Telescope installed. Rerouted
to a Snacks grep pre-filled with the todo keywords.

### Find history (searches, commands, notifications)
- `<lead>s/` - previous searches
- `<lead>sc` or `<lead>:` - command history
- `<lead>n` - notification history
- `<lead>snh` - message history (noice)
- `<lead>snl` - show the last message again

Useful when a message flashed past before you could read it.

### Find marks, jumps, registers
- `<lead>sm` - list marks
- `<lead>sj` - list the jump list
- `<lead>s"` - list register contents
- `<lead>su` - browse the undo tree

### Clear search highlighting
- `<Esc>` - clear the highlight from the last search
- `<lead>ur` - redraw, clear highlight, refresh diff

## Replace

### Replace inside the current file
- `:%s/old/new/g` - every occurrence in the file
- `:s/old/new/g` - only on the current line
- `:%s/old/new/gc` - ask before each replacement

What you see:

```text
  before:                      after :%s/timeout/delay/g
    local timeout = 30           local delay = 30
    if timeout > 0 then          if delay > 0 then
    run(timeout)                 run(delay)

                                 3 substitutions on 3 lines
```

`%` = whole file, `g` = every match per line (without it, only the first
on each line), `c` = confirm.

### Replace with confirmation
- `:%s/old/new/gc`

What you see:

```text
  replace with new (y/n/a/q/l/^E/^Y)?

    y  replace this one        n  skip it
    a  replace all remaining   q  stop here
    l  replace this one then stop
```

### Replace only within a selection
Select lines with `V`, then type `:s/old/new/g`.

What you see:

```text
  :'<,'>s/old/new/g
   ▔▔▔▔▔
   Vim fills this range in for you - it means "the selection"
```

### Replace the word under the cursor
- `*` to search it, then `:%s//new/g`

Leaving the pattern empty reuses your last search, so you never retype it.

### Replace across the whole project
- `<lead>sr` - grug-far: search & replace across many files, with preview

What you see:

```text
  ╭─ grug-far ────────────────────────────────────╮
  │ Search:   timeout                             │
  │ Replace:  delay                               │
  │ Files:    *.lua                               │
  ├───────────────────────────────────────────────┤
  │ config.lua:12                                 │
  │ -   local timeout = 60                        │
  │ +   local delay = 60                          │
  │                                               │
  │ init.lua:40                                   │
  │ -   timeout_ms = 300                          │
  │ +   delay_ms = 300                            │
  ╰───────────────────────────────────────────────╯
```

Every match is listed with the exact before/after **before** anything is
written. Edit the Search/Replace/Files fields in place and the list updates.
The key to actually apply is shown in the buffer's own header.

### Replace across files without a plugin
- `:grep <pattern>` - fill the quickfix list (uses ripgrep)
- `:cfdo s/old/new/g | update` - substitute in every listed file and save

Faster to type than grug-far, but runs blind with no preview. Still undoable
per file with `u`, and nothing is written until `update` runs.

## Buffers

### What a buffer is
A file loaded into memory. Not a window (a viewport onto a buffer) and not a
tab (a whole layout of windows). One buffer can be shown in several windows,
and closing a window doesn't close the buffer.

### Open a file
- `:e {path}` - open a file into a new buffer
- `:enew` - blank new buffer
- `<lead><lead>` - find a file by name and open it

### Switch between buffers
- `H` / `L` - previous / next buffer
- `[b` / `]b` - same thing
- `<lead>bb` - jump back to the buffer you were just in
- `<lead>` then a backtick - same thing, one key shorter
- `<lead>,` or `<lead>fb` - fuzzy-pick from open buffers
- `<lead>bj` - pick a buffer by an on-screen letter label

What you see (the bufferline across the top):

```text
  ▎ init.lua  │  cheatsheet.md ●  │  keymaps.lua       
    ▔▔▔▔▔▔▔▔                ▲
    current                 ● = unsaved changes

  H ← move left        move right → L
```

### Close buffers
- `<lead>bd` - close this buffer, keep the window open
- `<lead>bD` - close this buffer and its window
- `<lead>bo` - close every buffer except this one
- `<lead>bl` / `<lead>br` - close all buffers left / right of this one
- `<lead>bP` - close all buffers that aren't pinned
- `<lead>bi` - close buffers not visible in any window

`<lead>bd` is the one you want day-to-day: it won't collapse your split
layout the way `:bdelete` does.

### Pin and reorder buffers
- `<lead>bp` - pin this buffer (protects it from `<lead>bP`)
- `[B` / `]B` - move this buffer left / right in the bufferline

### List buffers
- `:ls` or `:buffers` - plain list with numbers
- `:b {number}` or `:b {name}` - switch directly

## Windows & Splits

### Split the window
- `<lead>-` - split below (horizontal)
- `<lead>|` - split right (vertical)
- `:sp {file}` / `:vsp {file}` - split and open a specific file

What you see:

```text
      <lead>|                       <lead>-
  ╭────────┬────────╮           ╭─────────────────╮
  │        │        │           │                 │
  │   A    │   B    │           │        A        │
  │        │        │           ├─────────────────┤
  │        │        │           │        B        │
  ╰────────┴────────╯           ╰─────────────────╯
   <C-h>  ←→  <C-l>              <C-k> ↑↓ <C-j>
```

### Move between splits
- `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` - focus left / down / up / right
- `<C-w>` then `<lead>` - window "hydra" mode: repeatable window commands

### Resize splits
- `<C-Left>` / `<C-Right>` - narrower / wider
- `<C-Up>` / `<C-Down>` - taller / shorter

### Close or zoom a split
- `<lead>wd` - close this window (the buffer stays open)
- `<lead>wm` - zoom this split to fill the screen; press again to restore

Zoom is handy for briefly reading a file in a cramped 3-way split.

## Tabs

### What a tab is here
A saved layout of windows, not a single file. Day-to-day switching is
buffers (`H`/`L`); tabs are for keeping separate workspaces.

### Create, close, switch tabs
- `<lead><Tab><Tab>` - new tab
- `<lead><Tab>]` / `<lead><Tab>[` - next / previous
- `<lead><Tab>f` / `<lead><Tab>l` - first / last
- `<lead><Tab>d` - close this tab
- `<lead><Tab>o` - close all other tabs
- Native: `:tabnew`, `gt` / `gT`, `:tabclose`

## Moving around

### Basic motions
- `h` `j` `k` `l` - left, down, up, right
- `w` / `b` - start of next / previous word; `e` - end of word
- `W` / `B` / `E` - same but whitespace-separated (ignores punctuation)
- `{` / `}` - previous / next paragraph
- `%` - jump to the matching bracket

What you see:

```text
  local result = compute(a, b)
  █                                start

  w    → local │result = compute(a, b)      next word start
  W    → local result │= compute(a, b)      punctuation ignored
  $    → end of line
  %    → with cursor on "(" jumps to the matching ")"
```

### Jump to a line or file position
- `gg` / `G` - top / bottom of file
- `{n}G` or `:{n}` - go to line n
- two backticks in a row - jump back to where you just were

### Jump to any visible spot on screen
- `gs` then 2 characters - labels appear on matches; press one to jump **[custom]**
- `gS` - same, but jumps between code structures (treesitter)

What you see:

```text
  press  gs  then type  re

    local result = compute(rate, offset)
          ▔▔a                   ▔▔s
    return result
    ▔▔d       ▔▔f

  now press a / s / d / f to jump straight to that spot
```

Stock LazyVim binds these to `s` / `S`, which steals Vim's substitute-char
and substitute-line. Moved here so `s` / `S` keep working normally.

### Scroll the view
- `<C-d>` / `<C-u>` - half page down / up
- `<C-f>` / `<C-b>` - full page forward / backward
- `zz` / `zt` / `zb` - center / top / bottom the cursor line on screen

`zz` is the one worth building a habit around - it re-centres the line
you're working on without moving the cursor.

### Jump list (go back and forward)
- `<C-o>` - go back to where you were
- `<C-i>` - go forward again
- `<lead>sj` - browse the whole jump list

Works across files, so it's the "back button" after a go-to-definition.

### Marks
- `m{a-z}` - set a mark at the cursor
- a backtick then `{a-z}` - jump to that mark
- `<lead>sm` - list all marks

```text
  ma        set mark "a" here
  ...move around, other files...
  `a        jump straight back
```

## Editing

### Enter insert mode
- `i` / `a` - insert before / after the cursor
- `I` / `A` - insert at first non-blank / end of line
- `o` / `O` - open a new line below / above
- `<Esc>` - back to normal mode

### Delete, change, yank
- `d{motion}` - delete (`dw` word, `dd` line, `d$` to end of line)
- `c{motion}` - change: delete then insert (`cw`, `cc`, `C`)
- `y{motion}` - yank/copy (`yw`, `yy`, `Y`)
- `p` / `P` - paste after / before the cursor
- `x` - delete the character under the cursor **[custom: keeps your yank]**

### cw vs ciw
The single most common confusion in Vim.

```text
  before:   hel█lo world          █ = cursor

  cw   →    hel█ world            only "lo" went (cursor → word END)
  ciw  →    █ world               the whole word "hello" went
```

`cw` is really `ce` - it changes from the cursor to the end of the word,
ignoring anything before it. `ciw` ("change inner word") always takes the
whole word no matter where in it you are. `ciw` is almost always what you
actually want.

### Undo and redo
- `u` - undo
- `<C-r>` - redo
- `<lead>su` - browse the full undo tree

The undo tree matters because Vim never throws branches away: undo, type
something else, and the old branch is still reachable through `<lead>su`.

### Repeat and small operators
- `.` - repeat the last change
- `J` - join this line with the one below
- `~` - toggle the case of a character
- `<C-a>` / `<C-x>` - increment / decrement the number under the cursor

```text
  port = 8080        cursor anywhere on the number
  <C-a>  →  port = 8081
  10<C-a> →  port = 8091
```

`.` is the highest-leverage key in Vim: `ciwnew<Esc>` then `n.` `n.` `n.`
replaces word after word.

### Indent and move lines
- `>>` / `<<` - indent / unindent the line
- Visual `>` / `<` - indent the selection (`gv` reselects it after)
- `<M-j>` / `<M-k>` - move the current line down / up
- `]<lead>` / `[<lead>` - add a blank line below / above, staying in normal mode

Indent width here is **4 spaces** (LazyVim's default is 2) **[custom]**.

## Text objects

### Inside vs around
`i` = inside (contents only), `a` = around (contents plus delimiters).

```text
  foo("hello world")
        █

  di"  →  foo("")            inside the quotes
  da"  →  foo()              the quotes too
  ci(  →  foo(█)             inside parens, now inserting
```

Works with any operator: `d`, `c`, `y`, `v`.

### Common text objects
- `iw` / `aw` - word
- `i"`, `i'`, or i-then-backtick - quoted string
- `i(` `i[` `i{` - bracket contents (also `ib` / `iB`)
- `ip` / `ap` - paragraph
- `it` / `at` - HTML/XML tag

The extra "smart" objects (`af` function, `ac` class, `au` call) came from
mini.ai, which is **disabled** in this setup.

## Registers & Clipboard

### How registers work
- `"{reg}y` - yank into a named register, e.g. `"ayy`
- `"{reg}p` - paste from it, e.g. `"ap`
- `<lead>s"` - browse all register contents

```text
  "0p     paste the last YANK    (survives deletes)
  ""p     paste the last DELETE
  "ayy    yank this line into register a
  "ap     paste register a back
```

Register `0` is the useful one: a normal delete overwrites the unnamed
register but never touches `"0`, so your last real copy is still there.

### Copy to the system clipboard
- `<lead>y` - yank selection/motion to the system clipboard **[custom]**
- `<lead>Y` - yank to end of line to the system clipboard **[custom]**

Plain `y` / `yy` deliberately stay internal, so ordinary yanks don't
overwrite what you copied from a browser. Over SSH this routes through
OSC 52, so it reaches your **local** machine's clipboard with no X or
Wayland forwarding.

### Delete without clobbering the clipboard
- `x` deletes into the black-hole register **[custom]**

```text
  yiw            copy the word "config"
  ...move...
  xxx            delete 3 characters
  p              stock Vim: pastes those deleted chars (copy lost)
                 here:      pastes "config"  ← still intact
```

## Macros

### Record and replay
- `q{a-z}` - start recording into that register; `q` again to stop
- `@{a-z}` - replay
- `@@` - replay the last macro again
- `{n}@{a-z}` - replay n times

```text
  qa              start recording into register a
  I// <Esc>j      prefix the line with "// " and move down
  q               stop recording
  10@a            apply to the next 10 lines
```

Macros are just recorded keystrokes, so anything you can type you can
record - including `:` commands and searches.

## Comments

### Toggle comments
- `gcc` - toggle the current line
- `gc{motion}` - toggle a motion (`gcap` = a paragraph); visual `gc`
- `<C-/>` (or `<C-_>`) - same as `gcc` / `gc`, VSCode-style **[custom]**

```text
  int x = 1;            →    // int x = 1;
  x = 1                 →    # x = 1          (python)
  <!-- markdown -->     →    correct per language, automatically
```

Comment syntax comes from Neovim itself (per-filetype `commentstring`), so
it's right in C, C++, Python, Markdown and so on with no extra config.

Stock LazyVim uses `<C-/>` to toggle a terminal; that moved aside - the
terminal is still on `<lead>ft`.

### Add a comment line
- `gco` - add a comment on a new line below
- `gcO` - add one above

## Autocomplete

### Using the completion menu
Just type - the menu appears automatically in insert mode.

What you see:

```text
  os.pa█
  ╭──────────────────────────────╮
  │ path              Module     │  ← selected
  │ pathsep           Variable   │
  │ pardir            Variable   │
  ╰──────────────────────────────╯
   <CR> or <Tab> accept · <C-n>/<C-p> move · <C-e> dismiss
```

Sources: LSP, snippets, file paths, and words from open buffers.

### Turn autocomplete on or off
- `<lead>ac` - toggle the whole completion engine **[custom]**

Added because the menu gets in the way when writing prose or moving fast.
Shows an on/off notification and stays that way until you flip it back.

### Inline "ghost text" is off
Stock LazyVim previews the top candidate as greyed-out text ahead of your
cursor (`ghost_text` follows `vim.g.ai_cmp`, on by default). Disabled here
**[custom]** - the dropdown still works normally.

```text
  stock:  os.pa|th          ← "th" shown ghosted ahead of the cursor
  here:   os.pa|            ← nothing until you pick from the menu
```

## Autopairs

### How autopairs behaves
- Typing `(`, `[`, `{`, `"` or `'` inserts the closing half

```text
  type  (      →   (█)            cursor lands between
  type  "      →   "█"
  type  )  when the next char is already )  →  just steps over it
  foo█bar, type (  →  (  no auto-close: next char is a word character
```

### Turn it off
- `<lead>up` - toggle autopairs (a stock LazyVim toggle, not custom)

## Formatting

### Format the current file
- `<lead>cf` - format the whole buffer
- `<lead>cF` - format injected languages (e.g. code inside markdown)

```text
  before <lead>cf:            after:
    int main(){int x=1;         int main() {
    return x;}                      int x = 1;
                                    return x;
                                }
```

### Format on save
On by default. Toggles:
- `<lead>uf` - auto-format for this buffer
- `<lead>uF` - auto-format globally

Turn it off temporarily when touching a file whose existing style you don't
want to churn.

### Which formatter runs
- C / C++ -> `clang-format` **[custom]** (already on the system via `clang`)
- Python -> `ruff format` **[custom]** (installed through Mason)
- Lua / fish / sh -> `stylua` / `fish_indent` / `shfmt` (LazyVim defaults)
- Markdown -> nothing, deliberately (prettier would pull in npm/Node)

Stock LazyVim configures **no** formatter for C, C++ or Python - those come
from language "extras" this setup skips - so `<lead>cf` silently did nothing
on those files until this was wired up.

## LSP (code intelligence)

### Go to things
- `gd` - go to definition (when the server supports it)
- `gD` - go to declaration
- `gr` - list references
- `gI` - go to implementation
- `gy` - go to type definition
- `gO` - document symbols
- `<C-o>` - jump back afterwards

### Hover documentation
- `K` - docs for the symbol under the cursor

What you see:

```text
  os.getcwd()
     █          press K

  ╭─────────────────────────────────────────╮
  │ getcwd() -> str                         │
  │                                         │
  │ Return a unicode string representing    │
  │ the current working directory.          │
  ╰─────────────────────────────────────────╯

  press K again to jump inside the popup · q closes it
```

### Change code
- `<lead>ca` - code actions (quick fixes, refactors)
- `<lead>cA` - source-level actions
- `grn` - rename the symbol everywhere (Neovim native binding)
- `<lead>cl` - LSP info: which servers are attached here
- `<lead>cm` - open Mason to install/manage servers

`grn` renames across every reference the server knows about, not just this
file - safer than a find-and-replace for symbols.

### Neovim's built-in LSP keys
Neovim 0.11+ ships its own LSP bindings under `gr`, separate from LazyVim's.
Both sets are live here, so either works.

- `grn` - rename symbol
- `gra` - code action
- `grr` - list references
- `gri` - go to implementation
- `grt` - go to type definition
- `grx` - run codelens
- `gO` - document symbols
- `<C-w>d` (or `<C-w><C-d>`) - show the diagnostic under the cursor in a float

LazyVim's equivalents (`<lead>ca`, `gr`, `gI`, `gy`, `K`) are buffer-local
and only appear once a language server actually attaches.

### C and C++ language server (clangd)
`clangd` is set up **[custom]** and attaches automatically to `.c` / `.cpp`
files, so everything above works there: definitions, references, hover,
diagnostics and code actions.

- `<lead>ch` - switch between the source and its header **[custom]**
- `<lead>cl` - confirm clangd is attached to this buffer

It runs the system `clangd` (from the `clang` package, same one that gives
you `clang-format`) rather than a Mason-installed copy, with
`--clang-tidy` on, so you get clang-tidy lint warnings alongside compiler
errors.

**For accurate results in a real project**, clangd wants a
`compile_commands.json` so it knows your include paths and flags. CMake
emits one with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`; symlink it into the
project root if it lands in a build directory. Without one, clangd falls
back to single-file analysis - still useful, but cross-file resolution and
includes will be weaker.

Python is covered separately by `ruff`, which also attaches automatically.

## Diagnostics

### Move between problems
- `]d` / `[d` - next / previous diagnostic
- `]e` / `[e` - errors only
- `]w` / `[w` - warnings only
- `]D` / `[D` - last / first in the file

What you see:

```text
   12   import os
   13   x = undefined_name
                          ■ undefined name `undefined_name`
        ▲
        a sign in the gutter marks the line, with the message inline
```

### See the details
- `<lead>cd` - diagnostic for the current line
- `<C-w>d` - diagnostic under the cursor, in a float
- `<lead>sd` - searchable list of all diagnostics
- `<lead>sD` - diagnostics for this buffer only
- `<lead>ud` - toggle diagnostics display on/off

## Git

### See changed lines in the gutter
Changed lines get a coloured bar in the left gutter as you type, before you
save anything.

```text
  ▎ 41   local timeout = 60      ▎ = changed / added
  ▎ 42   local retries = 3
        43   local host = "x"     (unchanged: no bar)
       delete marker sits between lines
```

- `<lead>gs` - git status picker
- `<lead>gd` - diff of current hunks
- `<lead>gD` - diff against origin
- `<lead>gl` / `<lead>gL` - git log (project / cwd)
- `<lead>gf` - history of just the current file

### Move between changed hunks
- `]h` / `[h` - next / previous changed hunk

### Stage or reset a hunk
- `<lead>ghs` - stage the hunk under the cursor
- `<lead>ghr` - reset (discard) that hunk
- `<lead>ghS` - stage the whole file
- `<lead>ghu` - undo the last stage
- `<lead>ghR` - reset the whole file

`<lead>ghs` on individual hunks is how you split one messy working tree
into several clean commits.

### Preview a hunk inline
- `<lead>ghp` - draws the diff into the buffer itself

What you see:

```text
   41   local timeout = 60
      - local timeout = 30          ← old version shown inline
   42   local retries = 3
```

Limits worth knowing: it **cannot wrap** long lines (Neovim's virtual-line
API only supports truncate or horizontal scroll, not wrapping), and it
disappears the moment the cursor moves. Wide or tall hunks are unreadable
this way - use the popup below instead.

### Preview a hunk in a popup
- `<lead>ghP` - floating popup, focused in one keypress **[custom]**

What you see:

```text
  ╭─ Hunk 1 of 3 ──────────────────────────────╮
  │ - local timeout = 30                       │
  │ + local timeout = 60                       │
  │   local retries = 3                        │
  ╰────────────────────────────────────────────╯

  j / k   scroll inside it
  q       close
```

The popup auto-widens to fit the longest line, and because this binding
calls the preview twice, your cursor lands **inside** the window - so `j`/`k`
scroll it instead of closing it. Stock LazyVim only binds the inline
version; this one is custom.

### Blame
- `<lead>ghb` - blame the current line (gitsigns)
- `<lead>gb` - blame line (Snacks)
- `<lead>ghB` - blame the whole file

```text
  ╭──────────────────────────────────────────────╮
  │ a1b2c3d  Jayavardhan  3 days ago             │
  │ Move the force-kill picker off SUPER+Escape  │
  ╰──────────────────────────────────────────────╯
```

### GitHub
- `<lead>gi` / `<lead>gI` - open issues / all issues
- `<lead>gp` / `<lead>gP` - open pull requests / all
- `<lead>gB` - open the current file on GitHub in a browser
- `<lead>gY` - copy that link instead

`<lead>gB` opens the exact line you're on, which makes it an easy way to
link a colleague to code.

## Sessions

### Restore your layout
- `<lead>qs` - restore the session for this directory
- `<lead>ql` - restore the most recent session, any directory
- `<lead>qS` - pick from all saved sessions

Sessions store open buffers and window layout per project, saved
automatically when you quit. Reopen `nvim` in that directory and `<lead>qs`
puts the splits back exactly as they were.

### Skip saving
- `<lead>qd` - don't save this session on exit
- `<lead>qq` - quit everything

## Terminal

### Open a terminal
- `<lead>ft` - terminal at the project root
- `<lead>fT` - terminal at the current working directory

Opens as a floating window over the editor. `<C-/>` does this in stock
LazyVim, but that key is the comment toggle here **[custom]**.

## File explorer

### Browse files in a tree
- `<lead>e` - explorer from the project root
- `<lead>E` - explorer from the current working directory
- `<lead>fe` / `<lead>fE` - same pair, alternate keys

```text
  ╭─ Explorer ──────────────╮
  │  configs/               │
  │    neovim/              │
  │      cheatsheet.md      │
  │      lazyvim-migr.md    │
  │  ▸ cachyos/             │
  ╰─────────────────────────╯
```

## UI toggles

### Common toggles (`<lead>u` prefix)
- `<lead>uw` - wrap long lines
- `<lead>ul` - line numbers · `<lead>uL` - relative numbers
- `<lead>us` - spell check
- `<lead>ud` - diagnostics
- `<lead>uh` - inlay hints
- `<lead>uc` - conceal level
- `<lead>ug` - indent guides
- `<lead>uz` - zen mode · `<lead>uZ` - zoom
- `<lead>ub` - dark/light background
- `<lead>uC` - pick a colorscheme
- `<lead>un` - dismiss all notifications
- `<lead>ua` animations · `<lead>uS` smooth scroll · `<lead>uD` dimming
- `<lead>ac` - autocomplete **[custom, deliberately not under `u`]**

Press `<lead>u` and pause to see the whole list with on/off state.

### Discover any keybinding
Press `<lead>` (or any prefix) and wait - which-key lists what's available.

```text
  ╭─────────────────────────────────────────╮
  │  b  +buffer        f  +file/find        │
  │  c  +code          g  +git              │
  │  s  +search        u  +ui               │
  │  q  +quit/session  x  +diagnostics      │
  ╰─────────────────────────────────────────╯
```

- `<lead>?` - buffer-local keymaps only (what's special where you are)
- `<lead>sk` - searchable list of every keymap

## Scratch buffers

### Quick throwaway notes
- `<lead>.` - toggle a scratch buffer
- `<lead>S` - pick from existing scratch buffers

Scratch buffers persist per project - useful for notes or trying a snippet
without creating a file.

## Selection by code structure

### Expand or shrink a selection by syntax node
Grows the selection outward following the code's structure, not lines.

- `<C-Space>` - grow the selection to the next bigger node
- `<BS>` - shrink it back again (while selecting)
- `an` / `in` - select the parent (outer) / child (inner) node
- `]n` / `[n` - next / previous sibling node

What you see:

```text
  press <C-Space> repeatedly:

    compute(a, b)        1st →  a
                         2nd →  a, b
                         3rd →  (a, b)
                         4th →  compute(a, b)
```

Faster than counting brackets for `ci(`-style edits on nested code.

### Flash in operator-pending mode
- `r` - remote flash: run the pending operator somewhere else
- `R` - treesitter search

```text
  yr  then a label   →  yank that spot without moving the cursor
  dr  then a label   →  delete there, come straight back
```

## Lists: quickfix & location

### Quickfix list
A global list of positions - grep results, diagnostics, compiler errors.

- `<lead>xq` - open the quickfix list
- `<lead>sq` - fuzzy-search its entries
- `]q` / `[q` - next / previous item
- `]Q` / `[Q` - last / first item

```text
  :grep timeout            fill it from a project search
  :cfdo s/old/new/g | update   run a command on every file in it
```

### Location list
Same idea as quickfix, but **per window** rather than global - so you can
keep one list per split.

- `<lead>xl` - open the location list
- `<lead>sl` - fuzzy-search it
- `]l` / `[l` - next / previous item
- `]L` / `[L` - last / first
- `]<C-l>` / `[<C-l>` - first item in the next / previous **file**
- `]<C-q>` / `[<C-q>` - same idea for the quickfix list

### Jump between paired things
`[` and `]` are Vim's universal "previous / next" prefixes. In this setup:

```text
  b  buffer        d  diagnostic    e  error        w  warning
  q  quickfix      l  loclist       a  argument     t  todo comment
  h  git hunk      n  syntax node   T  tag stack

  ]x  next      [x  previous      ]X / [X  last / first
```

So `]d` is next diagnostic, `[h` is previous git hunk, and so on - one
pattern instead of a separate key per feature. The full set of targets:
`]b` `[b` buffers, `]d` `[d` diagnostics, `]e` `[e` errors, `]w` `[w`
warnings, `]q` `[q` quickfix, `]l` `[l` loclist, `]a` `[a` arguments,
`]t` `[t` todo comments, `]h` `[h` git hunks, `]n` `[n` syntax nodes, and
`]<C-t>` `[<C-t>` the tag stack.

## Tools & meta

### Save the file
- `<C-s>` - save, from normal, insert **or** visual mode

Saves without making you leave insert mode first.

### Open a link or file under the cursor
- `gx` - open the URL or path under the cursor with the system handler

Opens a web link in your browser, a folder in your file manager - useful on
a plugin URL inside a config file.

### Look up the word under the cursor
- `<lead>K` - run `keywordprg` on the word (man page for shell, etc.)

Different from `K`, which is LSP hover documentation.

### Manage plugins and tools
- `<lead>l` - open Lazy: update, clean, profile startup, see what loaded
- `<lead>L` - LazyVim changelog
- `<lead>cm` - open Mason: install/remove LSP servers, formatters, linters

`<lead>cm` is where `ruff` was installed for Python formatting.

### Profile startup and performance
- `<lead>dpp` - toggle the profiler
- `<lead>dph` - toggle profiler highlights
- `<lead>dps` - open the profiler scratch buffer

Reach for these if Neovim starts feeling slow; Lazy (`<lead>l`) also shows
per-plugin startup time.

### Inspect highlights and syntax
- `<lead>ui` - inspect highlight groups under the cursor
- `<lead>uI` - open the treesitter tree inspector
- `<lead>uT` - toggle treesitter highlighting
- `<lead>sH` - search all highlight groups

The answer to "why is this word coloured like that?" - `<lead>ui` names the
exact highlight group in play.

### Browse icons
- `<lead>si` - search and insert nerd-font icons

### Noice message tools
- `<lead>sna` - all messages
- `<lead>snh` - message history
- `<lead>snl` - show the last message again
- `<lead>snd` - dismiss everything on screen
- `<lead>snt` - noice picker

### Snippets
- `<Tab>` / `<S-Tab>` - jump to the next / previous snippet placeholder

Snippets come from friendly-snippets through blink.cmp: accept one from the
completion menu, then `<Tab>` between the fields it leaves you.

### Vim defaults worth knowing
- `j` / `k` / `<Down>` / `<Up>` move by **screen** line, so they behave
  sensibly on wrapped text
- `&` - repeat the last `:s` substitution on this line
- `Y` - yank to end of line
- visual `@` - run a macro over every selected line
- visual `q` - see `:help v_Q-default`

## Visual & block editing

### The three visual modes
- `v` - character-wise
- `V` - line-wise
- `<C-v>` - **block** (column) selection
- `gv` - reselect whatever you selected last
- `o` - jump to the other end of the selection, to extend it the other way

### Edit many lines at once
Block selection plus `I` or `A` inserts the same text on every selected line.

```text
  <C-v>  then  jjj  to select a column, then  I  # <Esc>

    foo = 1            # foo = 1
    bar = 2      →     # bar = 2
    baz = 3            # baz = 3

  I  inserts before the block   ·   A  appends after it
  $  before A appends at each line's own end, however ragged
```

`c` on a block replaces the column on every line at once.

### Number a column automatically
- `g<C-a>` - in a visual selection, turn a column of numbers into an
  incrementing sequence

```text
  select the zeros, press g<C-a>

    0. item        1. item
    0. item   →    2. item
    0. item        3. item
```

### Operators inside a selection
- `d` / `c` / `y` - delete, change, yank the selection
- `>` / `<` - indent; `gv` afterwards reselects so you can repeat
- `u` / `U` / `~` - lowercase / uppercase / toggle case
- `r{char}` - replace every selected character
- `J` - join the selected lines
- `gq` - reflow the selection as text
- `:` - starts an Ex command already scoped to the selection

## Ex command line & shell

### Ranges
Almost every `:` command takes a range in front of it.

```text
  :%s/…        whole file            :.s/…       current line
  :1,20s/…     lines 1-20            :.,+5s/…    this line + next 5
  :'<,'>s/…    the visual selection  :$s/…       last line
  :/foo/s/…    next line matching foo
  :'a,'bs/…    from mark a to mark b
```

### The command window
- `q:` - open your command history as an **editable buffer**
- `q/` - the same for search history
- `<C-f>` while typing a `:` command - switch into it mid-command

Edit any past command like normal text, press `<CR>` on a line to run it.
Far easier than arrowing through history for something long.

### Run shell commands
- `:!cmd` - run a shell command, show the output
- `:r !cmd` - read a command's output **into** the buffer
- `:w !cmd` - pipe the buffer into a command (without saving)
- `!{motion}cmd` - filter text **through** a command, replacing it

```text
  !ipsort<CR>        sort the current paragraph through `sort`
  :%!jq .            pretty-print the whole buffer as JSON
  :r !date           paste today's date on the next line
```

### Sort lines
- `:sort` - sort the whole file (or a range)
- `:sort!` - reverse
- `:sort u` - sort and remove duplicates
- `:sort n` - numeric sort (so 9 comes before 10)
- `:'<,'>sort` - sort just the selection

## Folding

### How folding works here
This setup uses `foldmethod=indent` with `foldlevel=99`, so folds follow
indentation and everything starts **open** - you only see folds if you make
them.

- `za` - toggle the fold under the cursor
- `zo` / `zc` - open / close it
- `zR` / `zM` - open **all** folds / close all folds
- `zj` / `zk` - move to the next / previous fold
- `zv` - open just enough to see the cursor line

```text
  zc on an indented block:

    def handler():              def handler():
        parse()            →    +---  3 lines ------
        run()
        log()
```

## Insert-mode tricks

### Paste and delete without leaving insert
- `<C-r>{reg}` - insert a register's contents
- `<C-r>"` - the last yank · `<C-r>0` - the last explicit yank
- `<C-r>%` - the current filename
- `<C-w>` - delete the word before the cursor
- `<C-u>` - delete back to the start of the line
- `<C-o>` - run **one** normal-mode command, then return to insert
- `<C-t>` / `<C-d>` - indent / unindent the current line

`<C-o>` is the one to remember: `<C-o>A` jumps to end of line and keeps
typing, without an `<Esc>` round trip.

### Special characters
- `<C-k>` then two letters - insert a digraph, e.g. `<C-k>a:` gives ä
- `<C-v>u00e9` - insert a character by unicode codepoint

## Command-line editing

### Pull text into the command line
- `<C-r><C-w>` - insert the word under the cursor
- `<C-r><C-a>` - the WORD under the cursor
- `<C-r>%` - the current filename
- `<C-r>{reg}` - any register

```text
  cursor on "timeout", then:   :%s/<C-r><C-w>/delay/g
  → the command line already reads  :%s/timeout/delay/g
```

### History and extras
- `<Up>` / `<Down>` - history **filtered by what you've typed so far**
- `q:` - full history as an editable buffer
- `<S-CR>` - redirect the command's output into a popup (noice)
- `<C-s>` - toggle flash search while typing a `/` search

## Repeat a change across matches

### cgn: change next match, then repeat
`gn` selects the next match of the last search, so `cgn` changes it - and
then `.` repeats the whole find-and-change.

```text
  /timeout<CR>        search for it once
  cgn delay <Esc>     change this match
  .                   change the next one
  n .                 skip one, change the one after
```

The advantage over `:%s` is that you approve each change as you go, with a
single keystroke, and you can skip freely with `n`.

- `gn` / `gN` - select the next / previous match
- `dgn` - delete the next match
- `cgn` - change it

## More operators

### Change case with a motion
- `gU{motion}` - uppercase · `gu{motion}` - lowercase · `g~{motion}` - toggle
- `gUiw` - uppercase the word · `guu` / `gUU` - the whole line

### Re-indent code
- `={motion}` - re-indent by the language's rules
- `==` - the current line · `=G` - from here to end of file · `=ip` - paragraph

Uses the same treesitter-based indent logic as typing does.

### Reflow paragraphs and comments
**Use `gw`, not `gq`, in this setup.** LazyVim points `formatexpr` at its own
formatter, so `gq` runs conform/LSP **code formatting** over the range rather
than wrapping text. `gw` always uses Vim's internal formatter and ignores
`formatexpr`, so it is the one that actually reflows prose.

- `gw{motion}` - reflow text, e.g. `gwip` for a paragraph
- `gww` - the current line
- `gwap` - a paragraph including its blank line
- `gq{motion}` - runs the **code formatter** here (same as `<lead>cf` on a range)

Wrap width comes from `textwidth`, which is `0` by default here - with 0 it
falls back to 79 columns. Set `:setlocal textwidth=72` first if you want a
specific width. Verified: with `textwidth=60`, `gww` wraps at 60 while `gqq`
leaves the line untouched.

## Diff mode

### Compare two files
- `nvim -d file1 file2` - open straight into a diff
- `:diffthis` in two windows - diff whatever is already open
- `:diffoff` - stop diffing · `:diffupdate` - recompute

### Move and apply changes
- `]c` / `[c` - next / previous difference
- `do` - "diff obtain": pull the other side's version into this buffer
- `dp` - "diff put": push this side's version to the other buffer

For git specifically, `<lead>ghd` (gitsigns) diffs the current file against
the index without setting this up manually.

## Spell checking

### Turn it on and fix words
Spell checking is **off** by default here.

- `<lead>us` - toggle it on/off
- `]s` / `[s` - jump to the next / previous misspelling
- `z=` - suggest corrections for the word under the cursor
- `zg` - add the word to your dictionary ("good")
- `zw` - mark a word as wrong
- `zug` - undo a `zg`

```text
  z= on a misspelled word:

    Change "recieve" to:
      1  receive
      2  relieve
    Type number and <Enter>:
```

## Undo time travel

### Beyond plain undo
Undo in Vim is a **tree**, not a line, and this setup has `undofile` on -
so undo history survives closing and reopening the file.

- `u` / `<C-r>` - undo / redo
- `g-` / `g+` - move backwards / forwards through **every** state, including
  branches that plain `u` can't reach
- `:earlier 10m` / `:later 5m` - jump by time
- `:earlier 3f` / `:later 1f` - jump by file **writes**
- `<lead>su` - browse the whole tree visually

`:earlier 1f` is the "undo everything since my last save" button.

## Terminal mode

### Working inside a terminal buffer
- `<lead>ft` / `<lead>fT` - open a terminal (root dir / cwd)
- `<C-\><C-n>` - leave terminal-insert mode, so you can scroll, search and
  yank the output like any buffer
- `i` or `a` - go back to typing in the shell
- `<C-/>` - closes the terminal from **inside** it

That last one is worth knowing: `<C-/>` is the comment toggle in normal and
visual mode here, but inside a terminal buffer it still toggles the terminal
away, which is exactly what you want.

## Config & health

### Inspect this setup
- `:checkhealth` - full diagnostic report (providers, LSP, plugins)
- `:set opt?` - show an option's current value, e.g. `:set shiftwidth?`
- `:verbose set opt?` - show its value **and which file last set it**
- `:setlocal` - change an option for this buffer/window only

`:verbose set shiftwidth?` is the fastest way to answer "why is this 4 and
where did that come from?".

### Manage the setup
- `:Lazy` (`<lead>l`) - plugins: update, clean, see startup times
- `:Mason` (`<lead>cm`) - language servers, formatters, linters
- `:LazyExtras` - LazyVim's **language packs**: enable one and it wires up
  the LSP, formatter, treesitter parser and debugger for that language
  together

`:LazyExtras` is LazyVim's route to language packs. The C/C++ server here
was set up directly instead (`lua/plugins/clangd.lua`) rather than through
the extra, to avoid pulling in `clangd_extensions.nvim` - see the clangd
entry under LSP.

### Where the config lives
```text
  ~/.config/nvim/
    lua/config/options.lua     editor options
    lua/config/keymaps.lua     custom keybindings
    lua/config/autocmds.lua    automatic behaviour
    lua/plugins/*.lua          one file per plugin override
    cheatsheet.md              this document
    lua/cheatsheet.lua         the picker that shows it
```

Anything in `lua/plugins/` is merged over LazyVim's defaults, so a file
there only needs the parts you want to change.

## Regex & patterns

### Which regex flavour applies where
This matters constantly and trips people up - the same pattern does not work
everywhere in this setup.

- `/pattern`, `?pattern`, `:s`, `:g`, `:v` - **Vim regex**
- `<lead>sg` / `<lead>/` grep, and `<lead>sr` grug-far - **ripgrep** (Rust
  regex, essentially PCRE-style)

```text
  find "foo(" or "bar("      Vim:      /\v(foo|bar)\(
                             ripgrep:  (foo|bar)\(
```

Rule of thumb: in ripgrep `+ ? ( ) { } |` work bare; in Vim they need
backslashes unless you turn on very-magic mode with `\v`.

### Magic levels: \v \m \M \V
Vim has four levels controlling how many characters are "special".

```text
  \v  very magic    all of + ? ( ) { } | < > work bare, like PCRE
  \m  magic         DEFAULT: . * [] work bare; + ? ( ) | need a backslash
  \M  nomagic       only . and * lose their meaning too
  \V  very nomagic  literally everything except \ is a plain character
```

`\V` is the one to reach for when searching text full of punctuation -
`/\Vhttp://x.com` needs no escaping at all.

### Very magic mode: \v
Put `\v` at the start and Vim's regex behaves the way you expect from other
languages.

```text
  without \v :   /\(foo\|bar\)\+\d\{2,3}
  with    \v :   /\v(foo|bar)+\d{2,3}
```

Worth making a habit - nearly every non-trivial Vim pattern is shorter and
more readable with `\v`.

### Character classes
- `.` - any character except a newline
- `\d` / `\D` - digit / non-digit
- `\w` / `\W` - word character `[0-9A-Za-z_]` / non-word
- `\s` / `\S` - whitespace / non-whitespace
- `\a` - alphabetic, `\l` - lowercase letter, `\u` - uppercase letter
- `\x` - hex digit
- `[abc]` / `[^abc]` - any of / none of
- `[a-z0-9_]` - ranges, as usual

Careful: in a **replacement** `\u` and `\l` mean something completely
different (see "case tricks" below).

### Quantifiers and repeats
```text
  magic (default)        very magic (\v)      meaning
  *                      *                    0 or more
  \+                     +                    1 or more
  \?  or  \=             ?                    0 or 1
  \{2,5}                 {2,5}                between 2 and 5
  \{3}                   {3}                  exactly 3
  \{-}                   {-}                  0 or more, NON-greedy
  \{-1,}                 {-1,}                1 or more, non-greedy
```

`\{-}` is Vim's equivalent of PCRE's `*?` - it matches as little as
possible, which is what you want for things like `\v".{-}"`.

### Anchors and word boundaries
- `^` - start of line, `$` - end of line
- `\<` / `\>` - start / end of a word (in `\v`: `<` and `>`)
- `\%^` / `\%$` - start / end of the **file**
- `\%V` - restrict the match to the visual selection

```text
  /\<log\>      matches "log" but not "login" or "catalog"
  /\vlog>       same thing in very-magic mode
```

### Match start and end: \zs and \ze
Vim-specific and genuinely useful: they move where the *match* begins and
ends, so you can require context without consuming it.

```text
  /foo\zsbar        matches "bar", but only when preceded by "foo"
  /foo\zebar        matches "foo", but only when followed by "bar"

  :%s/version: \zs\d\+/99/     changes only the number, keeps the label
```

Replaces the need for lookahead/lookbehind in most practical cases.

### Groups, alternation and backreferences
- `\(...\)` - a group (in `\v`: `(...)` )
- `\%(...\)` - a group that does **not** capture
- `\|` - alternation (in `\v`: `|` )
- `\1` … `\9` - backreference to a captured group

```text
  find a doubled word:
    /\v<(\w+)\s+\1>

  swap two comma-separated fields:
    :%s/\v(\w+), (\w+)/\2, \1/
```

### The replacement side
The right-hand side of `:s` has its own small language.

- `&` or `\0` - the whole match
- `\1` … `\9` - captured groups
- `~` - the previous replacement string
- `\u` / `\l` - upper/lowercase the **next character**
- `\U` / `\L` - upper/lowercase until `\E`
- `\E` - end a `\U` or `\L` run
- `\=` - evaluate the rest as a Vimscript **expression**

```text
  :%s/\w\+/"&"/g              wrap every word in quotes
  :%s/\v_(\w)/\u\1/g          snake_case  →  camelCase
  :%s/\v(\l)(\u)/\1_\l\2/g    camelCase   →  snake_case
  :%s/\d\+/\=submatch(0)+1/g  increment every number by 1
```

### Newlines: the classic gotcha
`\n` does **not** mean the same thing on both sides of a `:s`.

```text
  searching:     \n  matches a line ending          ✔
  replacing:     \n  inserts a NUL byte (shows as ^@)   ✘
  replacing:     \r  inserts a real newline          ✔

  join every pair of lines:   :%s/\n//
  split on every comma:       :%s/,/\r/g
```

### Case sensitivity
This setup has `ignorecase` **on** with `smartcase` **on** (verified).

```text
  /timeout      matches Timeout, TIMEOUT, timeout   (all lowercase → loose)
  /Timeout      matches Timeout only        (a capital → case-sensitive)
  /timeout\c    force case-INsensitive, whatever the options say
  /Timeout\C    force case-sensitive
```

`\c` and `\C` work anywhere in the pattern, not just at the start.

### Live preview while substituting
`inccommand` is set to `nosplit`, so as you type a `:%s/.../.../` command the
matches highlight and the replacement is previewed **in the buffer**, before
you press Enter.

```text
  :%s/timeout/delay/g
     ▲ every match already shows as "delay" while you type;
       press <Esc> and nothing was ever changed
```

### Limit a substitution to part of the file
```text
  :%s/a/b/g        whole file
  :s/a/b/g         current line only
  :.,+5s/a/b/g     this line and the next 5
  :1,20s/a/b/g     lines 1 to 20
  :'<,'>s/a/b/g    the visual selection (Vim fills this in for you)
  :%s/\%Va/b/g     only inside the selection, anywhere in the file
```

Without the `g` flag only the **first** match on each line is replaced
(`gdefault` is off here, which is the standard behaviour).

### Run a command on every matching line: :g and :v
`:g` is one of the most powerful things in Vim and has no keybinding - it
runs an Ex command on every line matching a pattern.

```text
  :g/TODO/d            delete every line containing TODO
  :v/TODO/d            delete every line NOT containing it (also :g!)
  :g/^$/d              delete all blank lines
  :g/TODO/t$           copy matching lines to the end of the file
  :g/TODO/m0           move them to the top (reverses their order)
  :g/^/m0              reverse the whole file
  :g/pat/normal A;     append a ";" to every matching line
```

`:v` is just "inverse `:g`". Combining `:g` with `normal` lets you run any
normal-mode keystrokes on every matching line.

### Practical recipes
```text
  strip trailing whitespace     :%s/\s\+$//e
  blank runs → one blank line   :%s/\n\{3,}/\r\r/g
  delete blank runs entirely    :g/^$/,/./-1d
  remove adjacent duplicates    :g/^\(.*\)$\n\1$/d
  quote every line              :%s/^.*$/"&"/
  numbers → +1                  :%s/\d\+/\=submatch(0)+1/g
  keep only matching lines      :v/pattern/d
  count matches                 :%s/pattern//gn
```

The trailing `e` flag in the first one means "don't error if nothing
matched", which keeps it safe inside mappings and macros. The `n` flag in
the last one **counts** without changing anything.

## GhostText & buffer language

### Edit browser text in Neovim (GhostText)
Click the GhostText browser extension on any text box and it opens here in
a new tab; every edit syncs back to the page live. Close the tab (or the
page) to end it.

- `leetcode.com` opens straight into **C++** **[custom]** - clangd,
  clang-format and C++ indentation, all attached automatically
- any other site opens as plain text - use `<lead>cL` to pick a language

What you see:

```text
  tab title:   leetcode.com-2.cpp
  :set ft?     filetype=cpp
  <lead>cl     clangd attached
```

Why it needed work: ghost buffers are unnamed scratch buffers, and Neovim
refuses to attach a language server to those. This setup names the buffer
with the right extension (under `~/.cache/nvim/nvim-ghost/`) and starts the
matching servers itself. Nothing is ever written to disk.

### Set the language of any buffer
- `<lead>cL` - pick a filetype for the current buffer **[custom]**

Your languages are listed first; every other filetype is one fuzzy search
away. Works in any buffer - including plain `:enew` scratch buffers, which
otherwise have no language at all, so indentation, autopairs and formatting
behave oddly in them.

```text
  ╭─ Language for this buffer ───────╮
  │ > py                             │
  │   python                         │
  │   pyrex                          │
  ╰──────────────────────────────────╯
```

In a GhostText buffer, switching language also swaps the language server
(e.g. cpp -> python detaches clangd and attaches ruff).

### Formatting in a ghost buffer
- `<lead>cf` - format it

Format-on-save never fires for ghost buffers (they're never saved - the
text syncs to the browser instead), so format manually before you submit.

## Customizations: default vs current

### Keys changed from stock LazyVim
```text
  s / S        flash jump          →  gs / gS  (s/S back to substitute)
  <C-/>        terminal            →  toggle comment  (terminal: <lead>ft)
  x            deletes into "" reg →  black hole (your yank survives)
  <lead>st/sT  Telescope todo      →  Snacks grep (no Telescope here)
  <lead>xt/xT  Trouble todo        →  removed (Trouble disabled)

  new  <lead>ac    toggle autocomplete
  new  <lead>ghP   focused hunk popup
  new  <lead>y/Y   clipboard yank (OSC 52 over SSH)
  new  <lead>h     this cheatsheet
  new  <lead>ch    switch C/C++ source <-> header (clangd)
  new  <lead>cL    set the language of the current buffer
```

### Options changed
```text
  shiftwidth   2  →  4
  tabstop      2  →  4
  expandtab    true (unchanged - spaces, not tabs)
```

Indent *logic* was already treesitter-based; only the width changed.

### Plugins disabled
```text
  nvim-treesitter-textobjects   ]f/[f structural jumps - unused
  mini.ai                       af/if smart text objects - unused
  nvim-lint                     no linters configured; ruff LSP covers Python
  trouble.nvim                  diagnostics panel - unused
  tokyonight / catppuccin       colours come from colors/kitty.lua
  nvim-ts-autotag               HTML/JSX only
  ts-comments.nvim              HTML/JSX only
  lazydev.nvim                  Lua-config editing helper
```

### Plugins added
- `nvim-ghost.nvim` - edit browser textareas in Neovim (with per-site
  languages and LSP support - see the GhostText entry)

### Language servers
- Python - `ruff` (installed via Mason, also does the formatting)
- C / C++ - `clangd` **[custom]**, system package, configured in
  `lua/plugins/clangd.lua` without LazyVim's full extra

### Formatters added
- `clang-format` for C/C++ (system package, ships with `clang`)
- `ruff format` for Python (Mason)

On a fresh machine only ruff needs installing: `:MasonInstall ruff`.

### Colorscheme
Not a plugin theme - `colors/kitty.lua` reads kitty's live theme file and
matches it, so Neovim tracks your terminal colours automatically.

## This cheatsheet

### How to use it
- `<lead>h` - open it

`<lead>h` was chosen because it is genuinely unclaimed - no custom mapping,
nothing nested under it, and no native Vim command displaced. Bare `?`
stays as backward-search, and `<lead>?` is LazyVim's buffer-local keymaps
popup, so neither was taken.
- Type to fuzzy-search entry titles; the right pane previews the selection
- `<CR>` - open that one entry on its own
- `<Esc>` - close · `<BS>` from a single entry goes back to the list

### How to edit it
Lives at `~/.config/nvim/cheatsheet.md`. The format is `## Category`, then
`### Entry title` followed by body lines. Add a new `###` block and it shows
up immediately - the file is re-read every time you open it, no restart.

Headings inside fenced code blocks are ignored by the parser, so examples
containing `#` are safe.
