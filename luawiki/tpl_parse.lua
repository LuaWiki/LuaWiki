package.path = './modules/?.lua;' .. package.path

local z = {}
local re = require('lpeg.re')

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
    return tostring(t):gsub('%s+', '')
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

local tpl_defs = {
  cache_module = function(m)
    if not z.ext_modules[m] then
      z.ext_modules[m] = require(m)
    end
  end,
  cleanup_text = function(text)
    local res = text:gsub('^%s*', ''):gsub('\n%s*', '\n'):gsub('%s*$', '')
    return res
  end
}

local tpl_grammar = re.compile([=[--lpeg
  tpl_grm     <- {| __ tpl_text |}
  tpl_text    <- {:tag: '' -> 'text':} (func_call __ / wikitext)+
  func_call   <- {| {:tag: '' -> 'call':} '@' module_name (':' func_name)? __ ('()' / arguments) |}
  module_name <- {:module: name -> cache_module :}
  func_name   <- {:func: name :}
  name        <- %w [_%w%d]*
  arguments   <- {:args: {| text_param / '(' __ param __ (',' __ param __ )* ')' |} :}
  param       <- text_param / func_call / expr
  text_param  <- {| '{' __ tpl_text '}' |}
  expr        <- {| {:tag: '' -> 'expr':} {[^,)]+} |}
  wikitext    <- [^@}]+ -> cleanup_text
  __          <- %s*
]=], tpl_defs)

z.parse_template = function(tpl)
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
