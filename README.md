# Snipbase.nvim

A Neovim plugin for managing and searching code snippets with Telescope integration.

## Features

- Save code snippets with descriptions
- Search through snippets using Telescope
- Preview snippets before inserting
- Persistent storage of snippets

## Requirements

- Neovim >= 0.5.0
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
    'rspoonz/snipbase.nvim',
    requires = {'nvim-telescope/telescope.nvim'}
}
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'rspoonz/snipbase.nvim',
    dependencies = {'nvim-telescope/telescope.nvim'},
}
```

## Configuration

```lua
require('snipbase').setup({
    -- Optional configuration will go here in future versions
})
```

## Usage

### Default Keymaps

- `<Leader>ss` in visual mode: Save selected text as a snippet
- `<Leader>sp` in normal mode: Search through saved snippets

### Save a Snippet

1. Select the code you want to save in visual mode
2. Press `<Leader>ss`
3. Enter a description for the snippet

### Search and Insert Snippets

1. Press `<Leader>sp` in normal mode
2. Search through your snippets using Telescope
3. Preview the snippet content in the preview window
4. Press Enter to insert the selected snippet

## License

MIT
