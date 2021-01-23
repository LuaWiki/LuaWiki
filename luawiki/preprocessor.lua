local tpl_args = require('tpl_args')
local tpl_parse = require('tpl_parse')
local re = require('lpeg.re')

local eval_env = {
  math = math,
  string = string,
  type = type,
  _var =  {}
}

local text_visitor, eval_single_arg, eval_args, call_visitor

text_visitor = function(node)
  if not node then return '' end
  for i, v in ipairs(node) do
    if type(v) == 'string' then
      node[i] = v:gsub('%$([_%w]+);?', function(s)
        return eval_env._var[s]
      end)
    else -- cast to string in text
      node[i] = tostring(call_visitor(v) or '')
    end
  end
  return table.concat(node)
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
      args[i] = eval_single_arg(v, fname, i)
    end
  end
  return args
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

  return f(eval_args(node.args, fname), in_text)
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

local inspect = require('inspect')

z.process = function(content, title)
  local tpl_cache = {}
  return re.gsub(content, simple_tpl, function(tpl_text, tpl_name)
    tpl_name = tpl_name:sub(1, 1):upper() .. tpl_name:sub(2)
    eval_env._var = setmetatable(tpl_args.parse_args(tpl_text), var_meta)
    eval_env._var._pagename = title
    --print(inspect(eval_env._var))
    --print(tpl_name)
    if not tpl_cache[tpl_name] then
      local f = io.open('wiki/template/' .. tpl_name .. '.tpl')
      if not f then return tpl_text end
      tpl_cache[tpl_name] = tpl_parse.parse_template(f:read('*a'))
    end
    print(tpl_parse.dump(tpl_cache[tpl_name], 0))
    --print(text_visitor(tpl_cache[tpl_name]))
    return text_visitor(tpl_cache[tpl_name])
    --print(inspect(text_visitor(tpl_ast)))
  end)
end

return z
