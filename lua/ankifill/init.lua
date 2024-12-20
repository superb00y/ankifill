local has_telescope = pcall(require, "telescope")

if not has_telescope then
	error("This plugins requires nvim-telescope/telescope.nvim")
end

local editor = require("ankifill.editor")
local select = require("ankifill.select")
local config = require("ankifill.config")
local M = {}

function M.setup(user_config)
	config.setup(user_config)
end

function M.run()
	select.Card(editor.add_note)
end

return M
