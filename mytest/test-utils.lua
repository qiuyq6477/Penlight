local utils = require 'pl.utils'
local pretty = require 'pl.pretty'
local stringx = require 'pl.stringx'

stringx.format_operator()

local DIR1 = utils.enum("Left", "right", "up", "down")
local DIR2 = utils.enum({
  Left = 1,
  Right = 2
})


-- print(DIR1.Left)
-- print(DIR2.Left)
-- print(DIR1("Left"))
-- print(DIR2("Left"))

print(utils.string_lambda'|x, y|x+1' (2, 1))
print(utils.string_lambda'_ + 1' (2))

local function f(msg, name)
  print(msg .. " " .. name)
end
local hello = utils.bind1(f, "Hello")
print(hello("world"))     --> "Hello world"
print(hello("sunshine"))  --> "Hello sunshine"

local function f(a, b, c)
  print(a .. " " .. b .. " " .. c)
end
local hello = utils.bind2(f, "world")
print(hello("Hello", "!"))  --> "Hello world !"
print(hello("Bye", "?"))    --> "Bye world ?"

print("====== npairs")
-- local t = utils.pack(1, nil, 123, nil)  -- adds an `n` field when packing
local t = {1, nil, 123, nil}
for i, v in ipairs(t) do
  print(i .. "i")
end
print("======")
for i, v in utils.npairs(t) do  -- start at index 2
  print(i .. "i")
end

print("====== kpairs")

local t = {
  "hello",
  "world",
  hello = "hallo",
  world = "Welt",
}
for k, v in pairs(t) do
  print("%s %s" % {k, v})
end
print("======")
for k, v in utils.kpairs(t) do
  print("%s %s" % {k, v})
end

