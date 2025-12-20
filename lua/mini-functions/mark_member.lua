local parsers = require('nvim-treesitter.parsers')
local utils = require('mini-functions.utils')
local M = {}

---@class ParentCheckOpt
---@field lang string
---@field root TSNode
---@field node TSNode

---@class MemberGroups
---@field static_field? string
---@field public_field? string
---@field protected_field? string
---@field private_field? string
---@field property? string
---@field constructor? string
---@field public_method? string
---@field protected_method? string
---@field private_method? string
---@field nested_class? string

---@class MarkMemberConfig : MiniConfig
---@field member_group_marks MemberGroups
---@field auto_mark boolean

---@alias node_iterator fun():integer, TSNode, vim.treesitter.query.TSMetadata, TSQueryMatch

---@type MarkMemberConfig
local config = {
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

  auto_mark = true,

  keymaps = {
    -- go_to_next_member_group = '`n',
    -- go_to_previous_member_group = '`p',
    -- mark_member_manually = '<leader>mm',
  },
}

local query_statements = {
  ---@type MemberGroups
  c_sharp = {
    public_field = [[
      ((field_declaration) @field_declaration
        (#match? @field_declaration "\(.*\<static\>.*\)\@!.*\<public\>.*")
      )
    ]],
    protected_field = [[
      ((field_declaration) @field_declaration
        (#match? @field_declaration "\(.*\<static\>.*\)\@!.*\<protected\>.*")
      )
    ]],
    private_field = [[
      ((field_declaration) @field_declaration
        (#match? @field_declaration "\(.*\<static\>.*\)\@!.*\<private\>.*")
      )
    ]],
    static_field = [[
      ((field_declaration) @field_declaration
        (#match? @field_declaration ".*\<static\>.*")
      )
    ]],
    -- this pattern will cause memmax warning
    public_method = [[
      ((method_declaration) @method_declaration
        (#match? @method_declaration "\(.*\<static\>.*\)\@!.*\<public\>.*")
      )
    ]],
    protected_method = [[
      ((method_declaration) @method_declaration
        (#match? @method_declaration "\(.*\<static\>.*\)\@!.*\<protected\>.*")
      )
    ]],
    -- this pattern will cause memmax warning
    private_method = [[
      ((method_declaration) @method_declaration
        (#match? @method_declaration "\(.*\<static\>.*\)\@!.*\<private\>.*")
      )
    ]],
    static_method = [[
      ((method_declaration) @method_declaration
        (#match? @method_declaration ".*\<static\>.*")
      )
    ]],
    property = [[
      ((property_declaration) @property_declaration)
    ]],
    constructor = [[
      ((constructor_declaration) @constructor)
    ]],
    nested_class = [[
      (class_declaration (declaration_list (class_declaration) @class_declaration))
    ]],
  },
}

local class_node_types = {
  c_sharp = 'class_declaration',
}

local class_query_statements = {
  c_sharp = [[
    (class_declaration) @class_declaration
  ]],
}

---@type table<string, fun(opts: ParentCheckOpt):boolean>
local parent_check_handlers = {
  c_sharp = function(opts)
    local declaration_list_statement = [[(declaration_list) @declaration_list]]
    local ok, query = pcall(vim.treesitter.query.parse, opts.lang, declaration_list_statement)
    if not ok then return false end
    for _, declaration_list_node, _ in query:iter_captures(opts.root, 0) do
      if declaration_list_node:parent() == opts.root and opts.node:parent() == declaration_list_node then
        return true
      end
    end
    return false
  end,
}

---@return TSNode
local function get_current_class_node(lang)
  ---@type TSNode?
  local current_node = vim.treesitter.get_node()

  while current_node do
    if current_node:type() == class_node_types[lang] then return current_node end
    current_node = current_node:parent()
  end

  ---@type TSNode
  local root = parsers.get_parser():parse()[1]:root()
  local ok, query = pcall(vim.treesitter.query.parse, lang, class_query_statements[lang])
  if not ok then return root end

  for _, node, _ in query:iter_captures(root, 0) do
    return node
  end

  return parsers.get_parser():parse()[1]:root()
end

local function get_member_group_node_iter(query_statement, lang, class_node)
  local ok, query = pcall(vim.treesitter.query.parse, lang, query_statement)
  if not ok then return end

  return query:iter_captures(class_node, 0)
end

local function jump_to_first_node_of_member_group(query_statement, lang)
  local class_node = get_current_class_node(lang)
  local iter = get_member_group_node_iter(query_statement, lang, class_node)
  if not iter then return end
  for _, node, _ in iter do
    if parent_check_handlers[lang]({ lang = lang, root = class_node, node = node }) then
      utils.update_cursor(node)
      break
    end
  end
end

local function dynamic_query_and_bindkey()
  ---@type string
  local lang = parsers.get_buf_lang(0)
  if not query_statements[lang] then return end

  for declaration_type, query_statement in pairs(query_statements[lang]) do
    ---@type string
    local mapping = '`' .. config.member_group_marks[declaration_type]
    local rhs = function()
      jump_to_first_node_of_member_group(query_statement, lang)
    end
    vim.keymap.set('n', mapping, rhs, { silent = true, noremap = true })
  end
end

M.mark_member_manually = function()
  ---@type string
  local lang = parsers.get_buf_lang(0)
  if not query_statements[lang] then return end
  for declaration_type, query_statement in pairs(query_statements[lang]) do
    ---@type string
    local mark_name = config.member_group_marks[declaration_type]
    local node_iter = get_member_group_node_iter(query_statement, lang)
    for _, node, _ in node_iter do
      local row, col, _ = node:start()
      vim.api.nvim_buf_set_mark(0, mark_name, row + 1, col, {})
      break
    end
  end
end

local mark_member_group = vim.api.nvim_create_augroup('mark_member', { clear = true })

M.setup = function(user_config)
  config = vim.tbl_deep_extend('force', config, user_config or {})
  _G.MiniFunctionsAutoMark = M

  if config.auto_mark then
    vim.api.nvim_create_autocmd('BufEnter', {
      group = mark_member_group,
      pattern = { '*.cs', '*.ts' },
      callback = dynamic_query_and_bindkey,
    })
  end
end

M.disable = function()
  _G.MiniFunctionsAutoMark = nil
  vim.api.nvim_clear_autocmds({ group = mark_member_group })
end

return M
