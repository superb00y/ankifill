local API = require("ankifill.api")
-- -- local Buffer = require("ankifill.buffer")
local scan = require("plenary.scandir") -- For directory scanning
local Path = require("plenary.path") -- Require plenary for file handling
local image_dir = "/home/youq-chan/Pictures/Screenshots" -- Replace this with the directory containing your images

Select = {}
Select.Card = function(func)
  local deck_names = API.GetDeckNames()
  deck_names[#deck_names + 1] = "Add Deck"
  local model_names = API.GetModelNames()
  vim.ui.select(deck_names, {
    prompt = "Choose a deck:",
  }, function(deck)
    if deck == "Add Deck" then
      vim.ui.input({
        prompt = "Enter deck name:",
      }, function(name)
        if name then
          API.CreateDeck(name)
          vim.ui.select(model_names, {
            prompt = "Choose a model:",
          }, function(model)
            if model then
              func(model, name)
            end
          end)
        end
      end)
    else
      if deck then
        vim.ui.select(model_names, {
          prompt = "Choose a model:",
        }, function(model)
          if model then
            func(model, deck)
          end
        end)
      end
    end
  end)
end

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
