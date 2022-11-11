local z = {}

z.escape_html = function(content)
  if content then
    return content:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
  else
    return ''
  end
end

z.decode_html = function(content)
  if content then
    return content:gsub('&lt;', '<'):gsub('&gt;', '>'):gsub('&amp;', '&')
  else
    return ''
  end
end

local html_stag_map = {}
local html_single_tags = {
  'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'keygen', 
  'link', 'meta', 'param', 'source', 'track', 'wbr'
}
for _, v in ipairs(html_single_tags) do
  html_stag_map[v] = true
end

z.expand_single = function(content)
  return content:gsub('<((%a+)[^>]-)/>', function(p1, p2)
    if not html_stag_map[p2] then
      return '<' .. p1 .. '></' .. p2 .. '>'
    end
  end)
end

return z
