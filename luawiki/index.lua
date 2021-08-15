local title = ngx.unescape_uri(ngx.var.arg_title)

local f = io.open('wiki/' .. title)

if not f then
  return ngx.say('Page not found')
end

local nonparse = require('nonparse')
local preprocessor = require('preprocessor').new(title)
local parser = require('parser')
local wikitext = f:read('*a')
local wiki_state = {}
wikitext = nonparse.decorate(wikitext)
wikitext = preprocessor:process(wikitext)
local wiki_html = parser.parse(wikitext)
ngx.say('<!DOCTYPE html><html><head><title>维基百科，自由的百科全书</title>' ..
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@latest/dist/katex.min.css">' ..
    '<link rel="stylesheet" type="text/css" href="/wiki.css">' ..
    '</head><body>' ..
    '<h1>' .. title .. '</h1>' .. (wiki_html:gsub('<((%a+)[^>]-)/>', '<%1></%2>')
      or '') ..
    '<script src="/simplequery.js"></script>' ..
    '<script defer src="https://cdn.jsdelivr.net/npm/katex@latest/dist/katex.min.js"></script>' ..
    '<script src="/wiki.js"></script>' ..
    '</body></html>')