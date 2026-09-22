return {
  {
    "folke/todo-comments.nvim",
    -- stylua: ignore
    keys = {
      -- Trouble was disabled (see disabled.lua) - no working replacement
      -- for these without it.
      { "<leader>xt", false },
      { "<leader>xT", false },
      -- Telescope isn't installed in this setup at all (picker is snacks,
      -- see lazyvim.json/config/options.lua) - rerouted to Snacks' grep
      -- picker with the todo keywords pre-filled instead of TodoTelescope.
      { "<leader>st", function() Snacks.picker.grep({ search = "TODO|FIX|FIXME|HACK|WARN|PERF|NOTE" }) end, desc = "Todo" },
      { "<leader>sT", function() Snacks.picker.grep({ search = "TODO|FIX|FIXME" }) end, desc = "Todo/Fix/Fixme" },
    },
  },
}
