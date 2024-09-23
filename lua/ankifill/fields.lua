local M = {}
local utils = require("ankifill.utils")

M.editor_conf = function(fields)
  local editor_fields = {}
  for _, field in pairs(fields) do
    editor_fields[field] = {
      title = " ● " .. field .. ":",
      height = 0.9 / #fields,
      width = 1,
    }
  end

  local editor_fields_order = utils.table_copy(fields)
  return editor_fields, editor_fields_order
end

return M
