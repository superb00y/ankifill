local Utils = {}

Utils.table_copy = function(t)
  local r = {}
  for _, v in pairs(t) do
    table.insert(r, v)
  end
  return r
end

return Utils
