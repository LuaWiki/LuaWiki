local re = require('lpeg.re')
local html_utils = require('utils/html_utils')
local inspect = require('inspect')

local extlink_counter = 0
local global_state = {}

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

local function getFilePath(filename, width)
  if not ngx then return '' end
  local md5hash = ngx.md5(filename)
  if width then
    local file_ext = ''
    if not filename:match('[.]png') and not filename:match('[.]jpg') then
      file_ext = '.png'
    end
    return 'https://upload.wikimedia.org/wikipedia/commons/thumb/' .. md5hash:sub(1,1) .. '/' .. md5hash:sub(1,2)
      .. '/' .. filename .. '/' .. width .. '-' ..filename .. file_ext
  else
    return 'https://upload.wikimedia.org/wikipedia/commons/' .. md5hash:sub(1,1) .. '/' .. md5hash:sub(1,2)
      .. '/' .. filename
  end
end

local wiki_grammar = nil
local last_p = re.compile[=[--lpeg
  all <- {~ s ~}
  s <- ('<p>' { (!'</p>' .)* } '</p>' !.) -> '%1'
        / . [^<]* s 
]=]

local function parse_inside(a)
  local inner_html = wiki_grammar:match( (a:gsub('[^\n]$', '%0\n')) )
  if not inner_html then return '' end
  local str = inner_html:gsub('^<p>(.-)</p>', '%1')
  return last_p:match(str) or str
end

local defs = {
  cr = lpeg.P('\r'),
  t  = lpeg.P('\t'),
  eb = lpeg.P(']'),
  escape_html = html_utils.escape_html,
  merge_text = function(a, b) return a .. b end,
  fast_merge = function(t) return table.concat(t) end,
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
    local h_text = v[1]:gsub('^[ ]*', ''):gsub('[ ]*$', '')
    return '<' .. htag .. ' id="' .. h_text ..  '">' .. h_text ..
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
      return s .. '[' .. extlink_counter .. ']</a>'
    end
  end,
  gen_file = function(t)
    local prefix = ''
    local suffix = ''
    local loc_class = ''
    if t.loc == 'right' or t.loc == '右' then
      loc_class = ' tright'
    elseif t.loc == 'left' or t.loc == '左' then
      loc_class = ' tleft'
    elseif t.loc == 'center' then
      -- do nothing
    elseif t.type == 'thumb' or t.type == '缩略图' then
      loc_class = ' tright'
    end
    if t.type then
      if not t.size then t.size = '220px' end
      if t.type == 'thumb' or t.type == '缩略图' then
        local size_num = t.size:match('^(%d+)') or 220
        prefix = '<div class="thumbinner' .. loc_class .. '" style="width:' ..
          (size_num + 2) .. 'px">'
        if t.caption then
          suffix = suffix .. '<div class="thumbcaption">' .. t.caption .. '</div>'
        end
        suffix = suffix .. '</div>'
      end
    end
    
    t.height = ''
    if t.size then
      if t.size == 'upright' then
        t.size = '220px'
      elseif t.size:sub(1,1) == 'x' then
        t.height = ' height="' .. t.size:sub(2) .. '"'
        t.size = t.size:gsub('x(%d+)px', function(p1) return 2*tonumber(p1) .. 'px' end)
      end
    end
    
    local filepath = getFilePath(t[1]:sub(1, 1):upper() .. t[1]:sub(2):gsub(' +$', ''):gsub(' ', '_'), t.size and t.size:gsub('x%d.*$', ''))
    return prefix .. '<img src="' .. filepath .. '" ' .. (t.alt and ('alt="' .. t.alt .. '"') or '') .. t.height .. '>' .. suffix
  end,
  gen_th = function(t)
    return '<th ' .. (t.attr and t.attr:gsub('%s$', '') or '') .. '>'
      .. (t[1] or '') .. '</th>'
  end,
  gen_td = function(t)
    return '<td ' .. (t.attr and t.attr:gsub('%s$', '') or '') .. '>'
      .. (t[1] or '') .. '</td>'
  end,
  gen_tr = function(t)
    return '<tr ' .. (t.attr and t.attr:gsub('%s$', '') or '') .. '>'
      .. (t[1] or '') .. '</tr>'
  end,
  gen_tb_caption = function(t)
    return '<caption ' .. (t.attr and t.attr:gsub('%s$', '') or '') .. '>'
      .. t[1] .. '</caption>'
  end,
  gen_table = function(t)
    return '<table ' .. (t.attr and t.attr:gsub('%s$', '') or '') .. '>'
      .. (t.caption or '') .. '<tbody>' .. table.concat(t) .. '</tbody>'
      .. '</table>'
  end,
  parse_inside = parse_inside,
  gen_block_html = function(t)
    local str = '<' .. t[1] .. t[2] .. (t[3] or '') ..
      '</' .. t[1] .. '>'
    if t[1] == 'references' then
      str = '<div>' .. str .. '</div>'
    end
    return str
  end,
  decide_f_caption = function(s, i, p)
    local next_char = s:sub(i, i)
    if next_char == '|' then return true end
    if s:sub(i, i+1) == ']]' then return true, parse_inside(p) end
  end,
  extract_npb = function(i) return global_state.npb_cache[tonumber(i)] end,
  extract_nw = function(i) return global_state.nw_cache[tonumber(i)] end
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

defs.table = re.compile([=[--lpeg
  table         <- {| '{|' table_attr? (%nl __ table_caption)? ((table_row1) (%nl %s* table_row)*)?
                    __ %nl %s* '|}' |} -> gen_table
  table_caption <- '|+' {:caption: {| (__ cell_attr)? __ [^%nl]+ -> parse_inside |} -> gen_tb_caption :}
  table_row1    <- {| (%nl %s* '|-' (__ table_attr)? __)? tb_row_core |} -> gen_tr
  table_row     <- '|-' ({| (__ table_attr)? __ tb_row_core |} -> gen_tr / [^%nl]*)
  tb_row_core   <- (%nl %s* (th_line / td_line) )+ ~> merge_text
  th_line       <- '!' header_cell (__ ('!!' / '||') __ header_cell)*
  td_line       <- '|' ![}-] data_cell   (__ '||' __ data_cell)*
  header_cell   <- {| th_attr? th_inline -> parse_inside |} -> gen_th
  data_cell     <- {| cell_attr? td_inline -> parse_inside |} -> gen_td
  th_inline     <- {(!'!!' !'||' ([^%nl] / %nl '<'))* ( &'!!' / &'||' / tb_restlines )}
  td_inline     <- {(!'||' ([^%nl] / %nl '<'))*       ( &'||' / tb_restlines )}
  tb_restlines  <- ( %nl __ ![|!] [^%nl]* )*
  table_attr    <- {:attr: [^%nl]+ :}
  cell_attr     <- {:attr: (!'[[' [^|%nl] [^|[%nl]*)* :} '|' !'|'
  th_attr       <- {:attr: (!'!!' !'[[' [^|%nl] [^|![%nl]*)* :} '|' !'|'
  
  __            <- [ %t]*
]=], defs)

-- general formatted text

defs.plain_text = re.compile([=[--lpeg
  plain_text     <- (inline_element / {[^%cr%nl'] ("'"? [^%cr%nl[<']+)*})+
  inline_element <- np_inline / ref_inline / file_link / internal_link / external_link
  
  np_inline      <- '<nw-' %d+ -> extract_nw '/>'
  ref_inline     <- {~ '<ref' (' ' [^>]*)? (<'/' '>' / '>' (!'</ref>' .)* -> parse_inside {'</ref>'}) ~}
  
  internal_link  <- ('[[' {link_part} ('|' (!']]' . [^%eb]*)+ $> ld_formatted)? ']]') -> gen_link
  external_link  <- ('[' { 'http' 's'? '://' [^ %t%eb]+ } ([ %t]+ [^%cr%nl%eb]+ $> ld_formatted)? ']') -> gen_extlink

  file_link      <- {| '[[' ([Ff] 'ile' / [Ii] 'mage') ':' {link_part} ('|' (f_type / f_border 
                      / f_location / f_align / f_size / f_link / f_alt
                      / f_caption))* ']]' |} -> gen_file
  f_type         <- {:type: 'thumb' / 'frameless' / 'frame' / '缩略图' :}
  f_border       <- {:border: 'border' :}
  f_location     <- {:loc: 'right' / 'left' / 'center' / 'none' / '右' / '左' :}
  f_align        <- {:align: 'baseline' / 'middle' / 'sub' / 'super' / 'text-top' / 'text-bottom' / 'top' / 'bottom' :}
  f_size         <- {:size: {'upright'} ('=' [^|]*)? / %d+ 'px' ('x' (%d+ 'px'))? / 'x' %d+ 'px' :}
  f_link         <- 'link=' {:link: 'http' 's'? '://' [^ %t%eb]+ :}
  f_alt          <- 'alt=' {:alt: [^|%eb]* :}
  
  f_fake_link    <- '[[' (!']]' . [^%eb]*)* ']]'
  f_fake_table   <- '{|' (!'|}' . [^|]*)* '|}'
  f_caption      <- {:caption: { ( f_fake_link / f_fake_table / !']]' [^|] )* } => decide_f_caption :}
  
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
  formatted      <- {| ((&{"'"+} => eat_ticks)? (bold_text / italic_text / {"'"} %plain_text? / %plain_text))+ |} -> fast_merge
  bold_text      <- "'''" ( (!"'''" [^%cr%nl] [^'%cr%nl]*)+ "'"^-5 ) $> bold_body    ("'''"/ &[%cr%nl])
  italic_text    <- "''"  ( (!"''"  [^%cr%nl] [^'%cr%nl]*)+ "'"^-5 ) $> italic_body  ("''"/ &[%cr%nl])
]=], defs)

-- General Parsing
-- note: '<' [btdh] stand for blockquote, table, div and h1-h7
wiki_grammar = re.compile([=[--lpeg
  article        <- {| block+ |} -> fast_merge
  block          <- sol? (block_html / special_block / paragraph_plus)
  paragraph_plus <- {| (newline / pline) latter_plines? |} -> gen_par_plus
  latter_plines  <- {:html: block_html :} / {:special: special_block :} /
                    pline ((![-={<*#:;] / &('<' [^btdh])) pline)* latter_plines?
  pline          <- (%formatted newline -> ' ') ~> merge_text
  special_block  <- &[-={*#:;] (horizontal_rule / heading / list_block / %table) newline?
  block_html     <- &[<] '<npb-' {%d+} -> extract_npb '/>'
                    / {| bhtml_start bhtml_body -> parse_inside bhtml_end |} -> gen_block_html
  bhtml_body     <- (!bhtml_end . [^<]*)*
  bhtml_start    <- '<' {bhtml_tags} ' data-lw="' {:lw: %a+ :} '"' {[^<>]* '>'}
  bhtml_end      <- '</' bhtml_tags ' data-lw="' (=lw) '"' '>'
  bhtml_tags     <- 'blockquote' /'table' / 'div' / 'h' [1-7] / 'references'

  horizontal_rule <- ('-'^+4 -> '<hr>' (%formatted -> '<p>%1</p>')?) ~> merge_text
  heading        <- {| heading_tag {[^=]+} =htag [ %t]* |} -> gen_heading
  heading_tag    <- {:htag: '=' '='^-6 :}
  list_block     <- {| list_item (newline list_item)* |} -> gen_list
  list_item      <- {| {[*#:;]+} __ (%formatted / {''}) |}

  sol            <- __ newline
  __             <- [ %t]*
  newline        <- %cr? %nl
]=], defs)

local sanitize = require('core/sanitizer').sanitize

return {
  parse = function(wiki_state, wikitext)
    extlink_counter = 0
    global_state = wiki_state
    return wiki_grammar:match(
      sanitize(wikitext:gsub('\n[ \t]\n', '\n\n'))
    ) or ''
  end
}
