# Ankifill.nvim

Ankifill is a Neovim plugin that allows you to create and manage Anki cards directly from your editor.

## Features

- Create new Anki cards with custom decks and models
- Edit card content using Markdown
- Format code blocks within cards
- Save cards directly to Anki using AnkiConnect

## Installation

Add the following to your Neovim configuration:

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'your-username/ankifill.nvim',
  requires = 'nvim-lua/plenary.nvim',
  config = {
    anki_connect_url = "http://localhost:8765",
    default_deck = "My Default Deck",
    default_model = "Basic",
    code_formatters = {}
  }
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "yourusername/ankifill.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("ankifill").setup({
      anki_connect_url = "http://localhost:8765",
      default_deck = "My Default Deck",
      default_model = "Basic",
      code_formatters = {}
    })
  end,
}
```

## use "ziontee113/icon-picker.nvim"
