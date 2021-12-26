local mp_parser = require('resty/multipart/parser')

local function getFile(file_name)
  local f = assert(io.open(file_name, 'r'))
  local string = f:read("*all")
  f:close()
  return string
end

local function post_args()
  local req_headers = ngx.req.get_headers()
  ngx.req.read_body()
  if req_headers['content-type']:sub(1, 5) == 'multi' then
    local body = ngx.req.get_body_data()
    if not body then
      local file_name = ngx.req.get_body_file()
      if file_name then
        body = getFile(file_name)
      end
    end

    local p, err = mp_parser.new(body, ngx.var.http_content_type)
    if not p then
       ngx.say("failed to create parser: ", err)
       return
    end

    local arg_map = {}
    while true do
      local part_body, name = p:parse_part()
      if not part_body then break end
      arg_map[name] = part_body
    end
    return arg_map
  else
    return ngx.req.get_post_args()
  end
end

return post_args
