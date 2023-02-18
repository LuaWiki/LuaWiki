-- A sandbox module that creates a safe environment for executing Lua code
-- It allows only a subset of global variables and functions from the base and standard libraries
-- It prevents modifications to read-only tables and metatables

local sandbox = {}

-- note: math.random math.randomseed string.dump can be potentially unsafe
local allowed_globals = {
  -- base
  'assert', 'error', 'getmetatable', 'ipairs', 'next', 'pairs',
  'pcall', 'rawequal', 'rawget', 'rawset', 'select', 'setmetatable',
  'tonumber', 'type', 'unpack', 'xpcall', '_VERSION', 
  'tostring', 'print',
  -- libs
  'table', 'math', 'string', 'mw'
}

sandbox.env_table = function(t)
  t = t or allowed_globals
  
  local BASE_ENV = {}
  for _, id in ipairs(t) do
    local obj = _G[id]
    if type(obj) == 'table' then
      local mod_copy = {}
      for k, v in pairs(obj) do
        mod_copy[k] = v
      end
      
      BASE_ENV[id] = setmetatable({}, {
        __index = mod_copy,
        __newindex = function() error('Attempt to modify read-only table') end,
        __metatable = false
      })
    else
      BASE_ENV[id] = obj
    end
  end
  return BASE_ENV
end

return sandbox
