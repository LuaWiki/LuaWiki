local re = require('lpeg.re')
local lpeg = require('lpeg')

local z = {}

local sub_count = 0
z.sub_tpl = {}

local defs = {
  cr = lpeg.P('\r'),
  t  = lpeg.P('\t'),
  eb = lpeg.P(']'),
  ts = lpeg.P('{{'),
  te = lpeg.P('}}'),
  merge_text = function(a, b) return a .. b end,
  store_tpl = function(s)
    sub_count = sub_count + 1
    z.sub_tpl[sub_count] = s
    return '&' .. sub_count .. ';'
  end
}

-- General Parsing
local tpl_grammar = re.compile([=[--lpeg
  template      <- {| %ts __ tpl_name ('|' __ param_expr %s*)* %te |}
  tpl_name      <- { ([_/!-] / [^%p])+ }
  param_expr    <- {| {:tag: param_name :} __ '=' __ any_text / any_text |}
  param_name    <- {~ param_word (__ -> '_' param_word)* ~} 
  param_word    <- ([_-] / [^%s%p])+
  any_text      <- (another_tpl / inlink_like / { char_no_pipe [^|{[%te]* })+
                      ~> merge_text / ''
  char_no_pipe  <- [^|%te]
  inlink_like   <- {'[['} (another_tpl / { [^[%eb] [^[{%eb]* })+ {']]'}
  another_tpl   <- {~ (%ts ([^%te] [^{}]* / another_tpl)* %te) -> store_tpl ~}
  __            <- [ %t]*
]=], defs)

local function reorganize(t)
  local counter = 0
  local new_t = {}
  new_t._name = t[1]:gsub('%s+$', '')
  for i = 2, #t do
    local item = t[i]
    item[1] = item[1] and item[1]:gsub('%s+$', '')
    if item[1] == '' then item[1] = nil end
    if item.tag then
      new_t[item.tag] = item[1]
    else
      counter = counter + 1
      new_t[tostring(counter)] = item[1]
    end
  end
  return new_t
end

z.parse_args = function(tpl)
  sub_count = 0
  z.sub_tpl = {}
  local arg_table = tpl_grammar:match(tpl)
  if arg_table then
    return reorganize(arg_table), z.sub_tpl
  else error(tpl) end
end

return z
