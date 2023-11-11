local M = {}

M.next = function()
  local current_buf = vim.api.nvim_get_current_buf()
  local all_bufs = vim.api.nvim_list_bufs()
  local is_last_buf = current_buf == all_bufs[#all_bufs]

  if not is_last_buf then
    vim.api.nvim_command("bnext")
  end
end

M.previous = function()
  local current_buf = vim.api.nvim_get_current_buf()
  local all_bufs = vim.api.nvim_list_bufs()
  local is_first_buf = current_buf == all_bufs[1]

  if not is_first_buf then
    vim.api.nvim_command("bprevious")
  end
end

return M
