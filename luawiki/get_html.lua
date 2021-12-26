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
  nw_cache = {}
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

local html_stag_map = {}
local html_single_tags = {
  'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'keygen', 
  'link', 'meta', 'param', 'source', 'track', 'wbr'
}
for _, v in ipairs(html_single_tags) do
  html_stag_map[v] = true
end
  
ngx.say(cjson.encode({
  code = 0,
  result = '<h1>' .. pagename .. '</h1>' .. wiki_html:gsub('<((%a+)[^>]-)/>', function(p1, p2)
    if not html_stag_map[p2] then
      return '<' .. p1 .. '></' .. p2 .. '>'
    end
  end),
  parse_time = ngx.now() - begin_time
}))
