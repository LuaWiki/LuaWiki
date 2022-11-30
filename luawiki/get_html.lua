local cjson = require('cjson')

if ngx.var.request_method ~= 'GET' then
  ngx.status = ngx.HTTP_NOT_ALLOWED
  ngx.say(cjson.encode({
    error = 'Only GET method is allowed!'
  }))
  return
end

local pagename = ngx.var[1]

local fetch_wikitext = require('fetch_wikitext')

local flag, content = fetch_wikitext(pagename)

if not flag then
  ngx.say(cjson.encode({
    code = 1,
    error = content
  }))
  return
end

-- main parsing
local nonparse = require('core/nonparse')
local parser = require('core/parser')
local wikitext = content
local wiki_state = {
  title = pagename,
  npb_index = 0,
  nw_index = 0,
  npb_cache = {},
  nw_cache = {},
  links = {}
}

-- start timer
ngx.update_time()
local begin_time = ngx.now()

wikitext = nonparse.decorate(wiki_state, wikitext)

local preprocessor = require('core/preprocessor').new(wiki_state)
wikitext = preprocessor:process(wikitext)
local wiki_html = parser.parse(wiki_state, wikitext)

-- end timer
ngx.update_time()

local html_utils = require('utils/html_utils')
local parser_output = '<h1>' .. pagename .. '</h1>' .. html_utils.expand_single(wiki_html)

local postprocessor = require('core/postprocessor')
parser_output = postprocessor.process(parser_output)
  
ngx.say(cjson.encode({
  code = 0,
  result = parser_output,
  parse_time = ngx.now() - begin_time
}))
