local z = {}

z.escape_html = function(content)
  if content then
    return content:gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('&', '&amp;')
  else
    return ''
  end
end

return z
