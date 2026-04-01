local M = {}

local config = {
  trigger_events = { 'BufLeave', 'FocusLost', 'InsertLeave', 'TextChanged' },
  delay = 2000,
}


---@type table<number, number>
local timer_table = {}

local debounce = function(func, delay)
  local time_id = nil

  return function()
    local buf = vim.api.nvim_get_current_buf()
    if timer_table[buf] then
      vim.fn.timer_stop(timer_table[buf])
    end
    time_id = vim.fn.timer_start(delay, function() func(buf) end)
    timer_table[buf] = time_id
  end
end

local save = function(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if vim.api.nvim_get_option_value("buftype", { buf = buf }) ~= '' then
    return
  end
  local is_readonly = vim.api.nvim_get_option_value("readonly", { buf = buf })  ---@type boolean
  if (is_readonly) then
    return
  end
  if not vim.api.nvim_get_option_value("modified", { buf = buf }) then
    return
  end
  local buf_name = vim.api.nvim_buf_get_name(buf)
  if (buf_name == '') then
    return
  end
  vim.api.nvim_buf_call(buf, function()
    vim.api.nvim_command("silent update")
  end)
  local file_name = string.match(buf_name, "/([^/]+)$")
  local message = string.format('"%s" auto written at %s', file_name, os.date("%H:%M:%S") )
  vim.print(message, vim.log.levels.INFO, { title = "Auto Save" })
end

---@type function
-- local delay = configs.get_config('auto_save').delay
-- local debounced_save = debounce(save, delay)
local debounced_save = debounce(save, config.delay)

local auto_save_group = vim.api.nvim_create_augroup('auto_save', { clear = true })
local auto_save = function(opts)
  if opts.fargs[1] == 'disable' then
    vim.notify('Auto Save Disabled', vim.log.levels.WARN, { title = "Auto Save" })
    vim.api.nvim_clear_autocmds({ group = auto_save_group })
    return
  end
  if opts.fargs[1] == 'enable' then
    vim.notify('Auto Save Enabled', vim.log.levels.WARN, { title = "Auto Save" })
    vim.api.nvim_create_autocmd(
      config.trigger_events,
      {
        group = auto_save_group,
        callback = debounced_save,
      }
    )
    return
  end
  if opts.fargs[1] == 'delay' and tonumber(opts.args[2]) then
    config.delay = tonumber(opts.args[2])
    debounced_save = debounce(save, config.delay)
    vim.api.nvim_clear_autocmds({ group = auto_save_group })
    vim.api.nvim_create_autocmd(
      config.trigger_events,
      {
        group = auto_save_group,
        callback = debounced_save,
      }
    )
  end
end

M.setup = function(user_config)
  config = vim.tbl_deep_extend('force', config, user_config or {})

  vim.api.nvim_create_autocmd(
    config.trigger_events,
    {
      group = auto_save_group,
      callback = debounced_save,
    }
  )

  vim.api.nvim_create_user_command('AutoSave', auto_save, {
    nargs = '*',
    complete = function(arglead, cmdline, cursorpos)
      local commands = { 'enable', 'disable', 'delay' }
      local args = {}
      for _, cmd in ipairs(commands) do
        if vim.startswith(cmd, arglead) then
          table.insert(args, cmd)
        end
      end
      return args
    end,
  });
end

return M
