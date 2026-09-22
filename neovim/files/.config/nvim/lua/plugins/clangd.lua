-- C/C++ language server. Closes the gap where .c/.cpp files had no LSP at
-- all: no go-to-definition, hover, references or diagnostics.
--
-- Deliberately not LazyVim's full `lang.clangd` extra: that also pulls in
-- clangd_extensions.nvim, whose remaining value here is an AST viewer and an
-- nvim-cmp score comparator that does nothing in this setup (we use
-- blink.cmp). Source/header switching is provided by nvim-lspconfig itself,
-- not that plugin. The clangd cmd flags below are taken from the extra.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          -- clangd 22.x ships system-wide in the `clang` package (same one
          -- that provides clang-format), so don't have Mason install a
          -- second copy.
          mason = false,
          keys = {
            { "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_markers = {
            "compile_commands.json",
            "compile_flags.txt",
            "configure.ac",
            "Makefile",
            "meson.build",
            "build.ninja",
            ".git",
          },
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
      },
    },
  },
}
