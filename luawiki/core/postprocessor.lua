-- LuaWiki postprocesoor
-- 
-- 1. Fix <div> inside <p> problem
-- 2. Section wrapping
-- 3. Move references
-- 4. Mark red links

local html_parser = require('html_parser')
local counters = require('counters/init')

local mysql = require('resty.mysql')
local cerror = require('utils/common').cerror
local db, err = mysql:new()
local wrap = ngx.quote_sql_str

local z = {}

local inspect = require('inspect')

local function traverse_a(node)
  node.nodeName = node.nodeName and string.lower(node.nodeName)
  -- traverse children
  if node.children then
    for i, v in ipairs(node.children) do
      v.parent = node
      v.index = i
      
      if v.nodeName == 'div' and node.nodeName == 'p' then
        local new_p = { nodeName = 'p', children = {} }
        table.move(node.children, i+1, #node.children, 1, new_p.children)
        node.children[i + 1] = nil -- stop this loop
        if i == 1 then
          node.parent.children[node.index] = v
          v.parent = node.parent
          v.index = node.index
          table.insert(node.parent.children, node.index + 1, new_p)
          
          traverse_a(v)
        else
          node.children[i] = nil
          table.insert(node.parent.children, node.index + 1, v)
          table.insert(node.parent.children, node.index + 2, new_p)
        end
      else
        traverse_a(v)
      end
    end
  end
end

-- wrap content into sections
-- return new root node
local function wrap_section(root)
  local header_counter = 0
  local root2 = { nodeName = '#root', children = {} }
  local h2sec = { nodeName = 'section', class = 'h2sec', children = {}, id = 'toc0' }
  local h3sec = nil
  for i, x in ipairs(root.children) do
    if i == 1 then
      table.insert(root2.children, x)
    elseif x.nodeName == 'h2' then
      if h3sec then
        table.insert(h2sec.children, h3sec)
        h3sec = nil
      end
      table.insert(root2.children, h2sec)
      header_counter = header_counter + 1
      h2sec = { nodeName = 'section', class = 'h2sec', children = {},
        id = 'toc' .. header_counter }
      table.insert(h2sec.children, x)
    elseif x.nodeName == 'h3' then
      if h3sec then
        table.insert(h2sec.children, h3sec)
      end
      header_counter = header_counter + 1
      h3sec = { nodeName = 'section', class = 'h3sec', children = {},
        id = 'toc' .. header_counter }
      table.insert(h3sec.children, x)
    else
      if h3sec then
        table.insert(h3sec.children, x)
      else
        table.insert(h2sec.children, x)
      end
    end
  end
  if h3sec then table.insert(h2sec.children, h3sec) end
  table.insert(root2.children, h2sec)

  return root2
end

local function get_counter(g, num)
  if #g > 0 then
    if counters[g] then
      return counters[g]:render(num)
    else
      return g .. ' ' .. num
    end
  else
    return num
  end
end

-- move references to correct places
local function move_refs(root)
  --- 1.find out <ref> and <references>
  local cite_store = {}
  local ref_store = {}
  local function traverse_r(node)
    if node.nodeName == 'ref' then
      local key = node.group or ''
      if cite_store[key] then
        table.insert(cite_store[key], node)
      else
        cite_store[key] = { node }
      end
    elseif node.nodeName == 'references' then
      node.parent.class = 'mw-references-columns'
      if not node.children then
        node.children = {}
      end
      local key = node.group or ''
      if not ref_store[key] then
        ref_store[key] = node
      end
    end
    
    -- traverse children
    if node.children and node.class ~= 'hidden' then
      for i, v in ipairs(node.children) do
        v.parent = node
        v.index = i
        traverse_r(v)
      end
    end
  end
  traverse_r(root)

  --- 2.generate reference groups
  local id_target = {}
  local function build_ref_group(g)
    
    local ref_map = {}
    
    local hidden = ref_store[g].children and ref_store[g].children[1]
    local hidden_map = {}
    local function traverse_hidden(node)
      if node.nodeName == 'ref' and node.name then
        hidden_map[node.name] = node
      end
      
      -- traverse children
      if node.children then
        for i, v in ipairs(node.children) do
          traverse_hidden(v)
        end
      end
    end
    if hidden then traverse_hidden(hidden) end
    
    local ref_counter = 0
    
    local cite_store_g = cite_store[g]
    if not cite_store_g then return end
    for _, x in ipairs(cite_store_g) do
      local name = x.name
      local anchor = 'cite_note-error'
      if name then
        name = name:gsub(' ' , '_')
        if ref_map[name] then
          anchor = ('cite_note-%s-%s'):format(name, ref_map[name])
          if x.text then
            local target_element = id_target[anchor]
            target_element.class = ''
            target_element.text = x.text
            target_element.children = nil
          elseif x.children and x.children[1] then
            local target_element = id_target[anchor]
            target_element.class = ''
            target_element.text = nil
            target_element.children = x.children
          end
          x.nodeName = 'sup'
          x.text = ('[<a href="#%s">%s</a>]'):format(anchor, get_counter(g, ref_map[name]))
          x.children = nil
          goto continue
        end
        ref_counter = ref_counter + 1
        anchor = ('cite_note-%s-%s'):format(name, ref_counter)
        ref_map[name] = ref_counter
        if hidden_map[name] then
          x.text = hidden_map[name].text
          x.children = hidden_map[name].children
        end
      else
        ref_counter = ref_counter + 1
        anchor = ('cite_note-%s-%s'):format(g, ref_counter)
      end
      local cite_node = { nodeName = 'sup',
        text = ('[<a href="#%s">%s</a>]'):format(anchor, get_counter(g, ref_counter)) }
      x.id = anchor
      id_target[anchor] = x
      if not x.text and not (x.children and x.children[1]) then
        x.class = 'cite_note-error'
        x.text = '引用错误：没有为名为<code>' .. (name or '') .. '</code>的参考文献提供内容'
        x.children = nil
      end
      x.parent.children[x.index] = cite_node
      table.insert(ref_store[g].children, x)
      ::continue::
    end
  end

  --- 3.run groups
  for k in pairs(ref_store) do
    build_ref_group(k)
  end
end

z.process = function(html, wiki_state)
  if not wiki_state then
    print('No wiki_state!')
    return html
  end
  
  local function sql_error(msg)
    cerror(msg .. ': ' .. err .. ': ' .. errcode .. ' ' .. sqlstate)
  end

  local ok = db:connect(dbconf)
  if ok then
    local links = {}
    for k in pairs(wiki_state.links) do
      table.insert(links, wrap(k))
    end
    ok = db:send_query('SELECT page_title FROM page WHERE page_title IN (' .. table.concat(links, ',') .. ')')
    if not ok then
      print('query links error')
    end
  end

  local root = html_parser.parse(html)
  if not root then
    print('HTML PARSE ERROR!')
    return html
  end
  --if true then return html end
  
  -- div inside p, add parent and index
  traverse_a(root)

  -- add sections
  root = wrap_section(root)

  -- move refs
  move_refs(root)
  
  local res = db:read_result()
  if not res then res = {} end
  
  local blue_links = {}
  for _, v in ipairs(res) do
    blue_links[v.page_title] = true
  end
  
  -- tag red links
  local function link_state(node)
    if node.nodeName == 'a' and node.class == 'internal' then
      if blue_links[node.title] then
        node.class = nil
      else
        node.class = 'new'
      end
      return
    end
    if node.children then
      for _, v in ipairs(node.children) do
        link_state(v)
      end
    end
  end
  
  link_state(root)
  
  return html_parser.serialize(root)
end

return z
