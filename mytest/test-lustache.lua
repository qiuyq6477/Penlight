local lustache = require "pl.lustache"

view_model = {
  title = "Joe",
  calc = function ()
    return 2 + 4
  end
}

output = lustache:render("{{title}} spends {{calc}}", view_model)
print(output)
