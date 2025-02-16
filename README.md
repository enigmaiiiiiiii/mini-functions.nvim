# mini-functions.nvim

## Installation

lazynvim

```lua
require('lazy').setup({
  'enigmaiiiiiiii/mini-functions.nvim',
})
```

## Usage

```lua
require('mini-functions.configs').setup({
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
      mark_member_manually = '<leader>mm',
    },
  }
})
```
