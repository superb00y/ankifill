local M = {}

M.default = {
  default_deck = "Default",
  default_model = "Basic",
  image_dir = "/home/youq-chan/Pictures/Screenshots",
  image_formatting = function(choice)
    return string.format('<div style="text-align: center;"><img src="%s"></div>', choice)
  end,
  text_formatting = {},
  code_formatters = {},
}

M.options = {}

function M.set(opts)
  M.options = vim.tbl_deep_extend("force", M.default, opts)
  print("Debug: Resulting config:", vim.inspect(M.options))
end

function M.get(key)
  if key then
    return M.options[key]
  end
  return M.options
end

return M
