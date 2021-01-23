local wp_lang = require('wp_languages')

local z = {}

z.lang_name = function(args)
  return wp_lang[args[1]][1]
end

return z
