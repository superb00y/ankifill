local M = {}

M.defaults = {
  default_deck = "Default",
  default_model = "Basic",
  image_dir = "/home/youq-chan/Pictures/Screenshots",
  image_formating = {},
  text_formating = {},
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
