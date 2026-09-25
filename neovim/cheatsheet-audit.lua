-- Cheatsheet coverage audit - see personal-cheatsheet.md, "Full coverage audit" (2026-09-26).
-- Run inside the full config with a .cpp buffer open, after VeryLazy and a few seconds for LSP:
--   AUDIT_OUT=/tmp/audit.txt nvim --headless x.cpp +'lua vim.defer_fn(function() vim.api.nvim_exec_autocmds("User",{pattern="VeryLazy"}); require("blink.cmp"); require("grug-far"); vim.defer_fn(function() dofile("cheatsheet-audit.lua"); vim.cmd("qa!") end, 5000) end, 300)'
-- Known false positives: keys containing a backtick, punctuation Ex commands (:! :& :<),
-- abbreviated names (:Ex, BufferLineCloseLeft/Right shorthand), grug-far keys written as \r.

-- Coverage audit: what nvim + plugins offer vs what the cheatsheet mentions.
local out = {}
local function w(s) out[#out + 1] = s end
local norm = function(s)
  s = s:gsub("<lead>", "<leader>"):gsub(" ", ""):lower()
  s = s:gsub('^%["x%]', ""):gsub("{[^}]*}", ""):gsub("%[count%]", "")
  return s
end

-- documented spans (fences stripped)
local doc = vim.fn.readfile(vim.fn.stdpath("config") .. "/cheatsheet.user.md")
local text, inf = {}, false
for _, l in ipairs(doc) do
  if l:match("^%s*```") then inf = not inf elseif not inf then text[#text + 1] = l end
end
local body = table.concat(text, "\n")
local fulltext = table.concat(doc, "\n"):lower()
local spans, exwords = {}, {}
for s in body:gmatch("`([^`]+)`") do
  spans[norm(s)] = true
  for piece in s:gmatch("[^%s/·,]+") do spans[norm(piece)] = true end
  for c in s:gmatch(":(%a+)") do exwords[c:lower()] = true end
end
for c in fulltext:gmatch(":(%a+)") do exwords[c] = true end

-- 1. :help index
local idx = vim.fn.readfile(vim.env.VIMRUNTIME .. "/doc/index.txt")
local section = "?"
local miss = {}
local function key_from_index(k)
  k = k:gsub("CTRL%-(%S)", "<C-%1>"):gsub("<C%-(%a)>", function(c) return "<C-" .. c:lower() .. ">" end)
  return k
end
for _, l in ipairs(idx) do
  local sec = l:match("^%d+%.?%d* (.+)%s+%*[%w_-]+%*$") or l:match("^%d%.%d? (%u.+)$")
  if l:match("^=+$") then
  elseif l:match("^%d+%.") or l:match("^%d %u") then section = l:gsub("%s*%*.*$", "") end
  local tag, key, desc = l:match("^|([^|]+)|%s+(%S[^\t]*)\t+(.*)$")
  if tag and key then
    key = vim.trim(key)
    local d = desc:gsub("^%s*[%d%-]*%s*", "")
    local covered
    if key:match("^:") then
      local full = key:gsub("[%[%]]", ""):sub(2):lower():match("^(%a+)")
      local short = key:match("^:(%a*)") or ""
      covered = false
      if full then
        for wd in pairs(exwords) do
          if #wd >= math.max(#short:lower(), 1) and full:sub(1, #wd) == wd then covered = true break end
        end
      end
    else
      local k = norm(key_from_index(key))
      covered = spans[k] or spans[k:gsub("<c%-(.)>", "ctrl-%1")] or false
    end
    local alias = d:match("^same as") or d:match("^like ") or key:match("Mouse") or key:match("ScrollWheel")
    if not covered and not alias and not d:match("not used") and not d:match("^reserved") and not d:match("^nothing") then
      miss[section] = miss[section] or {}
      table.insert(miss[section], ("%-22s %s"):format(key, d))
    end
  end
end
local secs = vim.tbl_keys(miss); table.sort(secs)
w("=== BUILT-IN (:help index) NOT MENTIONED ===")
for _, s in ipairs(secs) do
  w(("## %s  (%d missing)"):format(s, #miss[s]))
  for _, m in ipairs(miss[s]) do w("  " .. m) end
end

-- 2. live keymaps with a description
w("=== KEYMAPS (desc) NOT MENTIONED ===")
local leader = vim.g.mapleader or "\\"
local seen = {}
local function check(m, mode, scope)
  if not m.desc or m.desc == "" then return end
  local lhs = m.lhs:gsub("^" .. vim.pesc(leader), "<leader>"):gsub(vim.pesc(leader) .. "$", "<leader>")
  lhs = lhs:gsub(" ", "<leader>")
  local k = norm(lhs)
  if spans[k] or spans[norm(m.lhs)] then return end
  local id = mode .. lhs
  if seen[id] then return end
  seen[id] = true
  w(("  %s %-18s %-40s %s"):format(mode, lhs, m.desc, scope))
end
for _, mode in ipairs({ "n", "x", "o", "i", "c", "t" }) do
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do check(m, mode, "") end
  for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do check(m, mode, "(buffer)") end
end

-- 3. user commands from plugins
w("=== COMMANDS NOT MENTIONED ===")
local cmds = vim.tbl_keys(vim.api.nvim_get_commands({}))
for k in pairs(vim.api.nvim_buf_get_commands(0, {})) do cmds[#cmds + 1] = k end
table.sort(cmds)
for _, c in ipairs(cmds) do
  if not exwords[c:lower()] then w("  :" .. c) end
end

w("=== PLUGINS ===")
for _, p in ipairs(require("lazy").plugins()) do
  w(("  %s %s"):format(p.name, p._.loaded and "(loaded)" or ""))
end
-- 4. keys inside plugin windows
w("=== IN-WINDOW PLUGIN KEYS NOT MENTIONED ===")
local function inner(label, tbl)
  for lhs, spec in pairs(tbl or {}) do
    local name = type(spec) == "table" and (spec[1] or spec.desc) or spec
    if type(name) ~= "string" then name = "fn" end
    if not spans[norm(lhs)] then w(("  %-14s %-16s %s"):format(label, lhs, name)) end
  end
end
local pk = require("snacks.picker.config.defaults").defaults.win
inner("picker-input", pk.input.keys); inner("picker-list", pk.list.keys)
local ok, ex = pcall(function() return require("snacks.picker.config.sources").explorer.win.list.keys end)
if ok then inner("explorer", ex) end
local bk = require("blink.cmp.config").keymap
w("  blink preset: " .. tostring(bk.preset))
local okp, preset = pcall(require, "blink.cmp.keymap.presets")
if okp then inner("blink", preset.get and preset.get(bk.preset) or preset[bk.preset]) end
local okg, gf = pcall(function() return require("grug-far.opts").defaultOptions.keymaps end)
if okg then for k, v in pairs(gf) do if type(v) == "table" and v.n and not spans[norm(v.n)] then w(("  grug-far       %-16s %s"):format(v.n, k)) end end end
local lz = require("lazy.view.config").commands
for k, v in pairs(lz) do if v.key and not spans[norm(v.key)] then w(("  lazy-ui        %-16s %s"):format(v.key, k)) end end
vim.fn.writefile(out, vim.env.AUDIT_OUT)
