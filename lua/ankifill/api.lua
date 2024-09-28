local curl = require("plenary.curl")
local api = vim.api
local URL = "localhost:8765"

local API = {}

API.Post = function(body)
  body = vim.fn.json_encode(body)

  local response = curl.post(URL, { body = body, headers = { content_type = "application/json" } })
  if response.status ~= 200 then
    api.nvim_err_writeln("Error fetching decks: " .. response.body)
    return {}
  end

  local result = vim.fn.json_decode(response.body)
  return result.result or {}
end

API.GetDeckNames = function()
  return API.Post({ action = "deckNames", version = 6 })
end

API.CreateDeck = function(deck_name)
  return API.Post({ action = "createDeck", version = 6, params = { deck = deck_name } })
end

API.GetModelNames = function()
  return API.Post({ action = "modelNames", version = 6 })
end

API.GetModelFieldNames = function(model_name)
  return API.Post({ action = "modelFieldNames", version = 6, params = { modelName = model_name } })
end

API.AddCard = function(deck_name, model_name, fields)
  local body = {
    action = "addNote",
    version = 6,
    params = {
      note = {
        deckName = deck_name,
        modelName = model_name,
        fields = fields,
        options = {
          allowDuplicate = false,
          duplicateScope = "deck",
          duplicateScopeOptions = {
            deckName = deck_name,
            checkChildren = false,
            checkAllModels = false,
          },
        },
      },
    },
  }
  return API.Post(body)
end

API.guiAddCard = function(deck_name, model_name, fields)
  local body = {
    action = "guiAddCards",
    version = 6,
    params = {
      note = {
        deckName = deck_name,
        modelName = model_name,
        fields = fields,
      },
    },
  }
  return API.Post(body)
end

API.guiDeckOveriew = function(deck)
  local body = {
    action = "guiDeckOverview",
    version = 6,
    params = {
      name = deck,
    },
  }
  return API.Post(body)
end

API.SendImagetoAnki = function(filename, path)
  local body = {
    action = "storeMediaFile",
    version = 6,
    params = {
      filename = filename,
      path = path,
    },
  }
  return API.Post(body)
end

return API
