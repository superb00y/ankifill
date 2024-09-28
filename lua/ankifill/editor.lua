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
      M.remKeyMaps()
    else
      api.nvim_err_writeln("Id '" .. id .. "' doesn't match any editor")
      return
    end
  end
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

  e:send_images()
  M.reset_fields()
  API.AddCard(deck, model.name, fields)
  e:reset_images()
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

  e:send_images()
  API.guiAddCard(model.deck, model.name, fields)
  e:reset_images()

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

function M.reset()
  local c = current_editor()
  local id = c:get_id()
  M.delete_editor(id)
  local function editor(model, deck)
    local e = editor_class.Editor:new(model, deck)
    table.insert(M.editors, e)
  end
  Select.Card(editor)
  M.setKeyMaps()
  utils.notify("Editor reset!  ")
end

function M.pasteimage()
  local e = current_editor()
  if e then
    select.SelectImage(e)
  end
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

function M.reset_fields()
  local e = current_editor()
  if e then
    e:reset_fields()
    utils.notify("Fields reset (except locked field) 󱀸 ")
  end
end

function M.lock_current_field()
  local e = current_editor()
  if e then
    local current_win = api.nvim_get_current_win()
    for field_name, field in pairs(e.fields) do
      if field.win == current_win then
        e:lock_field(field_name)
        utils.notify("Field '" .. field_name .. "' locked  ")
        return
      end
    end
    utils.notify("No field selected")
  end
end

function M.unlock_field()
  local e = current_editor()
  if e then
    local current_win = api.nvim_get_current_win()
    for field_name, field in pairs(e.fields) do
      if field.win == current_win then
        e:unlock_field(field_name)
        utils.notify("Field '" .. field_name .. "' unlocked  ")
        return
      end
    end
    utils.notify("No field selected")
  end
end

local keymaps = {
  {
    mode = "n",
    lhs = "<leader>nk",
    rhs = function()
      M.prev_field()
    end,
    opts = { desc = "Go to previous field" },
  },
  {
    mode = "n",
    lhs = "<leader>nj",
    rhs = function()
      M.next_field()
    end,
    opts = { desc = "Go to next field" },
  },
  {
    mode = "n",
    lhs = "<leader>ns",
    rhs = function()
      M.write()
    end,
    opts = { desc = "Save card" },
  },
  {
    mode = "n",
    lhs = "<leader>nr",
    rhs = function()
      M.reset()
    end,
    opts = { desc = "Reset editor" },
  },
  {
    mode = "n",
    lhs = "<leader>nf",
    rhs = function()
      M.reset_fields()
    end,
    opts = { desc = "Reset editor fields" },
  },

  {
    mode = "n",
    lhs = "<leader>nl",
    rhs = function()
      M.lock_current_field()
    end,
    opts = { desc = "Lock the current field" },
  },

  {
    mode = "n",
    lhs = "<leader>nu",
    rhs = function()
      M.unlock_field()
    end,
    opts = { desc = "Unlock the current field" },
  },
  {
    mode = "n",
    lhs = "<leader>ni",
    rhs = function()
      M.pasteimage()
    end,
    opts = { desc = "Paste image" },
  },
  {
    mode = "n",
    lhs = "<leader>ng",
    rhs = function()
      M.sendtogui()
    end,
    opts = { desc = "Send to Anki GUI" },
  },
  {
    mode = "n",
    lhs = "<leader>no",
    rhs = function()
      M.guiDeckOverview()
    end,
    opts = { desc = "Open Anki deck overview" },
  },
}

function M.setKeyMaps()
  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts)
  end
  utils.notify("Key maps set!")
end

function M.remKeyMaps()
  for _, keymap in ipairs(keymaps) do
    vim.keymap.del(keymap.mode, keymap.lhs)
  end
  utils.notify("Key maps removed!")
end

function M.setup_highlights()
  local highlights = {
    AnkiHeaderTitle = { fg = "#0aafdd", bold = true },
    AnkiHeaderBorder = { fg = "#a1ffdd" },
    AnkiFieldTitle = { fg = "#afdfdd", bold = true },
    AnkiFieldBorder = { fg = "#a1aadd" },
    AnkiFieldTitleLocked = { fg = "#d03311", bold = true },
    AnkiFieldBorderLocked = { fg = "#d03311" },
  }

  for name, opts in pairs(highlights) do
    api.nvim_set_hl(0, name, opts)
  end
end

function M.add_note(model, deck)
  local e = editor_class.Editor:new(model, deck)
  table.insert(M.editors, e)
  M.setKeyMaps()
  M.setup_highlights()
  utils.notify("opened")
end

return M
