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

return z
