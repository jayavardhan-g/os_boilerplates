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
        -- wraps properly and, called a 2nd time while already open, moves
        -- focus into the window so j/k scroll without closing it.
        vim.keymap.set(
          "n",
          "<leader>ghP",
          function() require("gitsigns").preview_hunk() end,
          { buffer = buffer, desc = "Preview Hunk (Popup)" }
        )
      end
      return opts
    end,
  },
}
