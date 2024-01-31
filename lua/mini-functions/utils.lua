local M = {}

-- get property value at path
---@param path string path split by '.'
---@return table|nil result the value at path or nil
function M.get_at_path(tbl, path)
  if path == '' then return tbl end
  local segments = vim.split(path, '.', true)
  ---@type table[] | table
  local result = tbl

  for _, segment in ipairs(segments) do
    if type(result) == 'table' then
      ---@type table
      result = result[segment]
    end
  end

  return result
end

function M.setup_commands(mod, commands)
  for command_name, def in pairs(commands) do
    local f_args = def.args or '<f-args>'
    local call_fn =
      string.format('lua require("mini-function.%s").commands.%s["run<bang>"(%s)])', mod, command_name, f_args)
    local parts = vim.tbl_flatten({
      'command!',
      '-bar',
      def.args,
      command_name,
      call_fn,
    })
    vim.api.nvim_command(table.concat(parts, ' '))
  end
end

function M.table_inspect(tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep('  ', indent) .. k .. ': '
    if type(v) == 'table' then
      print(formatting)
      M.table_inspect(v, indent + 1)
    else
      print(formatting .. tostring(v))
    end
  end
end

return M
