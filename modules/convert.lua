local data = require('convert/data')
local inspect = require('inspect')

local z = {}

local function name_fallback(unit, abbr)
  if abbr and unit.symbol then return ' ' .. unit.symbol end
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

local function split(text, delimiter)
  -- Return a numbered table with fields from splitting text.
  -- The delimiter is used in a regex without escaping (for example, '.' would fail).
  -- Each field has any leading/trailing whitespace removed.
  local t = {}
  text = text .. delimiter  -- to get last item
  for item in text:gmatch('%s*(.-)%s*' .. delimiter) do
    table.insert(t, item)
  end
  return t
end

local function evaluate_condition(value, condition)
  -- Return true or false from applying a conditional expression to value,
  -- or throw an error if invalid.
  -- A very limited set of expressions is supported:
  --    v < 9
  --    v * 9 < 9
  -- where
  --    'v' is replaced with value
  --    9 is any number (as defined by Lua tonumber)
  --      only en digits are accepted
  --    '<' can also be '<=' or '>' or '>='
  -- In addition, the following form is supported:
  --    LHS and RHS
  -- where
  --    LHS, RHS = any of above expressions.
  local function compare(value, text)
    local arithop, factor, compop, limit = text:match('^%s*v%s*([*]?)(.-)([<>]=?)(.*)$')
    if arithop == nil then
      cerror('Invalid default expression')
    elseif arithop == '*' then
      factor = tonumber(factor)
      if factor == nil then
        cerror('Invalid default expression')
      end
      value = value * factor
    end
    limit = tonumber(limit)
    if limit == nil then
      cerror('Invalid default expression')
    end
    if compop == '<' then
      return value < limit
    elseif compop == '<=' then
      return value <= limit
    elseif compop == '>' then
      return value > limit
    elseif compop == '>=' then
      return value >= limit
    end
    cerror('Invalid default expression')  -- should not occur
  end
  local lhs, rhs = condition:match('^(.-%W)and(%W.*)')
  if lhs == nil then
    return compare(value, condition)
  end
  return compare(value, lhs) and compare(value, rhs)
end

local function get_default(value, unit_table)
  local default = data.default_exceptions[unit_table.defkey or unit_table.symbol] or unit_table.default
  if not default then
    -- unimplemented
    return
  end
  if default:find('!', 1, true) == nil then return default end
  local t = split(default, '!')
  if #t == 3 or #t == 4 then
    local result = evaluate_condition(value, t[1])
    default = result and t[2] or t[3]
    if #t == 4 then
      default = default .. t[4]
    end
    return default
  end
end

-- ref: https://stackoverflow.com/a/10990879/17237579
function num_with_commas(n)
  return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,")
                                :gsub(",(%-?)$","%1"):reverse()
end

z.main = function(args)
  args = args[1]
  local value = tonumber((args['1']:gsub(',', '')))
  
  local unit1 = get_data(args['2'])
  if not unit1 then
    cerror('不明单位' .. args['2'])
  end
  local unit2
  if args['3'] then unit2 = get_data(args['3'])
  else unit2 = get_data(get_default(value, unit1)) end
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
  
  local part1 = num_with_commas(value) .. (unit1.exp or '') .. name_fallback(unit1, abbr)
  local part2 = num_with_commas(result) .. (unit2.exp or '') .. name_fallback(unit2, abbr)
  return part1 .. '（' .. part2 .. '）'
end

return z

