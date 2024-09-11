local api = vim.api
local API = require("ankifill.api")
local Utils = require("ankifill.utils")
local Path = require("plenary.path") -- Require plenary for file handling
local scan = require("plenary.scandir") -- For directory scanning
local image_dir = "/home/youq-chan/Pictures/Screenshots" -- Replace this with the directory containing your images
Buffer = {}
Buffer.bufopts = {
  modifiable = true,
  buftype = "nofile",
  swapfile = false,
  filetype = "markdown",
}
Buffer.buffers = {} -- Store the created buffers

-- Buffer.OpenWindow = function(deck, model)
--   local fields = API.GetModelFieldNames(model)
--   local buf = api.nvim_create_buf(false, true)
--   print("new buffer....")
--   api.nvim_set_current_buf(buf)
--   for k, v in pairs(Buffer.bufopts) do
--     api.nvim_buf_set_option(buf, k, v)
--   end
--   api.nvim_buf_set_option(buf, "syntax", "anki")
--   api.nvim_set_option("foldmethod", "syntax")
--   api.nvim_buf_set_keymap(buf, "n", "q", "<Cmd>noautocmd q!<CR>", {})
--   api.nvim_command("setlocal spell")
--   cmd("set conceallevel=2")
--   print("")
--   Buffer.PopulateFields(buf, fields)
--   Buffer.AddKeymap(buf, deck, model, fields)
-- end

Buffer.OpenWindow = function(deck, model)
  local fields = API.GetModelFieldNames(model)
  Buffer.buffers = {} -- Store the created buffers

  for i, field in pairs(fields) do
    local buf = vim.api.nvim_create_buf(false, true)
    if i == 1 then
      vim.cmd("new") -- Create a new vertical split window
    else
      vim.cmd("split") -- Create a new vertical split window
    end
    vim.api.nvim_set_current_buf(buf)

    Buffer.buffers[field] = buf
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "#" .. field })
  end

  -- Buffer.PopulateFields(fields)
  Buffer.AddKeymap(deck, model, fields)
end

Buffer.PopulateFields = function(fields)
  for _, value in pairs(fields) do
    api.nvim_buf_set_lines(Buffer.buffers[value], 0, -1, true, { "#" .. value })
  end
end

-- Add Keymap
Buffer.AddKeymap = function(deck, model, fields)
  local params = {
    deck = deck,
    fields = fields,
    model = model,
  }

  -- Triggered by <S-s>
  api.nvim_set_keymap(
    "n",
    "<S-s>",
    "<Cmd>lua require('anki').Buffer.Save('" .. vim.fn.json_encode(params) .. "')<CR>",
    {}
  )

  -- Triggered by <S-r>
  api.nvim_set_keymap(
    "n",
    "<S-r>",
    "<Cmd>lua require('anki').Buffer.Change_Model('" .. vim.fn.json_encode(params) .. "')<CR>",
    {}
  )

  -- Triggered by <S-g>
  api.nvim_set_keymap(
    "n",
    "<S-g>",
    "<Cmd>lua require('anki').Buffer.SendGui('" .. vim.fn.json_encode(params) .. "')<CR>",
    {}
  )

  -- Triggered by <S-g>
  api.nvim_set_keymap("n", "<S-p>", "<Cmd>lua require('anki').Buffer.SelectImage()<CR>", {})

  -- Triggered by <S-g>
  api.nvim_set_keymap(
    "n",
    "<S-o>",
    "<Cmd>lua require('anki').Buffer.guiDeckOverview('" .. vim.fn.json_encode(params) .. "')<CR>",
    {}
  )
end

-- Save Callback
Buffer.Save = function(data)
  local deck = data.deck
  local fields = Utils.GetFieldsFromBuff(data.fields)
  local model = data.model

  local res = API.AddCard(deck, model, fields)
  if res then
    fields = API.GetModelFieldNames(model)
    Buffer.PopulateFields(fields)
  end
end

-- change model
Buffer.Change_Model = function(data)
  local deck = data.deck
  local model_names = API.GetModelNames()

  vim.ui.select(model_names, {
    prompt = "Choose a model:",
  }, function(choice)
    if choice then
      local fields = API.GetModelFieldNames(choice)
      Buffer.PopulateFields(fields)
      Buffer.AddKeymap(deck, choice, fields)
    end
  end)
end

-- gui add card
Buffer.SendGui = function(data)
  local buf = data.buf
  local deck = data.deck
  local fields = Utils.GetFieldsFromBuff(buf, data.fields)
  local model = data.model

  API.guiAddCard(deck, model, fields)
end

-- gui add card
Buffer.guiDeckOverview = function(data)
  local deck = data.deck

  API.guiDeckOveriew(deck)
end

Buffer.PasteText = function(text)
  vim.api.nvim_put({ text }, "l", true, true)
end

Buffer.SelectImage = function()
  local images = scan.scan_dir(image_dir, { only_dirs = false, depth = 1 })
  local image_files = {}

  for _, file in ipairs(images) do
    if file:match("%.jpg$") or file:match("%.png$") or file:match("%.jpeg$") then
      table.insert(image_files, Path:new(file):make_relative(image_dir)) -- Use relative paths
    end
  end

  if #image_files == 0 then
    print("No images found in the directory: " .. image_dir)
    return
  end

  vim.ui.select(image_files, {
    prompt = "choose an image:",
  }, function(choice)
    if choice then
      local image_path = Path:new(image_dir, choice):absolute() -- Convert relative path to absolute
      local image_reference = string.format('<div style="text-align: center;"><img src="%s"></div>', choice)
      API.SendImagetoAnki(choice, image_path)
      Buffer.PasteText(image_reference)
      Buffer.PasteText(image_path)
      Buffer.PasteText(choice)
    end
  end)
end

return Buffer
