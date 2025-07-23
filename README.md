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
require('mini-functions').setup({
  auto_save = {
    trigger_events = { 'BufLeave', 'FocusLost', 'InsertLeave', 'TextChanged' },
    delay = 2000,
  },
  block_action = {
    keymaps = {
      go_outer_start = '[[',
      go_outer_end = ']]',
      go_next_sibling = '[j',
      go_previous_sibling = '[k',
    },
  },
  mark_member = {
    auto_mark = true,
    member_group_marks = {
      static_field = '1',
      static_method = '2',
      public_field = '3',
      protected_field = '4',
      private_field = '5',
      property = '6',
      constructor = '7',
      public_method = '8',
      protected_method = '9',
      private_method = '0',
      nested_class = 'a',
    },
    keymaps = {
      -- go_to_next_member_group = '`n',
      -- go_to_previous_member_group = '`p',
      -- mark_member_manually = '<leader>mm',
    },
  },
  quick_funks = {
    keymaps = {
      replace_with_clipboard = 'cp',
      switch_focus_on_vertical = '<c-\\>',
    },
  },
  slide_block = {
    keymaps = {
      slide_down = 'gj',
      slide_up = 'gk',
    },
  },
})
```
