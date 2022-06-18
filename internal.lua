local z = {}
local util = require('utils/library_util')

z.expr = function(args, in_text)
  return args[1]
end

z['and'] = z.expr
z['or'] = z.expr

z.switch = function(args, _, size)
  if size % 2 == 0 then
    error('even number of arguments in switch function')
  end
  local c = args[1]
  for i = 2, size, 2 do
    local cases = args[i]
    local ret = args[i + 1]
    if cases == 'default' then return ret end
    util.check_type(i, cases, 'table')
    for i = 1, cases.n do
      if c == cases[i] then
        return ret
      end
    end
  end 
end

z.map = function(args)
  local list = args[1]
  local func = args[2]
  util.check_type(1, list, 'table')
  util.check_type(2, func, 'function')
  local new_list = {}
  new_list.n = list.n or #list
  for i = 1, new_list.n do
    local v = list[i]
    new_list[i] = func(v, i)
  end
  return new_list
end

z.array = function(args, _, size)
  local new_args = {}
  for i = 1, size do
    new_args[i] = args[i]
  end
  new_args.n = size
  return new_args
end

z.cases = z.arg_table

z.join = function(args)
  local list = args[1]
  util.check_type(1, list, 'table')
  if list.n == 0 then return '' end
  if list.n == 1 then return list[1] end
  util.check_type(2, args[2], 'string')
  local res = {}
  for i = 1, list.n do
    if list[i] then
      table.insert(res, list[i])
    end
  end
  if next(res) then return table.concat(res, args[2])
  else return nil end
end

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
