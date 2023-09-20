local M = {}

-- current buffer path print and copy to clipboard
M.buffer_path = function()
  local full_path = vim.fn.expand('%:p')
  vim.fn.setreg('+', full_path)
  print(full_path)
end

return M

