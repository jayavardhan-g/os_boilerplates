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
    return nil
  end
  local c = {}
  for line in tf:lines() do
    local key, val = line:match("^%s*([%a_][%w_]*)%s+(#%x%x%x%x%x%x)%s*$")
    if key then
      c[key] = val
    end
  end
  tf:close()
  return c
end

local c = read_kitty_theme()
if not c or not c.background then
  vim.cmd("colorscheme habamax") -- kitty theme file unreadable - fall back rather than error
  return
end

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Base editor UI
hl("Normal", { fg = c.foreground, bg = c.background })
hl("NormalFloat", { fg = c.foreground, bg = c.color0 })
hl("FloatBorder", { fg = c.color8, bg = c.color0 })
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
