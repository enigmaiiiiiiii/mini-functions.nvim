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
  require('my-addons.mod-collection.auto_save').setup(user_config.auto_save)
end

return M
