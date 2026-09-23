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

      -- The plugin ships no keys for run/submit, only :Leet commands. These
      -- are buffer-local to solution buffers, so they can't clash with
      -- anything elsewhere. No separate "test" key: :Leet test and :Leet run
      -- hit the same endpoint (interpret_solution). question_enter fires
      -- after the solution buffer exists, and again for the new buffer when
      -- :Leet lang switches language.
      hooks = {
        question_enter = {
          function(question)
            local function map(lhs, sub, desc)
              vim.keymap.set("n", lhs, "<cmd>Leet " .. sub .. "<cr>", { buffer = question.bufnr, desc = desc })
            end
            map("<localleader>r", "run", "LeetCode: Run")
            map("<localleader>s", "submit", "LeetCode: Submit")
          end,
        },
      },
    },
  },
}
