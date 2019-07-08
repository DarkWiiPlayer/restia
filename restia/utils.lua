--- Utility functions for Restia

local lfs = require 'lfs'
local colors = require 'restia.colors'

--- Builds a directory structure recursively from a table template.
-- @tparam string prefix A prefix to the path, aka. where to initialize the directory structure.
-- @tparam table tab A table representing the directory structure. Table entries are subdirectories, strings are files, everything else is an error.
-- @usage
-- 	build_dir {
-- 		sub_dir = {
-- 			empty_file = ''
-- 		}
-- 		file = 'Hello World!';
-- 	}
-- @todo add `true` option for empty file
-- @todo add `false` option to delete existing files/directories
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
