-- Cheatsheet coverage audit - see personal-cheatsheet.md, "Full coverage audit".
-- Run inside the full config with a .cpp buffer open, after VeryLazy and a few
-- seconds for LSP to attach:
--   AUDIT_OUT=/tmp/audit.txt nvim --headless x.cpp +'lua vim.defer_fn(function()
--     vim.api.nvim_exec_autocmds("User",{pattern="VeryLazy"}); require("blink.cmp");
--     require("grug-far"); vim.defer_fn(function() dofile("cheatsheet-audit.lua");
--     vim.cmd("qa!") end, 5000) end, 300)'
--
-- Compares the cheatsheet's `backtick spans` with: Neovim's :help index (every
-- built-in key and Ex command), every described keymap, every user command, and
-- the keys inside plugin windows. Output: real gaps per area, then everything
-- counted as covered only through ALLOW (documented in prose/shorthand) with the
-- reason - so nothing is hidden silently. A clean run prints 0 everywhere.

local out = {}
local function w(s) out[#out + 1] = s end

-- Things the doc can only describe in words (a key containing a backtick can't
-- be a span) or writes as shorthand. Each entry says where it's covered.
local ALLOW = {
  ["CTRL-G CTRL-J"] = "alias of <C-g>j", ["CTRL-G <Down>"] = "alias of <C-g>j",
  ["CTRL-G CTRL-K"] = "alias of <C-g>k", ["CTRL-G <Up>"] = "alias of <C-g>k",
  ["<Left>"] = "arrow keys, in prose", ["<Right>"] = "arrow keys, in prose",
  ["<Help>"] = "no Help key on PC keyboards; <F1> is documented",
  ["/{pattern}<CR>"] = 'written "/pattern then <CR>"', ["?{pattern}<CR>"] = 'written "?pattern"',
  ["/<CR>"] = 'written "/ then <CR>"', ["?<CR>"] = 'written "? then <CR>"',
  ["3"] = "counts", ["4"] = "counts", ["5"] = "counts", ["6"] = "counts", ["7"] = "counts",
  ["8"] = "counts", ["9"] = "counts",
  [":"] = "the Ex command line - used throughout",
  ["`{a-zA-Z0-9}"] = "backtick key: Marks entry, in words", ["`("] = "backtick key: More marks, in words",
  ["`)"] = "backtick key: More marks, in words", ["`<"] = "backtick key: More marks, in words",
  ["`>"] = "backtick key: More marks, in words", ["`["] = "backtick key: More marks, in words",
  ["`]"] = "backtick key: More marks, in words", ['"``"'] = 'backtick key: "two backticks in a row"',
  ["`{"] = "backtick key: More marks, in words", ["`}"] = "backtick key: More marks, in words",
  ["a`"] = 'backtick key: "a+backtick"', ["i`"] = 'backtick key: "i-then-backtick"',
  ["[`"] = "backtick key: More marks, in words", ["]`"] = "backtick key: More marks, in words",
  ["CTRL-W CTRL-C"] = "a no-op", ["CTRL-W J"] = "shorthand after <C-w>H", ["CTRL-W K"] = "shorthand after <C-w>H",
  ["CTRL-W L"] = "shorthand after <C-w>H", ["CTRL-W j"] = "shorthand after <C-w>h",
  ["CTRL-W k"] = "shorthand after <C-w>h", ["CTRL-W l"] = "shorthand after <C-w>h",
  ["g?g?"] = "alias of g??", ["'wildchar'"] = "that's <Tab>, documented",
  [":{range}"] = "Ranges entry", [":fo[ld]"] = "written :{range}fo",
  ["<leader>`"] = "backtick key: Switch buffers entry, in words",
  ["`"] = "backtick key (which-key marks trigger / autopair)", ["g`"] = "backtick key: More marks, in words",
  ["<C-W>J"] = "shorthand after <C-w>H", ["<C-W>K"] = "shorthand after <C-w>H", ["<C-W>L"] = "shorthand after <C-w>H",
  ["<2-LeftMouse>"] = '"double-click - open", in words',
  ["z{char}"] = "a pointer to the z section of :help index, not a key", ["z"] = "which-key's z trigger, not a key",
}
local allowed = {}
local function allow(key) if ALLOW[key] then allowed[#allowed + 1] = ("  %-18s %s"):format(key, ALLOW[key]); return true end end

local function norm(s)
  s = s:gsub("<lead>", "<leader>"):gsub("<localleader>", "\\"):gsub("<[Ss]pace>", "<leader>")
  -- case matters outside <...> (<lead>uA is not <lead>ua, gJ is not gj);
  -- inside it, <C-W> and <C-w> are the same key
  s = s:gsub("<[Ee]nter>", "<cr>"):gsub(" ", ""):gsub("<[^>]+>", string.lower)
  s = s:gsub('^%["x%]', ""):gsub("{[^}]*}", ""):gsub("%[count%]", "")
  return s
end

-- documented spans (fences stripped: ``` pairs would shift span pairing)
local doc = vim.fn.readfile(vim.env.CHEATSHEET or (vim.fn.stdpath("config") .. "/cheatsheet.user.md"))
local text, inf = {}, false
for _, l in ipairs(doc) do
  if l:match("^%s*```") then inf = not inf elseif not inf then text[#text + 1] = l end
end
local body = table.concat(text, "\n")
local spans, rawspans = {}, {}
for s in body:gmatch("`([^`]+)`") do
  rawspans[#rawspans + 1] = s
  spans[norm(s)] = true
  for piece in s:gmatch("[^%s/·,]+") do spans[norm(piece)] = true end
end

-- every :command the doc names, resolved to its full name by Neovim itself
local fullcmds = {}
-- fullcommand() also expands modifiers (:abo, :vert, :sil …), which
-- nvim_parse_cmd rejects without a command after them
local function full_name(word)
  local ok, f = pcall(vim.fn.fullcommand, word)
  if ok and f ~= "" then return f end
  local okp, p = pcall(vim.api.nvim_parse_cmd, word, {})
  return okp and p.cmd ~= "" and p.cmd or word
end
local function resolve(word)
  fullcmds[full_name(word)] = true
  fullcmds[word] = true
end
for _, s in ipairs(rawspans) do
  for c in (" " .. s):gmatch("[%s|(]:(%a+)") do resolve(c) end
end
for c in table.concat(doc, "\n"):gmatch(":(%a+)") do resolve(c) end
local function doc_has_literal(prefix)
  for _, s in ipairs(rawspans) do if s:sub(1, #prefix) == prefix then return true end end
end

-- families the doc covers with a stated rule
local rule_covered
function rule_covered(full)
  if full:match("^l") and fullcmds["c" .. full:sub(2)] then return true end          -- :l… twins
  local prev = full:gsub("Next$", "previous"):gsub("Nfile$", "pfile")                -- :…N = :…previous
  if prev ~= full and (fullcmds[prev] or rule_covered(prev)) then return true end
  if full:match("menu$") or full:match("^%a?unmenu$") or full:match("^%a+menu$") then return true end
  if full:match("^end") then return true end                                         -- Vimscript end…
  if full:match("^s") and (fullcmds[full:sub(2)] or fullcmds["b" .. full:sub(3)]) then return true end
  if full:match("rewind$") then return true end                                      -- …rewind = …first
  if full:match("^pt") and fullcmds["t" .. full:sub(3)] then return true end         -- :pt… twins
  if full:match("^%amapclear$") then return true end
  if full:match("do$") or full:match("file$") then                                   -- provider …do/…file
    local base = full:gsub("do$", ""):gsub("file$", "")
    if fullcmds[base] or fullcmds[full_name(base)] then return true end
  end
end

-- 1. :help index
local idx = vim.fn.readfile(vim.env.VIMRUNTIME .. "/doc/index.txt")
local section, order, miss = "?", {}, {}
local function key_from_index(k)
  return (k:gsub("CTRL%-(%S)", "<C-%1>"):gsub("<C%-(%a)>", function(c) return "<C-" .. c:lower() .. ">" end))
end
for _, l in ipairs(idx) do
  if l:match("^%d+%.") or l:match("^%d %u") then section = l:gsub("%s*%*.*$", "") end
  local _, key, desc = l:match("^|([^|]+)|%s+(%S[^\t]*)\t+(.*)$")
  if key then
    key = vim.trim(key)
    local d = desc:gsub("^%s*[%d%-]*%s*", "")
    local skip = d:match("^same as") or d:match("^like ") or key:match("Mouse") or key:match("ScrollWheel")
      or d:match("not used") or d:match("^reserved") or d:match("^nothing")
    local covered
    if skip then
      covered = true
    elseif key:match("^:") then
      local name = key:gsub("[%[%]]", ""):sub(2)
      local word = name:match("^(%a+)")
      if word then
        local full = full_name(word)
        covered = fullcmds[full] or fullcmds[word] or rule_covered(full)
      else
        covered = doc_has_literal(key:gsub("%[.*$", ""):sub(1, 4))
      end
    else
      local k = norm(key_from_index(key))
      covered = spans[k]
    end
    if not covered and not allow(key) then
      if not miss[section] then miss[section] = {}; order[#order + 1] = section end
      table.insert(miss[section], ("%-22s %s"):format(key, d))
    end
  end
end
w("=== BUILT-IN (:help index) NOT MENTIONED ===")
for _, s in ipairs(order) do
  w(("## %s  (%d missing)"):format(s, #miss[s]))
  for _, m in ipairs(miss[s]) do w("  " .. m) end
end

-- 2. live keymaps with a description (group prefixes skipped)
w("=== KEYMAPS (desc) NOT MENTIONED ===")
local leader = vim.g.mapleader or "\\"
local seen = {}
local function check(m, mode, scope)
  if not m.desc or m.desc == "" or m.desc:match("^%+") then return end
  local lhs = m.lhs:gsub("^" .. vim.pesc(leader), "<leader>"):gsub(vim.pesc(leader) .. "$", "<leader>")
  lhs = lhs:gsub(" ", "<leader>")
  if spans[norm(lhs)] or spans[norm(m.lhs)] or seen[mode .. lhs] then return end
  seen[mode .. lhs] = true
  if not allow(lhs) then w(("  %s %-18s %-40s %s"):format(mode, lhs, m.desc, scope)) end
end
for _, mode in ipairs({ "n", "x", "o", "i", "c", "t" }) do
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do check(m, mode, "") end
  for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do check(m, mode, "(buffer)") end
end

-- 3. user commands
w("=== COMMANDS NOT MENTIONED ===")
local cmds = vim.tbl_keys(vim.api.nvim_get_commands({}))
for k in pairs(vim.api.nvim_buf_get_commands(0, {})) do cmds[#cmds + 1] = k end
table.sort(cmds)
for _, c in ipairs(cmds) do
  if not fullcmds[c] then w("  :" .. c) end
end

-- 4. keys inside plugin windows
w("=== IN-WINDOW PLUGIN KEYS NOT MENTIONED ===")
local function inner(label, tbl)
  for lhs, spec in pairs(tbl or {}) do
    local name = type(spec) == "table" and (spec[1] or spec.desc) or spec
    if type(name) ~= "string" then name = "fn" end
    if not spans[norm(lhs)] and not allow(lhs) then w(("  %-14s %-16s %s"):format(label, lhs, name)) end
  end
end
local pk = require("snacks.picker.config.defaults").defaults.win
inner("picker-input", pk.input.keys)
inner("picker-list", pk.list.keys)
local ok, ex = pcall(function() return require("snacks.picker.config.sources").explorer.win.list.keys end)
if ok then inner("explorer", ex) end
local okp, preset = pcall(require, "blink.cmp.keymap.presets")
if okp then
  local bk = require("blink.cmp.config").keymap
  inner("blink", preset.get and preset.get(bk.preset) or preset[bk.preset])
end
local okg, gf = pcall(function() return require("grug-far.opts").defaultOptions.keymaps end)
if okg then
  for k, v in pairs(gf) do
    if type(v) == "table" and v.n and not spans[norm(v.n)] and not allow(v.n) then
      w(("  grug-far       %-16s %s"):format(v.n, k))
    end
  end
end
for k, v in pairs(require("lazy.view.config").commands) do
  if v.key and not spans[norm(v.key)] then w(("  lazy-ui        %-16s %s"):format(v.key, k)) end
end


-- 5. entries that describe a setting but don't say how to make it the default
w("=== SETTINGS WITHOUT A DEFAULT LINE ===")
-- entries that only use an option name as an example, with why
local ALLOW_ENTRIES = {
  ["The help system"] = "`:h 'wrap'` is an example help topic",
  ["Inspect this setup"] = "`:set shiftwidth?` is an example of reading any option",
  ["Work on lines"] = "`:>` uses shiftwidth - its default is in Indent and move lines",
  ["Join, paste and case extras"] = "`:retab` uses tabstop/expandtab - defaults in Indent and move lines",
  ["Diff commands"] = "`:syncb` mentions scrollbind, a per-window state",
}
local optnames = {}
for name in pairs(vim.api.nvim_get_all_options_info()) do optnames[name] = true end
local entries, cur, fence = {}, nil, false
for _, l in ipairs(doc) do
  if l:match("^%s*```") then fence = not fence end
  local t = not fence and l:match("^###%s+(.+)$")
  if t then cur = { title = t, lines = {} }; entries[#entries + 1] = cur
  elseif not fence and l:match("^##%s") then cur = nil
  elseif cur then cur.lines[#cur.lines + 1] = l end
end
-- entries that had a Default line when this list was made (2026-09-26):
-- plugin settings are described in words the patterns can't see, so
-- losing one of these is caught by name instead
local EXPECT_DEFAULT = {
  ["Find text in the current file"] = true,
  ["Find files by name"] = true,
  ["Clear search highlighting"] = true,
  ["More buffer commands"] = true,
  ["Split the window"] = true,
  ["Scroll the view"] = true,
  ["Indent and move lines"] = true,
  ["Copy to the system clipboard"] = true,
  ["Toggle comments"] = true,
  ["Using the completion menu"] = true,
  ["Turn autocomplete on or off"] = true,
  [ [[Inline "ghost text" is off]] ] = true,
  ["Turn it off"] = true,
  ["Format on save"] = true,
  ["Function parameters (signature help)"] = true,
  ["See the details"] = true,
  ["Blame"] = true,
  ["Browse files in a tree"] = true,
  ["Common toggles (`<lead>u` prefix)"] = true,
  ["Discover any keybinding"] = true,
  ["Things that happen by themselves"] = true,
  ["Reading the status line"] = true,
  ["Using the mouse"] = true,
  ["Look up the word under the cursor"] = true,
  ["Inspect highlights and syntax"] = true,
  ["Turn wrap on or off"] = true,
  ["Nicer-looking wrapping"] = true,
  ["Long lines with wrap off"] = true,
  ["Hard wrap: break lines at a width"] = true,
  ["How folding works here"] = true,
  ["Make folds by hand"] = true,
  ["Built-in completion"] = true,
  ["History and extras"] = true,
  ["Reflow paragraphs and comments"] = true,
  ["Turn it on and fix words"] = true,
  ["More spelling keys and commands"] = true,
  ["Beyond plain undo"] = true,
  ["Undo commands"] = true,
  ["Crash recovery (swap files)"] = true,
  ["Case sensitivity"] = true,
  ["Live preview while substituting"] = true,
  ["Limit a substitution to part of the file"] = true,
  ["Solve LeetCode inside Neovim"] = true,
}
local missing = 0
for _, e in ipairs(entries) do
  local body = table.concat(e.lines, "\n")
  local found = {}
  for span in body:gmatch("`([^`\n]+)`") do
    for _, pat in ipairs({ ":set%a*%s+no(%a+)", ":set%a*%s+(%a+)", "vim%.opt%.(%a+)", "vim%.o%.(%a+)", "^(%a+)=", "'(%a+)'" }) do
      for n in span:gmatch(pat) do if optnames[n] then found[n] = true end end
    end
  end
  for k in body:gmatch("`(<lead>u%a)`") do found[k] = true end
  local lower = body:lower()
  if lower:match("by default") or lower:match("starts %*%*off") or lower:match("starts %*%*on") then found["(says: by default)"] = true end
  local has = body:match("\nDefaults?[ ,:]") or body:match("^Defaults?[ ,:]") or body:match("\nDefault for ")
  if EXPECT_DEFAULT[e.title] and not has then found["(had a Default line)"] = true end
  if next(found) and not has then
    if ALLOW_ENTRIES[e.title] then
      allowed[#allowed + 1] = ("  %-18s %s"):format("entry", e.title .. ": " .. ALLOW_ENTRIES[e.title])
    else
      missing = missing + 1
      w(("  %-45s %s"):format(e.title, table.concat(vim.tbl_keys(found), ", ")))
    end
  end
end

w("=== COVERED ONLY IN PROSE / SHORTHAND (allowlist, with where) ===")
table.sort(allowed)
local last
for _, a in ipairs(allowed) do if a ~= last then w(a) end; last = a end
vim.fn.writefile(out, vim.env.AUDIT_OUT)
