local M = {}

local function BufferPath()
  local full_path = vim.fn.expand('%:p')
  vim.fn.setreg('+', full_path)
  print(full_path)
end

vim.api.nvim_create_user_command(
  "Bufferpath",
  -- "let @+ = expand('%:p')",
  BufferPath,
  {bang = false, nargs = 0}
)

local function hello_world()
  print("hello world!")
end

M.BufferPath = BufferPath
M.hello_world = hello_world

return M
