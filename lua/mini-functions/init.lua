local replace_with_clipboard = require('mini-functions.mini-replace-with-clipboard').replace_with_clipboard
local insert_markdown_TOC = require('mini-functions.mini-insert-markdown-TOC').insert_markdown_TOC
local get_buffer_path = require('mini-functions.mini-get-buffer-path').get_buffer_path

local M = {}

M.insert_markdown_TOC =  insert_markdown_TOC
M.replace_with_clipboard= replace_with_clipboard
M.get_buffer_path = get_buffer_path

vim.keymap.set('n', 'cp', M.replace_with_clipboard, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>mt', M.insert_markdown_TOC, { noremap = true, silent = true })

return M
