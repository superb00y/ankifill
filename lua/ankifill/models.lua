local M = {}
local utils = require("ankifill.utils")

M.defaut_editor_conf = function(fields)
  local borderchars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
  local editor_fields = {
    Deck = {
      height = 0.1, -- 10%
      width = 1, -- 100%
      borderchars = borderchars,
    },
  }

  for _, field in pairs(fields) do
    editor_fields[field] = {
      height = 0.9 / #fields,
      width = 1,
      borderchars = borderchars,
    }
  end

  local editor_fields_order = utils.table_copy(fields)
  table.insert(editor_fields_order, 1, "Deck")
  return editor_fields, editor_fields_order
end

M.default_fmt_fn = function(fields)
  return function(note_info, level)
    local highlights = {}
    local indent = string.rep(" ", level * 2 + 2)
    local suspended_info = ""
    if note_info.queue == -1 then
      suspended_info = "● "
      highlights["Suspended"] = {
        string.len(indent) + 1,
        string.len(indent) + string.len(suspended_info) - 1,
      }
    end
    return string.format("%s%s%s\n", indent, suspended_info, note_info.fields[fields[1]].value or ""), highlights
  end
end

return M
