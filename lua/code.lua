local syntax = require("syntaxhighlight")
Code = {}

Code.Codeblock = function(text)
  local start_pattern = "%[%[%["
  local end_pattern = "%]%]%]"

  local ntext = ""
  local content = ""
  Language = "cpp"
  local inBlock = false

  for line in text:gmatch("[^\r\n]+") do
    if inBlock then
      if line:match(end_pattern) then
        inBlock = false
        content = Code.Texttohtml(content, Language)
        ntext = ntext .. content
      else
        content = content .. line .. "\n"
      end
    else
      if line:match(start_pattern) then
        language = line:match("%[%[%[%s+(%w+)")
        inBlock = true
        content = ""
      else
        ntext = ntext .. line .. "<br>"
      end
    end
  end

  if inBlock then
    ntext = ntext .. content .. "<br>"
  end

  return ntext
end

Code.Texttohtml = function(input_code, language)
  local result = syntax.highlight_to_html(language, input_code, { class_prefix = "" })
  if result then
    return result
  else
    return "nil"
  end
end

Code.format = function()
  local in_title = true
  local in_block = false
  local current_indent

  for i = 1, vim.fn.line("$") do
    local line = vim.fn.getline(i)
    current_indent = vim.fn.indent(i)

    if string.match(line, "# Front") or string.match(line, "# Back") then
      in_title = true
      goto continue
    end

    if in_title then
      if string.match(line, "%]%]%]") then
        in_block = false
        goto continue
      end

      if string.match(line, "%[%[%[") then
        in_block = true
        goto continue
      end

      if in_block then
        if current_indent ~= 4 then
          vim.fn.setline(i, string.rep(" ", 2) .. line)
        end
      else
        if current_indent ~= 2 then
          vim.fn.setline(i, string.rep(" ", 2) .. line)
        end
      end
    end
    ::continue::
  end
end

return Code
