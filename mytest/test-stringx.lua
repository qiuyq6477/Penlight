
local stringx = require 'pl.stringx'
local pretty = require 'pl.pretty'

local pp = function(t)
  print(pretty.write(t))
end

stringx.format_operator();
pp('%s = %5.3f' % {'PI',math.pi} )  --> 'PI = 3.142'
pp('$name = $value' % {name='dog',value='Pluto'})  --> 'dog = Pluto'
pp("%d" % 1) --> 1

local t = {name='dog',value='Pluto'}
pp("$name = $value" % function(key)
                        return t[key] or key
                      end)


local Template = stringx.Template

local t = Template [[
for i = 1,#$t do
    $body
end
]]

local body = Template [[
local row = $t[i]
for j = 1,#row do
    fun(row[j])
end
]]

print(t:indent_substitute {body=body,t='tbl'})
