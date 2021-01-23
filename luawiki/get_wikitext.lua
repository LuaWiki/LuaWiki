local mysql = require "resty.mysql"
local db, err = mysql:new()

local flag, content = pcall(function()
  local err, errcode, sqlstate = '', '', ''
  local ok, res
  
  local function sql_error(msg)
    error(msg .. ': ', err, ': ', errcode, ' ', sqlstate)
  end

  ok, err, errcode, sqlstate = db:connect{
    host = "127.0.0.1",
    port = 3306,
    database = "zhwiki",
    user = "root",
    password = "123456",
    charset = "utf8mb4",
    max_packet_size = 1024 * 1024,
  }
  if not ok then sql_error('failed to connect') end
  
  local pagename = ngx.var[1]
  res, err, errcode, sqlstate = -- get latest revision by page name
    db:query("SELECT page_latest FROM page WHERE page_title = '" .. pagename .. "'", 1)
  if not res then sql_error('bad result') end
  
  local res = res[1]
  if not res then error('Page not found: ' .. pagename) end
  
  local revision_id = res.page_latest
  res, err, errcode, sqlstate = -- get revision text by revision id
    db:query("SELECT rev_text FROM revision WHERE rev_id = '" .. revision_id .. "'", 1)
  if not res then sql_error('bad result') end
  
  res = res[1]
  if not res then error('Revision not found: ' .. pagename .. '#' .. revision_id) end
  
  return res.rev_text
end)

db:close()

if not flag then
  ngx.say(content)
  return
end

local parser = require('parser')
ngx.say(parser.parse(content))
