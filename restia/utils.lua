local lfs = require 'lfs'
local colors = require 'restia.colors'

local function build_dir(prefix, tab)
  for path, value in pairs(tab) do
    if prefix then
      path = prefix.."/"..tostring(path)
    end

    if type(value) == "table" then
      lfs.mkdir(path)
      print (
        "Directory  "
        ..colors.blue(path)
      )
      build_dir(path, value)

    elseif type(value) == "string" then
      print(
        "File       "
        ..colors.magenta(path)
        .." with "
        ..#value
        .." bytes"
      )
      local file = io.open(path,'w')
      file:write(value)
      file:close()

    else
      print(
        "Unknown type at     "
        ..colors.red(path)
        .." ("
        ..colors.red(type(value))
        ..")"
      )

    end
  end
end

return {
  build_dir = build_dir
}
