local title = ngx.unescape_uri(ngx.var.arg_title)

local f = io.open('wiki/' .. title)

if not f then
  return ngx.say('Page not found')
end

local wikitext = f:read('*a')

-- start timer
ngx.update_time()
local begin_time = ngx.now()

local output = require("output")

local content = output.fromWikiText(title, wikitext)
-- end timer
ngx.update_time()

ngx.say('<!DOCTYPE html><html><head><title>维基百科，自由的百科全书</title>' ..
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@latest/dist/katex.min.css">' ..
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/styles/default.min.css">' ..
    '<link rel="stylesheet" type="text/css" href="/wiki.css">' ..
    '</head><body>' ..
    '<h1>' .. title .. '</h1>' .. content ..
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
