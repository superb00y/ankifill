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
  syntax = "html.css",
  bufhidden = "wipe",
}

local function create_buf()
  local buf = api.nvim_create_buf(false, true)
  for k, v in pairs(Editor.bufopts) do
    api.nvim_set_option_value(k, v, { buf = buf })
  end
  api.nvim_buf_attach(buf, false, {})
  return buf
end

local function mk_header(deck)
  local ui = api.nvim_list_uis()[1]
  local buf = api.nvim_create_buf(false, true)
  api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  api.nvim_buf_set_lines(buf, 0, -1, true, { "   Deck:" .. deck })
  api.nvim_set_option_value("modifiable", false, { buf = buf })
  api.nvim_buf_attach(buf, false, {})
  local properties = {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    height = 1,
    width = math.floor(ui.width - 2),
    row = 1,
    col = 1,
  }
  local win = api.nvim_open_win(buf, true, properties)
  api.nvim_set_option_value("winhl", "FloatTitle:AnkiHeaderTitle,FloatBorder:AnkiHeaderBorder", { win = win })
  cmd("autocmd WinClosed <buffer=" .. buf .. '> lua require"ankifill.editor".delete_editor(' .. id .. ")")
  return buf, win
end

local function mk_field(properties, row)
  local ui = api.nvim_list_uis()[1]
  local buf = create_buf()
  properties.relative = "editor"
  properties.border = "rounded"
  properties.height = math.floor(ui.height * properties.height - 2)
  properties.width = math.floor(ui.width * properties.width - 2)
  properties.row = row
  properties.col = 1
  local win = api.nvim_open_win(buf, true, properties)
  api.nvim_set_option_value("winhl", "FloatTitle:AnkiFieldTitle,FloatBorder:AnkiFieldBorder", { win = win })
  cmd("autocmd WinClosed <buffer=" .. buf .. '> lua require"ankifill.editor".delete_editor(' .. id .. ")")
  return buf, win
end

function Editor:new(model_name, deck)
  local model = {}
  model.deck = deck
  model.name = model_name
  model.model_fields = API.GetModelFieldNames(model_name)
  model.editor_fields, model.editor_fields_order = models.editor_conf(model.model_fields)
  local fields = {}
  local head_buf, head_win = mk_header(deck)
  fields["header"] = {
    buf = head_buf,
    win = head_win,
  }
  local row = 4
  for _, field in ipairs(model.editor_fields_order) do
    local properties = model.editor_fields[field]
    local buf, win = mk_field(properties, row)
    row = row + properties.height + 2
    fields[field] = {
      buf = buf,
      win = win,
      locked = false,
    }
  end
  local current_field = model.editor_fields_order[1]
  api.nvim_set_current_win(fields[current_field].win)
  vim.cmd("startinsert")

  local this = {
    id = id,
    fields = fields,
    model = model,
    images = {
      to_send = {},
      sent = false,
    },
  }

  id = id + 1
  setmetatable(this, self)
  return this
end

function Editor:get_id()
  return self.id
end

function Editor:get_model()
  return self.model
end

function Editor:reset_fields()
  for field_name, field in pairs(self.fields) do
    if field_name ~= "header" and field.locked ~= true then
      api.nvim_buf_set_lines(field.buf, 0, -1, false, { "" })
    end
  end
end

function Editor:lock_field(field_name)
  if self.fields[field_name] then
    self.fields[field_name].locked = true
    api.nvim_set_option_value(
      "winhl",
      "FloatTitle:AnkiFieldTitleLocked,FloatBorder:AnkiFieldBorderLocked",
      { win = self.fields[field_name].win }
    )
  else
    error("Invalid field name: " .. field_name)
  end
end

function Editor:unlock_field(field_name)
  if self.fields[field_name] then
    self.fields[field_name].locked = false
    api.nvim_set_option_value(
      "winhl",
      "FloatTitle:AnkiFieldTitle,FloatBorder:AnkiFieldBorder",
      { win = self.fields[field_name].win }
    )
  else
    error("Invalid field name: " .. field_name)
  end
end

function Editor:add_image(image_name, image_path)
  table.insert(self.images.to_send, { name = image_name, path = image_path })
  self.images.sent = false
end

function Editor:send_images()
  for _, image in ipairs(self.images.to_send) do
    API.SendImagetoAnki(image.name, image.path)
  end
  self.images.to_send = {}
  self.images.sent = true
end

function Editor:reset_images()
  self.images.to_send = {}
  self.images.sent = false
end

function Editor:get_fields_contents()
  local fields = {}
  for _, field in ipairs(self.model.editor_fields_order) do
    local lines = api.nvim_buf_get_lines(self.fields[field].buf, 0, -1, true)
    -- fields[field] = table.concat(lines, "<br>\n")
    fields[field] = table.concat(lines, "")
  end
  return fields
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

M.Editor = Editor
return M
