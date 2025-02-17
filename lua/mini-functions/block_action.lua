local ts_utils = require('nvim-treesitter.ts_utils')
local parsers = require('nvim-treesitter.parsers')

local utils = require('mini-functions.utils')

local M = {}

---@type MiniConfig
M.config = {
  keymaps = {
    go_outer = '[[', -- Go to outer node
    -- go_outer_end = ']]', -- Go to inner node
    go_next_sibling = '[j', -- Go to next sibling
    go_previous_sibling = '[k', -- Go to previous sibling
  },
}

---@param get_target fun(node: TSNode): TSNode | nil
---@return fun():nil
local function sibling(get_target)
  return function()
    local node = ts_utils.get_node_at_cursor(0, true) ---@type TSNode?
    if node == nil then return end
    local csrow, cscol, cerow, cecol = node:range() ---@type integer, integer, integer, integer

    -- Find a node that changes the current selection.jump
    -- local root = parsers.get_parser():parse()[1]:root()
    -- node = root:named_descendant_for_range(csrow - 1, cscol - 1, cerow - 1, cecol)

    while true do
      local target = get_target(node)
      local parent = node:parent()
      if parent == nil or target == nil then return end
      local tsrow, _, _, _ = target:range()
      local psrow, _, perow, _ = parent:range()

      -- for root node or no next node selected
      -- if not target or target == node then
      --   -- Keep searching in the main tree
      --   -- TODO: we should search on the parent tree of the current node.
      --   local root = parsers.get_parser():parse()[1]:root()
      --   target = root:named_descendant_for_range(csrow - 1, cscol - 1, cerow - 1, cecol)
      --   if not target or root == node or target == node then
      --     update_cursor(node)
      --     return
      --   end
      -- end

      if (psrow == csrow and perow == cerow) or (psrow == tsrow and tsrow == csrow) then
        node = node:parent()
      else
        if target ~= node then
          utils.update_cursor(target)
          return
        else
          return
        end
      end
    end
  end
end

-- M.go_outer = move(function(node) return node:parent() or node end)
M.go_outer = utils.make_dot_repeat(function()
  local node = ts_utils.get_node_at_cursor() ---@type TSNode
  local csrow, cscol, cerow, cecol = node:range() ---@type integer, integer, integer, integer

  -- Find a node that changes the current selection.
  -- local root = parsers.get_parser():parse()[1]:root()
  -- node = root:named_descendant_for_range(csrow - 1, cscol - 1, cerow - 1, cecol)
  while true do
    local target = node:parent() or node  ---@type TSNode?
    if target == nil then return end
    local tsrow, _, _, _ = target:range()

    -- for root node or no next node selected
    if not target or target == node then
      -- Keep searching in the main tree
      ---@type TSNode
      local root = parsers.get_parser():parse()[1]:root()
      target = root:named_descendant_for_range(csrow - 1, cscol - 1, cerow - 1, cecol)
      if not target or root == node or target == node then
        utils.update_cursor(node)
        return
      end
    end

    if tsrow == csrow then
      node = target
    else
      utils.update_cursor(target)
      return
    end
  end
end, 'v:lua.MiniFunctionsBlockAction.go_outer')

-- M.go_inner = sibling(function(node) return node:child(0) or node end)

M.go_next_sibling = utils.make_dot_repeat(
  sibling(function(node) return node:next_sibling() or node end),
  'v:lua.MiniFunctionsBlockAction.go_next_sibling'
)

M.go_previous_sibling = utils.make_dot_repeat(
  sibling(function(node) return node:prev_sibling() or node end),
  'v:lua.MiniFunctionsBlockAction.go_previous_sibling'
)

local FUNCTION_DESCRIPTIONS = {
  go_inner = 'Go to inner node',
  go_outer = 'Go to outer node',
  go_next_sibling = 'Go to next sibling',
  go_previous_sibling = 'Go to previous sibling',
}

local keymap_opts = function(desc) return { silent = true, expr = true, noremap = true, buffer=true, desc = desc } end

local function set_block_action_keymaps()
  vim.keymap.set('n', M.config.keymaps.go_outer, function() M.go_outer() end, keymap_opts('Go To Outer Node'))
  -- vim.keymap.set('n', M.config.keymaps.go_inner, function() M.go_inner() end, keymap_opts('Go To Inner Node'))
  vim.keymap.set(
    'n',
    M.config.keymaps.go_next_sibling,
    function() M.go_next_sibling() end,
    keymap_opts('Go To Next Sibling')
  )
  vim.keymap.set(
    'n',
    M.config.keymaps.go_previous_sibling,
    function() M.go_previous_sibling() end,
    keymap_opts('Go To Previous Sibling')
  )
end

local autocmd_group = 'MiniFunctionsBlockAction'
--- @return boolean
local function is_nofile_buf()
  local buftype = vim.bo.buftype
  if buftype == 'nofile' or buftype == 'terminal' then return true end
  return false
end

M.attach = function()
  _G.MiniFunctionsBlockAction = M
  vim.api.nvim_create_augroup(autocmd_group, { clear = true })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = autocmd_group,
    pattern = '*',
    callback = function()
      if is_nofile_buf() then return end
      set_block_action_keymaps()
    end,
  })
end

M.detach = function(bufnr)
  _G.MiniFunctionsBlockAction = nil
  vim.api.nvim_clear_autocmds({
    group = autocmd_group,
  })
end
return M
