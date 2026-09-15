-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Over SSH only, register OSC52 as the provider for the "+"/"*" registers
-- so <leader>y (see keymaps.lua) still reaches the LOCAL machine's
-- clipboard with no X/Wayland forwarding (kitty understands OSC52 both
-- locally and over SSH). Left alone entirely when not over SSH - wl-copy
-- already works fine there via LazyVim's own unnamedplus default and
-- Neovim's built-in provider auto-detection; overriding it unconditionally
-- would replace that working local path with OSC52 escape codes too.
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
