local inspect = require('inspect')
local tpl_args = require('tpl_args')

local wikitext = [=[
{{lang-en|Someday or One Day}}
]=]

print(
  inspect(tpl_args.parse_args(wikitext))
)

print(
  inspect(tpl_args.sub_tpl)
)