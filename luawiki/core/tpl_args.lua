-- Defines a grammar for template syntax and a function to reorganize the parsed
-- arguments into a table. It also stores sub-templates in another table and
-- replaces them with placeholders.
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
  tpl_name      <- { ([_/!+-] / [^%p])+ }
  param_expr    <- {| {:tag: param_name :} __ '=' __ any_text / any_text |}
  param_name    <- {~ param_word (__ -> '_' param_word)* ~} 
  param_word    <- ([_-] / [^%s%p])+
  any_text      <- (sub_tpl / inlink_like / { char_no_pipe [^|{[%te]* })+
                      ~> merge_text / ''
  char_no_pipe  <- [^|%te]
  inlink_like   <- {'[['} (sub_tpl / { [^[%eb] [^[{%eb]* })+ {']]'}
  sub_tpl       <- {~ {another_tpl} -> store_tpl ~}
  another_tpl   <- (%ts ([^%te%ts] [^{}]* / another_tpl)* %te)
  __            <- [ %t]*
]=], defs)

-- The function takes a table of parsed arguments and returns a new table with
-- the template name and the parameters indexed by name or number. It also removes
-- any trailing whitespace from the template name and the parameter names.
-- It assigns a counter to unnamed parameters and increments it for each one.
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
