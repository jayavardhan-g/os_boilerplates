-- LeetCode inside Neovim: browse problems, run, test and submit without the
-- browser. Launch a dedicated session with `nvim leetcode.nvim`.
--
-- Solutions are real .cpp files, so clangd, clang-format and format-on-save
-- all work normally (unlike the GhostText route, which needs workarounds).

--- Sign-in with two boxes (csrftoken, then LEETCODE_SESSION) instead of the
--- plugin's single "paste the whole Cookie header" box. The plugin's parser
--- needs both, as `name=value` pairs; pasting just one value fails with
--- "Bad csrf token format". The assembled string goes through the plugin's
--- own cookie.set, so saving and the login check are unchanged. A full
--- Cookie header pasted into the first box still works as before.
---@param cb? fun(success: boolean)
local function two_box_cookie_prompt(cb)
  local cmd = require("leetcode.command")
  local cookie = require("leetcode.cache.cookie")
  local log = require("leetcode.logger")
  local NuiInput = require("nui.input")
  local event = require("nui.utils.autocmd").event
  local toggle = require("leetcode.config").user.keys.toggle

  -- same look as the plugin's own prompt, just wider (tokens are long)
  local function ask(title, on_value)
    local input = NuiInput({
      relative = "editor",
      position = { row = "50%", col = "50%" },
      size = 60,
      border = { style = "rounded", text = { top = (" %s "):format(title), top_align = "left" } },
      win_options = { winhighlight = "Normal:Normal" },
    }, {
      prompt = " 󰆘 ",
      on_submit = function(value)
        on_value(vim.trim(value or ""))
      end,
    })
    input:mount()
    input:map("n", toggle, function()
      input:unmount()
    end)
    input:on(event.BufLeave, function()
      input:unmount()
    end)
  end

  local function finish(str)
    local err = cookie.set(str)
    if not err then
      log.info("Sign-in successful")
      cmd.start_user_session()
    else
      log.error("Sign-in failed: " .. err)
    end
    pcall(cb, not err)
  end

  ask("1/2  csrftoken", function(csrf)
    if csrf == "" then
      return
    end
    if csrf:find("LEETCODE_SESSION=", 1, true) then
      return finish(csrf)
    end
    csrf = csrf:gsub("^csrftoken=", "")
    -- let the first popup close before mounting the second
    vim.schedule(function()
      ask("2/2  LEETCODE_SESSION", function(session)
        if session == "" then
          return
        end
        session = session:gsub("^LEETCODE_SESSION=", "")
        finish(("csrftoken=%s; LEETCODE_SESSION=%s"):format(csrf, session))
      end)
    end)
  end)
end

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
        -- No swap files in LeetCode sessions. The plugin loads solutions with
        -- bufload(), and when any other Neovim already has that file open (a
        -- second LeetCode session, or a stale .swp), Neovim raises E325
        -- there instead of prompting - the plugin treats that as fatal and
        -- the question never opens, whichever of Recover/Delete you pick.
        -- A per-file fix doesn't work (the swap check runs before
        -- BufReadPre/SwapExists could intervene); session-wide does. `enter`
        -- fires at session start, before any question buffer exists.
        -- Tradeoff: a crash loses edits since the last :w.
        enter = {
          function()
            vim.o.swapfile = false
          end,
        },
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
    config = function(_, opts)
      require("leetcode").setup(opts)
      -- Two places hold the prompt: `:Leet cookie update` keeps a reference
      -- in cmd.commands (captured when the module loads, so it's patched
      -- directly), and the sign-in page's button captures cmd.cookie_prompt
      -- when that page first renders - which happens after this runs.
      local cmd = require("leetcode.command")
      cmd.cookie_prompt = two_box_cookie_prompt
      cmd.commands.cookie.update[1] = two_box_cookie_prompt

      -- Plain description text is drawn in the theme's Conceal colour, which
      -- is meant to be faint: 1.2:1 contrast on the old grey panel, 2.4:1
      -- even transparent. Use the normal text colour instead (14.4:1).
      -- Wrapping default.get rather than setting a fixed colour keeps it in
      -- step with the colorscheme - Theme.load re-reads get() at start and on
      -- every ColorScheme event, and kitty's colours change with Noctalia.
      -- A real fg, not a link: the plugin merges `normal` with bold/italic
      -- for emphasised words, and a link would silently drop those.
      local default = require("leetcode.theme.default")
      local get = default.get
      default.get = function()
        local theme = get()
        theme.normal = { fg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg }
        return theme
      end
    end,
  },
}
