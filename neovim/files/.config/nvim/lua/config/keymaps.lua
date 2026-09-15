-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Delete a character without yanking it (plain x overwrites the unnamed
-- register, clobbering whatever you last copied with y)
vim.keymap.set("n", "x", '"_x', { noremap = true, silent = true })

-- Yank to the system clipboard - reaches the LOCAL machine even over SSH
-- via OSC52 (see options.lua). Scoped to <leader>y so plain y/yy don't
-- touch the system clipboard on every internal yank.
local yank_opts = { noremap = true, silent = true }
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', yank_opts)
vim.keymap.set("n", "<leader>Y", '"+y$', yank_opts)
