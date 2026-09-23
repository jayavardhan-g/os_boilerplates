# LeetCode in Neovim (leetcode.nvim)

**Category:** neovim
**Files touched:** `lua/plugins/leetcode.lua`, `lua/plugins/languages.lua` (all under `~/.config/nvim/`; copies in [`files/`](files/))

Solving LeetCode inside Neovim: setup, health check, run/submit keys, two-box sign-in, and the swap-file fix. Part of the LazyVim setup - see [[lazyvim-migration]] for the migration itself and the index of all topic files.

Entries are in the order they happened. They were split out of `lazyvim-migration.md` on 2026-09-23 without rewording, so "above" and "previous follow-up" refer to entries in this file unless a link says otherwise.

## Follow-up: leetcode.nvim - run, test and submit LeetCode from Neovim (2026-09-23)

**What**: asked whether page commands (e.g. LeetCode's `Ctrl+'` to run tests) could be
sent from Neovim through GhostText. They can't: the GhostText protocol carries only
text, selections, URL and a syntax hint - no channel back to the page. Building one
(forking the extension plus patching nvim-ghost, or a userscript polling a local
server) was estimated at half a day to a day, plus ongoing breakage from per-site DOM
selectors. Checked for an existing solution first instead: **kawre/leetcode.nvim**, an
actively maintained plugin that replaces the LeetCode browser tab entirely - `:Leet
run` / `test` / `submit` natively. Chosen over building anything.

It's also the better fit than GhostText for LeetCode specifically: solutions are real
`.cpp` files, so clangd / clang-format / format-on-save work with none of the ghost-
buffer workarounds.

**Findings while setting it up** (read the plugin's source rather than trusting its
README alone):
- **Picker**: it auto-detects in order snacks -> fzf-lua -> telescope -> mini. Its
  Snacks check is `assert(Snacks.config["picker"].enabled)` - ran that exact condition
  here: true, so it uses Snacks with no config.
- **`html` treesitter parser** is "optional, but highly recommended" (renders problem
  descriptions). It had been deliberately removed in the very first trim follow-up
  ("languages actually used", in [[languages-and-lsp]]). Restored in `languages.lua`, with a comment saying
  why, so it isn't trimmed again. Other web parsers (javascript/jsdoc/tsx/typescript)
  stay removed. Confirmed `html` is back in the merged `ensure_installed` list.
- **Upstream's `build = ":TSUpdate html"` fails here** ("Not an editor command: TSUpdate
  html") - treesitter isn't loaded at plugin-build time, and it would fail again on a
  fresh machine. Dropped: `ensure_installed` installs the parser instead.
- **C++ includes**: LeetCode compiles with `bits/stdc++.h` and `using namespace std`
  implicitly, so solutions use `vector`/`string` with no `#include`. I initially wrote
  an `injector` adding those two lines - then found the plugin **already injects exactly
  those by default** (`lua/leetcode/config/imports.lua`; `inject_imports()` returns the
  defaults when no `imports` override is set), folded out of the way. My version would
  have put them in every file twice. Removed. Also confirmed only the marked
  `@leet start`/`@leet end` code section is sent on run/test/submit
  (`console.lua:63`), so injected lines never get submitted.
- `bits/stdc++.h` exists on this system (`/usr/include/c++/16/...`, GCC libstdc++), so
  clangd can resolve it.

**Change** - `lua/plugins/leetcode.lua` (new): the plugin with `plenary.nvim` +
`nui.nvim` (both already installed), `lang = "cpp"` (its default, made explicit), no
injector override. `lua/plugins/languages.lua`: `html` no longer filtered out.

**Verified live**:
- `:Leet` command registered; config resolved `lang=cpp`, no injector override.
- A LeetCode-style solution file laid out as the plugin writes it (imports section +
  marked code section): clangd attached, **0 errors**. Same file without the imports
  section: **3 errors** ("No template named 'vector'") - i.e. exactly the problem the
  default imports solve.
- `nvim leetcode.nvim` launches cleanly: after `VimEnter` the working directory moved
  to `~/.local/share/nvim/leetcode` (its storage home), the menu buffer mounted
  (`ft=leetcode.nvim`), 0 errors in `:messages`. (Note for headless testing: `-c`
  commands run **before** `VimEnter`, and the plugin starts on `VimEnter` - checks must
  be deferred past it or they see nothing. The first attempt hit exactly that.)

**Not done, needs the user**: logging in. `:Leet cookie update` with the `Cookie` value
from the browser's **request** headers. The plugin stores it under its own cache dir;
no cookie value is in this repo. Cookies expire periodically, and the same "expired"
message appears when LeetCode throttles its API during contests.

**Cheatsheet**: new "LeetCode" category (6 entries: launching, login, run/test/submit,
console keys, finding problems, the cookie-expired case); GhostText entry points
LeetCode users here instead. Keymap coverage unchanged at 280/284 (no new global
keymaps - everything is under `:Leet`).

## Follow-up: leetcode.nvim health check, and the "cookie expired" error explained (2026-09-23)

**Is it still working?** Its last *tagged release* is v0.3.1 (2025-06-28), but commits
continued to 2026-04-28 (the installed version); not archived, ~2.2k stars, issues and
PRs active through this week. Caveat: nothing merged since April, nine community PRs
pending - fixes are slow. Tested live against LeetCode rather than inferring from dates:
problem lookup (GraphQL) returned correct data, the problem list returned all 4,060
problems, and unauthenticated POSTs to the run/submit endpoints reached LeetCode's own
server (Django's "403 CSRF verification failed" page - `server: cloudflare` is just the
CDN edge, not the bot check). So Cloudflare wasn't blocking this machine at the time.
Logged-in run/submit remain untested (needs the user's cookie).

(Testing note: a first probe used a zsh loop variable named `path`, which in zsh is tied
to `$PATH` - it wiped the command search path, so its "origin answered" output was
meaningless. Renamed the variable and re-ran.)

**The "cookie expired" message is a catch-all** - `api/utils.lua:153` shows it for any
401/403, so it can't distinguish its three real causes: a genuinely expired cookie
(fix: `:Leet cookie update`), LeetCode throttling its API during contests (fix: wait),
and Cloudflare flagging the request as a bot (fix: curl-impersonate). Documented a
diagnosis order: fresh cookie first; if a fresh cookie fails immediately outside
contest time, it's Cloudflare.

**curl-impersonate** (community-confirmed fix in issue #167, latest confirmation
2026-08-29): plenary.curl shells out to `curl`, and Cloudflare recognises curl by its
TLS handshake regardless of the User-Agent header. curl-impersonate is a curl build that
handshakes like a real browser. Verified before documenting it: plenary really reads
`vim.g.plenary_curl_bin_path` (`plenary/curl.lua:291`); the package is in the official
repos (`extra`, 2.2.2) so plain `pacman -S` works; and Arch's own file list for the
package confirms it installs `curl_chrome136` - the exact profile the reports used -
plus newer ones (`curl_chrome150`, `curl_firefox147`). **Not installed** - only needed
if the Cloudflare case actually occurs.

**Cheatsheet**: the LeetCode "cookie expired" entry now has the cause/diagnosis table,
plus new entries for the curl-impersonate fix and for what plenary is (and what its
announced end of active maintenance means). 153 entries; keymap coverage unchanged.

## Follow-up: LeetCode run/submit keys (2026-09-23)

**What**: leetcode.nvim ships **no** keys for run/test/submit - checked the source: its
configurable `keys` only cover its own windows (`q`, `<CR>`, `r`, `U`, `H`, `L`), and
nothing binds run or submit. Added `\r` (run) and `\s` (submit); `\` is the local
leader.

**Decision** (asked, with options checked first): `<leader>l...` was out (`<leader>l`
is Lazy, so a group under it would delay opening Lazy); `<leader>r` / `<leader>R` are
free today but reserved by the refactoring / REST extras; `Ctrl+'` / `Ctrl+Enter`
(LeetCode's website keys) only reach Neovim in terminals that support kitty's keyboard
protocol. Chose local-leader keys, bound **buffer-locally** to solution buffers only.

No test key: `:Leet test` and `:Leet run` hit the same endpoint (`urls.run` and
`urls.interpret` are both `/problems/%s/interpret_solution/`).

**Change** - `lua/plugins/leetcode.lua`: a `hooks.question_enter` function. That hook
fires in `Question:handle_mount()` right after `create_buffer()`, and again when
`:Leet lang` opens a new, not-yet-loaded solution buffer - so the keys follow a
language switch.

**Verified**: calling the registered hook on a buffer binds `\r` -> `<Cmd>Leet run<CR>`
and `\s` -> `<Cmd>Leet submit<CR>` there, while an unrelated buffer gets neither. In a
real `nvim leetcode.nvim` session (checked after `VimEnter`), `run` and `submit` are
both among its 23 subcommands. Not verified: pressing them on a live problem, which
needs the user's login. Cheatsheet "Run, test and submit" entry updated.

## Follow-up: LeetCode sign-in split into two boxes (2026-09-23)

**What**: first real sign-in failed with "Bad csrf token format". The user had copied
just the `LEETCODE_SESSION` value from dev tools' Cookies tab. `Cookie.parse`
(`lua/leetcode/cache/cookie.lua:88`) needs **both** `csrftoken=...` and
`LEETCODE_SESSION=...` as `name=value` pairs, checking csrftoken first - hence that exact
error. Asked for separate input boxes for the two values instead of one "paste the
whole Cookie header" box.

**Change** - `lua/plugins/leetcode.lua`: a `two_box_cookie_prompt` that asks for
csrftoken, then LEETCODE_SESSION, assembles `csrftoken=X; LEETCODE_SESSION=Y`, and hands
it to the plugin's **own** `cookie.set` - so saving and the login check are the
plugin's, unchanged. Uses the same nui popup style as the original prompt (wider, since
the tokens are long). Also strips a pasted `name=` prefix, trims whitespace, cancels on
an empty first box, and still accepts a full Cookie header in the first box (skipping
the second).

Done from config rather than editing the plugin's files, which are overwritten on every
plugin update. It had to reach **three** places, since two of them keep references
rather than looking the function up when called: `cmd.cookie_prompt` itself;
`cmd.commands.cookie.update[1]`, which the `:Leet cookie update` table captures when its
module loads, so it's patched directly; and the sign-in page's "Sign in" button, which
captures the prompt when that page first renders - after our `config` runs, so it picks
up the replacement. A custom `config` function calls `require("leetcode").setup(opts)`
first, then patches.

**Verified**: in a real `nvim leetcode.nvim` session, all three references point at the
new function (the sign-in page module was found holding it). Behaviour tested with a
fake popup feeding scripted answers and `cookie.set` stubbed (nothing written, no
network) - 5/5: two plain values; values pasted with their names; stray whitespace; a
full Cookie header in box 1 (one box only, passed through untouched); empty box 1
cancels. Real popups were also confirmed to show the right titles in order ("1/2
csrftoken" then "2/2 LEETCODE_SESSION").

**Testing notes** for next time: leetcode.nvim resolves its storage paths only once a
session starts, so its cookie module can't even be required in a plain Neovim (`field
'cache' (a nil value)`) - test inside `nvim leetcode.nvim` after `VimEnter`. And typing
into nui popups via feedkeys doesn't work when the whole test runs as one script
(`startinsert` only takes effect once control returns to the main loop), so keystrokes
landed as normal-mode commands - a fake `nui.input` gives a deterministic test instead.

Also confirmed the failed attempt didn't leave a bad cookie behind: `Cookie.set` parses
before writing, so a malformed paste never reaches disk.

## Follow-up: LeetCode questions failing to open - swap files (2026-09-23)

**What**: reopening a previously attempted problem showed a "code already found,
recover/delete?" prompt, and after either choice the question never appeared.

**Diagnosis**: the plugin has no such prompt (grepped) - it's Neovim's own swap-file
`ATTENTION` dialog. `nvim -r` showed the swap for `33.search-in-rotated-sorted-array.cpp`
owned by a **still-running** `nvim leetcode.nvim` (pid 48973), i.e. the same solution
file open in two places. Reproduced on a throwaway file with a second headless Neovim
holding it open: the plugin loads solutions via `vim.fn.bufload()`, which raises
**`E325: ATTENTION`** as an error rather than prompting. The buffer actually loads
(`loaded=true`), but the plugin treats the error as fatal - so the question never
opens whichever option is chosen.

**What didn't work, tested rather than assumed**: a `SwapExists` autocmd setting
`v:swapchoice` ('o' or 'e'), and `swapfile=false` per-buffer in `BufReadPre` - both still
got E325, because the swap check runs before either can intervene. (A first
reproduction attempt gave meaningless results: `-c "set directory=..."` runs *after*
the file loads, so the holder's swap went to the default directory and no conflict
existed. Fixed with `--cmd`, which runs before.) What works session-wide:
`shortmess+=A` and `noswapfile`.

**Decision** (asked): no swap files in LeetCode sessions. Chosen over `shortmess+=A`,
which keeps swap files but hides the warning - stale swaps from crashes would then pile
up unnoticed and ambush a normal Neovim later. Tradeoff accepted: a crash loses edits
since the last `:w`.

**Change** - `lua/plugins/leetcode.lua`: `hooks.enter` sets `vim.o.swapfile = false`.
`enter` fires in `leetcode.start()` before any question buffer exists, so every
solution buffer inherits it; normal Neovim sessions are untouched.

**Verified**: in a real `nvim leetcode.nvim` session, `swapfile` is `false` after
start, and loading a file that another Neovim holds with a swap succeeds (`ok=true`,
no E325, no own swap). A normal session still has `swapfile=true`. The other instance's
swap and the user's live problem-33 swap were left untouched.
