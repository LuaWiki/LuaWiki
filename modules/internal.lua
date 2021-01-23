local z = {}
local util = require('library_util')

z.expr = function(args, in_text)
  return args[1]
end

z['and'] = z.expr
z['or'] = z.expr

z.join_last = function(args)
  local list = args[1]
  util.check_type(1, list, 'table')
  if list.n == 0 then return '' end
  if list.n == 1 then return list[1] end
  util.check_type(2, args[2], 'string')
  util.check_type(3, args[3], 'string')
  local res = {}
  for i = 1, list.n - 1 do
    res[i] = list[i] or ''
  end
  return table.concat(res, args[2]) .. args[3] .. list[list.n]
end

return z
