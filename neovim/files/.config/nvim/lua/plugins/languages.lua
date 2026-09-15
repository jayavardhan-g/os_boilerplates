return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- ensure_installed is an opts_extend list (LazyVim concatenates, it
      -- doesn't replace) - so removals have to filter the merged result,
      -- additions can't just be left out of a replacement list.
      local remove = { html = true, javascript = true, jsdoc = true, tsx = true, typescript = true }
      opts.ensure_installed = vim.tbl_filter(function(lang)
        return not remove[lang]
      end, opts.ensure_installed)
      -- C++ specifically wasn't in the default list (only bare "c" was)
      table.insert(opts.ensure_installed, "cpp")
      return opts
    end,
  },
}
