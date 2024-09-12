if vim.g.loaded_ankifill == 1 then
  return
end
vim.g.loaded_ankifill = 1

vim.api.nvim_create_user_command("Anki", require("ankifill").run, {})
