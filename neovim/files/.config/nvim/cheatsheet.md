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
- `<lead>bb` or ``<lead>` `` - jump back to the buffer you were just in
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
- ``` `` ``` - jump back to where you just were

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
- `` `{a-z} `` - jump to that mark
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
- `i"` `i'` `` i` `` - quoted string
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

### C and C++ have no LSP (known gap)
Nothing attaches for `.c` / `.cpp`: no definitions, references, hover or
diagnostics. `clangd` was never set up here. Python works (`ruff` attaches
automatically). Formatting still works for C/C++ because `clang-format`
runs independently of any language server.

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
  new  g?          this cheatsheet (native g? is ROT13, unused)
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
- `nvim-ghost.nvim` - edit browser textareas in Neovim

### Formatters added
- `clang-format` for C/C++ (system package, ships with `clang`)
- `ruff format` for Python (Mason)

On a fresh machine only ruff needs installing: `:MasonInstall ruff`.

### Colorscheme
Not a plugin theme - `colors/kitty.lua` reads kitty's live theme file and
matches it, so Neovim tracks your terminal colours automatically.

## This cheatsheet

### How to use it
- `g?` - open it
- Type to fuzzy-search entry titles; the right pane previews the selection
- `<CR>` - open that one entry on its own
- `<Esc>` - close · `<BS>` from a single entry goes back to the list

### How to edit it
Lives at `~/.config/nvim/cheatsheet.md`. The format is `## Category`, then
`### Entry title` followed by body lines. Add a new `###` block and it shows
up immediately - the file is re-read every time you open it, no restart.

Headings inside fenced code blocks are ignored by the parser, so examples
containing `#` are safe.
