local API = require("ankifill.api")
local Buffer = require("ankifill.buffer")

Select = {}
-- selects a deck or adds a new one --> callback Anki.SelectModel
Select.SelectDeck = function(deck_names, model_names, type)
  vim.ui.select(deck_names, {
    prompt = "Choose a deck:",
  }, function(choice)
    if choice == "Add Deck" then
      vim.ui.input({
        prompt = "Enter deck name:",
      }, function(name)
        if name then
          API.CreateDeck(name)
          Select.SelectModel(model_names, name, type)
        end
      end)
    else
      if choice then
        Select.SelectModel(model_names, choice, type)
      end
    end
  end)
end

-- selects a model --> callback Buffer.OpenWindow (opens the model window)
Select.SelectModel = function(model_names, selected_deck, type)
  if not type then
    vim.ui.select(model_names, {
      prompt = "Choose a model:",
    }, function(choice)
      if choice then
        Buffer.OpenWindow(selected_deck, choice)
      end
    end)
  else
    Buffer.OpenWindow(selected_deck, type)
  end
end

return Select
