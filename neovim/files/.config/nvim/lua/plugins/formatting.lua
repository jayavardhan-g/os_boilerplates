return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- clang-format handles both C and C++ - already installed
        -- system-wide (part of the clang package), nothing to install.
        cpp = { "clang-format" },
        c = { "clang-format" },
        -- ruff format - installed via Mason, not present system-wide.
        python = { "ruff_format" },
      },
    },
  },
}
