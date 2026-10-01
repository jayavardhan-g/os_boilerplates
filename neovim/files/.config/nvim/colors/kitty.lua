-- Reads kitty's actual theme file at load time (not a hardcoded snapshot),
-- so this colorscheme always matches whatever kitty is currently using -
-- including if Noctalia regenerates ~/.config/kitty/themes/noctalia.conf
-- later (e.g. on a wallpaper change).

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.g.colors_name = "kitty"

local function read_kitty_theme()
  -- Follow the same `include` kitty.conf uses, so this keeps working if the
  -- included theme file's name ever changes.
  local conf = vim.fn.expand("~/.config/kitty/kitty.conf")
  local theme_path = nil
  local f = io.open(conf, "r")
  if f then
    for line in f:lines() do
      local inc = line:match("^%s*include%s+(.+)%s*$")
      if inc then
        theme_path = vim.fn.expand("~/.config/kitty/" .. inc)
      end
    end
    f:close()
  end
  if not theme_path then
    return nil
  end

  local tf = io.open(theme_path, "r")
  if not tf then
    return nil, theme_path
  end
  local c = {}
  for line in tf:lines() do
    local key, val = line:match("^%s*([%a_][%w_]*)%s+(#%x%x%x%x%x%x)%s*$")
    if key then
      c[key] = val
    end
  end
  tf:close()
  return c, theme_path
end

-- Reload this colorscheme whenever the theme file changes while Neovim is open.
-- Noctalia rewrites it on a wallpaper change and SIGUSR1-reloads every kitty, so
-- kitty switches to the new background at once. Without this, Neovim kept painting
-- the OLD background colour, which kitty no longer treats as its own (only cells in
-- exactly kitty's background colour get background_opacity) - so the see-through
-- editor turned into a solid dark box until Neovim was reopened.
-- Watches the directory, not the file: a file replaced via rename would otherwise
-- silently drop the watch. Exactly one watcher + one timer per Neovim (the guard
-- survives reloads); both are reused for every event, so nothing accumulates.
local function watch_theme(theme_path)
  if vim.g.kitty_theme_watched or not theme_path then
    return
  end
  local dir, name = vim.fs.dirname(theme_path), vim.fs.basename(theme_path)
  local watcher, timer = vim.uv.new_fs_event(), vim.uv.new_timer()
  local function close_all()
    for _, h in ipairs({ watcher, timer }) do
      if h and not h:is_closing() then
        h:close()
      end
    end
  end
  if not watcher or not timer then
    close_all()
    return
  end

  local reload = vim.schedule_wrap(function()
    -- Only reload from a complete file. A half-written one has no background, which
    -- would drop the scheme to its habamax fallback - and this watcher only follows
    -- "kitty", so it would stay stuck there. The write's final event retries.
    local t = read_kitty_theme()
    if vim.g.colors_name == "kitty" and t and t.background then
      vim.cmd.colorscheme("kitty")
    end
  end)

  local function give_up()
    -- Free both handles; the next `:colorscheme kitty` (or a new Neovim) starts a
    -- fresh watch.
    close_all()
    vim.schedule(function()
      vim.g.kitty_theme_watched = nil
    end)
  end

  local ok = watcher:start(dir, {}, function(err, fname)
    -- Runs in libuv's loop: only uv calls here, editor state goes via vim.schedule.
    if err then
      give_up()
      return
    end
    if fname ~= name then
      -- Deleting the watched dir arrives as an ordinary event (no err) and leaves a
      -- dead watch behind - verified. Only other names in the dir get here, so the
      -- stat is rare.
      if not vim.uv.fs_stat(dir) then
        give_up()
      end
      return
    end
    -- Debounce: one regeneration fires several events. Restarting the same timer
    -- means a burst of writes costs one reload, 150 ms after the last of them.
    timer:start(150, 0, reload)
  end)
  if not ok then
    close_all() -- dir missing/unwatchable: nothing started, nothing left open
    return
  end
  vim.g.kitty_theme_watched = true
end

local c, theme_path = read_kitty_theme()
watch_theme(theme_path)
if not c or not c.background then
  vim.cmd("colorscheme habamax") -- kitty theme file unreadable - fall back rather than error
  return
end

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Base editor UI
hl("Normal", { fg = c.foreground, bg = c.background })
-- Floats and sidebars share the editor background on purpose: kitty renders
-- cells in exactly its own background colour at background_opacity, so this
-- makes them see-through like the editor. With color0 they were solid grey
-- boxes. Covers every NormalFloat user (Snacks explorer box via SnacksNormal,
-- the leetcode.nvim description panel, hover docs, which-key, Lazy, ...);
-- rounded borders still set them apart. Pmenu (completion menu) is left
-- solid below so the selected item stays easy to pick out.
hl("NormalFloat", { fg = c.foreground, bg = c.background })
hl("FloatBorder", { fg = c.color8, bg = c.background })
hl("Cursor", { fg = c.background, bg = c.cursor })
hl("CursorLine", { bg = c.color0 })
hl("CursorLineNr", { fg = c.cursor, bold = true })
hl("LineNr", { fg = c.color8 })
hl("Visual", { bg = c.selection_background, fg = c.selection_foreground })
hl("Search", { bg = c.color3, fg = c.background })
hl("IncSearch", { bg = c.cursor, fg = c.background })
hl("MatchParen", { fg = c.cursor, bold = true })
hl("WinSeparator", { fg = c.color8 })
hl("SignColumn", { bg = c.background })
hl("Pmenu", { fg = c.foreground, bg = c.color0 })
hl("PmenuSel", { fg = c.background, bg = c.cursor })
hl("StatusLine", { fg = c.foreground, bg = c.color0 })
hl("StatusLineNC", { fg = c.color8, bg = c.color0 })
hl("TabLine", { fg = c.inactive_tab_foreground or c.color8, bg = c.inactive_tab_background or c.color0 })
hl("TabLineSel", { fg = c.active_tab_foreground or c.background, bg = c.active_tab_background or c.cursor })
hl("TabLineFill", { bg = c.color0 })
hl("NonText", { fg = c.color8 })
hl("Whitespace", { fg = c.color8 })

-- Syntax (base16-style mapping onto kitty's 16-color palette)
hl("Comment", { fg = c.color8, italic = true })
hl("Constant", { fg = c.color3 })
hl("String", { fg = c.color2 })
hl("Character", { fg = c.color2 })
hl("Number", { fg = c.color3 })
hl("Boolean", { fg = c.color3 })
hl("Identifier", { fg = c.color4 })
hl("Function", { fg = c.color4, bold = true })
hl("Statement", { fg = c.color5 })
hl("Keyword", { fg = c.color5 })
hl("Operator", { fg = c.foreground })
hl("PreProc", { fg = c.color1 })
hl("Type", { fg = c.color6 })
hl("Special", { fg = c.color1 })
hl("Underlined", { fg = c.color4, underline = true })
hl("Error", { fg = c.color1, bold = true })
hl("Todo", { fg = c.background, bg = c.color3, bold = true })
hl("DiffAdd", { fg = c.color2, bg = c.background })
hl("DiffDelete", { fg = c.color1, bg = c.background })
hl("DiffChange", { fg = c.color3, bg = c.background })
hl("DiffText", { fg = c.color4, bg = c.background, bold = true })

-- Diagnostics
hl("DiagnosticError", { fg = c.color1 })
hl("DiagnosticWarn", { fg = c.color3 })
hl("DiagnosticInfo", { fg = c.color4 })
hl("DiagnosticHint", { fg = c.color6 })
