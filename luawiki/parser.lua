local re = require('lpeg.re')

local extlink_counter = 0

local list_marks = {
  ['*'] = {'ul','li'},
  ['#'] = {'ol','li'},
  [':'] = {'dl','dd'},
  [';'] = {'dl','dt'}
}

-- fetch_list_node does a very simple thing
-- it returns a last children of the node
-- whose tag is the given tag;
-- if the last children is not that tag
-- create one and return that tag
local function fetch_list_node(node, tag)
  local len = #node
  if node[len] and node[len].tag == tag then
    node = node[len]
  else
    local new_node = { tag = tag }
    node[len + 1] = new_node
    node = new_node
  end
  return node
end

-- otter_html generates HTML from a DOM tree
-- (represented by its root node)
-- a tree node is in form { tag: 'xxx', #1, #2, #3, ... }
-- the function simulates outerHTML in browser DOM
local function otter_html(node)
  local str = ''
  for _, v in ipairs(node) do
    if type(v) == 'table' then str = str .. otter_html(v)
    else str = str .. v end
  end
  if node.tag then
    str = '<' .. node.tag .. '>' .. str ..
      '</' .. node.tag .. '>'
  end
  return str
end

local wiki_grammar = nil

local defs = {
  cr = lpeg.P('\r'),
  t  = lpeg.P('\t'),
  eb = lpeg.P(']'),
  merge_text = function(a, b) return a .. b end,
  eat_ticks = function(s, i, ticks)
    local len = #ticks
    if len > 5 then
      return i + len - 5, ticks:sub(len-5)
    end
    return true
  end,
  rep_newline = function(s)
    return s:gsub('%s+', ' ')
  end,
  gen_heading = function(v)
    local htag = 'h' .. #v.htag
    return '<' .. htag .. '>' .. v[1]:gsub('^[ ]*', ''):gsub('[ ]*$', '') ..
      '</' .. htag .. '>'
  end,
  -- t is formatted in form { { '#:', '123' }, { '###', '456' } }
  -- and gen_list iterates the list, to create a tree structure
  -- which could be expanded by otter_html at last
  gen_list = function(t)
    local dom_tree = {}
    for _, v in ipairs(t) do
      -- let's start from the root node
      local pnode = dom_tree
      -- first we process all marks except the last one
      local pstr = v[1]:sub(1,-2)
      for c in string.gmatch(pstr, '.') do
        local tags = list_marks[c]
        -- pnode actually increases level when fetched node
        -- is assigned to it
        pnode = fetch_list_node(pnode, tags[1])
        pnode = fetch_list_node(pnode, tags[2])
      end
      -- now we process the last mark
      local ostr = v[1]:sub(-1)
      local tags = list_marks[ostr]
      pnode = fetch_list_node(pnode, tags[1])
      -- this pnode is where we could add our innermost node
      -- with prepared content in v[2]
      pnode[#pnode + 1] = { tag = tags[2], v[2] }
    end
    return otter_html(dom_tree)
  end,
  gen_par_plus = function(t)
    local p_content = table.concat(t)
    if p_content == '' then p_content = '<br>' end
    local str = '<p>' .. p_content .. '</p>'
    if t.html then str = str .. t.html end
    if t.special then str = str .. t.special end
    return str
  end,
  gen_link = function(a, b)
    local href = nil
    if a:sub(1, 1) == '#' then href = a
    else href = '/wiki/' ..a end
    local s = '<a title="' .. a .. '" href="' .. href:gsub(' ', '_') .. '">'
    if b then return s .. b .. '</a>'
    else return s .. a .. '</a>' end
  end,
  gen_extlink = function(a, b)
    local s = '<a class="external" href="' .. a .. '">'
    if b then return s .. b .. '</a>'
    else
      extlink_counter = extlink_counter + 1
      return s .. extlink_counter .. '</a>'
    end
  end,
  parse_inside = function(a)
    local inner_html = wiki_grammar:match(a:gsub('\n?$', '\n'))
    return inner_html:gsub('^<p>(.-)</p>', '%1'):gsub('<p>(.-)</p>$', '%1')
  end,
  gen_block_html = function(t)
    return '<' .. t[1] .. t[2] .. (t[3] or '') ..
      '</' .. t[1] .. '>'
  end
}

-- formatted text in link

defs.plain_text = re.compile([=[--lpeg
  ( [^'] ("'"? [^']+)* ) -> rep_newline
]=], defs)

defs.bold_body = re.compile([=[--lpeg
  bold_body      <- ((it_in_b / %plain_text) (it_in_b /  {"'"}? %plain_text)*) ~> merge_text -> '<b>%1</b>'
  it_in_b        <- ("''" !"'" %plain_text "''") -> '<i>%1</i>'
]=], defs)

defs.italic_body = re.compile([=[--lpeg
  italic_body    <- ((b_in_it / %plain_text) (b_in_it / {"'"}? %plain_text)*) ~> merge_text -> '<i>%1</i>'
  b_in_it        <- ("'''" !"'" %plain_text "'''") -> '<b>%1</b>'
]=], defs)

defs.ld_formatted = re.compile([=[--lpeg
  formatted      <- ((&{"'"+} => eat_ticks)? (bold_text / italic_text / {"'"} %plain_text? / %plain_text))+ ~> merge_text
  bold_text      <- "'''" ( (!"'''" . [^']*)+ "'"^-5 ) $> bold_body    ("'''"/ !.)
  italic_text    <- "''"  ( (!"''"  . [^']*)+ "'"^-5 ) $> italic_body  ("''"/ !.)
]=], defs)

-- general formatted text

defs.plain_text = re.compile([=[--lpeg
  plain_text     <- (inline_element / {[^%cr%nl'] ("'"? [^%cr%nl[<']+)*})+
  inline_element <- np_inline / internal_link / external_link
  
  np_inline      <- '<nowiki>' {(!'</nowiki>' . [^<]*)*} '</nowiki>'
  
  internal_link  <- ('[[' {link_part} ('|' (!']]' . [^%eb]*)+ $> ld_formatted)? ']]') -> gen_link
  external_link  <- ('[' { 'http' 's'? '://' [^ %t%eb]+ } ([ %t]+ [^%cr%nl%eb]+ $> ld_formatted)? ']') -> gen_extlink
  link_part      <- [^|[%eb]+
]=], defs)

defs.bold_body = re.compile([=[--lpeg
  bold_body      <- ((it_in_b / %plain_text) (it_in_b /  {"'"}? %plain_text)*) ~> merge_text -> '<b>%1</b>'
  it_in_b        <- ("''" !"'" %plain_text "''") -> '<i>%1</i>'
]=], defs)

defs.italic_body = re.compile([=[--lpeg
  italic_body    <- ((b_in_it / %plain_text) (b_in_it / {"'"}? %plain_text)*) ~> merge_text -> '<i>%1</i>'
  b_in_it        <- ("'''" !"'" %plain_text "'''") -> '<b>%1</b>'
]=], defs)

defs.formatted = re.compile([=[--lpeg
  formatted      <- ((&{"'"+} => eat_ticks)? (bold_text / italic_text / {"'"} %plain_text? / %plain_text))+ ~> merge_text
  bold_text      <- "'''" ( (!"'''" [^%cr%nl] [^'%cr%nl]*)+ "'"^-5 ) $> bold_body    ("'''"/ &[%cr%nl])
  italic_text    <- "''"  ( (!"''"  [^%cr%nl] [^'%cr%nl]*)+ "'"^-5 ) $> italic_body  ("''"/ &[%cr%nl])
]=], defs)

-- General Parsing
wiki_grammar = re.compile([=[--lpeg
  article        <- (block+) ~> merge_text
  block          <- sol? (block_html / special_block / paragraph_plus)
  paragraph_plus <- {| (newline / pline) latter_plines? |} -> gen_par_plus
  latter_plines  <- {:html: block_html :} / {:special: special_block :} /
                    pline (![-={*#:;] pline)* latter_plines?
  pline          <- (%formatted newline -> ' ') ~> merge_text
  special_block  <- &[-={*#:;] (horizontal_rule / heading / list_block / table) newline?
  block_html     <- &[<] '<npblock>' {(!'</npblock>' . [^<]*)*} '</npblock>'
                    / {| bhtml_start bhtml_body -> parse_inside bhtml_end |} -> gen_block_html
  bhtml_body     <- (!bhtml_end . [^<]*)*
  bhtml_start    <- '<' {bhtml_tags} ' data-lw="' {:lw: %a+ :} '"' {[^<>]* '>'}
  bhtml_end      <- '</' bhtml_tags ' data-lw="' (=lw) '"' '>'
  bhtml_tags     <- 'blockquote' /'table' / 'div' / 'h' [1-7]

  horizontal_rule <- ('-'^+4 -> '<hr>' (%formatted -> '<p>%1</p>')?) ~> merge_text
  heading        <- {| heading_tag {[^=]+} =htag [ %t]* |} -> gen_heading
  heading_tag    <- {:htag: '=' '='^-6 :}
  list_block     <- {| list_item (newline list_item)* |} -> gen_list
  list_item      <- {| {[*#:;]+} __ (%formatted / {''}) |}
  table          <- { '{|' (!'|}' .)* '|}' }

  sol            <- __ newline
  __             <- [ %t]*
  newline        <- %cr? %nl
]=], defs)

local sanitize = require('sanitizer').sanitize

return {
  parse = function(wikitext)
    extlink_counter = 0
    return wiki_grammar:match(
      sanitize(wikitext:gsub('\n[ \t]\n', '\n\n'))
    )
  end
}
