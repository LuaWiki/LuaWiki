--------------------------------------------------------------------------------
--                              Module:Hatnote                                --
--                                                                            --
-- This module produces hatnote links and links to related articles. It       --
-- implements the {{hatnote}} and {{format link}} meta-templates and includes --
-- helper functions for other Lua hatnote modules.                            --
--------------------------------------------------------------------------------

local p = {}
--------------------------------------------------------------------------------
-- Hatnote 顶注
--
-- Produces standard hatnote text. Implements the {{hatnote}} template.
-- 产生标准顶注文字。实现{{hatnote}}模板
--------------------------------------------------------------------------------

function p.main(args)
	local s = args[1]
	local options = {}
	if not s then
		error('text参数缺失')
	end
	options.extraclasses = args.extraclasses
	options.selfref = args.selfref
	return p._hatnote(s, options)
end

function p._hatnote(s, options)
	options = options or {}
	local classes = {'hatnote', 'navigation-not-searchable'}
	local extraclasses = options.extraclasses
	local selfref = options.selfref
	if type(extraclasses) == 'string' then
		classes[#classes + 1] = extraclasses
	end
	if selfref then
		classes[#classes + 1] = 'selfref'
	end
	return string.format(
		'<div role="note" class="%s">%s</div>',
		table.concat(classes, ' '),
		s
	)
end

return p