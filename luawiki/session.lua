local mlcache = require('resty.mlcache')
local resty_random = require('resty.random')
local str = require('resty.string')

local session_cache = mlcache.new('lw_cache', 'cache_dict', {
  lru_size = 500,          -- size of the L1 (Lua VM) cache
  ttl      = 86400 * 30,   -- 30 days ttl for hits
  neg_ttl  = 30,           -- 30s ttl for misses
  ipc_shm  = 'ipc_dict'
})

local z = {}

z.new_session = function(user_id)
  local strong_random = resty_random.bytes(16, true)
  while strong_random == nil do
    strong_random = resty_random.bytes(16, true)
  end
  strong_random = str.to_hex(strong_random)
  session_cache:set(strong_random, nil, user_id)
  return strong_random
end

local function cache_fallback(stoken)
  local mysql = require('resty.mysql')
  local db = mysql:new()
  local wrap = ngx.quote_sql_str
  if not db:connect(dbconf) then return end
  
  local res = db:query('SELECT user_id FROM user WHERE user_token = ' .. wrap(stoken))
  
  local ok, err = db:set_keepalive(10000, 100)
  if not ok then
    print("failed to set keepalive: ", err)
  end
  
  if res and res[1] then
    return res[1].user_id
  end
end

z.get_session = function(stoken)
  return session_cache:get(stoken, nil, cache_fallback, stoken)
end

z.remove_session = function(stoken)
  return session_cache:delete(stoken)
end

return z
