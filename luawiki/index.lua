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

-- start timer
ngx.update_time()
local begin_time = ngx.now()

wikitext = nonparse.decorate(wiki_state, wikitext)

local preprocessor = require('preprocessor').new(wiki_state)
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

ngx.say('<!DOCTYPE html><html><head><title>维基百科，自由的百科全书</title>' ..
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@latest/dist/katex.min.css">' ..
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/styles/default.min.css">' ..
    '<link rel="stylesheet" type="text/css" href="/wiki.css">' ..
    '</head><body>' ..
    '<h1>' .. title .. '</h1>' .. wiki_html:gsub('<((%a+)[^>]-)/>', function(p1, p2)
      if not html_stag_map[p2] then
        if p2 == 'references' then
          return '<div><' .. p1 .. '></' .. p2 .. '></div>'
        else
          return '<' .. p1 .. '></' .. p2 .. '>'
        end
      end
    end) ..
    '<!-- Total parse time: ' .. (ngx.now() - begin_time) .. '-->' ..
    '<script src="/simplequery.js"></script>' ..
    '<script defer src="https://cdn.jsdelivr.net/npm/katex@latest/dist/katex.min.js"></script>' ..
    '<script defer src="https://cdn.jsdelivr.net/npm/katex@latest/dist/contrib/mhchem.min.js"></script>' ..
    '<script defer src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/highlight.min.js"></script>' ..
    '<script src="/zh_convert.js"></script>' ..
    '<script src="/wiki.js"></script>' ..
    [[<script>
    $(document).ready(function(){
      document.body.innerHTML = doMwConvert(document.body.innerHTML);
      buildRef();
      buildMath();
      buildHighlight();
    });
    </script>]] ..
    '</body></html>')