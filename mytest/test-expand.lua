local expand = require("pl.Expand")





----[[

template = [[
you can access variables: $v
or environment variables: ${HOME}

you can call functions: ${table.concat(list, ', ')}
this list has ${list.n} elements
   ${string.rep('=', list.n)}
   ${table.concat(list)}
   ${string.rep('=', list.n)}

or evaluate code inline
${for i=1,list.n do
    OUT = table.concat{ OUT, ' list[', i, '] = ', list[i], '\n'}
  end}
you can access global variables:
This example is from ${mjd} at $(mjdweb)

The Lord High Chamberlain has gotten ${L.n}
things for me this year.
${do diff = L.n - 5
    more = 'more'
    if diff == 0 then
      diff = 'no'
    elseif diff < 0 then
      diff = -diff
      more = 'fewer'
    end
  end}
That is $(diff) $(more) than he gave me last year.

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
io.write(expand(template, x, os.getenv))

------------------------------------------------------------------------------

fun_temp = [[
==============================================================================
$(foreach funcs

  ${type} x = ${name}( ${table.concat(args, ', ')} ) {
    $(code)
$(when stuff
    x = $x;
    y = $y;
)    reutrn $(exit);
  }
)
==============================================================================
]]

fun_list = {
  exit = 1;
  stuff = false;

  funcs = {
    { type = 'int';
      name = 'bill';
      args = { 'a', 'b', 'c' };
      code = 'something';
      stuff = { x=99, y=34 };
    };
    { type = 'char *';
      name = 'bert';
      args = { 'one', 'two', 'three' };
      code = 'something else';
      exit = 2
    };
  };
}

io.write(expand(fun_temp, fun_list, _G))

--]]
