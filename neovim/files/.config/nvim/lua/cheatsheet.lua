-- Searchable cheatsheet, driven by ~/.config/nvim/cheatsheet.md.
--
-- The markdown is parsed into one entry per "### Title" block, grouped by the
-- "## Category" above it. The picker fuzzy-matches entry titles (plus their
-- category), previews the selected entry on the right, and <CR> opens just
-- that entry on its own - deliberately never dumping you into the raw file
-- scrolled to a line, which is what made earlier versions unpleasant.

local M = {}

local function path()
  return vim.fn.stdpath("config") .. "/cheatsheet.md"
end

---@return { category: string, title: string, body: string }[]
function M.entries()
  local fd = io.open(path(), "r")
  if not fd then
    return {}
  end
  local content = fd:read("*a")
  fd:close()

  local items, category, title, body = {}, nil, nil, {}

  local function flush()
    if title then
      -- trim trailing blank lines so previews don't have dead space
      while #body > 0 and body[#body]:match("^%s*$") do
        table.remove(body)
      end
      items[#items + 1] = { category = category or "", title = title, body = table.concat(body, "\n") }
    end
    title, body = nil, {}
  end

  -- Headings inside fenced code blocks are content, not structure - the
  -- bodies contain shell/vim snippets and ASCII mockups where a leading
  -- "#" is common.
  local in_fence = false

  for line in (content .. "\n"):gmatch("(.-)\n") do
    if line:match("^%s*```") then
      in_fence = not in_fence
    end

    -- "###" must be tested before "##": the "##" pattern needs whitespace
    -- after it, so it won't match a "###" line, but order makes that explicit
    local entry = not in_fence and line:match("^###%s+(.+)$") or nil
    local cat = not in_fence and line:match("^##%s+(.+)$") or nil
    if entry then
      flush()
      title = entry
    elseif cat then
      flush()
      category = cat
    elseif title then
      body[#body + 1] = line
    end
  end
  flush()

  return items
end

--- Open a single entry in its own centered floating window.
---@param item table
function M.show(item)
  local lines = vim.split("# " .. item.title .. "\n\n" .. item.body, "\n")

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local width = math.min(92, math.floor(vim.o.columns * 0.8))
  -- +2 for the title/padding, capped so long entries still fit on screen
  local height = math.max(5, math.min(#lines + 2, math.floor(vim.o.lines * 0.8)))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " " .. item.title .. " ",
    title_pos = "center",
  })
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].conceallevel = 2

  local opts = { buffer = buf, silent = true, nowait = true }
  vim.keymap.set("n", "q", "<cmd>close<cr>", opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", opts)
  -- backspace goes back to the search list, so you can keep browsing
  vim.keymap.set("n", "<BS>", function()
    vim.api.nvim_win_close(win, true)
    M.open()
  end, opts)
end

--- Pull the `backtick spans` out of a body - the keys and commands an entry
--- is about, without the surrounding prose.
---@param body string
---@return string
local function key_terms(body)
  local seen, out = {}, {}
  for term in body:gmatch("`([^`]+)`") do
    if not seen[term] and #term <= 24 then
      seen[term] = true
      out[#out + 1] = term
    end
  end
  return table.concat(out, " ")
end

function M.open()
  local items = {}
  for i, entry in ipairs(M.entries()) do
    items[#items + 1] = {
      idx = i,
      score = 0,
      -- Matching runs against the title, its category, and the keys the
      -- entry mentions - so "ghP" or "ciw" find the right entry. The prose
      -- body is deliberately excluded: including it made a search for
      -- "find" return 69 noisy hits with the wrong one ranked first.
      text = entry.title .. " " .. entry.category .. " " .. key_terms(entry.body),
      title = entry.title,
      category = entry.category,
      body = entry.body,
      preview = {
        text = "# " .. entry.title .. "\n\n" .. entry.body,
        ft = "markdown",
        loc = false,
      },
    }
  end

  Snacks.picker({
    source = "cheatsheet",
    title = "Cheatsheet",
    items = items,
    preview = "preview",
    layout = {
      preset = "default",
      -- Snacks' default backdrop is a 60%-opacity black overlay across the
      -- whole editor, which reads as "the theme changed" every time this
      -- opens. Off: everything behind keeps its normal colours.
      layout = { backdrop = false },
    },
    -- The bodies are prose, so let the preview wrap instead of cutting
    -- lines off at the pane edge (Snacks defaults preview windows to
    -- wrap=false, which suits code previews, not paragraphs).
    win = {
      preview = { wo = { wrap = true, linebreak = true } },
    },
    format = function(item)
      return {
        { ("%-46s"):format(item.title) },
        { item.category, "Comment" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        M.show(item)
      end
    end,
  })
end

return M
