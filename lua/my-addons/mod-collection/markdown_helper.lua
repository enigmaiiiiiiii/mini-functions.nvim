local M = {}

local function generate_markdown_toc()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local toc = {}
  for _, line in ipairs(lines) do
    local level, title = string.match(line, '^(##+)%s*(.*)')
    if level and title then
      local item = string.format('%s* [%s](#%s)', string.rep('  ', #level - 2), title, title:lower():gsub('%s+', '-')) -- for marksman
      -- local item = string.format('%s* [%s](#%s)', string.rep('  ', #level - 2), title, title:gsub("%s+$", "")) -- for markdown-oxide
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
    local win_config = vim.api.nvim_win_get_config(win)
    if not win_config.relative or win_config.relative == '' then available = true end
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

return M
