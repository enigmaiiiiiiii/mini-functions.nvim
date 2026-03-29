local M = {}

---@class UserConfig
---@field quick_funks table
---@field block_action table
---@field mark_member table
---@field auto_save table
---@field diff_current_split table
---@field slide_block table

---@param user_config UserConfig
function M.setup(user_config)
  require('mini-functions.quick_funks').setup(user_config.quick_funks)
  require('mini-functions.block_action').setup(user_config.block_action)
  require('mini-functions.mark_member').setup(user_config.mark_member)
  require('mini-functions.auto_save').setup(user_config.auto_save)
  require('mini-functions.slide_block').setup(user_config.slide_block)
end

M.utils = require('mini-functions.utils')

return M
