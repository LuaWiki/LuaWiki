local _M = {}

_M.nonparse = require("core/nonparse")
_M.parser = require("core/parser")
_M.preprocessor = require("core/preprocessor")

_M.html_stag_map = {}
_M.html_single_tags = {
    'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'keygen',
    'link', 'meta', 'param', 'source', 'track', 'wbr'
}
for _, v in ipairs(_M.html_single_tags) do
    _M.html_stag_map[v] = true
end

---fromWikiFile, without title
---@param location string
function _M.fromWikiFileWithoutTitle(location)
    return _M.fromWikiTextWithoutTitle(io.open(location):read("*a"))
end

---fromWikiFile
---@param title string
---@param location string
function _M.fromWikiFile(title, location)
    return _M.fromWikiText(title, io.open(location):read("*a"))
end

---parse, without title
---@param wikitext string
---@return string
function _M.fromWikiTextWithoutTitle(wikitext)
    local wiki_state = {
        title = "",
        npb_index = 0,
        nw_index = 0,
        npb_cache = {},
        nw_cache = {}
    }
    wikitext = _M.nonparse.decorate(wiki_state, wikitext)
    local preprocessor = _M.preprocessor.new(wiki_state)
    wikitext = preprocessor:process(wikitext)
    local wiki_html = _M.parser.parse(wiki_state, wikitext)
    return "" .. wiki_html:gsub('<((%a+)[^>]-)/>', function(p1, p2)
        if not html_stag_map[p2] then
            if p2 == 'references' then
                return '<div><' .. p1 .. '></' .. p2 .. '></div>'
            else
                return '<' .. p1 .. '></' .. p2 .. '>'
            end
        end
    end)
end

---parse
---@param title string
---@param wikitext string
---@return string
function _M.fromWikiText(title, wikitext)
    local wiki_state = {
        title = title,
        npb_index = 0,
        nw_index = 0,
        npb_cache = {},
        nw_cache = {}
    }
    wikitext = _M.nonparse.decorate(wiki_state, wikitext)
    local preprocessor = _M.preprocessor.new(wiki_state)
    wikitext = preprocessor:process(wikitext)
    local wiki_html = _M.parser.parse(wiki_state, wikitext)
    return wiki_html:gsub('<((%a+)[^>]-)/>', function(p1, p2)
        if not html_stag_map[p2] then
            if p2 == 'references' then
                return '<div><' .. p1 .. '></' .. p2 .. '></div>'
            else
                return '<' .. p1 .. '></' .. p2 .. '>'
            end
        end
    end)
end

return _M
