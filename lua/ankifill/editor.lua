local M = {}
local api = vim.api
local select = require("ankifill.select")
local API = require("ankifill.api")
local editor_class = require("ankifill.editor_classes")
local utils = require("ankifill.utils")
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
      goto continue
    else
      api.nvim_err_writeln("Id '" .. id .. "' doesn't match any editor")
      return
    end
  end
  ::continue::
  M.remKeyMaps()
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

  utils.notify("card sent to anki!")
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
  utils.notify("editor reset!")
end

function M.setKeyMaps()
  api.nvim_set_keymap("n", "<S-k>", '<Cmd>lua require("ankifill.editor").prev_field()<CR>', {})
  api.nvim_set_keymap("n", "<S-j>", '<Cmd>lua require("ankifill.editor").next_field()<CR>', {})
  api.nvim_set_keymap("n", "<S-s>", '<Cmd>lua require("ankifill.editor").write()<CR>', {})
  api.nvim_set_keymap("n", "<S-i>", '<Cmd>lua require("ankifill.editor").pasteimage()<CR>', {})
  api.nvim_set_keymap("n", "<S-g>", '<Cmd>lua require("ankifill.editor").sendtogui()<CR>', {})
  api.nvim_set_keymap("n", "<S-o>", '<Cmd>lua require("ankifill.editor").guiDeckOverview()<CR>', {})
  utils.notify("key maps set!")
end

function M.remKeyMaps()
  api.nvim_del_keymap("n", "<S-k>")
  api.nvim_del_keymap("n", "<S-j>")
  api.nvim_del_keymap("n", "<S-s>")
  api.nvim_del_keymap("n", "<S-i>")
  api.nvim_del_keymap("n", "<S-g>")
  api.nvim_del_keymap("n", "<S-o>")
  utils.notify("key maps removed!")
end

function M.pasteimage()
  select.SelectImage()
  utils.notify("image sent to anki!")
end

function M.guiDeckOverview()
  local e = current_editor()
  local deck
  if e then
    deck = e:get_model().deck
    API.guiDeckOveriew(deck)
    utils.notify("gui deck overview")
  end
end

function M.add_note(model, deck)
  local e = editor_class.Editor:new(model, deck)
  table.insert(M.editors, e)
  M.setKeyMaps()
  utils.notify("opened")
end

return M
