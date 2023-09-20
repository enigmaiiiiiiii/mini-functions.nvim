local M = {}

M.ReplaceWithClipboard = function()
  local clipboard_content= vim.fn.getreg('"')
  vim.fn.expand('<cword>')
  vim.api.nvim_command('normal! ciw' .. clipboard_content)
  vim.fn.setreg('"', clipboard_content)
end


return M
