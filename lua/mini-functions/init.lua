
local replace_with_clipboard = require('mini-replace-with-clipboard').replace_with_clipboard
local insert_markdown_TOC = require('mini-mdTOC').InsertMarkdownTOC
local get_buffer_path = require('mini-bufferpath').get_buffer_path

local M = {}

M.insert_markdown_TOC =  insert_markdown_TOC
M.replace_with_clipboard= replace_with_clipboard
M.get_buffer_path = get_buffer_path

vim.api.nvim_set_keymap("n", "cp", ":lua replace_with_clipboard()<CR>", {noremap = true, silent = true})
-- vim.api.nvim_set_keymap("n", "<leader>mt", ":lua InsertMarkdownTOC()<CR>", {noremap = true, silent = true})
vim.keymap.set('n', '<leader>mt', M.insert_markdown_TOC, { noremap = true, silent = true })

return M
