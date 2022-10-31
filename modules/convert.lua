local data = require('convert/data')

local z = {}

local function name_fallback(unit, abbr)
  if abbr then return ' ' .. unit.symbol end
  return unit.name1 or unit._name1 or ' ' .. unit.symbol
end

local function get_unit(unitcode)
  local unit = data.all_units[unitcode]
  if not unit then return end
  if unit.target then
    unit = data.all_units[unit.target]
  end
  return clone(unit)
end

local function get_data(unitcode)
  if not unitcode then return end
  local exponent, baseunit = unitcode:match('^e(%d+)(.*)')
  local unit
  if exponent then
    unit = get_unit(baseunit)
    unit.exp = ' × 10<sup>' .. exponent .. '</sup>'
    unit.scale = unit.scale * 10 ^ tonumber(exponent)
  else
    unit = get_unit(unitcode)
  end
  return unit
end

z.main = function(args)
  args = args[1]
  local value = tonumber(args['1'])
  
  local unit1 = get_data(args['2'])
  if not unit1 then
    cerror('不明单位' .. args['2'])
  end
  local unit2
  if args['3'] then unit2 = get_data(args['3'])
  else unit2 = get_data(unit1.default) end
  if not unit2 then
    cerror('不明单位' .. args['3'])
  end
  if unit1.utype ~= unit2.utype then
    cerror('无法将' .. unit1.utype .. '转换为' .. unit2.utype)
  end
  local abbr = args.abbr == 'on'
  local precision = args['4']
  local result = (value - (unit1.offset or 0)) * unit1.scale / unit2.scale + (unit2.offset or 0)
  
  -- precision
  local int_part = math.floor(value)
  if int_part == value then
    result = math.floor(result + 0.5)
  else
    if not precision then
      local frac_part = value - int_part
      precision = #tostring(frac_part) - 2
    end
    result = string.format('%.' .. precision .. 'f', result)
  end
  
  local part1 = value .. (unit1.exp or '') .. name_fallback(unit1, abbr)
  local part2 = result .. (unit2.exp or '') .. name_fallback(unit2, abbr)
  return part1 .. '（' .. part2 .. '）'
end

return z

