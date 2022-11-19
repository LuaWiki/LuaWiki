local wp_lang = require('wp_languages')
local lang_data = require('lang/data')

local z = {}

z.lang_name = function(args)
  return wp_lang[args[1]][1]
end

z.transl = function(args)
  local title_table = lang_data.translit_title_table
  local language_code = args[1]
  local transl_scheme = args[2]
  local data = title_table[transl_scheme]
  if data then
    return data[language_code] or data.default
  else
    local lang_name = wp_lang[language_code][1]
    if lang_name then
      return lang_name .. '转写'
    end
  end
end

return z
