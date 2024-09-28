local M = {}
local api = vim.api
local select = require("ankifill.select")
local API = require("ankifill.api")
local editor_class = require("ankifill.editor_classes")
local utils = require("ankifill.utils")

local get_config = require("ankifill.config").get
local image_formatting = get_config("image_formatting")
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
    utils.notify("editor reset!")
  end
  Select.Card(editor)
  M.setKeyMaps()
  utils.notify("reset!!!!")
end

function M.setKeyMaps()
  vim.keymap.set("n", "<leader>nk", function()
    M.prev_field()
  end)
  vim.keymap.set("n", "<leader>nj", function()
    M.next_field()
  end)
  vim.keymap.set("n", "<leader>ns", function()
    M.write()
  end)
  vim.keymap.set("n", "<leader>nr", function()
    M.reset()
  end)
  vim.keymap.set("n", "<leader>ni", function()
    M.pasteimage()
  end)
  vim.keymap.set("n", "<leader>ng", function()
    M.sendtogui()
  end)
  vim.keymap.set("n", "<leader>no", function()
    M.guiDeckOverview()
  end)
  utils.notify("key maps set!")
end

function M.remKeyMaps()
  vim.keymap.del("n", "<leader>nk")
  vim.keymap.del("n", "<leader>nj")
  vim.keymap.del("n", "<leader>ns")
  vim.keymap.del("n", "<leader>nr")
  vim.keymap.del("n", "<leader>ni")
  vim.keymap.del("n", "<leader>ng")
  vim.keymap.del("n", "<leader>no")
  utils.notify("key maps removed!")
end

function M.pasteimage()
  local e = current_editor()
  if e then
    local image = select.SelectImage()
    e:add_image(image.name, image.path)
    vim.api.nvim_put({
      image_formatting(image.name),
    }, "l", true, true)
  end
  -- utils.notify("image sent to anki!")
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

function M.setup_highlights()
  api.nvim_set_hl(0, "AnkiHeaderTitle", { fg = "#0aafdd", bold = true })
  api.nvim_set_hl(0, "AnkiHeaderBorder", { fg = "#a1ffdd" })
  api.nvim_set_hl(0, "AnkiFieldTitle", { fg = "#afdfdd", bold = true })
  api.nvim_set_hl(0, "AnkiFieldBorder", { fg = "#a1aadd" })
end

function M.add_note(model, deck)
  local e = editor_class.Editor:new(model, deck)
  table.insert(M.editors, e)
  M.setKeyMaps()
  M.setup_highlights()
  utils.notify("opened")
end

return M
