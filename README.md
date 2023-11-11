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
vim.keymap.set('n', 'cp', require('mini-functions').replace_with_clipboard ,{ noremap = true, silent = true })
vim.keymap.set('n', '<leader>mt', require('mini-functions').insert_markdown_TOC, { noremap = true, silent = true }
```
