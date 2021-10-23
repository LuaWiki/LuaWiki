local re = require('lpeg.re')
local inspect = require('inspect')

local defs = {
  t = lpeg.P('\t'),
  new_table = function() return {} end,
  add_params = function(t, name, value)
    if value then
      if type(value) == 'table' then
        t[name] = value
      else
        t[name] = value:gsub('%s+$', '')
      end
    end
    return t
  end
}

local data_grammar = re.compile([=[--lpeg
  data       <- ('' -> new_table __ param_expr*) ~> add_params
  param_expr <- {: {param_name} __ '=' [ %t]* (object / raw_value) __ :}
  param_name <- ([_-] / [^%s%p])+
  object     <- ( '{' -> new_table __ param_expr* '}' ) ~> add_params
  raw_value  <- {[^%nl]*}
  __         <- %s*
]=], defs)

return {
  parse_data = function(data_str)
    return data_grammar:match(data_str)
  end
}
