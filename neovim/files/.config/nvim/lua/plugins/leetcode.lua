-- LeetCode inside Neovim: browse problems, run, test and submit without the
-- browser. Launch a dedicated session with `nvim leetcode.nvim`.
--
-- Solutions are real .cpp files, so clangd, clang-format and format-on-save
-- all work normally (unlike the GhostText route, which needs workarounds).
return {
  {
    "kawre/leetcode.nvim",
    -- No `build = ":TSUpdate html"` (upstream's suggestion): it fails here
    -- because treesitter isn't loaded at plugin-build time. The html parser
    -- is installed via treesitter's ensure_installed instead (languages.lua).
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lang = "cpp", -- the plugin's default too; explicit for the record
      -- No injector needed for C++: LeetCode compiles with bits/stdc++.h and
      -- `using namespace std` implicitly, and the plugin already injects
      -- exactly those two lines by default (lua/leetcode/config/imports.lua),
      -- folded out of the way. That's what keeps clangd from flagging every
      -- vector/string as undeclared. Only the marked code section is sent on
      -- run/test/submit, so the injected lines never get submitted.
    },
  },
}
