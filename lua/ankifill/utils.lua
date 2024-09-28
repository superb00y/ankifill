-- local get_config = require("ankifill.config").get
local Utils = {}

Utils.notify = function(msg)
  vim.notify(msg, vim.log.levels.INFO, {
    title = "ankifill",
  })
end

Utils.table_copy = function(t)
  local r = {}
  for _, v in pairs(t) do
    table.insert(r, v)
  end
  return r
end

-- Utils.set_mappings = function(buf)
--   local mappings = get_config("mappings")
--   local all_chars = {
--     "a",
--     "b",
--     "c",
--     "d",
--     "e",
--     "f",
--     "g",
--     "h",
--     "i",
--     "j",
--     "k",
--     "l",
--     "m",
--     "n",
--     "o",
--     "p",
--     "q",
--     "r",
--     "s",
--     "t",
--     "u",
--     "v",
--     "w",
--     "x",
--     "y",
--     "z",
--     " ",
--     "<bs>",
--   }
--   for _, mapping in pairs(all_chars) do
--     vim.api.nvim_buf_set_keymap(buf, "n", mapping, ":<CR>", {
--       nowait = true,
--       noremap = true,
--       silent = true,
--     })
--   end
--
--   for k, mapping in pairs(mappings) do
--     vim.keymap.set("n", k, ':lua require("ankifill.editor").' .. mapping .. "<CR>", {
--       nowait = true,
--       noremap = true,
--       silent = true,
--     })
--   end
-- end

return Utils
