-- GhostText: edit browser textareas in Neovim.
--
-- nvim-ghost opens each textarea as an unnamed scratch buffer
-- (buftype=nofile) with whatever filetype the browser hinted - usually none.
-- That breaks two things, and they need different fixes:
--
--   formatting  only needs a filetype -> per-site defaults below, plus the
--               <leader>cL picker (config/keymaps.lua) for anything else.
--   LSP         also needs a file path, and Neovim's auto-attach refuses any
--               buffer whose buftype isn't "" ($VIMRUNTIME/lua/vim/lsp.lua:
--               "Only ever attach to buffers ... that represent an actual
--               file"). Flipping buftype to "" would satisfy that, but breaks
--               nvim-ghost's own close: it runs a plain :bdelete, which
--               refuses a modified normal buffer. So the buffer stays nofile,
--               is given a name with the right extension, and the matching
--               language servers are started by hand.

-- Sites that should open straight into a language (host -> filetype).
local site_filetypes = {
  ["leetcode.com"] = "cpp",
}

local extensions = {
  c = "c",
  cpp = "cpp",
  python = "py",
  markdown = "md",
  text = "txt",
  lua = "lua",
  sh = "sh",
  javascript = "js",
  typescript = "ts",
  rust = "rs",
  go = "go",
  java = "java",
  json = "json",
  yaml = "yaml",
}

local function is_filetype(ft)
  return ft ~= "" and vim.list_contains(vim.fn.getcompletion("", "filetype"), ft)
end

--- nvim-ghost's events are `User <host>`, but a pattern-"*" User autocmd
--- also fires for every other plugin's plain `doautocmd User Foo` (lazy.nvim
--- alone fires VeryLazy, LazyRender, LazyDone...). Only a hostname counts.
---@param s string
local function is_host(s)
  return s:match("^[%w%.%-]+:?%d*$") ~= nil and (s:find(".", 1, true) ~= nil or s:match("^localhost") ~= nil)
end

--- Give a ghost buffer a path matching its filetype and attach the language
--- servers for it. Safe to call repeatedly (e.g. when the language changes).
---@param buf integer
local function attach_language(buf)
  local host, ft = vim.b[buf].ghost_host, vim.bo[buf].filetype
  if not host or ft == "" then
    return
  end

  local dir = vim.fn.stdpath("cache") .. "/nvim-ghost"
  vim.fn.mkdir(dir, "p")
  -- buffer number keeps two textareas from the same site from colliding
  local name = ("%s/%s-%d.%s"):format(dir, host:gsub("[^%w%.%-]", "_"), buf, extensions[ft] or ft)
  if vim.api.nvim_buf_get_name(buf) ~= name then
    pcall(vim.api.nvim_buf_set_name, buf, name)
  end

  -- lspconfig loads on file-open events, which a ghost buffer never fires;
  -- a Neovim started only to serve GhostText would otherwise never load it
  require("lazy").load({ plugins = { "nvim-lspconfig" } })

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    local fts = client.config.filetypes
    if fts and not vim.list_contains(fts, ft) then
      vim.lsp.buf_detach_client(buf, client.id)
    end
  end
  for _, config in ipairs(vim.lsp.get_configs({ enabled = true, filetype = ft })) do
    vim.lsp.start(config, { bufnr = buf })
  end
end

return {
  {
    "subnut/nvim-ghost.nvim",
    lazy = false,
    config = function()
      -- nvim-ghost fires `User <host>` in this exact group once a textarea
      -- opens, and only creates the group itself if it doesn't exist yet.
      local ghost = vim.api.nvim_create_augroup("nvim_ghost_user_autocommands", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = ghost,
        pattern = "*",
        callback = function(ev)
          if not is_host(ev.match) then
            return
          end
          local buf = vim.api.nvim_get_current_buf()
          -- ghost buffers are unnamed nofile scratch buffers until we name them
          if vim.bo[buf].buftype ~= "nofile" then
            return
          end
          if vim.api.nvim_buf_get_name(buf) ~= "" and not vim.b[buf].ghost_host then
            return
          end

          local host = ev.match:gsub("^www%.", "")
          vim.b[buf].ghost_host = host

          -- the browser's hint is often empty, or a MIME type like
          -- "text/x-c++src" rather than a Neovim filetype
          if not is_filetype(vim.bo[buf].filetype) and site_filetypes[host] then
            vim.bo[buf].filetype = site_filetypes[host] -- FileType below attaches
            return
          end
          attach_language(buf)
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ghost_language", { clear = true }),
        callback = function(ev)
          if vim.b[ev.buf].ghost_host then
            attach_language(ev.buf)
          end
        end,
      })
    end,
  },
}
