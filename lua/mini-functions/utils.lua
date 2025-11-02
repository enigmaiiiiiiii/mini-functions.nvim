local M = {}

---@class MiniModule
---@field config MiniConfig
---@field attach function(string)

-- get property value at path
---@param path string path split by '.'
---@return ModuleConfig | nil result the value at path or nil
function M.get_at_path(configs, path)
  if path == '' then return configs end
  local segments = vim.split(path, '.', {plain = true})
  print("segments:", segments);
  ---@type table[] | table
  local result = configs

  for _, segment in ipairs(segments) do
    print("segment:", segment);
    if type(result) == 'table' then
      ---@type table
      result = result[segment]
    end
  end

  return result
end

-- create dot-repeat function
---@param func fun():nil function to repeat
---@param func_name string name of the function
function M.make_dot_repeat(func, func_name)
  return function(motion)
    if motion == nil then
      -- if the function is called from keymap or command
      func()
      vim.o.operatorfunc = func_name
      vim.api.nvim_feedkeys("g@l", "n", true)
    else
      func()
    end
  end
end

---@param node TSNode
function M.update_cursor(node, to_end)
  to_end = to_end or false
  local row, col = 0, 0
  if (to_end) then
    row, col, _ = node:end_()
  else
    row, col, _ = node:start()
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("m'", true, true, true), 'n', true)
  local total_lines = vim.api.nvim_buf_line_count(0)
  row = row + 1 < total_lines and row + 1 or total_lines
  vim.api.nvim_win_set_cursor(0, { row, col })
end

return M
