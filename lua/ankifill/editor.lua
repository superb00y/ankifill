local M = {}
local api = vim.api
local select = require("ankifill.select")
local API = require("ankifill.api")
local editor_class = require("ankifill.editor_classes")
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
  local deck = model.deck
  local fields = e:get_fields_contents()
  local fields_order = model.editor_fields_order

  if fields[fields_order[1]] == nil or fields[fields_order[1]] == "" then
    api.nvim_err_writeln("1st field is empty !")
    return
  end

  e:delete()
  API.AddCard(deck, model.name, fields)
end

function M.sendtogui()
  local e = current_editor()
  if not e then
    return
  end
  local model = e:get_model()
  local fields = e:get_fields_contents()
  local fields_order = model.editor_fields_order

  if fields[fields_order[1]] == nil or fields[fields_order[1]] == "" then
    api.nvim_err_writeln("1st field is empty !")
    return
  end

  API.guiAddCard(model.deck, model.name, fields)
end

function M.pasteimage()
  select.SelectImage()
end

function M.guiDeckOverview()
  local e = current_editor()
  local deck
  if e then
    deck = e:get_model().deck
    API.guiDeckOveriew(deck)
  end
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

function M.reset(model, deck)
  local c = current_editor()
  local id = c:get_id()
  M.delete_editor(id)
  local e = editor_class.Editor:new(model, deck)
  table.insert(M.editors, e)
end

function M.add_note(model, deck)
  local e = editor_class.Editor:new(model, deck)
  table.insert(M.editors, e)
end

return M
