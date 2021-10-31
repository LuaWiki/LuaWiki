local z = {}

local function harvard_names(list)
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
  return str
end

z.harvard_loc = function(args)
  local args = args[1]
  if args.p then
    return 'p. ' .. args.p
  elseif args.pp then
    return 'pp. ' .. args.pp
  elseif args.loc then
    return args.loc
  end
end

z.harvard_txt = function(args)
  local list = args[1]
  local loc = args[2]
  if list.n < 2 then return '' end
  return harvard_names(list) .. ' (' .. list[list.n] .. (loc and (':' .. loc) or '')
    .. ')'
end

z.harvard = function(args)
  local list = args[1]
  if list.n < 2 then return '' end
  return harvard_names(list) .. ' ' .. list[list.n]
end

return z
