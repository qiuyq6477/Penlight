local lpeg =require 'lpeg'
local match = lpeg.match
local p = lpeg.p
local S = lpeg.S
local R = lpeg.R


print(match(S'a', 'aaa'))
