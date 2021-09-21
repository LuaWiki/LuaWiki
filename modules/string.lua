local z = {}

z.split = function(s, sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  s:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

return z
