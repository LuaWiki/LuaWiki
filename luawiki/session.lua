local mlcache = require('resty.mlcache')
local resty_random = require('resty.random')
local str = require('resty.string')

local cache, err = mlcache.new('lw_cache', 'cache_dict', {
  ttl      = 86400 * 30, -- 30 days
  lru_size = 500,    -- size of the L1 (Lua VM) cache
  ttl      = 3600,   -- 1h ttl for hits
  neg_ttl  = 30,     -- 30s ttl for misses
  ipc_shm  = 'ipc_dict'
})

local z = {}

z.new_session = function(actor_id)
  local strong_random = resty_random.bytes(16, true)
  while strong_random == nil do
    strong_random = resty_random.bytes(16, true)
  end
  strong_random = str.to_hex(strong_random)
  cache:set('session:' .. strong_random, nil, actor_id)
  return strong_random
end

z.get_session = function(stoken)
  return cache:get('session:' .. stoken)
end

return z
