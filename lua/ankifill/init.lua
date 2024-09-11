local API = require("ankifill.api")
local Select = require("ankifill.select")
local M = {}

M.defaults = {
  anki_connect_url = "http://localhost:8765",
  default_deck = "Default",
  image_dir = "/home/youq-chan/Pictures/Screenshots",
  default_model = "Basic",
  code_formatters = {},
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

function M.getconfig(key)
  if key then
    return M.options[key]
  end
  return M.options
end

function M.run(type)
  local deck_names = API.GetDeckNames()
  local model_names = API.GetModelNames()
  deck_names[#deck_names + 1] = "Add Deck"
  Select.SelectDeck(deck_names, model_names, type)
end

return M
