local z = {}

z.array_iter = function(t)
  local i = 0
  return function ()
    i = i + 1
    if i <= t.n then return i, t[i] end
  end
end

return z
