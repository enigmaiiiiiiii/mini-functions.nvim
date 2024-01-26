local M = {}

-- get property value at path
---@param path string path split by '.'
---@return table|nil result the value at path or nil
function M.get_at_path(tbl, path)
  if path == "" then
    return tbl
  end
  local segments = vim.split(path, ".", true)
  ---@type table[] | table
  local result = tbl

  for _, segment in ipairs(segments) do
    if type(result) == "table" then
      ---@type table
      result = result[segment]
    end
  end
end

return M
