local z = {}

local inspect = require('inspect')

z.main = function(args)
  args = args[1]
  local lc_data = {
    T = args.T,
    rules = {}
  }
  
  for i = 1, 30 do
    local g_id = 'G' .. i
    if args[g_id] then
      local group_file = require('cgroup/' .. args[g_id])
      if group_file then
        local g_cont = group_file.content
        for _, v in ipairs(g_cont) do
          if v.type == 'item' then
            table.insert(lc_data.rules, v.rule)
          end
        end
      else
        print(args[g_id] .. ' not found')
      end
    end
  end
  
  for i = 1, 30 do
    local rule = args[tostring(i)]
    if rule then
      table.insert(lc_data.rules, rule)
    end
  end
  return mw.text.jsonEncode(lc_data)
end

return z
