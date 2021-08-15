local block_tag_pat = [=[--lpeg
  %nl? '<' {'/'}? {'blockquote' /'table' / 'div' / 'h' [1-7]} { [^<>]* '>' }
]=]
block_tag_pat = block_tag_pat:gsub("'(.-)'", function(p)
  local t = {}
  local function do_a()
    p = p:gsub('^%a+', function(pp)
      pp = pp:gsub('%a', function(letter)
        return string.format("[%s%s]", letter:lower(), letter:upper())
      end)
      table.insert(t, pp)
      return ''
    end)
  end
  local function do_A()
    p = p:gsub('^%A+', function(pp)
      pp = "'" .. pp .. "'"
      table.insert(t, pp)
      return ''
    end)
  end
  
  local flag = true
  while p:len() > 0 do
    if flag then
      do_a()
      flag = false
    else
      do_A()
      flag = true
    end
  end
  
  return table.concat(t)
end)

math.randomseed(os.time())
local charTable = {}
do
  local chars = 'abcdefghijklmnopqrstuvwxyz'
  for c in chars:gmatch('.') do
    table.insert(charTable, c)
  end
end
local function random_str()
  local randomString = {}
  for i = 1, 7 do
    randomString[i] = charTable[math.random(1, 26)];
  end
  return table.concat(randomString)
end

local stack = {}
local tag_counter = {}
local function block_tag_handler(p1, p2, p3)
  local luawiki_hash = ''
  if not p3 then
    luawiki_hash = random_str()
    table.insert(stack, { p1, luawiki_hash })
    tag_counter[p1] = tag_counter[p1] and (tag_counter[p1]+1) or 1
    return '\n' .. '<' .. p1 .. ' data-lw="' .. luawiki_hash .. '"' .. p2
  else
    local p0 = ''
    if stack[#stack] and p2 == stack[#stack][1] then
      luawiki_hash = table.remove(stack)[2]
      tag_counter[p2] = tag_counter[p2] - 1
      p0 = '</' .. p2 .. ' data-lw="' .. luawiki_hash .. '"' .. '>'
    elseif tag_counter[p2] and tag_counter[p2] > 0 then
      local prefix_str = ''
      while #stack > 0 and p2 ~= stack[#stack][1] do
        local unbalanced_tag = table.remove(stack)
        prefix_str = prefix_str .. '</' .. unbalanced_tag[1] .. ' data-lw="' ..
          unbalanced_tag[2] .. '">'
        tag_counter[unbalanced_tag[1]] = tag_counter[unbalanced_tag[1]] - 1
      end
      luawiki_hash = table.remove(stack)[2]
      tag_counter[p2] = tag_counter[p2] - 1
      p0 = prefix_str .. '</' .. p2 .. ' data-lw="' .. luawiki_hash .. '"' .. '>'
    else
      return ''
    end
    return p0
  end
end

local function sanitize(wikitext)
  stack = {}
  tag_counter = {}
  local base_html = re.gsub(wikitext, block_tag_pat, block_tag_handler)
  for i = #stack, 1, -1 do
    base_html = base_html .. '</' .. stack[i][1] .. '>'
  end
  return base_html
end

return {
  sanitize = sanitize
}
