local z = {}

z.escape_html = function(content)
  if content then
    return content:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
  else
    return ''
  end
end

return z
