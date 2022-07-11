local cjson = require('cjson')

if ngx.var.request_method ~= 'GET' then
  ngx.status = ngx.HTTP_NOT_ALLOWED
  ngx.say(cjson.encode({
    error = 'Only GET method is allowed!'
  }))
  return
end

local mysql = require('resty.mysql')
local db, err = mysql:new()
local wrap = ngx.quote_sql_str

local pagename = ngx.var[1]
local rv_end = ngx.var[2]
local rv_limit = ngx.var[3]

local sql_part = function(param, template)
  if param and param ~= '_' then
    return template:format(param)
  else
    return ''
  end
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
  res, err, errcode, sqlstate = -- get revisions whose page_title is pagename
    db:query(([[SELECT rev_id, rev_timestamp, rev_len, user_name, comment_text FROM revision
      JOIN page ON rev_page = page_id
      JOIN user ON rev_user = user_id
      JOIN comment ON rev_comment_id = comment_id
      WHERE page_title = %s %s
      ORDER BY rev_id DESC %s]]):format(wrap(pagename),
        sql_part(rv_end, [[AND rev_id < %d]]),
        sql_part(rv_limit or 10, [[LIMIT %d]])))
  if not res then sql_error('bad result') end
  
  return res
end)

local ok, err = db:set_keepalive(10000, 100)
if not ok then
  print("failed to set keepalive: ", err)
end

if not flag then
  ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
  ngx.say(cjson.encode({
    error = content
  }))
else
  ngx.say(cjson.encode({
    code = 0,
    result = content
  }))
end
