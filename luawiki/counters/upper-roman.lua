local romans = {
  {1000, "M"},
  {900, "CM"}, {500, "D"}, {400, "CD"}, {100, "C"},
  {90, "XC"}, {50, "L"}, {40, "XL"}, {10, "X"},
  {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"} }

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