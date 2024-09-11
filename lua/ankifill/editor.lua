local M = {}
local api = vim.api
local anki_connect = require("anki.connect")
local editor_class = require("anki.editor_class")
local deck_info = require("anki.deck_info")
local models = require("anki.models")
local utils = require("anki.utils")
M.editors = {}

local function current_editor()
  for _, e in ipairs(M.editors) do
    if e:is_focused() then
      return e
    end
  end
end

function M.delete_editor(id)
  for idx, e in ipairs(M.editors) do
    if e:get_id() == id then
      e:delete()
      table.remove(M.editors, idx)
      return
    end
  end
  api.nvim_err_writeln("Id '" .. id .. "' doesn't match any editor")
end

function M.write()
  local e = current_editor()
  if not e then
    return
  end

  local model = e:get_model()
  local fields = e:get_fields_contents()
  local fields_order = model.editor_fields_order
  local deck = fields.Deck
  fields.Deck = nil
  if deck == "" then
    api.nvim_err_writeln("Missing deck name !")
    return
  end
  if not deck_info.deck_exists(deck) then
    api.nvim_err_writeln("Unknown deck '" .. deck .. "' !")
    return
  end
  if fields[fields_order[2]] == nil or fields[fields_order[2]] == "" then
    api.nvim_err_writeln("1st field is empty !")
    return
  end
  e:delete()
  local note = { deckName = deck, modelName = model.name, fields = fields }

  local card_id = anki_connect.addNote(note)
  if not card_id then
    api.nvim_err_writeln("Error adding note !")
    return
  end

  -- local cards = anki_connect.findCards(query)
  local card_info = anki_connect.cardsInfo({ card_id })

  for _, browser_buf in ipairs(M.browser_bufs) do
    browser_buf:add_card(card_info[1])
    -- if (browser_buf:add_card(card_id)) then
    --  table.insert(affected_bufs, browser_buf)
    -- end
  end

  -- local affected_bufs = {}
  -- table.insert(actions_table, {
  --  fun = function()
  --    anki_connect.addNote(note)
  --  end,
  --  name = "Add note",
  --  affected_bufs = affected_bufs
  -- })
end
function M.next_field()
  local e = current_editor()
  if e then
    e:next_field()
  end
end
function M.prev_field()
  local e = current_editor()
  if e then
    e:prev_field()
  end
end

function M.add_note(model, deck)
  if not model then
    model = utils.get_input("", "Enter model name: ", "customlist,Anki_model_completion")
  end
  if not model or model == "" then
    return
  end
  if not models.model_exists(model) then
    api.nvim_err_writeln("Unknown model '" .. model .. "' !")
    return
  end

  local e = editor_class.Editor:new(model, deck)
  table.insert(M.editors, e)
end
