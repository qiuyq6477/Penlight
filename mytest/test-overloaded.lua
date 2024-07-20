require 'pl.overloaded'


foo = overloaded()

-- if passed a number, return its square
function foo.number(n)
    return n^2
end

-- if passed a string, convert it to a number and call the numeric version
function foo.string(s)
    return foo(tonumber(s))
end

-- if passed a string _and_ a number, act like string.rep
foo.string.number = string.rep

-- if given anything else, act like print
foo.default = print

--- begin test code ---
foo(6) --36
foo("4") -- 16
foo("not a valid number") --error (attempt to perform arithmetic on a nil value)
foo("foo", 4) -- foofoofoofoo
foo(true, false, {}) --true    false   table: 0x12345678
