local mlcache = require('resty.mlcache')
local resty_random = require('resty.random')
local str = require('resty.string')

local session_cache = mlcache.new('lw_cache', 'cache_dict', {
  lru_size = 500,          -- size of the L1 (Lua VM) cache
  ttl      = 86400 * 30,   -- 30 days ttl for hits
  neg_ttl  = 30,           -- 30s ttl for misses
  ipc_shm  = 'ipc_dict'
})

local reverse_cache = mlcache.new('wl_cache', 'cache_dict', {
  lru_size = 500,          -- size of the L1 (Lua VM) cache
  ttl      = 3600,         -- 1h ttl for hits
  neg_ttl  = 30,           -- 30s ttl for misses
  ipc_shm  = 'ipc_dict'
})

local z = {}

z.new_session = function(user_id)
  local cached_token = reverse_cache:get('user:' .. user_id)
  if cached_token then return cached_token end
  
  local strong_random = resty_random.bytes(16, true)
  while strong_random == nil do
    strong_random = resty_random.bytes(16, true)
  end
  strong_random = str.to_hex(strong_random)
  session_cache:set('session:' .. strong_random, nil, user_id)
  reverse_cache:set('user:' .. user_id, nil, strong_random)
  return strong_random
end

z.get_session = function(stoken)
  return session_cache:get('session:' .. stoken)
end

return z
