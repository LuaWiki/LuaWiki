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

local defs = {
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
]=], defs)

z.parse_template = function(tpl)
  return tpl_grammar:match(tpl)
end

return z
