-- This module implements {{Infobox ...}}
-- removed fixChildBoxes from Wikipedia

local z = {}
local inspect = require('inspect')

local args = {}
local root

local function get_arg_keys(prefix)
  local keys = {}
  local pattern = '^' .. prefix .. '[1-9]%d*$'
  for k in pairs(args) do
    if k:match(pattern) then
      table.insert(keys, k)
    end
  end
  table.sort(keys)
  return keys
end

local function render_title()
  if not args.title then return end
  if type(args.title) == 'string' then
    args.title = { data = args.title }
  end

  root
    :tag('caption')
      :addClass(args.title.titleclass)
      :cssText(args.title.titlestyle)
      :wikitext("'''" .. args.title.data .. "'''")
end

local function render_above_row()
  if not args.above then return end
  if type(args.above) == 'string' then
    args.above = { data = args.above }
  end

  root
    :tag('tr')
      :tag('th')
        :attr('colspan', 2)
        :addClass(args.above.aboveclass)
        :css('text-align', 'center')
        :css('font-size', '125%')
        :css('font-weight', 'bold')
        :cssText(args.above.abovestyle)
        :wikitext(args.above.data)
end

local function render_below_row()
  if not args.below then return end
  if type(args.below) == 'string' then
    args.below = { data = args.below }
  end

  root
    :tag('tr')
      :tag('th')
        :attr('colspan', 2)
        :addClass(args.below.belowclass)
        :css('text-align', 'center')
        :cssText(args.below.belowstyle)
        :wikitext(args.below.data)
end

local function add_row(row_args)
  -- Adds a row to the infobox, with either a header cell
  -- or a label/data cell combination.
  if row_args.header and row_args.header ~= '_BLANK_' then
    root
      :tag('tr')
        :addClass(row_args.rowclass)
        :cssText(row_args.rowstyle)
        :attr('id', row_args.rowid)
        :tag('th')
          :attr('colspan', 2)
          :attr('id', row_args.headerid)
          :addClass(row_args.class)
          :addClass(args.headerclass)
          :css('text-align', 'center')
          :cssText(row_args.headerstyle)
          :cssText(row_args.rowcellstyle)
          :wikitext(row_args.header)
    if row_args.data then
      root:wikitext('[[Category:使用已忽略数据行信息框模板的条目]]')
    end
  elseif row_args.data then
    if not row_args.data:gsub('%[%[%s*[Cc][Aa][Tt][Ee][Gg][Oo][Rr][Yy]%s*:[^]]*]]', ''):match('^%S') then
      row_args.rowstyle = 'display:none'
    end
    local row = root:tag('tr')
    row:addClass(row_args.rowclass)
    row:cssText(row_args.rowstyle)
    row:attr('id', row_args.rowid)
    if row_args.label then
      row
        :tag('th')
          :attr('scope', 'row')
          :css('text-align', 'left')
          :attr('id', row_args.labelid)
          :cssText(row_args.labelstyle)
          :cssText(row_args.rowcellstyle)
          :wikitext(row_args.label)
          :done()
    end

    local dataCell = row:tag('td')
    if not row_args.label then
      dataCell
        :attr('colspan', 2)
        :css('text-align', 'center')
    end
    dataCell
      :attr('id', row_args.dataid)
      :addClass(row_args.class)
      :cssText(row_args.datastyle)
      :cssText(row_args.rowcellstyle)
      :wikitext(row_args.data)
  end
end

local function render_rows()
  local all_rows = get_arg_keys('row')
  for _, v in ipairs(all_rows) do
    local row = args[v]
    row.headerstyle = args.headerstyle
    row.labelstyle = args.labelstyle
    row.datastyle = args.datastyle
    add_row(row)
  end
end

local function render_images()
  if args.image then
    args.image1 = args.image
  end
  local images = get_arg_keys('image')
  for _, v in ipairs(images) do
    local image_data = args[v]
    if type(image_data) == 'string' then
      image_data = { data = image_data }
    end
    local data = mw.html.create():wikitext(image_data.data)
    if image_data.caption then
      data
        :tag('div')
          :cssText(args.captionstyle)
          :wikitext(image_data.caption)
    end
    add_row({
      data = tostring(data),
      datastyle = args.imagestyle,
      class = args.imageclass,
      rowclass = image_data.imagerowclass
    })
  end
end


z.main = function(frame_args)
  args = frame_args[1]
  print(inspect(args))
  if next(args) then
    root = mw.html.create('table')
    root
      :addClass((args.subbox ~= 'yes') and 'infobox' or nil)
      :addClass(args.bodyclass)
      :attr('cellspacing', 3)
      :css('border-spacing', '3px')

      if args.subbox == 'yes' then
        root
          :css('padding', '0')
          :css('border', 'none')
          :css('margin', '-3px')
          :css('width', 'auto')
          :css('min-width', '100%')
          :css('font-size', 'small')
          :css('clear', 'none')
          :css('float', 'none')
          :css('background-color', 'transparent')
      else
        root
          :css('width', '22em')
          :css('text-align', 'left')
          :css('font-size', 'small')
          :css('line-height', '1.5em')
      end
    root:cssText(args.bodystyle)
    
    render_title()
    render_above_row()
  else
    root = mw.html.create()

    root:wikitext(args.title)
  end
  
  render_images()
  render_rows()
  render_below_row()
  return root
end

return z
