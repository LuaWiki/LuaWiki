local _M = {}

_M.test_total = 0
_M.test_success = 0
_M.test_failure = {}

_M.start_time = 0
_M.finish_time = 0

function _M.start()
    print("Test started at " .. os.time() .. ".")
    _M.start_time = os.clock()
end

---@param name string
---@param func function
function _M.testcase(name, func)
    _M.test_total = _M.test_total + 1
    local ret, data = pcall(func)
    if ret then
        _M.test_success = _M.test_success + 1
    else
        -- TODO: write failure reason
        table.insert(_M.test_failure, name)
    end
end

function _M.finish()
    _M.finish_time = os.clock()
    print("Test finished at " .. os.time() .. ". Took " .. _M.finish_time - _M.start_time .. " seconds.")
    print(_M.test_total .. " cases were tested with " .. _M.test_success .. " successful,")
    print("    result in a successful rate of " .. _M.test_success / _M.test_total * 100 .. "%")
    if _M.test_success ~= _M.test_total then
        print("Failure tests were: " .. table.concat(_M.test_failure, ","))
    else
        print("All test were successful.")
    end
end

function _M.assert_equals(actual, expect)
    assert(actual == expect)
end

function _M.assert_not_equals(actual, expect)
    assert(actual ~= expect)
end

function _M.assert_greater(actual, minimum)
    assert(actual > minimum)
end

function _M.assert_greater_equal(actual, minimum)
    assert(actual >= minimum)
end

function _M.assert_lesser(actual, minimum)
    assert(actual > minimum)
end

function _M.assert_lesser_equal(actual, minimum)
    assert(actual <= minimum)
end

return _M
