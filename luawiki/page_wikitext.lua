local cjson = require('cjson')
local mysql = require('resty.mysql')
local wrap = ngx.quote_sql_str
local inspect = require('inspect')

math.randomseed(os.time())

if ngx.var.request_method == 'GET' then
  -- get wikitext for a page
  local pagename = ngx.var[1]
  local fetch_wikitext = require('fetch_wikitext')
  
  local flag, content = fetch_wikitext(pagename)
  
  if not flag then
    ngx.say(cjson.encode({
      code = 1,
      error = content
    }))
    return
  end
  
  ngx.say(cjson.encode({
    code = 0,
    result = content
  }))
  
elseif ngx.var.request_method == 'POST' then
  local pagename = ngx.var[1]
  local post_args = require('utils/post_args')()
  local session = require('session')
  
  if pagename == '' then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say(cjson.encode({
      error = 'title is empty!'
    }))
    return
  end
  
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

  local db, err = mysql:new()
  
  local flag, content = pcall(function()
    local err, errcode, sqlstate = '', '', ''
    local ok, res
    
    local function sql_error(msg)
      error(msg .. ': ' .. err .. ': ' .. errcode .. ': ' .. sqlstate)
    end

    ok, err, errcode, sqlstate = db:connect(dbconf)
    if not ok then sql_error('failed to connect') end
    
    res, err, errcode, sqlstate = -- get latest revision by page name
      db:query('SELECT page_id FROM page WHERE page_title = ' .. wrap(pagename), 1)
    if not res then sql_error('bad result') end
    
    local page_id = res[1] and res[1].page_id
    local wrapped_time = wrap(os.date('%Y%m%d%H%M%S', os.time()))
    
    if not page_id then
      local page_queries = {
        string.format([[INSERT INTO page (page_namespace, page_title, page_random, page_touched, page_latest, page_len)
          VALUES (0, %s, %s, %s, 0, 0);]], wrap(pagename), math.random(), wrapped_time),
          'SELECT LAST_INSERT_ID() page_id;'
      }
      res, err, errcode, sqlstate = db:query(table.concat(page_queries))
      if not res then
        sql_error('failed to insert a new page')
      end
      
      res, err, errcode, sqlstate = db:read_result()
      if res and res[1] then
        page_id = res[1].page_id
      else
        print(res, err, errcode, sqlstate)
        sql_error('failed to insert a new page')
      end
    end
    
    local comment = post_args.comment or ''
    local c_hash = ngx.crc32_short(comment)
    if c_hash >= 0x80000000 then
      c_hash = bit.band(c_hash, 0x7FFFFFFF)
    end
    
    local content = post_args.content and post_args.content:gsub('\r', ''):gsub('[^\n]$', '%0\n') or ''

    local r_sha1 = ngx.md5(content)
    
    local statements = {
      'INSERT INTO comment (comment_hash,comment_text) VALUES (' .. c_hash .. ',' .. wrap(comment) .. ');',
        'SET @com_id := LAST_INSERT_ID();',
      'INSERT INTO text (old_text,old_flags) VALUES (' .. wrap(content) .. ', "utf-8");',
        'SET @text_id := LAST_INSERT_ID();',
      string.format([[INSERT INTO revision (rev_page, rev_text_id, rev_comment_id, rev_user, rev_timestamp, rev_len, rev_sha1)
        VALUES (%d, @text_id, @com_id, %d, %s, %d, %s);]], page_id, user_id, wrapped_time, #content, wrap(r_sha1) ),
        'SET @rev_id := LAST_INSERT_ID();',
      'UPDATE page SET page_latest = @rev_id WHERE page_id = ' .. page_id .. ';',
    }
    
    print('START TRANSACTION;' .. table.concat(statements) .. 'COMMIT;')
    -- create page
    res, err, errcode, sqlstate = -- insert new text
      db:query('START TRANSACTION;' .. table.concat(statements) .. 'COMMIT;')
    if not res then sql_error('bad result') end
    print(inspect(res))
  end)
  
  if not flag then
    ngx.say(cjson.encode({
      code = 1,
      error = content
    }))
    return
  end
  
  ngx.say(cjson.encode({
    code = 0,
    result = 'success'
  }))
  
else
  ngx.status = ngx.HTTP_NOT_ALLOWED
  ngx.say(cjson.encode({
    error = 'Request method is not allowed!'
  }))
  return
end
