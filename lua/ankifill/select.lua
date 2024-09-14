local API = require("ankifill.api")
-- -- local Buffer = require("ankifill.buffer")
local scan = require("plenary.scandir") -- For directory scanning
local Path = require("plenary.path") -- Require plenary for file handling
local image_dir = "/home/youq-chan/Pictures/Screenshots" -- Replace this with the directory containing your images

Select = {}

Select.SelectImage = function()
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
      vim.api.nvim_put({ image_reference }, "l", true, true)
    end
  end)
end

return Select
