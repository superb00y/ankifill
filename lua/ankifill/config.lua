local M = {}

local default_config = {
	default_deck = nil,
	default_model = nil,
	image_preview = false,
	image_dir = "/home/youq-chan/Pictures/Screenshots",
	image_formatting = function(choice)
		return string.format('<div style="text-align: center;"><img src="%s"></div>', choice)
	end,
	text_formatting = {},
	code_formatters = function(code)
		return string.format("<pre>%s</pre>", code)
	end,
	default_field_contents = {
		--
	},
	highlights = {
		AnkiHeaderTitle = { fg = "#0aafdd", bold = true },
		AnkiHeaderBorder = { fg = "#a1ffdd" },
		AnkiFieldTitle = { fg = "#afdfdd", bold = true },
		AnkiFieldBorder = { fg = "#a1aadd" },
		AnkiFieldTitleLocked = { fg = "#d03311", bold = true },
		AnkiFieldBorderLocked = { fg = "#d03311" },
	},
	keymaps = {
		prev_field = "<leader>nk",
		next_field = "<leader>nj",
		save_card = "<leader>ns",
		reset_editor = "<leader>nr",
		reset_fields = "<leader>nf",
		lock_field = "<leader>nl",
		unlock_field = "<leader>nu",
		paste_image = "<leader>ni",
		send_to_gui = "<leader>ng",
		deck_overview = "<leader>no",
	},
}

local config = {}

function M.setup(user_config)
	config = vim.tbl_deep_extend("force", default_config, user_config or {})

	for name, opts in pairs(config.highlights) do
		vim.api.nvim_set_hl(0, name, opts)
	end
end

function M.get(key)
	if key then
		return config[key]
	end
	return config
end

return M
