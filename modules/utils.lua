local z = {}
local util = require('library_util')

z.array_iter = function(t)
  local i = 0
  return function ()
    i = i + 1
    if i <= t.n then return i, t[i] end
  end
end

z.escape_bracket = function(args)
  util.check_type(1, args[1], 'string')
  return args[1]:gsub('%[', '&lbrack;'):gsub('%]', '&rbrack;')
end

return z
