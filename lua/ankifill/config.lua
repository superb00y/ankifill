local M = {
  options = {},
  config = {},
}

M.options = {
  default_deck = "Default",
  default_model = "Basic",
  image_dir = "/home/youq-chan/Pictures/Screenshots",
  image_formatting = function(choice)
    return string.format('<div style="text-align: center;"><img src="%s"></div>', choice)
  end,
  text_formatting = {},
  code_formatters = {},
}

function M.set(opts)
  M.config = vim.tbl_deep_extend("force", {}, M.options, opts or {})
end

function M.get(key)
  if key then
    return M.config[key]
  end
  return M.config
end

return M
