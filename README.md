# my-addons.nvim

## Installation

vim.pack

```lua
vim.pack.add({
  { src = "https://github.com/odezzshuuk/my-addons.nvim" },
})
```

lazynvim

```lua
require('lazy').setup({
  'odezzshuuk/my-addons.nvim',
})
```

## Usage

```lua
require('my-addons').setup({
  auto_save = {
    trigger_events = { 'BufLeave', 'FocusLost', 'InsertLeave', 'TextChanged' },
    delay = 2000,
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
  },
  -- slide_block = {
  --   keymaps = {
  --     slide_down = 'gj',
  --     slide_up = 'gk',
  --   },
  -- },
})
```
