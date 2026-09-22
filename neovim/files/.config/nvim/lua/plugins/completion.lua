return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        -- The inline "autofill" preview of the top completion candidate,
        -- shown ahead of the cursor as you type - distinct from the
        -- dropdown menu itself, which stays on.
        ghost_text = { enabled = false },
      },
      -- Gated behind vim.g.blink_cmp_enabled so the whole engine (menu,
      -- auto-trigger, everything) can be flipped off at runtime - see the
      -- <leader>uC toggle in config/keymaps.lua.
      enabled = function()
        return vim.g.blink_cmp_enabled ~= false
      end,
    },
  },
}
