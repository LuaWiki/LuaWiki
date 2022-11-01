local z = {}

-- clear error
z.cerror = function(msg)
  return error(msg, 0)
end

return z
