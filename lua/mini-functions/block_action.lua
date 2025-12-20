local parsers = require('nvim-treesitter.parsers')

local utils = require('mini-functions.utils')

local M = {}

local config = {
  keymaps = {
    go_outer_start = '[[', -- Go to outer node
    go_outer_end = ']]', -- Go to outer node end
    go_next_sibling = '[j', -- Go to next sibling
    go_previous_sibling = '[k', -- Go to previous sibling
  },
}

local function cursor_is_on_blank()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  if line == '' then
    return true;
  end

  if col < #line then
    return line:sub(col + 1, col + 1):match('%s') ~= nil
  end
  return false
end

---@param get_target fun(node: TSNode): TSNode | nil
---@return fun():nil
local function sibling(get_target)
  return function()
    -- local node = ts_utils.get_node_at_cursor(0, true) ---@type TSNode?
    local node = vim.treesitter.get_node()
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

local function go_outer(to_end)
  local node = vim.treesitter.get_node()  ---@type TSNode?
  if node == nil then return end
  local csrow, cscol, cerow, cecol = node:range() ---@type integer, integer, integer, integer

  if cursor_is_on_blank() then
    utils.update_cursor(node, to_end)
    return
  end

  while true do
    local target = node:parent() or node ---@type TSNode?
    if target == nil then return end

    -- for root node or no next node selected
    if not target or target == node then
      -- Keep searching in the main tree
      ---@type TSNode
      local root = parsers.get_parser():parse()[1]:root()
      target = root:named_descendant_for_range(csrow - 1, cscol - 1, cerow - 1, cecol)
      if not target or root == node or target == node then
        utils.update_cursor(node, to_end)
        return
      end
    end

    ---@type integer, integer
    local node_pos, target_pos
    if to_end then
      node_pos = node:end_()
      target_pos = target:end_()
    else
      node_pos = node:start()
      target_pos = target:start()
    end

    if node_pos == target_pos then
      node = target
    else
      utils.update_cursor(target, to_end)
      return
    end
  end
end

local go_outer_end = utils.make_dot_repeat(
  function()
    go_outer(true)
  end,
  'v:lua.MiniFunctionsBlockAction.go_outer_end'
)

local go_outer_start = utils.make_dot_repeat(
  function()
    go_outer(false)
  end,
  'v:lua.MiniFunctionsBlockAction.go_outer_start'
)

local go_next_sibling = utils.make_dot_repeat(
  sibling(function(node) return node:next_sibling() or node end),
  'v:lua.MiniFunctionsBlockAction.go_next_sibling'
)

local go_previous_sibling = utils.make_dot_repeat(
  sibling(function(node) return node:prev_sibling() or node end),
  'v:lua.MiniFunctionsBlockAction.go_previous_sibling'
)

local keymap_opts = function(desc) return { silent = true, expr = true, noremap = true, buffer = true, desc = desc } end

local function set_block_action_keymaps()
  vim.keymap.set('n', config.keymaps.go_outer_start, go_outer_start, keymap_opts('Go To Outer Node'))
  vim.keymap.set('n', config.keymaps.go_outer_end, go_outer_end, keymap_opts('Go To Outer Node End'))
  vim.keymap.set(
    'n',
    config.keymaps.go_next_sibling,
    go_next_sibling,
    keymap_opts('Go To Next Sibling')
  )
  vim.keymap.set(
    'n',
    config.keymaps.go_previous_sibling,
    go_previous_sibling,
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

M.go_outer_start = go_outer_start
M.go_outer_end = go_outer_end
M.go_next_sibling = go_next_sibling
M.go_previous_sibling = go_previous_sibling

M.setup = function(user_config)
  config = vim.tbl_deep_extend('force', config, user_config or {})
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

M.disable = function(bufnr)
  _G.MiniFunctionsBlockAction = nil
  vim.api.nvim_clear_autocmds({
    group = autocmd_group,
  })
end
return M
