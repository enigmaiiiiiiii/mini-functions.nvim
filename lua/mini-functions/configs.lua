local M = {}

---@class MiniConfig
---@field keymaps table<string, string>

local parent_mod = 'mini-functions'

---@type string[]
local mod_list = {
  'quick_funks',
  'block_action',
  'auto_save',
  'slide_block',
  'mark_member'
}


-- Setup user data to override module configurations
---@param user_config table<string, any> | nil
function M.setup(user_config)
  for i = 1, #mod_list do
    local mod_name = mod_list[i]
    ---@type boolean, MiniModule
    local ok, mod = pcall(require, parent_mod .. '.' .. mod_name)
    if not ok then goto continue end
    if user_config and user_config[mod_name] then
      mod.config = vim.tbl_deep_extend('force', mod.config, user_config[mod_name])
    end
    mod.attach()
    ::continue::
  end
end

return M
