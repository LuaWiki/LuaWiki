local cjson = require('cjson')

if ngx.var.request_method ~= 'POST' then
  ngx.status = ngx.HTTP_NOT_ALLOWED
  ngx.say(cjson.encode({
    error = 'Only POST method is allowed!'
  }))
  return
end

local pagename = ngx.var[1]
local post_args = require('utils/post_args')()
local session = require('session')

if pagename == '' then
  ngx.status = ngx.HTTP_BAD_REQUEST
  ngx.say(cjson.encode({
    error = 'title is empty!'
  }))
  return
end

local token = ngx.var.cookie_session
if not token then
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.say(cjson.encode({
    error = 'not logged in!'
  }))
  return
end
local user_id = session.get_session(token)
if not user_id then
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.say(cjson.encode({
    error = 'not logged in!'
  }))
  return
end

-- main parsing
local nonparse = require('core/nonparse')
local parser = require('core/parser')
local wikitext = post_args.content and post_args.content:gsub('\r', ''):gsub('[^\n]$', '%0\n') or ''
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
