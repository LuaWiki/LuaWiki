local tpl_args = require('tpl_args')
local tpl_parse = require('tpl_parse')
local re = require('lpeg.re')
local inspect = require('inspect')

local eval_env = {
  math = math,
  string = string,
  type = type,
  _var =  {}
}

local text_visitor, eval_single_arg, eval_args, call_visitor

text_visitor = function(node)
  if not node then return '' end
  local new_node = {}
  for i, v in ipairs(node) do
    if type(v) == 'string' then
      new_node[i] = v:gsub('%$([_%w]+);?', function(s)
        return eval_env._var[s]
      end)
    else -- cast to string in text
      new_node[i] = tostring(call_visitor(v) or '')
    end
  end
  return table.concat(new_node)
end

eval_single_arg = function(v, fname, i)
  local tag = v.tag
  if tag == 'text' then
    return text_visitor(v)
  elseif tag == 'call' then
    return call_visitor(v)
  else--[[if tag == 'expr' then]]
    local chunk = v[1]:gsub('%$([_%w]+)', '_var["%1"]')
    local f, err = load('return ' .. chunk, fname .. '@arg' .. i, 't', eval_env)
    if f then return f()
    else error(err) end
  end
end

eval_args = function(args, fname)
  local arg_size = #args
  local new_args = {}
  if fname == 'or' then
    local res = nil
    for i = 1, arg_size - 1 do
      res = eval_single_arg(args[i], fname, i)
      if res then return { res } end
    end
    return { eval_single_arg(args[arg_size], fname, arg_size) }
  elseif fname == 'and' then
    local res = nil
    for i = 1, arg_size - 1 do
      res = eval_single_arg(args[i], fname, i)
      if not res then return { res } end
    end
    return { eval_single_arg(args[arg_size], fname, arg_size) }
  else
    args.n = arg_size
    for i, v in ipairs(args) do
      new_args[i] = eval_single_arg(v, fname, i)
    end
  end
  return new_args
end

call_visitor = function(node, in_text)
  local mname = node.module
  local m = tpl_parse.ext_modules[mname]
  local fname, f
  if not m then error('Module ' .. (mname or '?') .. " doesn't exist.")
  elseif type(m) == 'function' then
    fname, f = mname, m
  elseif type(m) == 'table' then
    fname = node.func or 'main'
    f = m[fname]
  else
    error('Module ' .. (mname or '?') .. ' is corrupt.')
  end

  if not f then
    error("attempt to call '" .. mname .. '.' .. fname .. "' (a nil value)")
  end

  return f(eval_args(node.args, fname), in_text, #node.args)
end

----------------------------------------------------------------------------
-- MAIN PROCESS
----------------------------------------------------------------------------

local z = {}

local var_meta = {
  __index = function(t, key)
    if key == '_num' then
      local num_vars = { n = 0 }
      for k, v in pairs(t) do
        local the_num = tonumber(k)
        if the_num then
          num_vars[the_num] = v
          if the_num > num_vars.n then num_vars.n = the_num end
        end
      end
      rawset(t, '_num', num_vars)
      return num_vars
    elseif key == '_all' then
      rawset(t, '_all', t)
      return t
    end
  end
}

local simple_tpl = re.compile[=[--lpeg
  simp_tpl <- { tpl }
  tpl      <- '{{' tpl_name ([^{}] / tpl)* '}}'
  tpl_name <- { ([_/-] / [^%p%nl])+ () }
]=]

z.process = function(content, title)
  local tpl_cache = {}
  return re.gsub(content, simple_tpl, function(tpl_text, tpl_name)
    tpl_name = tpl_name:sub(1, 1):upper() .. tpl_name:sub(2):gsub(' +$', ''):gsub(' ', '_')

    if not tpl_cache[tpl_name] then
      local f = io.open('wiki/template/' .. tpl_name .. '.tpl')
      if not f then return tpl_text end
      tpl_cache[tpl_name] = tpl_parse.parse_template(f:read('*a'))
    end
    --print(tpl_parse.dump(tpl_cache[tpl_name].ast, 0))

    -- get mapped parameter names and set env
    local converted_args = {}
    do
      local alias_dict = tpl_cache[tpl_name].alias
      local raw_args = tpl_args.parse_args(tpl_text)
      for k, v in pairs(raw_args) do
        converted_args[alias_dict[k] or k] = v
      end
    end
    eval_env._var = setmetatable(converted_args, var_meta)
    eval_env._var._pagename = title
    
    return text_visitor(tpl_cache[tpl_name].ast)
  end)
end

return z
