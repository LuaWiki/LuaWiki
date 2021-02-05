package.path = "../modules/?.lua;" .. package.path;
local inspect = require('inspect')
local tpl_parse = require('tpl_parse')

local wikitext = [=[
@alias{
  a = a1 | a2 | a3
  b = b1 | b2
  c = c1 | c2 | c3 | c4
}
@lang:lang_name{en}：<span lang="en">$1</span>
]=]

tpl_parse.parse_template(wikitext)