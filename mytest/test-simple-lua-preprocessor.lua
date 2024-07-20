local prep = require "pl.SimpleLuaPreprocessor"
local pretty = require 'pl.pretty'
local path = require "pl.path"
local List = require 'pl.List'
local OrderedMap = require 'pl.OrderedMap'


local inputString = [[
Hello $(get_name()), welcome to $(place)!
The result of 2 + 2 is $(2 + 2).
]]

local get_name = function()
    return "abc"
end
local env = {
  name = "Alice",
  place = "Wonderland",
  tostring = tostring,  -- 确保 tostring 函数在环境中可用
  table = table,
  get_name = get_name,
}
print((prep.str(inputString, env)))

local inputString2 = [[
#if DEBUG then
    function log(fmt, ...) print(string.format(fmt, unpack(arg))) end
#else
    function log() end
#end

#for i = 0, 10 do
var$(i) = $(math.sin(math.pi * i / 10))
#end
]]

local env2 = {
  math = math,
  table = table,
  DEBUG = true,
}
print(pretty.write((prep.str(inputString2, env2))))



prep.file(assert(io.open"tests/data/prep_file_test_data.luap"))



local template = [[
you can access variables: $(v)
or environment variables: $(HOME)

you can call functions: $(table.concat(list, ', '))
this list has $(list.n) elements
   $(string.rep('=', list.n))
   $(table.concat(list))
   $(string.rep('=', list.n))

or evaluate code inline
-- $(for i=1,list.n do
--     OUT = table.concat{ OUT, ' list[', i, '] = ', list[i], '\n')
--   end)
you can access global variables:
This example is from $(mjd) at $(mjdweb)

The Lord High Chamberlain has gotten $(L.n)
things for me this year.
-- $(do diff = L.n - 5
--     more = 'more'
--     if diff == 0 then
--       diff = 'no'
--     elseif diff < 0 then
--       diff = -diff
--       more = 'fewer'
--     end
--   end)
-- That is $(diff) $(more) than he gave me last year.

values can have other variables: $(ref)
]]

mjd = "Mark J. Dominus"
mjdweb = 'http://perl.plover.com/'
HOME = "home"
L = { 'A', 'B', 'C', 'D', n=4}
local x = {
  v = 'this is v',
  list = L,
  ref = "$(mjd) made Text::Template.pm"
}
setmetatable(x, {__index=_G})
-- fill in the template with values in table x
print(pretty.write(prep.str(template, x)))




do
  local inputString = [[
# for i = 1,2 do
<p>Hello $(tostring(i))</p>
# end
]]
  print(pretty.write(prep.str(inputString, _G)))

end


do
  local inputString = [[
<ul>
# for name in ls:iter() do
   <li>$(name)</li>
#end
</ul>
]]
  local env = {
    ls = List{'john','alice','jane'}
  }
  setmetatable(env, {__index=_G})
  print(pretty.write(prep.str(inputString, env)))

end


do
  local inputString = [[
<ul>
# for i,v in ipairs{'alpha','beta','gamma'} do
    cout << obj.$(v) << endl;
# end
</ul>
]]
  print(pretty.write(prep.str(inputString, _G)))

end



do
  local inputString = [[
# for i = 1,3 do
    $(text[i])
# end
]]
  local env = {
    text={'foo','bar','baz'}
  }
  setmetatable(env, {__index=_G})
  print(pretty.write(prep.str(inputString, env)))

end


do
  local inputString = [[<ul>
# for i,val in ipairs(T) do
<li>$(i) = $(val:upper())</li>
# end
</ul>]]
  local env = {
    T = {'one','two','three'},
  }
  setmetatable(env, {__index=_G})
  print(pretty.write(prep.str(inputString, env)))

end

do
  local inputString = [[
# for i = 1,3 do
    print($(i+1))
# end
]]
  local env = {
  }
  setmetatable(env, {__index=_G})
  print(pretty.write(prep.str(inputString, env)))

end



do
  local inputString = [[
# for k,v in pairs(T) do
    "$(k)", -- $(v)
# end
]]
  local Tee = OrderedMap{{Dog = 'Bonzo'}, {Cat = 'Felix'}, {Lion = 'Leo'}}
  local env =
  {
    T = Tee
  }
  setmetatable(env, {__index=_G})
  print(pretty.write(prep.str(inputString, env)))

end
