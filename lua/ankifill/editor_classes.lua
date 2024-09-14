local M = {}
local api = vim.api
local cmd = vim.cmd
local API = require("ankifill.api")
local models = require("ankifill.fields")
local id = 0
local Editor = {}

Editor.__index = Editor
Editor.bufopts = {
  swapfile = false,
  buftype = "nofile",
  modifiable = true,
  filetype = "html",
  syntax = "html",
  bufhidden = "hide",
}

function Editor:get_id()
  return self.id
end

local function create_buf()
  local buf = api.nvim_create_buf(true, true)
  for k, v in pairs(Editor.bufopts) do
    api.nvim_set_option_value(k, v, { buf = buf })
  end
  api.nvim_buf_attach(buf, false, {})
  return buf
end

local function mk_win(properties, row)
  local ui = api.nvim_list_uis()[1]
  local buf = create_buf()
  properties.height = math.floor(ui.height * properties.height - 2 - 1)
  if properties.height <= 0 then
    properties.height = 1
  end
  properties.width = math.floor(ui.width * properties.width - 2)
  if properties.width <= 0 then
    properties.width = 1
  end
  properties.row = row
  properties.col = 1
  local win = api.nvim_open_win(buf, true, properties)
  cmd("autocmd WinClosed <buffer=" .. buf .. '> lua require"ankifill.editor".delete_editor(' .. id .. ")")
  return buf, win
end

function Editor:new(model_name, deck)
  local model = {}
  model.name = model_name
  model.model_fields = API.GetModelFieldNames(model_name)
  model.editor_fields, model.editor_fields_order = models.editor_conf(model.model_fields)
  local row = 1
  cmd("set winhighlight=Normal:MyNormal")
  local fields = {}
  for _, field in ipairs(model.editor_fields_order) do
    local properties = model.editor_fields[field]
    local buf, win = mk_win(properties, row)
    row = row + properties.height + 2
    fields[field] = {
      buf = buf,
      win = win,
    }
  end

  local current_field = model.editor_fields_order[1]

  if deck and fields.Deck then
    api.nvim_buf_set_lines(fields.Deck.buf, 0, -1, true, { deck, model.name })
    -- api.nvim_set_option_value("modifiable", false, { buf = fields.Deck.buf })
    if model.editor_fields_order[1] == "Deck" then
      current_field = model.editor_fields_order[2]
    end
  end

  api.nvim_set_current_win(fields[current_field].win)

  local this = { id = id, fields = fields, model = model }
  id = id + 1
  setmetatable(this, self)
  return this
end

function Editor:delete()
  for _, field in pairs(self.fields) do
    cmd("au! * <buffer=" .. field.buf .. ">")
    api.nvim_win_close(field.win, true)
  end
end

function Editor:is_focused()
  local cur_win = api.nvim_get_current_win()
  for _, field in pairs(self.fields) do
    if field.win == cur_win then
      return true
    end
  end
  return false
end

function Editor:next_field()
  local cur_win = api.nvim_get_current_win()
  for idx, field in ipairs(self.model.editor_fields_order) do
    if self.fields[field].win == cur_win then
      local next_field = self.model.editor_fields_order[idx + 1]
      if next_field then
        api.nvim_set_current_win(self.fields[next_field].win)
      end
      return
    end
  end
  return false
end
function Editor:prev_field()
  local cur_win = api.nvim_get_current_win()
  for idx, field in ipairs(self.model.editor_fields_order) do
    if self.fields[field].win == cur_win then
      local next_field = self.model.editor_fields_order[idx - 1]
      if next_field then
        api.nvim_set_current_win(self.fields[next_field].win)
      end
      return
    end
  end
  return false
end

function Editor:get_model()
  return self.model
end

-- TODO: Editor modify card model
-- api.nvim_err_writeln((vim.inspect(card_info)))
-- local model_name = card_info.modelName
-- local styling = anki_connect.modelStyling(model_name)
-- local template = anki_connect.modelTemplates(model_name)
-- local fields = anki_connect.modelFieldsOnTemplates(model_name)
-- api.nvim_err_writeln((vim.inspect(styling)))
-- api.nvim_err_writeln((vim.inspect(template)))
-- api.nvim_err_writeln((vim.inspect(fields)))
-- local fields_names = anki_connect.modelFieldNames(model_name)
-- local s = [[
--  <!doctype html>

--  <html lang="fr">
--  <head>
--    <meta charset="utf-8">
--    <title>Anki Preview</title>
--  <style>
-- ]]
-- s = s .. card_info.css .. "\n</style>\n</head>"
-- local note
---- Take the 1st note of the template (if the template generates multiple notes)
-- for _, c in pairs(template) do
--  note = c
--  break
-- end
-- local front = note.Front
---- api.nvim_err_writeln("Front : " .. front)
-- for yo in front:gmatch("{{(.-)}}") do
--  -- api.nvim_err_writeln("Match pour front : " .. tostring(yo))
-- end
-- local back = note.Back
-- for yo in back:gmatch("{{(.-)}}") do
--  -- api.nvim_err_writeln("Match pour back : " .. tostring(yo))
-- end

function Editor:get_fields_contents()
  local fields = {}
  for _, field in ipairs(self.model.editor_fields_order) do
    local lines = api.nvim_buf_get_lines(self.fields[field].buf, 0, -1, true)
    fields[field] = table.concat(lines)
  end
  return fields
end

M.Editor = Editor
return M
