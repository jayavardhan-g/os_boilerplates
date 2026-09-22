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

-- Toggle blink.cmp's autocomplete engine on/off at runtime (it gets in the
-- way sometimes). Gated via vim.g.blink_cmp_enabled, checked by the
-- "enabled" function in plugins/completion.lua. Snacks.toggle gives
-- which-key integration (shows on/off state, icon, color) for free.
-- <leader>uC was tried first, but was already taken (LazyVim's colorscheme
-- picker) - confirmed live via nvim_get_keymap, not just by grepping
-- keymaps.lua, since that one is registered outside this file. Settled on
-- <leader>ac ("autocomplete") instead - nothing else is bound under
-- <leader>a at all, confirmed the same way.
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
}):map("<leader>ac")

-- Personal cheatsheet (~/.config/nvim/cheatsheet.md). A single clean
-- rounded-border centered floating window, styled like noice.nvim's own
-- popups - tried Snacks.picker.lines() first (twice), but its layout
-- presets (ivy, vscode, select) either scattered multiple panes on screen
-- or wouldn't reliably render a preview pane at all once reshaped away
-- from the default. This is simpler and fully self-contained: native `/`
-- search (real incremental search, no picker involved) starts immediately
-- on open.
-- Bound to g? (native g? is ROT13-a-motion, essentially unused) rather than
-- bare ? (native backward-search, used constantly) or <leader>? (already
-- LazyVim's "buffer-local keymaps" popup) - both checked live and rejected
-- before landing here.
vim.keymap.set("n", "g?", function()
  local path = vim.fn.stdpath("config") .. "/cheatsheet.md"
  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.7)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " Cheatsheet ",
    title_pos = "center",
  })
  vim.wo[win].wrap = true
  vim.wo[win].conceallevel = 2
  vim.wo[win].cursorline = true
  vim.bo[buf].filetype = "markdown"
  local close_opts = { buffer = buf, silent = true }
  vim.keymap.set("n", "q", "<cmd>close<cr>", close_opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", close_opts)
  vim.api.nvim_feedkeys("/", "n", false)
end, { desc = "Cheatsheet" })
