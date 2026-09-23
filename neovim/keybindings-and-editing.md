# Keybindings and editing behaviour

**Category:** neovim
**Files touched:** `lua/config/keymaps.lua`, `lua/config/options.lua`, `lua/plugins/completion.lua` (all under `~/.config/nvim/`; copies in [`files/`](files/))

Key remaps and editing defaults layered on top of LazyVim: the old-vs-LazyVim key comparison, OSC 52 clipboard yank, VSCode-style comment toggle, 4-space indent, and the autocomplete toggle. Part of the LazyVim setup - see [[lazyvim-migration]] for the migration itself and the index of all topic files.

Entries are in the order they happened. They were split out of `lazyvim-migration.md` on 2026-09-23 without rewording, so "above" and "previous follow-up" refer to entries in this file unless a link says otherwise.

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
