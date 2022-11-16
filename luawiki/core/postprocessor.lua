local html_parser = require('html_parser')
local decode_html = require('utils/html_utils').decode_html

local z = {}

z.process = function(html)
  local root = html_parser.parse(html)
  if not root then return html end
  
  -- div inside p, add parent and index
  local function traverse_a(node)
    -- traverse children
    if node.children then
      for i, v in ipairs(node.children) do
        v.parent = node
        v.index = i
        
        if v.nodeName == 'div' and node.nodeName == 'p' then
          local new_p = { nodeName = 'p', children = {} }
          table.move(node.children, i+1, #node.children, 1, new_p.children)
          if i == 1 then
            node.parent.children[node.index] = v
            table.insert(node.parent.children, node.index + 1, new_p)
          else
            node.children[i + 1] = nil
            table.insert(node.parent.children, node.index + 1, v)
            table.insert(node.parent.children, node.index + 2, new_p)
          end
        end
        
        traverse_a(v)
      end
    end
  end
  traverse_a(root)

  -- add sections
  local header_counter = 0
  local root2 = { nodeName = '#root', children = {} }
  local h2sec = { nodeName = 'section', class = 'h2sec', children = {} }
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
  table.insert(root2.children, h2sec)

  -- move refs
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
        traverse_r(v)
        v.parent = node
        v.index = i
      end
    end
  end
  traverse_r(root2)

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
          x.text = ('[<a href="#%s">%s%s</a>]'):format(anchor, #g > 0 and (g .. ' ') or '', ref_map[name])
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
        text = ('[<a href="#%s">%s%s</a>]'):format(anchor, #g > 0 and (g .. ' ') or '', ref_counter) }
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
  
  return html_parser.serialize(root2)
end

return z
