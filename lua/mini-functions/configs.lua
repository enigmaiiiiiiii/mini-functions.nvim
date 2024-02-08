local api = vim.api

local parsers = require('nvim-treesitter.parsers')
local utils = require('mini-functions.utils')

local M = {}

local config = {
  modules = {},
  sync_install = false,
  ensure_installed = {},
  auto_install = false,
  ignore_install = {},
  parser_install_dir = nil,
}
local is_initialized = false

---@class TSModule
---@field module_path string
---@field enable boolean|string[]|function(string): boolean
---@field disable boolean|string[]|function(string): boolean
---@field keymaps table<string, string>
---@field is_supported function(string): boolean
---@field attach function(string)
---@field detach function(string)
---@field enabled_buffers table<integer, boolean>
---@field additional_vim_regex_highlighting boolean|string[]

local builtin_modules = {
  funk = {
    module_path = "mini-functions.funk",
    enable = true,
    keymaps = {
      replace_with_clipboard = 'cp',
      insert_markdown_TOC = '<leader>mt',
    },
  },
  jump_row = {
    module_path = "mini-functions.jump_row",
    enable = true,
    keymaps = {
      go_outer = '[[',
      -- go_inner = ']]',
      go_next_sibling = '[j',
      go_previous_sibling = '[k',
    },
  },
}

---@type TSModule[]
local queued_modules_defs = {}

---@param accumulator fun(name: string, module: TSModule, path: string, root: {[string]: TSModule}) called for each module
  -- @param name string
  -- @param path string
---@param root {[string]: TSModule} | nil
local function recurse_modules(accumulator, root, path)
  root = root or config.modules

  for name, module in pairs(root) do
    local new_path = path and (path .. '.' .. name) or name
    if M.is_module(module) then
      accumulator(name, module, new_path, root)
    elseif type(module) == 'table' then
      recurse_modules(accumulator, module, new_path)
    end
  end
end

-- enable module for buffer
---@param mod string
local function enable_module(mod)
  local module = M.get_module(mod)
  if not module then return end

  M.attach_module(mod)
end

-- Resolves a module by requiring the `module_path` or using definitions
---@mod_name string
---@return TSModule|nil
local function resolve_module(mod_name)
  local config_mod = M.get_module(mod_name)
  if not config_mod then return end

  if type(config_mod.attach) == 'function' and type(config_mod.detach) == 'function' then
    return config_mod
  elseif type(config_mod.module_path) == 'string' then
    return require(config_mod.module_path)
  end
end

function M.attach_module(mod_name)
  local resolved_mod = resolve_module(mod_name)

  if resolved_mod then resolved_mod.attach() end
end

local function enable_all(mod)
  local config_mod = M.get_module(mod)
  if not config_mod then return end

  config_mod.enable = true
  config_mod.enabled_buffers = nil

  enable_module(mod)
end

-- Gets a module config by path
---@param mod_path string path to the module
---@return TSModule|nil: the module or nil
function M.get_module(mod_path)
  local mod = utils.get_at_path(config.modules, mod_path)
  return M.is_module(mod) and mod or nil
end

-- Setup user data to override module ocnfigurations
-- @param user_data
function M.setup(user_data)
  config.modules = vim.tbl_deep_extend('force', config.modules, user_data)
  config.ignore_install = user_data.ignore_install or {}
  config.parser_install_dir = user_data.parser_install_dir or nil
  if config.parser_install_dir then config.parser_install_dir = vim.fn.expand(config.parser_install_dir, ':p') end
  recurse_modules(function(_, _, new_path)
    local data = utils.get_at_path(config.modules, new_path)
    if data.enable then enable_all(new_path) end
  end, config.modules)
end

---@param mod table|nil
---@return boolean
function M.is_module(mod)

  return type(mod) == 'table'
    and ((type(mod.attach) == 'function' and type(mod.detach) == 'function') or type(mod.module_path) == 'string')
end

-- Defines a table of modules
---@param mod_defs TSModule[]
function M.define_modules(mod_defs)
  if not is_initialized then table.insert(queued_modules_defs, mod_defs) end

  recurse_modules(function(key, mod, _, group)
    group[key] = vim.tbl_extend('keep', mod, {
      enable = false,
      disable = {},
      is_supported = function() return true end,
    })
  end, mod_defs)

  config.modules = vim.tbl_deep_extend('keep', config.modules, mod_defs)
end

M.init = function()
  is_initialized = true
  M.define_modules(builtin_modules)

  for _, mod_def in ipairs(queued_modules_defs) do
    M.define_modules(mod_def)
  end

  recurse_modules(function(_, _, new_path)
    local data = utils.get_at_path(config.modules, new_path)
    if data.enable then enable_all(new_path) end
  end, config.modules)
end

return M
