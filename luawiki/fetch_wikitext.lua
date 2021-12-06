local mysql = require('resty.mysql')
local db, err = mysql:new()
local wrap = ngx.quote_sql_str

local function fetch_wikitext(pagename)

  local flag, content = pcall(function()
    local err, errcode, sqlstate = '', '', ''
    local ok, res
    
    local function sql_error(msg)
      error(msg .. ': ' .. err .. ': ' .. errcode .. ' ' .. sqlstate)
    end

    ok, err, errcode, sqlstate = db:connect(dbconf)
    if not ok then sql_error('failed to connect') end
    
    res, err, errcode, sqlstate = -- get latest revision by page name
      db:query('SELECT page_latest FROM page WHERE page_title = ' .. wrap(pagename), 1)
    if not res then sql_error('bad result') end
    
    local res = res[1]
    if not res then error('Page not found: ' .. pagename) end
    
    local revision_id = res.page_latest
    res, err, errcode, sqlstate = -- get revision text by revision id
      db:query('SELECT old_text FROM text JOIN revision ON old_id = rev_text_id WHERE rev_id = ' .. wrap(revision_id), 1)
    if not res then sql_error('bad result') end
    
    res = res[1]
    if not res then error('Revision not found: ' .. pagename .. '#' .. revision_id) end

    return res.old_text
  end)

  local ok, err = db:set_keepalive(10000, 100)
  if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
  end

  return flag, content
end

return fetch_wikitext
