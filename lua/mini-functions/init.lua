local replace_with_clipboard = require('mini-functions.mini-replace-with-clipboard').replace_with_clipboard
local insert_markdown_TOC = require('mini-functions.mini-insert-markdown-TOC').insert_markdown_TOC
local get_buffer_path = require('mini-functions.mini-get-buffer-path').get_buffer_path
local no_circle_buffer_nav = require('mini-functions.mini-no-circle-buffer-nav')

local M = {}

M.insert_markdown_TOC         = insert_markdown_TOC
M.replace_with_clipboard      = replace_with_clipboard
M.get_buffer_path             = get_buffer_path
M.no_circle_buffer_nav_next   = no_circle_buffer_nav.next
M.no_circle_buffer_nav_prev   = no_circle_buffer_nav.previous

return M
