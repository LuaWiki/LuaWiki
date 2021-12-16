local cjson = require('cjson')

if ngx.var.request_method ~= 'POST' then
  ngx.status = ngx.HTTP_NOT_ALLOWED
  ngx.say(cjson.encode({
    error = 'Only POST method is allowed!'
  }))
  return
end

local mysql = require('resty.mysql')
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

local session = require('session')

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
    db:query('SELECT user_id, user_token FROM user WHERE user_name = ' .. wrap(post_args.username) ..
      ' AND user_password = ' .. wrap(post_args.password), 1)
  if not res then sql_error('bad result') end
  
  local res = res[1]
  if not res then error('username or password is wrong!') end
  
  if res.user_token ~= ngx.null then
    return res.user_token
  else
    local stoken = session.new_session(res.user_id)
    db:query(([[UPDATE user SET user_token = '%s' WHERE user_name = %s;]])
      :format(stoken, wrap(post_args.username)))
    return stoken
  end
end)

if not flag then
  ngx.say(cjson.encode({
    code = 1,
    error = content
  }))
else
  local expires = 3600 * 24  -- 1 day
  ngx.header["Set-Cookie"] = 'session=' .. content .. '; Path=/; Expires=' .. ngx.cookie_time(ngx.time() + expires)
  ngx.say(cjson.encode({
    code = 0,
    result = 'success'
  }))
end

local ok, err = db:set_keepalive(10000, 100)
if not ok then
  print("failed to set keepalive: ", err)
end
