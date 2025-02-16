local M = {}

-- get property value at path
---@param path string path split by '.'
---@return ModuleConfig |nil result the value at path or nil
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

function M.setup_commands(mod, commands)
  for command_name, def in pairs(commands) do
    local f_args = def.args or '<f-args>'
    local call_fn =
      string.format('lua require("mini-function.%s").commands.%s["run<bang>"(%s)])', mod, command_name, f_args)
    local parts = vim.iter({
      'command!',
      '-bar',
      def.args,
      command_name,
      call_fn,
    }):flatten():totable()
    vim.api.nvim_command(table.concat(parts, ' '))
  end
end

--- @param tbl table
function M.table_inspect(tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    --- @type string
    local formatting = string.rep('  ', indent) .. k .. ': '
    if type(v) == 'table' then
      print(formatting)
      M.table_inspect(v, indent + 1)
    else
      print(formatting .. tostring(v))
    end
  end
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

---@param mod MiniModule
function M.setup_config_keymaps(mod, mode)
  mode = mode or 'n'
  for funcname, mapping in pairs(mod.config.keymaps) do
    ---@type string | function
    local rhs = mod[funcname]
    if mapping then
      vim.keymap.set(mode, mapping, rhs, { silent = true, noremap = true })
    end
  end
end

return M
