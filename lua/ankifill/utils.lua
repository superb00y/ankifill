local Code = require("code")
local Utils = {}

Utils.GetFieldsFromBuff = function(fields)
  local extracted_fields = {}

  for _, field in pairs(fields) do
    extracted_fields[field] = Utils.ExtractField(Buffer.buffers[field], field)
  end

  return extracted_fields
end

Utils.ExtractField = function(buf, field)
  local save = false
  local text = ""
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  for _, line in ipairs(lines) do
    if save and string.match(line, "^# ") then
      save = false
    elseif string.match(line, "^# " .. field) then
      save = true
    elseif save then
      text = text .. line .. "\n"
    end
  end

  if string.match(text, "%[%[%[") and string.match(text, "%]%]%]") then
    text = Code.Codeblock(text)
  else
    text = text:gsub("\n", "<br>")
  end

  return text
end

return Utils
