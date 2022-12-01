local romans = {
  {1000, "m"},
  {900, "cm"}, {500, "d"}, {400, "cd"}, {100, "c"},
  {90, "xc"}, {50, "l"}, {40, "xl"}, {10, "x"},
  {9, "ix"}, {5, "v"}, {4, "iv"}, {1, "i"} }

return {
  render = function(_, counter_value)
    if counter_value > 5000 then
      return counter_value
    end
    local result = {}
    for _, v in ipairs(romans) do
      while counter_value >= v[1] do
        counter_value = counter_value - v[1]
        table.insert(result, v[2])
      end
    end
    return table.concat(result)
  end
}
