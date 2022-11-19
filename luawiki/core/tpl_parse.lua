local z = {}
local re = require('lpeg.re')
local env = _G

z.dump = function(t, level)
  if type(t) == 'table' then
    local res_list = {}
    local count = 0
    for k, v in pairs(t) do
      if k ~= 'tag' then
        count = count + 1
        local prefix = tonumber(k) and '' or k .. ' = '
        res_list[count] = prefix .. z.dump(v, level + 1)
      end
    end
    local base_indent = string.rep('\t', level)
    local sep = ',\n' .. base_indent .. '\t'
    return '{' .. (t.tag and (t.tag .. ':') or '') .. '\n' .. base_indent .. '\t' ..
        table.concat(res_list, sep) .. '\n' .. base_indent .. '}'
  else
    return tostring(t):gsub('%s+', ' ')
  end
end

z.ext_modules = require('internal')

local alias_list = re.compile[=[--lpeg
  alias_outer <- '@alias' __ '{' __ alias_body '}' {}
  alias_body  <- {| alias_line* |}
  alias_line  <- {| {param_name} __ '=' __ {alias_name} __ ('|' __ {alias_name} __)* |}
  param_name  <- [_%w]+
  alias_name  <- ([_-] / [^%s%p])+
  __          <- %s*
]=]

local tpl_grammar = nil

local data_defs = {
  t = lpeg.P('\t'),
  new_table = function() return {} end,
  add_params = function(t, name, value)
    if value then
      if type(value) == 'table' then
        t[name] = value
      else
        value = value:gsub('%s+$', '')
        t[name] = tpl_grammar:match(value)
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
]=], data_defs)

local tpl_defs = {
  parse_data = function(s)
    return data_grammar:match(s)
  end,
  cache_module = function(m)
    if not z.ext_modules[m] then
      local f = assert(loadfile(ngx.config.prefix() .. 'modules/'.. m .. '.lua', 't', env))
      z.ext_modules[m] = f()
    end
  end,
  cleanup_text = function(text)
    local res = text:gsub('^%s+', ''):gsub('%s+$', ' ')
                    :gsub('\n[ \t]*(%S)', ' %1')
    return res
  end
}

tpl_grammar = re.compile([=[--lpeg
  tpl_grm     <- {| __ tpl_text |}
  tpl_text    <- {:tag: '' -> 'text':} ((func_call __ / wikitext)+ / {''})
  func_call   <- {| {:tag: '@' -> 'call':} module_name (':' func_name)? __ ('()' / arguments) |}
  module_name <- {:module: name -> cache_module :}
  func_name   <- {:func: name :}
  name        <- %a [_%w]*
  arguments   <- {:args: {| text_param / '(' __ param __ (',' __ param __ )* ')' |} :}
  param       <- text_param / func_call / data / expr
  text_param  <- {| '{' __ tpl_text '}' |}
  data        <- {| {:tag: '<%' -> 'data':} (!'%>' .)* -> parse_data '%>' |}
  expr        <- {| {:tag: '' -> 'expr':} {([^,()]+ / balanced)+} |}
  balanced    <- '(' ([^()] / balanced)* ')'
  wikitext    <- ([^@|}]+ / '|}' / '|')+ -> cleanup_text
  __          <- %s*
]=], tpl_defs)

z.parse_template = function(tpl, mod_env)
  env = mod_env or _G
  local alias, end_pos = alias_list:match(tpl)
  local alias_dict = {}
  if alias then
    for i, v in ipairs(alias) do
      local var_name = v[1]
      for i = 2, #v do
        alias_dict[v[i]] = v[1]
      end
    end
  else
    end_pos = 1
  end
  end_pos = end_pos or 1
  local real_tpl = tpl:sub(end_pos)
  return {
    alias = alias_dict,
    ast = tpl_grammar:match(real_tpl)
  }
end

return z
