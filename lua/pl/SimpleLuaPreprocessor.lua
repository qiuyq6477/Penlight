-- 以 # 开头的行作为 Lua 执行。
-- 除了执行其中任意位置的 $(...) 之外其他内容不变。 （没有进行解析，所以你必须小心你的 $('s)
function prep_str(inputString, env)
  local chunk = {n=0}
  for line in inputString:gmatch("[^\r\n]+") do
    if string.find(line, "^-") then
      goto continue
    end
    if string.find(line, "^#") then
      -- table.insert(chunk, string.format('table.insert(output, %q)\n', string.sub(line, 2) .. "\n"))
      table.insert(chunk, string.sub(line, 2) .. "\n")
    else
      local last = 1
      for text, expr, index in string.gmatch(line, "(.-)$(%b())()") do
        last = index
        if text ~= "" then
          table.insert(chunk, string.format('table.insert(output, %q) ', text))
        end
        table.insert(chunk, string.format('table.insert(output, %s) ', string.sub(expr, 2, -2)))
      end
      table.insert(chunk, string.format('table.insert(output, %q)\n', string.sub(line, last) .. "\n"))
    end
    ::continue::
  end
  local code = "local output = {} ".. table.concat(chunk) .. "return table.concat(output)"
  local func = loadstring(code)
  if func then
    setfenv(func, env)
    return func()
  else
    error("Error loading code")
  end
end

function prep_file(file)
  local chunk = {n=0}
  for line in file:lines() do
    if string.find(line, "^--") then
      goto continue
    end
    if string.find(line, "^#") then
      table.insert(chunk, string.sub(line, 2) .. "\n")
    else
      local last = 1
      for text, expr, index in string.gmatch(line, "(.-)$(%b())()") do
        last = index
        if text ~= "" then
          table.insert(chunk, string.format('io.write %q ', text))
        end
        table.insert(chunk, string.format('io.write%s ', expr))
      end
      table.insert(chunk, string.format('io.write %q\n', string.sub(line, last).."\n"))
    end

    ::continue::
  end
  return loadstring(table.concat(chunk))()
end

return {
  str = prep_str,
  file = prep_file,
};
