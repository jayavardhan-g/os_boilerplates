return {
  -- Themes: no plugin - ~/.config/nvim/colors/kitty.lua reads kitty's own
  -- theme file directly and matches it exactly, staying in sync if
  -- Noctalia ever regenerates kitty's colors later.
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
  { "LazyVim/LazyVim", opts = { colorscheme = "kitty" } },

  -- HTML/JSX-specific - not used (C++, Python, C, Markdown, text files only)
  { "windwp/nvim-ts-autotag", enabled = false },
  { "folke/ts-comments.nvim", enabled = false },

  -- Lua-specific dev helper (better completion when editing Neovim's own
  -- config) - not needed since Lua isn't a language actually being used
  { "folke/lazydev.nvim", enabled = false },
}
