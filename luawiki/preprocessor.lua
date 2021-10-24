local tpl_args = require('tpl_args')
local tpl_parse = require('tpl_parse')
local data_parse = require('data_parse')
local nonparse = require('nonparse')
local re = require('lpeg.re')
local inspect = require('inspect')

local debug_flag = false
local function print_msg(msg)
  if ngx then ngx.say(msg .. '<br>')
  else print(msg) end
end

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
  tpl      <- '{{' tpl_name ([^{}]+ / balanced)* '}}'
  balanced <- '{' ([^{}] / balanced)* '}'
  tpl_name <- { ([_/!-] / [^%p%nl])+ }
]=]

local var_pat = re.compile([=[--lpeg
  '$' ( '[' {(!']' !%nl .)+} ']' / {[_%w]+})
]=])

local preproc = {}

preproc.new = function(wiki_state, template_cache)
  local z = {}
  
  z.tpl_cache = template_cache or {}
  
  z.eval_env = {
    math = math,
    string = string,
    type = type,
    _var =  {},
    _tpl = {},
    _tpl_expand = {}
  }

  function z:text_visitor(node)
    if not node then return '' end
    local new_node = {}
    for i, v in ipairs(node) do
      if type(v) == 'string' then
        new_node[i] = re.gsub(v, var_pat, function(s)
          return self.eval_env._var[s] or ''
        end):gsub('&(%d+);', function(tpl_num)
          local another_preproc = preproc.new(wiki_state, self.tpl_cache)
          return another_preproc:process(self.eval_env._tpl[tonumber(tpl_num)])
        end)
      else -- cast to string in text
        new_node[i] = tostring(self:call_visitor(v) or ''):gsub('&(%d+);', function(tpl_num)
          local another_preproc = preproc.new(wiki_state, self.tpl_cache)
          return another_preproc:process(self.eval_env._tpl[tonumber(tpl_num)])
        end)
      end
    end
    return table.concat(new_node)
  end

  function z:eval_single_arg(v, fname, i)
    local tag = v.tag
    if tag == 'text' then
      return self:text_visitor(v)
    elseif tag == 'call' then
      return self:call_visitor(v)
    elseif tag == 'data' then
      return data_parse.parse_data(v[1])
    else--[[if tag == 'expr' then]]
      local chunk = re.gsub(v[1], var_pat, '_var["%1"]')
      local f, err = load('return ' .. chunk, fname .. '@arg' .. i, 't', self.eval_env)
      if f then
        local ret = f()
        if type(ret) == 'string' then
          ret = ret:gsub('&(%d+);', function(tpl_num)
            local another_preproc = preproc.new(wiki_state, self.tpl_cache)
            return another_preproc:process(self.eval_env._tpl[tonumber(tpl_num)])
          end)
        end
        return ret
      else error(err) end
    end
  end

  function z:eval_args(args, fname)
    local arg_size = #args
    local new_args = {}
    if fname == 'or' then
      local res = nil
      for i = 1, arg_size - 1 do
        res = self:eval_single_arg(args[i], fname, i)
        if res then return { res } end
      end
      return { self:eval_single_arg(args[arg_size], fname, arg_size) }
    elseif fname == 'and' then
      local res = nil
      for i = 1, arg_size - 1 do
        res = self:eval_single_arg(args[i], fname, i)
        if not res then return { res } end
      end
      return { self:eval_single_arg(args[arg_size], fname, arg_size) }
    else
      args.n = arg_size
      for i, v in ipairs(args) do
        new_args[i] = self:eval_single_arg(v, fname, i)
      end
    end
    return new_args
  end

  function z:call_visitor(node, in_text)
    local mname = node.module
    if mname == 'debug' then
      debug_flag = true
      local res = self:eval_single_arg(node.args[1], 'debug', 1)
      debug_flag = false
      return res
    end

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

    if debug_flag then
      local res = f(self:eval_args(node.args, fname), in_text, #node.args)
      print_msg(fname .. ' returned ' .. inspect(res))
      return res
    end
    return f(self:eval_args(node.args, fname), in_text, #node.args)
  end

  function z:process(content)
    return re.gsub(content, simple_tpl, function(tpl_text, tpl_name)
      tpl_name = tpl_name:sub(1, 1):upper() .. tpl_name:sub(2):gsub(' +$', ''):gsub(' ', '_')

      if not self.tpl_cache[tpl_name] then
        local f = io.open('wiki/template/' .. tpl_name .. '.tpl')
        if not f then
          if #content == #tpl_text then
            return tpl_text
          else
            return '<a class="new" href="/wiki/Template:' .. tpl_name .. '">Template:' .. tpl_name .. '</a>'
          end
        end
        self.tpl_cache[tpl_name] = tpl_parse.parse_template(f:read('*a'))
      end
      --print(tpl_parse.dump(self.tpl_cache[tpl_name].ast, 0))

      -- get mapped parameter names and set env
      local converted_args = {}
      do
        local alias_dict = self.tpl_cache[tpl_name].alias
        local raw_args, sub_tpl = tpl_args.parse_args(tpl_text)
        for k, v in pairs(raw_args) do
          converted_args[alias_dict[k] or k] = v
        end
        
        self.eval_env._tpl = sub_tpl
        --print(inspect(sub_tpl))
      end
      self.eval_env._var = setmetatable(converted_args, var_meta)
      self.eval_env._var._pagename = wiki_state.title
      --print(inspect(converted_args))

      local expanded_wikitext = self:text_visitor(self.tpl_cache[tpl_name].ast)
      return nonparse.decorate(wiki_state, expanded_wikitext)
    end)
  end
  
  return z
end

return preproc
