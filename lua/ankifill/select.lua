local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
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

-- local function ub_socketr()
--   local ub_pid = 0
--   local ub_socket = ""
--   local ueberzug_tmp_dir = os.getenv("TMPDIR") or "/tmp"
--   local ub_pid_file = ueberzug_tmp_dir .. "/." .. vim.fn.getpid()
--   os.execute(string.format("ueberzugpp layer --no-stdin --silent --use-escape-codes --pid-file %s", ub_pid_file))
--   local pid_file = io.open(ub_pid_file, "r")
--   if pid_file then
--     ub_pid = pid_file:read("*n")
--     pid_file:close()
--     os.remove(ub_pid_file)
--   end
--   ub_socket = string.format("%s/ueberzugpp-%s.socket", ueberzug_tmp_dir, ub_pid)
--
--   return ub_socket
-- end
--
Select.SelectImage = function(opts)
  opts = opts or {}
  local search_dir = get_config("image_dir")
  local filetypes = { "png", "jpg", "gif" }
  opts.cwd = search_dir
  local fd = {
    "fd",
    "--type",
    "f",
    "--regex",
    [[.*.(]] .. table.concat(filetypes, "|") .. [[)$]],
    search_dir,
  }

  -- local ub_socket = ub_socketr()
  --
  -- local imagepre = previewers.new_buffer_previewer({
  --   define_preview = function(_, entry, _)
  --     local preview = opts.get_preview_window()
  --     local cmd = string.format(
  --       "ueberzugpp cmd -s %s -a add -i PREVIEW -x %d -y %d --max-width %d --max-height %d -f %s",
  --       ub_socket,
  --       preview.col,
  --       preview.line,
  --       preview.width,
  --       preview.height,
  --       entry.value
  --     )
  --     os.execute(cmd)
  --   end,
  -- })

  local image = nil
  local attach_mappings = function(prompt_bufnr, _)
    actions.select_default:replace(function()
      local selection = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      -- os.execute(string.format("ueberzugpp cmd -s %s -a exit", ub_socket))
      image = { name = selection.value:match("([^/]+)$"), path = selection.value }
    end)
    return true
  end

  -- local popup_opts = {}
  -- opts.get_preview_window = function()
  --   return popup_opts.preview
  -- end
  --

  local picker = pickers.new(opts, {
    prompt_title = "image files",
    finder = finders.new_oneshot_job(fd, opts),
    -- previewer = imagepre,
    attach_mappings = attach_mappings,
  })

  -- local line_count = vim.o.lines - vim.o.cmdheight
  -- if vim.o.laststatus ~= 0 then
  --   line_count = line_count - 1
  -- end
  -- popup_opts = picker:get_window_options(vim.o.columns, line_count)
  picker:find()
  return image
end

return Select
