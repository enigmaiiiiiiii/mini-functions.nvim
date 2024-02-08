local ts_utils = require('nvim-treesitter.ts_utils')
local parsers = require('nvim-treesitter.parsers')

local configs = require('mini-functions.configs')
local utils = require('mini-functions.utils')

local M = {}

local update_cursor = function(node)
  local srow, scol, _, _ = node:range()  ---@type integer, integer, integer, integer
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("m'", true, true, true), 'n', true)
  vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
end

---@param get_target fun(node: TSNode): TSNode | nil
---@return fun():nil
local function sibling(get_target)
  return function()
    local node = ts_utils.get_node_at_cursor(0, true) ---@type TSNode
    if node == nil then return end
    local csrow, cscol, cerow, cecol = node:range() ---@type integer, integer, integer, integer

    -- Find a node that changes the current selection.jump
    -- local root = parsers.get_parser():parse()[1]:root()
    -- node = root:named_descendant_for_range(csrow - 1, cscol - 1, cerow - 1, cecol)

    while true do
      local target = get_target(node)
      local parent = node:parent()
      if parent == nil then return end
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

      if (psrow == csrow and perow == cerow) or (psrow == tsrow and tsrow == csrow)  then
        node = node:parent()
      else
        if target ~= node then
          update_cursor(target)
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
    local target = node:parent() or node
    local tsrow, _, _, _ = target:range()

    -- for root node or no next node selected
    if not target or target == node then
      -- Keep searching in the main tree
      -- TODO: we should search on the parent tree of the current node.
      local root = parsers.get_parser():parse()[1]:root()
      target = root:named_descendant_for_range(csrow - 1, cscol - 1, cerow - 1, cecol)
      if not target or root == node or target == node then
        update_cursor(node)
        return
      end
    end

    if tsrow == csrow then
      node = target
    else
      update_cursor(target)
      return
    end
  end
end, 'v:lua.MiniFunctionsJumpRow.go_outer')

M.go_inner = sibling(function(node) return node:child(0) or node end)

M.go_next_sibling = utils.make_dot_repeat(
  sibling(function(node) return node:next_sibling() or node end),
  'v:lua.MiniFunctionsJumpRow.go_next_sibling'
)

M.go_previous_sibling = utils.make_dot_repeat(
  sibling(function(node) return node:prev_sibling() or node end),
  'v:lua.MiniFunctionsJumpRow.go_previous_sibling'
)

local FUNCTION_DESCRIPTIONS = {
  go_inner = 'Go to inner node',
  go_outer = 'Go to outer node',
  go_next_sibling = 'Go to next sibling',
  go_previous_sibling = 'Go to previous sibling',
}

M.attach = function()
  _G.MiniFunctionsJumpRow = M
  local config = configs.get_module('jump_row')
  for funcname, mapping in pairs(config.keymaps) do
    ---@type string|function
    local rhs = M[funcname]
    local mode = 'n'
    if mapping then
      vim.keymap.set(
        mode,
        mapping,
        rhs,
        { silent = true, expr = true, noremap = true, desc = FUNCTION_DESCRIPTIONS[funcname] }
      )
    end
  end
end

M.detach = function(bufnr)
  _G.MiniFunctionsJumpRow = nil
  local config = configs.get_module('jump_row')
  for _, mapping in pairs(config.keymaps) do
    if mapping then vim.keymap.del('n', mapping, { buffer = bufnr }) end
  end
end

return M
