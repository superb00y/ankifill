# Ankifill.nvim

Ankifill is a Neovim plugin that allows you to create and manage Anki cards directly from your editor.

## Features

- Create new Anki cards with custom decks and models
- Edit card content using Markdown
- Format code blocks within cards
- Save cards directly to Anki using AnkiConnect

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'your-username/ankifill.nvim',
  requires = 'nvim-lua/plenary.nvim',
  config = {
    anki_connect_url = "http://localhost:8765",
    default_deck = "My Default Deck",
    default_model = "Basic (and reversed card)",
    code_formatters = {
      lua = function(code)
        -- Add Lua formatting logic here
        return code
      end,
      python = function(code)
        -- Add Python formatting logic here
        return code
      end,
    }
  }
}
```
