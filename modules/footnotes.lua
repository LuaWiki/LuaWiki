local z = {}

z.havard = function(args)
  local list = args[1]
  local pp = args[2]
  if list.n < 2 then return '' end
  local str = ''
  if list.n == 2 then
    str = list[1]
  else
    local res = {}
    for i = 1, list.n - 2 do
      res[i] = list[i] or ''
    end
    str = table.concat(res, ', ') .. ' & ' .. list[list.n-1]
  end
  return str .. ' (' .. list[list.n] .. (pp and (':' .. pp) or '')
    .. ')'
end

return z
