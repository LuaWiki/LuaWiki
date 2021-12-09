require('mobdebug').start('127.0.0.1')
local cjson = require('cjson')

local mysql = require('resty.mysql')
local db = mysql:new()

local token = ngx.var.cookie_session
if not token then
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.say(cjson.encode({
    error = 'not logged in!'
  }))
  return
end

local session = require('session')
local user_id = session.get_session(token)
session.remove_session(token)

if not db:connect(dbconf) then
  error('failed to connect') 
end

db:query(([[UPDATE user SET user_token = NULL WHERE user_id = '%s';]]):format(user_id))

ngx.header["Set-Cookie"] = 'session=deleted; Path=/; Expires=' .. ngx.cookie_time(0)
ngx.say(cjson.encode({
  code = 0,
  result = 'success'
}))

local ok, err = db:set_keepalive(10000, 100)
if not ok then
  print("failed to set keepalive: ", err)
end
