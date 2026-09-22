return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      -- Wrap (not replace) the default on_attach so all of LazyVim's
      -- existing gh* mappings stay intact - just add the popup preview
      -- alongside them, same buffer-local pattern.
      local on_attach = opts.on_attach
      opts.on_attach = function(buffer)
        if on_attach then
          on_attach(buffer)
        end
        -- <leader>ghp (LazyVim default) = inline preview: can't wrap long
        -- lines (Neovim's virt_lines API has no wrap mode, only
        -- trunc/scroll) and closes on any cursor move. This popup version
        -- doesn't wrap either, but auto-widens to fit the longest line and,
        -- called a 2nd time while already open, moves focus into the window
        -- so j/k (and normal nowrap horizontal scroll) work without closing
        -- it - call it twice here so one keypress lands you focused in,
        -- instead of needing to press it again yourself.
        vim.keymap.set("n", "<leader>ghP", function()
          local gs = require("gitsigns")
          gs.preview_hunk()
          gs.preview_hunk()
        end, { buffer = buffer, desc = "Preview Hunk (Popup, focused)" })
      end
      return opts
    end,
  },
}
