local M = {}

M.config = {
  keymaps = {
    replace_with_clipboard = 'cp',
  },
}

local FUNCTION_DESCRIPTIONS = {
  get_buffer_path = 'Copy the full path of the current buffer to the clipboard',
  replace_with_clipboard = 'Replace the current word with the contents of the clipboard',
  insert_markdown_toc = 'Insert a table of contents for the current markdown file',
}

M.get_absolute_buffer_path = function()
  local full_path = vim.fn.expand('%:p')
  vim.fn.setreg('+', full_path)
  print(full_path)
end

M.get_workspace_buffer_path = function()
  local relative_path = vim.fn.expand('%:.:p')
  vim.fn.setreg('+', relative_path)
  print(relative_path)
end

M.replace_with_clipboard = function()
  local clipboard_content = vim.fn.getreg('"')
  vim.fn.expand('<cword>')
  vim.api.nvim_command('normal! ciw' .. clipboard_content)
  vim.fn.setreg('"', clipboard_content)
end

local function generate_markdown_toc()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local toc = {}
  for _, line in ipairs(lines) do
    local level, title = string.match(line, '^(##+)%s*(.*)')
    if level and title then
      -- local item = string.format('%s* [%s](#%s)', string.rep('  ', #level - 2), title, title:lower():gsub('%s+', '-')) -- for marksman
      local item = string.format('%s* [%s](#%s)', string.rep('  ', #level - 2), title, title:gsub("%s+$", "")) -- for markdown-oxide
      table.insert(toc, item)
    end
  end
  return toc
end

M.insert_markdown_toc = function()
  local toc = generate_markdown_toc()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_lines(0, row, row, false, toc)
end

M.switch_focus_on_vertical = function()
  local function is_normal_window(win)
    local available = false
    local config = vim.api.nvim_win_get_config(win)
    if not config.relative or config.relative == '' then available = true end
    return available
  end

  local current_win_id = vim.api.nvim_get_current_win()
  local current_pos = vim.api.nvim_win_get_position(current_win_id)
  local current_col = current_pos[2]

  local wins = vim.api.nvim_tabpage_list_wins(0)

  local target_win_id = nil
  for _, win_id in ipairs(wins) do
    if win_id ~= current_win_id and is_normal_window(win_id) then
      local pos = vim.api.nvim_win_get_position(win_id)
      if pos[2] == current_col then
        target_win_id = win_id
        break
      end
    end
  end

  if target_win_id then
    vim.api.nvim_set_current_win(target_win_id)
  end
end

-- M.commands = {
--   FunkBufferPath = {
--     run = M.get_buffer_path,
--     args = {
--       '-nargs=1',
--       '-complete=custom',
--     },
--   },
-- }

M.attach = function()
  -- bind the functions to keymaps
  for funcname, mapping in pairs(M.config.keymaps) do
    ---@type string|function
    local rhs = M[funcname]
    local mode = 'n'
    if mapping then
      vim.keymap.set(mode, mapping, rhs, { silent = true, noremap = true, desc = FUNCTION_DESCRIPTIONS[funcname] })
    end
  end
end

M.detach = function() end

return M
