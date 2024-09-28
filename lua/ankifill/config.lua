local M = {}

M.default = {
  default_deck = "Default",
  default_model = "Basic",
  image_preview = false,
  image_dir = "/home/youq-chan/Pictures/Screenshots",
  image_formatting = function(choice)
    return string.format('<div style="text-align: center;"><img src="%s"></div>', choice)
  end,
  text_formatting = {},
  code_formatters = function(code)
    return string.format("<pre>%s</pre>", code)
  end,
  -- mappings = {
  --   l = "next()",
  --   h = "prev()",
  --   n = "next()",
  --   b = "prev()",
  --   f = "flip()",
  --   q = "close()",
  --   a = "add()",
  --   e = "edit()",
  --   d = "delete()",
  --   g = "browse_cards()",
  --   o = "browse_subjects()",
  --   k = "know()",
  --   ["<CR>"] = "flip()",
  --   [" "] = "flip()",
  -- },
}

M.options = {}

function M.set(opts)
  M.options = vim.tbl_deep_extend("force", M.default, opts)
  -- print("Debug: Resulting config:", vim.inspect(M.options))
end

function M.get(key)
  if key then
    return M.options[key]
  end
  return M.options
end

return M
