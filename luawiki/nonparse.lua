local re = require('lpeg.re')
local block_tags = { 'pre', 'syntaxhighlight', 'graph' }
local inline_tags = { 'nowiki', 'math' }

--  np_block_tag   <- _block_tags_
--  np_inline_tag  <- _inline_tags_

local defs = {
  npb_open = '\n<npblock>',
  escape_html = function(content)
    if content then
      return content:gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('&', '&amp;')
    else
      return ''
    end
  end
}

local np_tags = [=[--lpeg
  article        <- {~ (&[<] (np_block / np_inline) / . [^<]*)+ ~}
  np_block       <- %nl? -> npb_open np_block_start
                    (!np_block_end . [^<]*)* -> escape_html
                    np_block_end '' -> '</npblock>'
  np_block_start <- '<' {:np: np_block_tag :} {(%s [^>]*)? '>'}
  np_block_end   <- '</' (=np) '>'
  
  np_inline       <- '' -> '<nowiki>' np_inline_start
                    (!np_inline_end . [^<]*)* -> escape_html
                    np_inline_end '' -> '</nowiki>'
  np_inline_start <- '<' {:np: np_inline_tag :} (%s [^>]*)? '>'
  np_inline_end   <- '</' (=np) '>'
  
  np_block_tag   <- 'pre' / 'syntaxhighlight' / 'graph'
  np_inline_tag  <- 'math' / 'score'
]=]

local np_grammar = re.compile(np_tags, defs)

return {
  decorate = function(wikitext)
    return np_grammar:match(wikitext) or ''
  end
}
