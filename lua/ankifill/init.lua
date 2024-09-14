local API = require("ankifill.api")
local editor = require("ankifill.editor")
local config = require("ankifill.config")
local M = {}

function M.setup(user_config)
  user_config = user_config or {}
  config.set(user_config)
end

function M.run()
  local deck_names = API.GetDeckNames()
  deck_names[#deck_names + 1] = "Add Deck"
  local model_names = API.GetModelNames()
  vim.ui.select(deck_names, {
    prompt = "Choose a deck:",
  }, function(deck)
    if deck == "Add Deck" then
      vim.ui.input({
        prompt = "Enter deck name:",
      }, function(name)
        if name then
          API.CreateDeck(name)
          vim.ui.select(model_names, {
            prompt = "Choose a model:",
          }, function(model)
            if model then
              editor.add_note(model, name)
            end
          end)
        end
      end)
    else
      if deck then
        vim.ui.select(model_names, {
          prompt = "Choose a model:",
        }, function(model)
          if model then
            editor.add_note(model, deck)
          end
        end)
      end
    end
  end)
end

return M
