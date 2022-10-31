local mwtext = {}

local cjson = require('cjson.safe')
local prettycjson = require('prettycjson')

mwtext.jsonArray = function()
  return setmetatable({}, cjson.array_mt)
end

mwtext.jsonEncode = function(value, flags)
  if not flags or flags < 4 then
    return cjson.encode(value)
  else
    return prettycjson(value, nil, '    ')
  end
end

mwtext.JSON_PRESERVE_KEYS = 1 -- unsupported
mwtext.JSON_TRY_FIXING = 2 -- unsupported
mwtext.JSON_PRETTY = 4

return mwtext
