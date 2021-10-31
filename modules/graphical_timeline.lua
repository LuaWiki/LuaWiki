-- Adapted from English Wikipedia
local p = {}

-- =================
-- UTILITY FUNCTIONS
-- =================

-- Default colors for first 28 bars/periods
local defaultColor = {"#6ca","#ff9","#6cf","#c96","#fcc","#9f9","#96c","#cc6","#ccc","#f66","#6c6","#99f","#c66","#f9c",
					  "#396","#ff3","#06c","#963","#c9c","#9c6","#c63","#c96","#999","#c03","#393","#939","#996","#f69"}
			
-- The default width of annotations (in em)		  
local defaultAW = 8
-- Previous version default width (in em)
local oldDefaultAW = 7

-- Function to turn blank arguments back into nil
-- Parameters:
--    s = a string argument
-- Returns
--    if s is empty, turn back into nil (considered false by Lua)
local function ignoreBlank(s)
	if s == "" then
		return nil
	end
	return s
end

-- Function to suppress incorrect CSS values
-- Parameters:
--    val = dimensional value 
--    unit = unit of value
--    nonneg = [bool] value needs to be non-negative
--    formatstr = optional format string
-- Returns:
--    correct string for html, or nil if val is negative
local function checkDim(val, unit, nonneg, formatstr)
	if not val then
		return nil
	end
	val = tonumber(val)
	if not val or (nonneg and val < 0) then
		return nil
	end
	if formatstr then
		return string.format(formatstr,val)..unit
	end
	return val..unit
end

-- function to scan argument list for pattern
-- Parameters:
--   args = an argument dict that will be scanned for one or more patterns
--   patterns = a list of Lua string patters to scan for
--   other = a list of other argument specification lists
--      each element o corresponds to a new argument to produce in the results
--         o[1] = key in new argument list
--         o[2] = prefix of old argument
--         o[3] = suffix of old argument
-- Returns:
--   new argument list that matches patterns specified, with new key names
--
-- This function makes the Lua module scalable, by specifying a list of string patterns that
-- contain relevant arguments for a single graphical element, e.g., "period(%d+)". These
-- patterns should have exactly one capture that returns a number.
--
-- When such a pattern is detected, the number is extracted and then other arguments
-- with the same number is searched for. Thus, if "period57" is detected, other relevant
-- arguments like "period57-text" are searched for and, if non-empty, are copied to the
-- output list with a new argument key. Thus, there is {"text","period","-text"}, and
-- "period(%d+)" detects period57, the code will look for "period57-text" in the input
-- and copy it's value to "text" on the output.
--
-- This function thus pulls all relevant arguments for a single graphical item out, and
-- makes an argument list to call a function to produce a single element (such as a bar or note)
function p._scanArgs(args,patterns,other)
	local result = {}
	for _, p in pairs(patterns) do
		for k, v in pairs(args) do
			local m = tonumber(string.match(k,p))
			-- if there is a matching argument, and it's not blank
			-- and we haven't handled that match yet, then find other
			-- arguments and copy them into output arg list. 
			-- We have to handle blank arguments for backward compatibility with the template
			-- we check for an existing output with item m to save time
			if m and v ~= "" and not result[m] then
				local singleResult = {}
				for _, o in ipairs(other) do
					local foundVal = args[(o[2] or "")..m..(o[3] or "")]
					if foundVal then
						singleResult[o[1]] = foundVal
					end
				end
				-- A hack: for any argument number m, there is a magic list of default
				-- colors. We copy that default color for m into the new argument list, in 
				-- case it's useful. After this, m is discarded
				singleResult.defaultColor = defaultColor[m]
				result[m] = singleResult
			end
		end
	end
	return result
end

-- Function to compute the numeric step in the timescale
-- Parameters:
--   p1, p2 = lower and upper bounds of timescale
-- Returns:
--   round step size that produces ~10 steps between p1 and p2
--
-- Implements [[Template:Calculate increment]], except with a slight tweak:
-- The round value (0.1, 0.2, 0.5, 1.0) is selected based on minimum log
-- distance, so the thresholds are slightly tweaked
function p._calculateIncrement(p1, p2)
	local d = math.abs(p1-p2)
	if d < 1e-10 then
		return 1e-10
	end
	local logd = math.log10(d)
	local n = math.floor(logd)
	local frac = logd-n
	local prevPower = math.pow(10,n-1)
	if frac < 0.5*math.log10(2) then
		return prevPower
	elseif frac < 0.5 then
		return 2*prevPower
	elseif frac < 0.5*math.log10(50) then
		return 5*prevPower
	else
		return 10*prevPower
	end
end

-- Signed power function for squashing timeline to be more readable
function p._signedPow(x,p)
	if x < 0 then
		return -math.pow(-x,p)
	end
	return math.pow(x,p)
end

-- Function to convert from time to location in HTML
-- Arguments:
--   t = time
--   from = earliest time in timeline
--   to = latest time in timeline
--   height = height of timeline (in some units)
--   scaling = method of scaling ('linear' or 'sqrt' or 'pow')
--   power = power law of scaling (if scaling='pow')
function p._scaleTime(t, from, to, height, scaling, power)
	if scaling == 'pow' then
		from = p._signedPow(from,power)
		to = p._signedPow(to,power)
		t = p._signedPow(t,power)
	end
	return height*(to-t)/(to-from)
end

-- Utility function to create HTML container for entire graphical timeline
-- Parameters:
--   container = HTML container for title
--   args = arguments passed to main
--      args["instance-id"] = unique string per Graphical timeline per page
--      args.embedded = is timeline embedded in another infobox?
--      args.align = float of timeline (default=right)
--      args.margin = uniform margin around timeline
--      args.bodyclass = CSS class for whole container
--      args.collapsible = make timeline collapsible
--      args.state = set collapse state
-- Returns;
--   html div object that is root of DOM for graphical timeline
--
--  CSS taken from previous version of [[Template:Grpahical timeline]]
local function createContainer(args)
	args.align = args.align or "right"
	local container = mw.html.create('table')
	container:attr("id","Container"..(args["instance-id"] or ""))
	container:attr("role","presentation")
	container:addClass(args.bodyclass)
	container:addClass("toccolours")
	container:addClass("searchaux")
	if not args.embedded then
		if args.state == "collapsed" then
			args.collapsible = true
			container:addClass("mw-collapsed")
			container:addClass("nomobile")
		elseif args.state == "autocollapse" then
			args.collapsible = true
			container:addClass("autocollapse")
			container:addClass("nomobile")
		end
		if args.collapsible then
			container:addClass("mw-collapsible")
		end
	end
	container:css("text-align","left")
	container:css("padding","0 0.5em")
	container:css("border-style",args.embedded and "none" or "solid")
	if args.embedded then
		container:css("margin","auto")
	else
		container:css("float",args.align)
		if args.align == "right" or args.align == "left" then
			container:css("clear",args.align)
		end
		local margins = {}
		margins[1] = args.margin or "0.3em"
		margins[2] = (args.align == "right" and 0) or args.margin or "1.4em"
		margins[3] = args.margin or "0.8em"
		margins[4] = (args.align == "left" and 0) or args.margin or "1.4em"
		container:css("margin",table.concat(margins," "))
	end
	container:css("overflow","hidden")
	return container
end

-- Utility function to create title for graphical timeline
-- Parameters:
--   args = arguments passed to main
--      args["instance-id"] = unique string per Graphical timeline per page
--      args["title-color"] = background color for title
--      args.title = title of timeline
-- Returns;
--   html div object that is the title
--
--  CSS taken from previous version of [[Template:Grpahical timeline]]
local function createTitle(container,args)
	container:attr("id","Title"..(args["instance-id"] or ""))
	local bottomPadding = args["link-to"] and (not args.embedded) 
	   and (not args.collapsible) and "0" or "1em"
	container:css("padding","1em 1em "..bottomPadding.." 1em")
	local title = container:tag('div')
	title:css("background-color",ignoreBlank(args["title-colour"] or args["title-color"] or "#77bb77"))
	title:css("padding","0 0.2em 0 0.2em")
	title:css("font-weight","bold")
	title:css("text-align","center")
	title:wikitext(args.title)
end

-- navboxHeader removed due to getting frame and expand template

-- ==================
-- TIME AXIS AND BARS
-- ==================

--Function to create HTML time axis on left side of timeline
--Arguments:
--  container = HTML parent object
--  args = arguments passed to main
--    args.from = beginning (earliest) time of timeline
--    args.to = ending (latest) time of timeline
--    args.height = height of timeline
--    args["height-unit"] = unit of height (default args.unit)
--    args.unit = unit of measurement (default em)
--    args["instance-id"] = unique string per Graphical timeline per page
--    args["scale-increment"] = gap between time ticks (default=automatically computed)
--    args.scaling = method of scaling (linear or sqrt, linear by default)
--    args["label-freq"] = frequency of labels (per major tick)
-- Returns;
--   html div object for the time axis
--
--  CSS taken from previous version of [[Template:Grpahical timeline]]
function p._scalemarkers(container,args)
	local height = tonumber(args.height) or 36
	local unit = args["height-unit"] or args.unit or "em"
	container:attr("id","Scale"..(args["instance-id"] or ""))
	container:css("width","4.2em")
	args.computedWidth = args.computedWidth+4.2
	container:css("position","relative")
	container:css("float","left")
	container:css("font-size","100%")
	container:css("height",checkDim(height,unit,true))
    container:css("border-right","1px solid #242020")
	local incr = args["scale-increment"] or p._calculateIncrement(args.from,args.to)
	-- step through by half the desired increment, alternating small and large ticks
	-- put labels every args["label-freq"] large ticks
	local labelFreq = args["label-freq"] or 1
	labelFreq = labelFreq*2 -- account for minor ticks
	local halfIncr = incr/2
	local tIndex = math.ceil(args.from/incr)*2 -- always start on a label
	local toIndex = math.floor(args.to/halfIncr)
	local tickCount = 0
	while tIndex <= toIndex do
		local t = tIndex*halfIncr
		local div = container:tag("div")
		div:css("float","right")
		div:css("position","absolute")
		div:css("right","-1px")
		div:css("top",checkDim(p._scaleTime(t,args.from,args.to,height,args.scaling,args.power),
			                   unit,nil,"%.2f"))
	    div:css("transform","translateY(-50%)")
		local span = div:tag("span")
		span:attr("name",showNum and "Number" or "Tick")
		span:css("font-size","90%")
		span:css("white-space:nowrap")
		local text = ""
		if tickCount%labelFreq == 0 then
			if t < 0 then
				text = string.format("&minus;%g&nbsp;",-t)
			else
			    text = string.format("%g&nbsp;",t)
			end
		end
		if tickCount%2 == 0 then
			text = text.."&mdash;"
		else
			text = text.."&ndash;"
		end
		span:wikitext(text)
		tIndex = tIndex + 1
		tickCount = tickCount + 1
	end
end

-- Function to create timeline container div
-- Arguments:
--   container = HTML parent object
--   args = arguments passed to main
--     args["plot-colour"] = background color for timeline
--     args["instance-id"] = unique string per graphical timeline per page
--     args.height = height of timeline (36 by default)
--     args.width = width of timeline (10 by default)
--     args["height-unit"] = unit of height measurement (args.unit by default)
--     args["width-unit"] = unit of width measurement (args.unit by default)
--     args.unit = unit of measurement (em by default)
-- Returns:
--   timeline HTML object created
local function createTimeline(container,args)
	local color = ignoreBlank(args["plot-colour"] or args["plot-color"])
	container:attr("id","Timeline"..(args["instance-id"] or ""))
	container:addClass("toccolours")
	container:css("position","relative")
	container:css("font-size","100%")
	container:css("width","100%")
	container:css("height",checkDim(args.height or 36,args["height-unit"] or args.unit or "em",true))
	container:css("padding","0px")
	container:css("float","left")
	local width = args.width or 10
	local widthUnit = args["width-unit"] or args.unit or "em"
	container:css("width",checkDim(width,widthUnit,true))
	if widthUnit == "em" then
        args.computedWidth = args.computedWidth+width
	elseif widthUnit == "px" then
	    args.computedWidth = args.computedWidth+width/13.3
	else
		args.computedWidth = args.computedWidth+10
	end
	container:css("border","none")
	container:css("background-color",color)
	return container
end

-- Function to draw single bar (or box)
-- Arguments:
--   container = parent HTML object for bar
--   args = arguments for this box
--     args.text = text to display
--     args.nudgedown = distance to nudge text down (in em)
--     args.nudgeup = distance to nudge text up (in em)
--     args.nudgeright = distance to nudge text right (in em)
--     args.nudgeleft = distance to nudge text left (in em)
--     args.colour = color of bar (default to color assigned to bar number)
--     args.left = fraction of timeline width for left edge of bar (default 0)
--     args.right = fraction of timeline width for right edge of bar (default 1)
--     args.to = beginning (bottom) of bar, in time units (default timeline begin)
--     args.from = end (top) of bar, in time units (default timeline end)
--     args.height = timeline height
--     args.width = timeline width
--     args["height-unit"] = units of timeline height (default args.unit)
--     args["width-unit"] = units of timeline width (default args.unit)
--     args.unit = units for timeline dimensions (default em)
--     args.border-style = CSS style for top/bottom of border (default "solid" if args.border)
function p._singleBar(container,args)
	args.text = args.text or "&nbsp;"
	args.nudgedown = (tonumber(args.nudgedown) or 0) - (tonumber(args.nudgeup) or 0)
	args.nudgeright = (tonumber(args.nudgeright) or 0) - (tonumber(args.nudgeleft) or 0)
	args.colour = args.colour or args.defaultColor
	args.left = tonumber(args.left) or 0
	args.right = tonumber(args.right) or 1
	args.to = tonumber(args.to) or args["tl-to"]
	args.from = tonumber(args.from) or args["tl-from"]
	args.height = tonumber(args.height) or 36
	args.width = tonumber(args.width) or 10
	args["height-unit"] = args["height-unit"] or args.unit or "em"
	args["width-unit"] = args["width-unit"] or args.unit or "em"
	args.border = tonumber(args.border)
	args["border-style"] = args["border-style"] or ((args.border or args["border-colour"]) and "solid") or "none"
	-- the HTML element for the box/bar itself
	local bar = container:tag('div')
	bar:css("font-size","100%")
	bar:css("background-color",ignoreBlank(args.colour or "#aaccff"))
	bar:css("border-width",checkDim(args.border,args["height-unit"],true))
	bar:css("border-color",ignoreBlank(args["border-colour"]))
	bar:css("border-style",args["border-style"].." none")
	bar:css("position","absolute")
	bar:css("text-align","center")
	bar:css("margin","0")
	bar:css("padding","0")
	local bar_top = p._scaleTime(args.to,args["tl-from"],args["tl-to"],args.height,args.scaling,args.power)
    local bar_bottom = p._scaleTime(args.from,args["tl-from"],args["tl-to"],args.height,args.scaling,args.power)
    local bar_height = bar_bottom-bar_top
	bar:css("top",checkDim(bar_top,args["height-unit"],nil,"%.3f"))
	if args["border-style"] ~= "none" and args.border then
		bar_height = bar_height-2*args.border
	end
	bar:css("height",checkDim(bar_height,args["height-unit"],true,"%.3f"))
	bar:css("left",checkDim(args.left*args.width,args["width-unit"],nil,"%.3f"))
	bar:css("width",checkDim((args.right-args.left)*args.width,args["width-unit"],true,"%.3f"))
	-- within the bar, use a div to nudge text away from center
	local textParent = bar
	if not args.alignBoxText then
	    local nudge = bar:tag('div')
	    nudge:css("font-size","100%")
	    nudge:css("position","relative")
	    nudge:css("top",checkDim(args.nudgedown,"em",nil))
	    nudge:css("left",checkDim(args.nudgeright,"em",nil))
	    textParent = nudge
	end
	-- put text div as child of nudge div (if exists)
	local text = textParent:tag('div')
	text:css("position","relative")
	text:css("text-align","center")
	text:css("font-size",ignoreBlank(args.textsize))
	text:css("vertical-align","middle")
	local text_bottom = -0.5*bar_height
	text:css("display","block")
	text:css("bottom",checkDim(text_bottom,args["height-unit"],nil,"%.3f"))
	text:css("transform","translateY(-50%)")
	text:css("z-index","5")
	text:wikitext(ignoreBlank(args.text))
end

-- Function to render all bars/boxes in timeline
-- Arguments:
--   container = parent HTML object
--   args = arguments to main function
--
--  Global (main) arguments are parsed, individual box arguments are picked out
--  and passed to p._singleBar() above
--
--  The function looks for bar*-left, bar*-right, bar*-from, or bar*-to,
--     where * is a string of digits. That string of digits is then used to
--     find corresponding parameters of the individual bar.
--  For example, if bar23-left is found, then bar23-colour turns into local colour,
--     bar23-left turns into local left, bar23-from turns into local from, etc.
function p._bars(container,args)
	local barArgs = p._scanArgs(args,{"^bar(%d+)-left$","^bar(%d+)-right$","^bar(%d+)-from","^bar(%d+)-to"},
		{{"text","bar","-text"},
	     {"textsize","bar","-font-size"},
		 {"nudgedown","bar","-nudge-down"},
		 {"nudgeup","bar","-nudge-up"},
		 {"nudgeright","bar","-nudge-right"},
		 {"nudgeleft","bar","-nudge-left"},
		 {"colour","bar","-colour"},
		 {"colour","bar","-color"},
		 {"border","bar","-border-width"},
		 {"border-colour","bar","-border-colour"},
		 {"border-colour","bar","-border-color"},
		 {"border-style","bar","-border-style"},
		 {"left","bar","-left"},
		 {"right","bar","-right"},
		 {"from","bar","-from"},
		 {"to","bar","-to"}})
    -- The individual bar arguments are placed into the barArgs table
    -- Iterating through barArgs picks out the 
	for _, barg in ipairs(barArgs) do
		-- barg is a table with the local arguments for one bar.
		-- barg needs to have some global arguments copied into it:
		barg["tl-from"] = args.from
		barg["tl-to"] = args.to
		barg.height = args.height
		barg.width = args.width
		barg["height-unit"] = args["height-unit"]
		barg["width-unit"] = args["width-unit"]
		barg.unit = args.unit
		barg.scaling = args.scaling
		barg.power = args.power
		barg.alignBoxText = not args["disable-box-align"]
		-- call _singleBar with the local arguments for one bar
		p._singleBar(container,barg)
	end
end

-- Function to draw a bar corresponding to a geological period
-- Arguments:
--   container = parent HTML object
--   args = global arguments passed to main
--
-- This function is just like _bars(), above, except with defaults for periods:
--    a period bar is triggered by period* (* = string of digits)
--    all other parameters start with "period", not "bar"
--    colour, from, and to parameters default to data from named period
--    text is a wikilink to period article
function p._periods(container,args)
	local periodArgs = p._scanArgs(args,{"^period(%d+)$"},
		{{"text","period","-text"},
		 {"textsize","period","-font-size"},
		 {"period","period"},
		 {"nudgedown","period","-nudge-down"},
		 {"nudgeup","period","-nudge-up"},
		 {"nudgeright","period","-nudge-right"},
		 {"nudgeleft","period","-nudge-left"},
		 {"colour","period","-colour"},
		 {"colour","period","-color"},
		 {"border-width","period","-border-width"},
		 {"border-colour","period","-border-colour"},
		 {"border-colour","period","-border-color"},
		 {"border-style","period","-border-style"},
		 {"left","period","-left"},
		 {"right","period","-right"},
		 {"from","period","-from"},
		 {"to","period","-to"}})
	-- Iterate through period* arguments, translating much like bar* arguments
	-- Supply period defaults to local arguments, also
	for _, parg in ipairs(periodArgs) do
		parg.text = parg.text or ("[["..parg.period.."]]")
		parg.textsize = "90%"
		if tonumber(parg.from) < tonumber(args.from) then
			parg.from = args.from
		end
		if tonumber(parg.to) > tonumber(args.to) then
			parg.to = args.to
		end
		parg["tl-from"] = args.from
		parg["tl-to"] = args.to
		parg.height = args.height
		parg.width = args.width
		parg["height-unit"] = args["height-unit"]
		parg["width-unit"] = args["width-unit"]
		parg.unit = args.unit
		parg.scaling = args.scaling
		parg.power = args.power
		parg.alignBoxText = not args["disable-box-align"]
		p._singleBar(container,parg)
	end
end

-- ===========
-- ANNOTATIONS
-- ===========

-- Function to render a single note (annotation)
-- Arguments:
--    container = parent HTML object
--    args = arguments for this single note
--       args.text = text to display in note
--       args.noarr = bool, true if no arrow should be used
--       args.height = height of timeline
--       args.unit = height units
--       args.at = position of annotation (in time units)
--       args.colour = color of text in note
--       args.textsize = size of text (default 90%)
--       args.nudgeright = nudge text (and arrow) to right (in em)
--       args.nudgeleft = nudge text (and arrow) to left (in em)
--       Following parameters are only applicable to "no arrow" case or when
--       args.alignArrow is false:
--         args.nudgedown = nudge text down (in em)
--         args.nudgeup = nudge text up (in em)
--         args.aw = annotation width (in em)

function p._singleNote(container,args)
	-- Ensure some parameters default to sensible values
	args.height = tonumber(args.height) or 36
	args.at = tonumber(args.at) or 0.5*(args.to+args.from)
	args.colour = args.colour or "black"
	args.aw = tonumber(args.aw)
	          -- if string is centering, use old width to not break it
	          or string.find(args.text,"center",1,true) and oldDefaultAW
	          or defaultAW
	args.textsize = args.textsize or "90%"
	-- Convert 4 nudge arguments to 2 numeric signed nudge dimensions (right, down)
	args.nudgeright = (tonumber(args.nudgeright) or 0)-(tonumber(args.nudgeleft) or 0)
	args.nudgedown = (tonumber(args.nudgedown) or 0)-(tonumber(args.nudgeup) or 0)
	-- Two cases: no arrow, and arrow
	--   For no arrow case, use previous CSS which works well to position text
	if args.noarr then
		-- First, place a bar that pushes annotation down to right spot
		local bar = container:tag('div')
		bar:addClass("annot-bar")
		bar:css("width","auto")
		bar:css("font-size","100%")
		bar:css("position","absolute")
		bar:css("text-align","center")
		bar:css("margin-top",checkDim(p._scaleTime(args.at,args.from,args.to,args.height,args.scaling,args.power),
			                          args.unit,nil,"%.3f"))
		-- Now, nudge the text per nudge dimensions
		local nudge = bar:tag('div')
		nudge:addClass("annot-nudge")
		nudge:css("font-size","100%")
		nudge:css("float","left")
		nudge:css("position","relative")
		nudge:css("text-align","left")
		nudge:css("top",checkDim(args.nudgedown-0.75,"em",nil))
		nudge:css("left",checkDim(args.nudgeright,"em",nil))
		nudge:css("width",checkDim(args.aw,"em",true))
		-- Finally, place a dev for the text
		local text = nudge:tag('div')
		text:css("position","relative")
		text:css("width","auto")
		text:css("z-index","10")
		text:css("font-size",ignoreBlank(args.textsize))
		text:css("color",ignoreBlank(args.colour))
		text:css("vertical-align","middle")
		text:css("line-height","105%")
		text:css("bottom","0")
		text:wikitext(ignoreBlank(args.text))
	else
		-- In the arrow case, previous code didn't correctly line up the text
		-- Now that we're in Lua, it's easy to use a table to hold the arrow against the text
		-- One row: first td is arrow, second td is text
		-- Table gets placed directly using top CSS and absolute position
		local tbl = container:tag('table')
		tbl:attr("role","presentation") -- warn screen readers this table is for layout only
		-- choose a reasonable height for table, then position middle of that height in the timeline
		tbl:css("position","absolute")
		tbl:css("z-index","15")
		local at_location = p._scaleTime(args.at,args.from,args.to,args.height,args.scaling,args.power)
		tbl:css("top",checkDim(at_location,args.unit,nil,"%.3f"))
		tbl:css("left",checkDim(args.nudgeright,"em",nil))
		tbl:css("transform","translateY(-50%)")
		tbl:css("padding","0")
		tbl:css("margin","0")
		tbl:css("font-size","100%")
		local row = tbl:tag('tr')
		local arrowCell = row:tag('td')
		arrowCell:css("padding","0")
		arrowCell:css("text-align","left")
		arrowCell:css("vertical-align","middle")
		local arrowSpan = arrowCell:tag('span')
		arrowSpan:css("color",args.colour)
		arrowSpan:wikitext("&#8592;") --- HTML for left-pointing arrow
		local textCell = row:tag('td')
		textCell:css("padding","0")
		textCell:css("text-align","left")
		textCell:css("vertical-align","middle")
		local textParent = textCell
		-- If disable-arrow-align is true, nudge the text per nudge dimensions:
		if not args.alignArrow then
		  local nudge = textCell:tag('div')
		  nudge:addClass("annot-nudge")
		  nudge:css("font-size","100%")
		  nudge:css("float","left")
		  nudge:css("position","relative")
		  nudge:css("top",checkDim(args.nudgedown,"em",nil))
		  textParent = nudge
		end
		local text = textParent:tag('div')
		text:css("z-index","10")
		text:css("font-size",ignoreBlank(args.textsize))
		text:css("color",ignoreBlank(args.colour))
		text:css("display","block")
		text:css("line-height","105%") --- don't crunch multiple lines of text
		text:css("bottom","0")
		text:wikitext(ignoreBlank(args.text))
	end
end

-- Function to render all annotations in timeline
-- Arguments:
--   container = parent HTML object
--   args = arguments to main function
--
--  Global (main) arguments are parsed, individual box arguments are picked out
--  and passed to p._singleNote() above
--
--  The function looks for note*, where * is a string of digits
--     That string of digits is then used to find corresponding parameters of the individual note.
--  For example, if note23 is found, then note23-colour turns into local colour,
--     note-at turns into local at, note-texdt turns into local text, etc.
--
--  args["annotation-width"] overrides automatically determined width of annotation div
function p._annotations(container,args)
	local noteArgs = p._scanArgs(args,{"^note(%d+)$"},
								{{"text","note"},
								 {"noarr","note","-remove-arrow"},
								 {"noarr","note","-no-arrow"},
								 {"textsize","note","-size"},
								 {"textsize","note","-font-size"},
								 {"nudgedown","note","-nudge-down"},
								 {"nudgeup","note","-nudge-up"},
								 {"nudgeright","note","-nudge-right"},
								 {"nudgeleft","note","-nudge-left"},
								 {"colour","note","-colour"},
								 {"colour","note","-color"},
								 {"at","note","-at"}})
	if #noteArgs == 0 then
		return
	end
	-- a div to hold all of the notes
	local notes= container:tag('td')
	notes:attr("id","Annotations"..(args["instance-id"] or ""))
	notes:css("padding","0")
	notes:css("margin","0.7em 0 0.7em 0")
	notes:css("float","left")
	notes:css("position","relative")
	-- Is there a "real" note? If so, leave room for it
	-- real is: is non-empty and (has arrow or isn't nudged left)
	local realNote = false
	for _, narg in ipairs(noteArgs) do
		local left = (tonumber(narg.nudgeleft) or 0)-(tonumber(narg.nudgeright) or 0)
		if narg.text ~= "" and (not narg.noarr or left <= 0) then
			realNote = true
			args.hasRealNote = true -- record realNote boolean in args for further use
			break
		end
	end
	-- width of notes holder depends on whethere there are any "real" notes
	-- width can be overriden
	local aw = tonumber(args["annotations-width"]) or (realNote and defaultAW) or 0
	aw = aw+2.25
	notes:css("width",checkDim(aw,"em",true))
	args.computedWidth = args.computedWidth+aw
	local height = tonumber(args.height) or 36
	local unit = args["height-unit"] or args.unit or "em"
	notes:css("height",checkDim(height,unit,true))
	for _, narg in ipairs(noteArgs) do
		--- copy required global parameters to local note args
		narg.from = args.from
		narg.to = args.to
		narg.height = args.height
		narg.unit = args["height-unit"] or args["width-unit"] or "em"
		narg.aw = args["annotations-width"]
		narg.alignArrow = not args["disable-arrow-align"]
		narg.scaling = args.scaling
		narg.power = args.power
		p._singleNote(notes,narg)
	end
end

--  ====================
--  LEGENDS AND CAPTIONS
--  ====================

-- Function to render a single legend (below the timeline)
-- Arguments:
--   container = parent HTML object
--   args = argument table for this legend
--     args.colour = color to show in square
--     args.text = text that describes color
function p._singleLegend(container,args)
	if not args.text then  -- if no text, not a sensible legend
		return
	end
	args.colour = args.colour or args.defaultColor or "transparent"
	local row = container:tag('tr')
	local squareCell = row:tag('td')
	squareCell:css("padding",0)
	local square = squareCell:tag('span')
	square:css("background",ignoreBlank(args.colour))
	square:css("padding","0em .1em")
	square:css("border","solid 1px #242020")
	square:css("height","1.5em")
	square:css("width","1.5em")
	square:css("margin",".25em .9em .25em .25em")
	square:wikitext("&emsp;")
	local textCell = row:tag('td')
	textCell:css("padding",0)
	local text = textCell:tag('div')
	text:wikitext(args.text)
end

function p._legends(container,args)
	local legendArgs = p._scanArgs(args,{"^legend(%d+)$"},
		{{"text","legend"},
		 {"colour","bar","-colour"},
		 {"colour","bar","-color"},
		 {"colour","legend","-colour"},
		 {"colour","legend","-color"}
		 })
	if #legendArgs == 0 then
		return
	end
	local legendRow = container:tag('tr')
	local legendCell = container:tag('td')
    legendCell:attr("id","Legend"..(args["instance-id"] or ""))
	legendCell:attr("colspan",3)
	legendCell:css("padding","0 0.2em 0.7em 1em")
	local legend = legendCell:tag('table')
	legend:attr("id","Legend"..(args["instance-id"] or ""))
    legend:attr("role","presentation")
    legend:addClass("toccolours")
	legend:css("margin-left","3.1em")
	legend:css("border-style","none")
	legend:css("float","left")
	legend:css("clear","both")
	for _,larg in ipairs(legendArgs) do
		p._singleLegend(legend,larg)
	end
end

local helpString = [=[

----

'''Usage instructions'''

----

Copy the text below, adding multiple bars, legends and notes as required.
<br>Comments, enclosed in <code><!-</code><code>- -</code><code>-></code>, should be removed.

Remember:
* You must use <code>{</code><code>{!}</code><code>}</code> wherever you want a {{!}} to be
: rendered in the timeline
* Large borders will displace bars in many browsers
* Text should not be wider than its containing bar,
: as this may cause compatibility issues
* Units default to [[em (typography){{!}}em]], the height and width of an 'M'.

See {{tl|Graphical timeline}} for full documentation.

{{Graphical timeline/blank}}}}]=]

local function createCaption(container,args)
	local captionRow = container:tag("tr")
	local captionCell = captionRow:tag("td")
    captionCell:attr("id","Caption"..(args["instance-id"] or ""))
	captionCell:attr("colspan",3)
	captionCell:css("padding","0")
	captionCell:css("margin","0 0.2em 0.7em 0.2em")
	local caption = captionCell:tag("div")
	caption:attr("id","Caption"..(args["instance-id"] or ""))
	caption:addClass("toccolours")
	if args.embedded then
		caption:css("margin","0 auto")
		caption:css("float","left")
	else
		caption:css("margin","0 0.5em")
	end
	caption:css("border-style","none")
	caption:css("clear","both")
	caption:css("text-align","center")
	local widthUnit = args["width-unit"] or args.unit or "em"
	local aw = tonumber(args["annotations-width"]) or (args.hasRealNote and defaultAW) or -0.25
	aw = aw+5+((widthUnit == "em" and tonumber(args.width)) or 10)
	if aw > args.computedWidth then
		args.computedWidth = aw
	end
	caption:css("width",checkDim(aw,"em",true))
	caption:wikitext((args.caption or "")..((args.help and args.help ~= "off" and helpString) or ""))
end

function p._main(args)
	-- For backward compatibility with template, all empty arguments are accepted.
	-- But, for some parameters, empty will cause a Lua error, so for those, we convert
	-- empty to nil.
	for _, attr in pairs({"title","link-to","embedded","align","margin",
		"height","width","unit","height-unit","width-unit","scale-increment",
		"annotations-width","disable-arrow-align","disable-box-align","from","to"}) do
		args[attr] = ignoreBlank(args[attr])
	end
	-- Check that to > from, and that they're both defined
	local from = tonumber(args.from) or 0
	local to = tonumber(args.to) or 0
	if from > to then
		args.from = to
		args.to = from
	else
		args.from = from
		args.to = to
	end
	if args.scaling == 'sqrt' then
		args.scaling = 'pow'
		args.power = 0.5
	end
	if args.scaling == 'pow' then
		args.power = args.power or 0.5
	end
	args.computedWidth = 1.7
	-- Create container table
	local container = createContainer(args)
	-- TITLE
	if args.title and not args.embedded then
		local titleRow = container:tag('tr')
		local titleCell = titleRow:tag('td')
		titleCell:attr("colspan",3)
		createTitle(titleCell,args)
	end
	-- NAVBOX HEADER
	-- if args["link-to"] and not args.embedded then
	-- 	local navboxRow = container:tag('tr')
	-- 	local navboxCell = navboxRow:tag('td')
	-- 	navboxCell:attr("colspan",3)
	-- 	navboxHeader(navboxCell,args)
	-- end
	local centralRow = container:tag('tr')
	centralRow:css("vertical-align","top")
	-- SCALEBAR
	local scaleCell = centralRow:tag('td')
	scaleCell:css("padding","0")
	scaleCell:css("margin","0.7em 0 0.7em 0")
	p._scalemarkers(scaleCell,args)
	-- TIMELINE
	local timelineCell = centralRow:tag('td')
	timelineCell:css("padding","0")
	timelineCell:css("margin","0.7em 0 0.7em 0")
	local timeline = createTimeline(timelineCell,args)
	-- PERIODS
	p._periods(timeline,args)
	-- BARS
	p._bars(timeline,args)
	-- ANNOTATIONS
	p._annotations(centralRow,args)
	-- LEGEND
	p._legends(container,args)
	-- CAPTION
	createCaption(container,args)
	container:css("min-width",checkDim(args.computedWidth,"em"))
	return container
end

function p.main(frame)
	local args = frame[1]
	return tostring(p._main(args):allDone())
end

return p
