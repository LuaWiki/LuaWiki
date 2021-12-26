local z = {}

function z.check_type(arg_idx, arg, expect_type, nil_ok)
	if arg == nil and nil_ok then return end
	if type(arg) ~= expect_type then
		local msg = string.format("bad argument #%d to '%s' (%s expected, got %s)",
			arg_idx, debug.getinfo(2).name, expect_type, type(arg)
		)
		error(msg, 3)
	end
end

function z.check_type_multi(arg_idx, arg, expect_types)
	local arg_type = type(arg)
	for _, expect_type in ipairs(expect_types) do
		if arg_type == expect_type then return end
	end
	local n = #expect_types
	local type_list
	if n > 1 then
		type_list = table.concat(expect_types, ', ', 1, n - 1) .. ' or ' .. expect_types[n]
	else
		type_list = expect_types[1]
	end
	local msg = string.format("bad argument #%d to '%s' (%s expected, got %s)",
		arg_idx,
		debug.getinfo(2).name,
		type_list,
		type(arg)
	)
	error(msg, 3)
end

function z.check_type_for_index(index, value, expect_type)
	if type(value) ~= expect_type then
		local msg = string.format("value for index '%s' must be %s, %s given",
			index, expect_type, type(value)
		)
		error(msg, 3)
	end
end

function z.check_type_for_named_arg(arg_name, arg, expect_type, nil_ok)
	if arg == nil and nil_ok then return end
	if type(arg) ~= expect_type then
		local msg = string.format("bad named argument %s to '%s' (%s expected, got %s)",
			arg_name, debug.getinfo(2).name, expect_type, type(arg)
		)
		error(msg, 3)
	end
end

function z.make_check_self_function(library_name, var_name, self_obj, self_obj_desc)
	return function (self, method)
		if self ~= self_obj then
			error(string.format(
				"%s: invalid %s. Did you call %s with a dot instead of a colon, i.e. " ..
				"%s.%s() instead of %s:%s()?",
				library_name, self_obj_desc, method, var_name, method, var_name, method
			), 3)
		end
	end
end

return z