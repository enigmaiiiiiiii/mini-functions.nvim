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

local default_config = {
  auto_save = {
    trigger_events = { 'BufLeave', 'FocusLost', 'InsertLeave', 'TextChanged' },
    delay = 2000,
  },
  block_action = {
    keymaps = {
      go_outer = '[[', -- Go to outer node
      go_next_sibling = '[j', -- Go to next sibling
      go_previous_sibling = '[k', -- Go to previous sibling
    },
  },
  mark_member = {
    auto_mark = true,
    member_group_marks = {
      static_field     = '1',
      static_method    = '2',
      public_field     = '3',
      protected_field  = '4',
      private_field    = '5',
      property         = '6',
      constructor      = '7',
      public_method    = '8',
      protected_method = '9',
      private_method   = '0',
      nested_class     = 'a',
    },
    keymaps = {
      -- go_to_next_member_group = '`n',
      -- go_to_previous_member_group = '`p',
      mark_member_manually = '<leader>mm',
    },
  }
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
