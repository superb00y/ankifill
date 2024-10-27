if vim.g.loaded_ankifill == 1 then
	return
end
vim.g.loaded_ankifill = 1

vim.api.nvim_create_user_command("Anki", function()
	require("ankifill").run()
end, {})

vim.api.nvim_create_user_command("AnkiDefault", function()
	local config = require("ankifill.config")
	local default_deck = config.get("default_deck")
	local default_model = config.get("default_model")
	if not default_deck or not default_model then
		vim.notify("Default deck and model must be configured", vim.log.levels.ERROR)
		return
	end
	require("ankifill.editor").add_note(default_model, default_deck)
end, {})
