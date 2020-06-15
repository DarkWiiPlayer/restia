--- Utility functions for Restia
-- @module restia.utils
-- @author DarkWiiPlayer
-- @license Unlicense

local utils = {}

local lfs = require 'lfs'
local colors = require 'restia.colors'

local escapes = {
	['&'] = '&amp;',
	['<'] = '&lt;',
	['>'] = '&gt;',
	['"'] = '&quot;',
	["'"] = '&#039;',
}
do local buf = {}
	for char in pairs(escapes) do
		table.insert(buf, char)
	end
	escapes.pattern = "["..table.concat(buf).."]"
end
--- Escapes special HTML characters in a string
function utils.escape(str)
	return (tostring(str):gsub(escapes.pattern, escapes))
end

--- Removes excessive indentation from a block of text
function utils.normalize_indent(block)
	local indent = '^'..(block:match("^%s+") or '')
	return (block:gsub('[^\n]+', function(line)
		return line:gsub(indent, ''):gsub('[\t ]+$', ''):gsub("^%s*$", '')
	end))
end

--- Removes leading whitespace up to and including a pipe character.
-- This is used to trim off unwanted whitespace at the beginning of a line.
-- This is hopefully a bit faster and more versatile than the normalize_indent function.
function utils.unpipe(block)
	return block:gsub('[^\n]+', function(line)
		return line:gsub('^%s*|', '')
	end)
end

--- Indexes tables recursively with a chain of string keys
function utils.deep_index(object, keys)
	for key in keys:gmatch('[^.]+') do
		object = object[key]
		if not object then return nil end
	end
	return object
end

--- Turns a flat table and turns it into a nested table.
-- @usage
-- 	local deep = restia.utils.deep {
-- 		['foo.bar.baz'] = "hello";
-- 		['foo.1'] = "first";
-- 		['foo.2'] = "second";
-- 	}
-- 	-- Is equal to
-- 	local deep = {
-- 		foo = {
-- 			"first", "second";
-- 			bar = { baz = "hello" };
-- 		}
-- 	}
function utils.deepen(tab)
	local res = {}
	for key, value in pairs(tab) do
		if type(key) == 'string' and key:find(".", 1, false) then
			local tab = res
			local name
			local first, last = key:find("[^.]+")
			repeat
				name = key:sub(first, last); name = tonumber(name) or name
				tab[name] = tab[name] or {}
				first, last = key:find("[^.]+", last+1)
				if first then tab = tab[name] end
			until not first
			tab[name] = value
		else
			res[key] = value end
	end
	return res
end

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

local function random(n)
	if n > 0 then
		return math.random(256)-1, random(n-1)
	end
end

--- Recursively concatenates a table
function utils.rconcat(tab, separator)
	for key, value in ipairs(tab) do
		if type(value)=="table" then
			tab[key]=utils.rconcat(value, separator)
		else
			tab[key]=tostring(value)
		end
	end
	return table.concat(tab, separator)
end

--- Returns a list containing
function utils.stack(level)
	local stack = {}
	for i=level+1, math.huge do
		local info = debug.getinfo(i)
		if info then
			table.insert(stack, info)
		else
			break
		end
	end
	return stack
end

--- Returns a random hexadecimal string with N bytes
function utils.randomhex(n)
	return string.format(string.rep("%03x", n), random(n))
end

--- Returns an iterator over all the files in a directory and subdirectories
-- @tparam string dir The directory to look in
-- @treturn function Iterator over the file names
-- @usage -- 	for file in utils.files 'views' do
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
