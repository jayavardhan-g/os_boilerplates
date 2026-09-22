return {
  {
    "folke/flash.nvim",
    -- LazyVim's defaults put flash.jump()/flash.treesitter() on s/S,
    -- which steals Vim's native substitute-char/substitute-line. Free
    -- those back up and move flash to gs/gS instead - same 2-keystroke
    -- speed, no leader delay; gs was an obscure, unused "sleep N seconds"
    -- command natively, safe to give up.
    -- stylua: ignore
    keys = {
      { "s", false, mode = { "n", "x", "o" } },
      { "S", false, mode = { "n", "o", "x" } },
      { "gs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "gS", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },
}
