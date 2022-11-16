-- PEG html parser
-- ref: https://github.com/tgrospic/peg-html-parser/blob/master/src/peg-html-parser.pegls
-- removed doctype

local re = require('lpeg.re')

local defs = {
  extract_attr = function(t)
    if not t.attr then return t end
    for i, v in ipairs(t.attr) do
      if not t[v.name] then
        t[v.name] = v.value
      end
    end
    if t.children and #t.children == 1 and not t.children[1].nodeName then
      t.text = t.children[1].text
      t.children = nil
    end
    t.attr = nil
    return t
  end
}

local html_parser = re.compile([=[--lpeg
  Document <- {| {:nodeName: '' -> '#root' :} __ {:children: {| Element* |} :} __ !. |}
  Element  <- !'</' {| TextA / VoidA / RawText / Nested / VoidB / Comment / TextB |} -> extract_attr
  RawText  <- '<' RawTextTag Attributes '>' __  {:text: ( !('</' =nodeName __ '>') .)* :}
              '</' =nodeName __ '>'
  RawTextTag <- {:nodeName: 'script' / 'style' / 'textarea' / 'title' / 'plaintext' :}
  
  Nested   <- TagBegin __ {:children: {| Element* |} :} __ TagEnd
  TagBegin <- '<' TagName Attributes '>'
  TagEnd   <- '</' =nodeName __ '>'
  
  VoidA    <- {:type: '' -> 'void' :} '<' TagName Attributes '/>'
  VoidB    <- {:type: '' -> 'void' :} '<' TagName Attributes '>'
  
  TagName  <- {:nodeName: Symbol :}
  
  Comment  <- {:nodeName: '' -> '#comment' :} {:text: '<!--' (!'-->' .)* '-->' :}
  
  TextA    <- {:text: [^<]+ :}
  TextB    <- {:text: '<' [^<]+ :}
  
  Attributes <- {:attr: __ {| Attribute* |} __ :}
  Attribute  <- {| {:name: Symbol :} __ (__ '=' __ {:value: String :})? __ |} / !'/>' [^> ]+ __
  String <- '"' {[^"]*} '"' / "'" {[^']*} "'" / {[^"'<>` ]+}
  
  Symbol <- [a-zA-Z0-9_] [a-zA-Z0-9:_-]*
  __     <- %s*
]=], defs)

local reserved_attr = {
  children = true, index = true, nodeName = true, parent = true, text = true, type = true
}

local serialize = nil
local function ser_children(children)
  local t = {}
  for i, v in ipairs(children) do
    t[i] = serialize(v)
  end
  return table.concat(t)
end
local function join_attrs(node)
  local attrs = {}
  for k, v in pairs(node) do
    if not reserved_attr[k] then
      attrs[#attrs + 1] = k .. '="' .. v .. '"'
    end
  end
  return #attrs == 0 and '' or ' ' .. table.concat(attrs, ' ')
end
serialize = function(node, inner)
  if not node.nodeName then
    return node.text or ''
  elseif node.type == 'void' then
    return '<' .. node.nodeName .. join_attrs(node) .. '>'
  elseif node.nodeName:sub(1, 1) == '#' then
    return node.children and ser_children(node.children) or ''
  else
    return '<' .. node.nodeName .. join_attrs(node) .. '>' ..
      ((node.children and node.children[1]) and ser_children(node.children) or node.text or '') ..
      '</' .. node.nodeName .. '>'
  end
end

return {
  parse = function(content)
    return html_parser:match(content)
  end,
  serialize = serialize
}
