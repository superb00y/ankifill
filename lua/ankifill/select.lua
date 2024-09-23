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

Select.SelectImage = function(opts)
  opts = opts or {}
  -- local image_formatting = get_config("image_formatting")
  local search_dir = get_config("image_dir")
  local filetypes = { "png", "jpg", "gif" }

  local fd = {
    "fd",
    "--type",
    "f",
    "--regex",
    [[.*.(]] .. table.concat(filetypes, "|") .. [[)$]],
    ".",
    search_dir,
  }

  local ub_pid = 0
  local ub_socket = ""
  local ueberzug_tmp_dir = ""
  ueberzug_tmp_dir = os.getenv("TMPDIR") or "/tmp"
  local uuid = vim.fn.getpid()
  local ub_pid_file = ueberzug_tmp_dir .. "/." .. uuid
  os.execute(string.format("ueberzugpp layer --no-stdin --silent --use-escape-codes --pid-file %s", ub_pid_file))
  local pid_file = io.open(ub_pid_file, "r")
  if pid_file then
    ub_pid = pid_file:read("*n")
    pid_file:close()
    os.remove(ub_pid_file)
  else
    print("Error: Failed to read PID file")
    return
  end
  ub_socket = string.format("%s/ueberzugpp-%s.socket", ueberzug_tmp_dir, ub_pid)

  pickers
    .new(opts, {
      prompt_title = "image files",
      finder = finders.new_oneshot_job(fd, opts),
      previewer = previewers.new_termopen_previewer({
        get_command = function(entry, status)
          local win_info = vim.fn.getwininfo(status.preview_win)[1]
          local width = win_info.width - 1
          local height = win_info.height - 1
          local x = win_info.wincol
          local y = win_info.winrow

          local cmd = string.format(
            "ueberzugpp cmd -s %s -a add -i PREVIEW -x %d -y %d --max-width %d --max-height %d -f %s",
            ub_socket,
            x,
            y,
            width,
            height,
            entry.value
          )
          os.execute(cmd)

          local exit = string.format("ueberzugpp cmd -s %s -a remove -i PREVIEW", ub_socket)
          os.execute(exit)
          -- return cmd
        end,
      }),
      attach_mappings = function(_, map)
        actions.select_default:replace(function(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          os.execute(string.format("ueberzugpp cmd -s %s -a exit", ub_socket))
          print("Selected image: " .. selection.value)
        end)
        return true
      end,
    })
    :find()
end

return Select
