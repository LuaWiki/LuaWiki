local z = {}

z.authors = function(args)
  args = args[1]
  args.author1 = args.author1 or args.author
  args.authorlink1 = args.authorlink1 or args.authorlink
  args.first1 = args.first1 or args.first
  args.last1 = args.last1 or args.last
  local res = {}
  for i = 1, 9 do
    local author = ''
    if args['author' .. i] then
      author = args['author' .. i]
    elseif args['last' .. i] then
      if args['first' .. i] then
        author = args['last' .. i] .. ', ' .. args['first' .. i]
      else
        author = args['last' .. i]
      end
    else
      break
    end
    if args['authorlink' .. i] then
      author = '[[' .. args['authorlink' .. i] .. '|' .. author .. ']]'
    end
    res[i] = author
  end
  if next(res) then return table.concat(res, '; ')
  else return nil end
end

return z
