local cjson = require('cjson')

local mysql = require('resty.mysql')
local db, err = mysql:new()
local wrap = ngx.quote_sql_str

local session = require('session')

local token = ngx.var.cookie_session
if not token then
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.say(cjson.encode({
    error = 'not logged in!'
  }))
  return
end
local user_id = session.get_session(token)
if not user_id then
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.say(cjson.encode({
    error = 'not logged in!'
  }))
  return
end

local flag, content = pcall(function()
  local err, errcode, sqlstate = '', '', ''
  local ok, res
  
  local function sql_error(msg)
    error(msg .. ': ' .. err .. ': ' .. errcode .. ' ' .. sqlstate)
  end

  ok, err, errcode, sqlstate = db:connect(dbconf)
  if not ok then sql_error('failed to connect') end
  
  -- check duplicate
  res, err, errcode, sqlstate = -- get ug_group with ug_user = user_id
    db:query(([[SELECT ug_group FROM user_groups WHERE ug_user = '%s' AND
      (ug_expiry IS NULL OR ug_expiry > '%s') ORDER BY ug_group;]])
      :format(user_id, os.date('%Y%m%d%H%M%S', os.time())))
  if not res then sql_error('bad result') end
  
  local groups = {}
  for i, v in ipairs(res) do
    groups[i] = v
  end
  return session.new_csrf(groups)
end)

if not flag then
  ngx.say(cjson.encode({
    code = 1,
    error = content
  }))
else
  ngx.say(cjson.encode({
    code = 0,
    result = content
  }))
end

local ok, err = db:set_keepalive(10000, 100)
if not ok then
  print("failed to set keepalive: ", err)
end
