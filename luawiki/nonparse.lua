local re = require('lpeg.re')
local block_tags = { 'pre', 'syntaxhighlight', 'graph' }
local inline_tags = { 'nowiki', 'math' }

local global_state = {}

local defs = {
  newline = '\n',
  escape_html = function(content)
    if content then
      return content:gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('&', '&amp;')
    else
      return ''
    end
  end,
  gen_npblock = function(content)
    global_state.npb_index = global_state.npb_index + 1
    global_state.npb_cache[global_state.npb_index] = content
    return '<npb-' .. global_state.npb_index .. '/>'
  end,
  gen_nowiki = function(content)
    global_state.nw_index = global_state.nw_index + 1
    global_state.nw_cache[global_state.nw_index] = content
    return '<nw-' .. global_state.nw_index .. '/>'
  end
}

local np_tags = [=[--lpeg
  article        <- {~ (&[<] (comment / nowiki / np_block / np_inline) / . [^<]*)+ ~}

  comment        <- ('<!--' (!'-->' . [^-]*)* '-->') -> ''
  nowiki         <- ('<nowiki>' (!'</nowiki>' . [^<]*)* -> escape_html
                     '</nowiki>') -> gen_nowiki
  
  np_block       <- (!<%nl '' -> newline)? {~ np_block_start
                    (!np_block_end . [^<]*)* -> escape_html
                    np_block_end ~} -> gen_npblock
  np_block_start <- '<' {:np: np_block_tag :} {(%s [^>]*)? '>'}
  np_block_end   <- '</' (=np) '>'
  
  
  np_inline       <- {~ np_inline_start (!np_inline_end . [^<]*)* -> escape_html
                    np_inline_end ~} -> gen_nowiki
  np_inline_start <- '<' {:nw: np_inline_tag :} (%s [^>]*)? '>'
  np_inline_end   <- '</' (=nw) '>'
  
  np_block_tag   <- 'pre' / 'syntaxhighlight' / 'graph'
  np_inline_tag  <- 'math' / 'score'
]=]

local np_grammar = re.compile(np_tags, defs)

return {
  decorate = function(wiki_state, wikitext)
    global_state = wiki_state
    return np_grammar:match(wikitext) or ''
  end
}
