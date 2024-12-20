local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local API = require("ankifill.api")
local get_config = require("ankifill.config").get

Select = {}
Select.Card = function(func)
	local opts = {}
	pickers
		.new(opts, {
			prompt_title = "Deck",
			finder = finders.new_table({
				results = (function()
					return API.GetDeckNames()
				end)(),
			}),
			sorter = sorters.get_generic_fuzzy_sorter(),
			attach_mappings = function(prompt_bufnr)
				local on_select = function()
					local deck = action_state.get_selected_entry().value
					actions.close(prompt_bufnr)
					pickers
						.new(opts, {
							prompt_title = "Model",
							finder = finders.new_table({
								results = (function()
									return API.GetModelNames()
								end)(),
							}),
							sorter = sorters.get_generic_fuzzy_sorter(),
							attach_mappings = function(_prompt_bufnr)
								actions.select_default:replace(function()
									local model = action_state.get_selected_entry().value
									actions.close(_prompt_bufnr)
									func(model, deck)
								end)
								return true
							end,
						})
						:find()
				end
				actions.select_default:replace(on_select)
				return true
			end,
		})
		:find()
end

Select.SelectImage = function(e)
	local opts = {}
	local image_formatting = get_config("image_formatting")
	local filetypes = { "png", "jpg", "gif" }
	opts.cwd = get_config("image_dir")
	local fd = {
		"fd",
		"--type",
		"f",
		"--regex",
		[[.*.(]] .. table.concat(filetypes, "|") .. [[)$]],
	}

	local attach_mappings = function(prompt_bufnr, _)
		actions.select_default:replace(function()
			local selection = action_state.get_selected_entry()
			actions.close(prompt_bufnr)
			e:add_image(selection.name, selection.path)
			vim.api.nvim_put({
				image_formatting(selection.name),
			}, "l", true, true)
		end)
		return true
	end

	local entry_maker = function(entry)
		local path = opts.cwd .. "/" .. entry
		return {
			value = entry,
			display = entry,
			name = entry,
			path = path,
			ordinal = entry,
		}
	end

	local function get_image_sorter(opts)
		return sorters.new({
			scoring_function = function(_, prompt, line)
				local path = opts.cwd .. "/" .. line
				local modification_time = vim.loop.fs_stat(path).mtime.sec
				return -modification_time
			end,
		})
	end

	local picker = pickers.new(opts, {
		prompt_title = "image files",
		finder = finders.new_oneshot_job(fd, {
			entry_maker = entry_maker,
			cwd = opts.cwd,
		}),
		sorter = get_image_sorter(opts),
		attach_mappings = attach_mappings,
	})

	picker:find()
end

return Select
