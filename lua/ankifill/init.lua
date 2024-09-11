local API = require("ankifill.api")
local Select = require("ankifill.select")
local config = require("ankifill.config")
local api = vim.api
local M = {}

function M.setup(opts)
  config.set(opts)
  api.nvim_create_user_command("Anki", M.run, {})
end

function M.run(type)
  local deck_names = API.GetDeckNames()
  local model_names = API.GetModelNames()
  deck_names[#deck_names + 1] = "Add Deck"
  Select.SelectDeck(deck_names, model_names, type)
end

return M
