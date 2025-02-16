local M = {}

M.config = {
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
  if not vim.api.nvim_get_option_value("modified", { buf = buf }) then
    return
  end
  vim.api.nvim_buf_call(buf, function()
    vim.api.nvim_command("silent update")
  end)
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local file_name = string.match(buf_name, "/([^/]+)$")
  local message = string.format('"%s" auto written at %s', file_name, os.date("%H:%M:%S") )
  print(message)
end

---@type function
-- local delay = configs.get_config('auto_save').delay
-- local debounced_save = debounce(save, delay)
local debounced_save = debounce(save, M.config.delay)

local auto_save_group = vim.api.nvim_create_augroup('auto_save', { clear = true })
local auto_save = function()
  -- local config = configs.get_config('auto_save')
  vim.api.nvim_create_autocmd(
    M.config.trigger_events,
    {
      group = auto_save_group,
      callback = debounced_save,
    }
)
end

M.attach = function()
  auto_save()
end

M.detach = function() vim.api.nvim_clear_autocmds({ group = auto_save_group }) end

return M
