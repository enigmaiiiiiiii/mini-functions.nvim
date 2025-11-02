local ts_utils = require('nvim-treesitter.ts_utils')

local M = {}

local config = {
  keymaps = {
    slide_down = 'gj',
    slide_up = 'gk',
  }
}

M.slide_down = function()
  print("Slide Down")
end

M.slide_up = function()
  print("Slide Up")
end

local function move_to_line()
end

M.setup = function(user_config)
  config = vim.tbl_deep_extend('force', config, user_config or {})
  _G.MiniFunctionsSlideBlock = M
  for funcname, mapping in pairs(config.keymaps) do
    ---@type string | function
    local rhs = M[funcname]
    local mode = 'v'
    if mapping then
      vim.keymap.set(
        mode,
        mapping,
        rhs,
        { silent = true, expr = true, noremap = true }
      )
    end
  end
end

M.disable = function()
  _G.MiniFunctionsSlideBlock = nil
  for _, mapping in pairs(config.keymaps) do
    if mapping then vim.keymap.del('v', mapping) end
  end
end

return M
