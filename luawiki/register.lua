local cjson = require('cjson')

if ngx.var.request_method ~= 'POST' then
  ngx.status = ngx.HTTP_NOT_ALLOWED
  ngx.say(cjson.encode({
    error = 'Only POST method is allowed!'
  }))
  return
end

local mysql = require('resty.mysql')
local inspect = require('inspect')
local db, err = mysql:new()
local wrap = ngx.quote_sql_str

local post_args = require('post_args')()

if not post_args.username or post_args.username == '' or
    not post_args.password or post_args.password == '' then
  ngx.status = ngx.HTTP_BAD_REQUEST
  ngx.say(cjson.encode({
    error = 'Username or password is empty!'
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
  res, err, errcode, sqlstate = -- get user_id whose user_name is the same as new username
    db:query("SELECT user_id FROM user WHERE user_name = " .. wrap(post_args.username), 1)
  if not res then sql_error('bad result') end
  
  local res = res[1]
  if res then error('Username duplicate!') end
 
  -- create account
  res, err, errcode, sqlstate = -- get user_id whose user_name is the same as new username
    db:query("INSERT INTO user (user_name, user_password, user_newpassword, user_email, user_touched) VALUES (" ..
      wrap(post_args.username) .. "," .. wrap(post_args.password) .. ",'',''," ..
      wrap(os.date('%Y%m%d%H%M%S', os.time())) .. ")")
  if not res then sql_error('bad result') end
end)

local ok, err = db:set_keepalive(10000, 100)
if not ok then
  ngx.say("failed to set keepalive: ", err)
  return
end

if not flag then
  ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
  ngx.say(cjson.encode({
    error = content
  }))
else
  ngx.say(cjson.encode({
    code = 0,
    result = 'success'
  }))
end
