--- Utility functions for Restia

local utils = {}

local lfs = require 'lfs'
local colors = require 'restia.colors'

local function files(dir, func)
	for path in lfs.dir(dir) do
		if path:sub(1, 1) ~= '.' then
			local name = dir .. '/' .. path
			local mode = lfs.attributes(name, 'mode')
			if mode == 'directory' then
				files(name, func)
			elseif mode == 'file' then
				func(name)
			end
		end
	end
end

--- Returns an iterator over all the files in a directory and subdirectories
-- @tparam string dir The directory to look in
-- @treturn function Iterator over the file names
-- @usage
-- 	for file in utils.files 'views' do
-- 		print('found view: ', file)
-- 	end
function utils.files(dir)
	return coroutine.wrap(files), dir, coroutine.yield
end

--- Deletes a file or directory recursively
-- @tparam string path The path to the file or directory to delete
function utils.delete(path)
	path = path:gsub('/+$', '')
	local mode = lfs.attributes(path, 'mode')
	if mode=='directory' then
		for entry in lfs.dir(path) do
			utils.delete(path..'/'..entry)
		end
	end
	os.remove(path)
end

--- Builds a directory structure recursively from a table template.
-- @tparam string prefix A prefix to the path, aka. where to initialize the directory structure.
-- @tparam table tab A table representing the directory structure.
-- Table entries are subdirectories, strings are files, false means delete, true means touch file, everything else is an error.
-- @usage
-- 	build_dir {
-- 		sub_dir = {
-- 			empty_file = ''
-- 		}
-- 		file = 'Hello World!';
-- 	}
-- @todo add `true` option for empty file -- @todo add `false` option to delete existing files/directories
function utils.build_dir(prefix, tab)
	if not tab then
		tab = prefix
		prefix = '.'
	end
	if not type(tab) == 'table' then
		error("Invalid argument; expected table, got "..type(tab), 1)
	end

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
			utils.build_dir(path, value)

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
			file:write('\n')
			file:close()

		elseif value==false then
			print(
				"Deleting   "..colors.red(path)
			)
			utils.delete(path)

		elseif value==true then
			print(
				"Touching   "..colors.yellow(path)
			)
			local file = io.open(path)
			if not file then
				file = io.open(path, 'w')
				file:write('')
			end
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

return utils
