local z = {}

local function array_reverse(x)
  local n, m = #x, #x/2
  for i=1, m do
    x[i], x[n-i+1] = x[n-i+1], x[i]
  end
  return x
end

z.__index = {
  render = function(self, counter_value)
    local remainder = counter_value
    local sym_len = #self.symbols
    if remainder >= 1 and sym_len > 0 then
      local text = {}
      while remainder > 0 do
        table.insert(text, self.symbols[(remainder - 1) % sym_len + 1])
        remainder = math.floor((remainder - 1) / sym_len)
      end
      return table.concat(array_reverse(text));
    end
  end
}

return z
