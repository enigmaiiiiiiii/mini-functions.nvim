local configs = require('mini-functions.configs')

local M = {}

local FUNCTION_DESCRIPTIONS = {
  get_buffer_path = 'Copy the full path of the current buffer to the clipboard',
  replace_with_clipboard = 'Replace the current word with the contents of the clipboard',
  insert_markdown_TOC = 'Insert a table of contents for the current markdown file',
}

M.get_buffer_path = function()
  local full_path = vim.fn.expand('%:p')
  vim.fn.setreg('+', full_path)
  print(full_path)
end

M.replace_with_clipboard = function()
  local clipboard_content = vim.fn.getreg('"')
  vim.fn.expand('<cword>')
  vim.api.nvim_command('normal! ciw' .. clipboard_content)
  vim.fn.setreg('"', clipboard_content)
end

local function generate_markdown_TOC()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local toc = {}
  for _, line in ipairs(lines) do
    local level, title = string.match(line, '^(##+)%s*(.*)')
    if level and title then
      local item = string.format('%s* [%s](#%s)', string.rep('  ', #level - 2), title, title:lower():gsub('%s+', '-'))
      table.insert(toc, item)
    end
  end
  return toc
end

M.insert_markdown_TOC = function()
  local toc = generate_markdown_TOC()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_lines(0, row, row, false, toc)
end

M.attach = function()
  local config = configs.get_module('funk')
  for funcname, mapping in pairs(config.keymaps) do
    ---@type string|function
    local rhs = string.format(":lua require('mini-functions.funk').%s()<CR>", funcname)
    local mode = 'n'
    if mapping then
      vim.keymap.set(
        mode,
        mapping,
        rhs,
        { noremap = true, silent = true, noremap = true, desc = FUNCTION_DESCRIPTIONS[funcname] }
      )
    end
  end
end

return M
