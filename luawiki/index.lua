local title = ngx.unescape_uri(ngx.var.arg_title)

local f = io.open('wiki/' .. title)

if not f then
  return ngx.say('Page not found')
end

local nonparse = require('nonparse')
local parser = require('parser')
local wikitext = f:read('*a')
local wiki_state = {
  title = title,
  npb_index = 0,
  nw_index = 0,
  npb_cache = {},
  nw_cache = {}
}
wikitext = nonparse.decorate(wiki_state, wikitext)

local preprocessor = require('preprocessor').new(wiki_state)
wikitext = preprocessor:process(wikitext)
local wiki_html = parser.parse(wiki_state, wikitext)
ngx.say('<!DOCTYPE html><html><head><title>维基百科，自由的百科全书</title>' ..
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@latest/dist/katex.min.css">' ..
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/styles/default.min.css">' ..
    '<link rel="stylesheet" type="text/css" href="/wiki.css">' ..
    '</head><body>' ..
    '<h1>' .. title .. '</h1>' .. wiki_html:gsub('<((%a+)[^>]-)/>', '<%1></%2>') ..
    '<script src="/simplequery.js"></script>' ..
    '<script defer src="https://cdn.jsdelivr.net/npm/katex@latest/dist/katex.min.js"></script>' ..
    '<script defer src="https://cdn.jsdelivr.net/npm/katex@latest/dist/contrib/mhchem.min.js"></script>' ..
    '<script defer src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/highlight.min.js"></script>' ..
    '<script src="/wiki.js"></script>' ..
    '</body></html>')