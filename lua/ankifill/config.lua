local M = {}

M.defaults = {
  anki_connect_url = "http://localhost:8765",
  default_deck = "Default",
  default_model = "Basic",
  code_formatters = {},
}

M.options = {}

function M.set(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

function M.get(key)
  if key then
    return M.options[key]
  end
  return M.options
end

return M
