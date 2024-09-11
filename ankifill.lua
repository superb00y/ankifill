local API = require("lua.api")
local api = vim.api
local Select = require("lua.select")
local M = {}

M.config = {
  photo_path = "/home/youq-chan/Pictures/Screenshots/",
  default_deck = "Default",
  default_model = "Basic",
}

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  api.nvim_create_user_command("anki", M.run(), {})
end

function M.run(type)
  local deck_names = API.GetDeckNames()
  local model_names = API.GetModelNames()
  deck_names[#deck_names + 1] = "Add Deck"
  Select.SelectDeck(deck_names, model_names, type)
end

return M
