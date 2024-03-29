--- Utility functions for Restia
-- @module restia.utils
-- @author DarkWiiPlayer
-- @license Unlicense

local utils = {}

local lfs = require 'lfs'
local colors = require 'restia.colors'

local htmlescapes = {
	['&'] = '&amp;',
	['<'] = '&lt;',
	['>'] = '&gt;',
	['"'] = '&quot;',
	["'"] = '&#039;',
}

do local buf = {}
	for char in pairs(htmlescapes) do
		table.insert(buf, char)
	end
	htmlescapes.pattern = "["..table.concat(buf).."]"
end
--- Escapes special HTML characters in a string
function utils.htmlescape(str)
	return (tostring(str):gsub(htmlescapes.pattern, htmlescapes))
end

--- Makes a table look up missing keys with `require`
function utils.deepmodule(prefix)
	return setmetatable({}, {
		__index = function(self, name)
			return require(prefix .. "." .. name)
		end
	})
end

--- Mixes several tables into another and returns it.
function utils.mixin(first, second, ...)
	if type(second)=="table" then
		for key, value in pairs(second) do
			if type(value) == "table" then
				if type(first[key]) ~= "table" then
					first[key] = {}
				end
				utils.mixin(first[key], value)
			else
				first[key] = value
			end
		end
		return utils.mixin(first, ...)
	else
		return first
	end
end

--- Removes excessive indentation from a block of text
function utils.normalizeindent(block)
	local indent = '^'..(block:match("^%s+") or '')
	return (block:gsub('[^\n]+', function(line)
		return line:gsub(indent, ''):gsub('[\t ]+$', ''):gsub("^%s*$", '')
	end))
end

--- Removes leading whitespace up to and including a pipe character.
-- This is used to trim off unwanted whitespace at the beginning of a line.
-- This is hopefully a bit faster and more versatile than the normalizeindent function.
function utils.unpipe(block)
	return block:gsub('[^\n]+', function(line)
		return line:gsub('^%s*|', ''):gsub('^%s+$', '')
	end)
end

--- Indexes tables recursively with a chain of string keys
function utils.deepindex(tab, path)
	if type(path)~="string" then
		return nil, "path is not a string"
	end
	local index, rest = path:match("^%.?([%a%d]+)(.*)")
	if not index then
		index, rest = path:match("^%[(%d+)%](.*)")
		index = tonumber(index)
	end
	if index then
		if #rest>0 then
			if tab[index] then
				return utils.deepindex(tab[index], rest)
			else
				return nil, "full path not present in table"
			end
		else
			return tab[index]
		end
	else
		return nil, "malformed index-path string"
	end
end

--- Inserts a table into a nested table following a path.
-- The path string mimics normal chained indexing in normal Lua.
-- Nil-elements along the path will be created as tables.
-- Non-nil elements will be indexed and error accordingly if this fails.
-- @tparam table tab A table or indexable object to recursively insert into
-- @tparam table path A string describing the path to iterate
-- @param value The value that will be inserted
-- @usage
-- utils.deepinsert(some_table, 'foo.bar.baz', value)
function utils.deepinsert(tab, path, value)
	if type(path) == "table" then
		local current = tab
		for i=1,math.huge do
			local key = path[i]
			if path[i+1] then
				if not current[key] then
					current[key] = {}
				end
				current = current[key]
			else
				current[key] = value
				break
			end
		end
		return value or true
	elseif type(path) == "string" then
		local index, rest = path:match("^%.?([^%[%.]+)(.*)")
		if not index then
			index, rest = path:match("^%[(%d+)%](.*)")
			index = tonumber(index)
		end
		if index then
			if #rest>0 then
				local current
				if tab[index] then
					current = tab[index]
				else
					current = {}
					tab[index] = current
				end
				return utils.deepinsert(current, rest, value)
			else
				tab[index] = value
				return value or true
			end
		else
			return nil, "malformed index-path string: " .. path
		end
	else
		return nil, "path is neither string nor table: " .. type(path)
	end
end

--- Turns a flat table and turns it into a nested table.
-- @usage
-- 	local deep = restia.utils.deep {
-- 		['foo.bar.baz'] = "hello";
-- 		['foo[1]'] = "first";
-- 		['foo[2]'] = "second";
-- 	}
-- 	-- Is equal to
-- 	local deep = {
-- 		foo = {
-- 			"first", "second";
-- 			bar = { baz = "hello" };
-- 		}
-- 	}
function utils.deepen(tab)
	local deep = {}
	for path, value in pairs(tab) do
		if not utils.deepinsert(deep, path, value) then
			deep[path] = value
		end
	end
	return deep
end

utils.tree = {}

--- Inserts a value into a tree.
-- Every node in the tree, not only leaves, can hold a value.
-- The special index __value is used for this and should not appear in the route.
-- @tparam table head The tree to insert the value into.
-- @tparam table route A list of values to recursively index the tree with.
-- @param value Any Lua value to be inserted into the tree.
-- @treturn table The head node of the tree.
-- @see tree.get
-- @usage
-- 	local insert = restia.utils.tree.insert
-- 	local tree = {}
-- 	insert(tree, {"foo"}, "value 1")
-- 	-- Nodes can have values and children at once
-- 	insert(tree, {"foo", "bar"}, "value 2")
-- 	-- Keys can be anything
-- 	insert(tree, {function() end, {}}, "value 2")
-- @function tree.insert
function utils.tree.insert(head, route, value)
	local tail = head
	for i, key in ipairs(route) do
		local next = tail[key]
		if not next then
			next = {}
			tail[key] = next
		end
		tail = next
	end
	tail.__value = value
	return head
end

--- Gets a value from a tree.
-- @tparam table head The tree to retreive the value from.
-- @tparam table route A list of values to recursively index the tree with.
-- @return The value at the described node in the tree.
-- @see tree.insert
-- @usage
-- 	local tree = { foo = { bar = { __value = "Some value" }, __value = "Unused value" } }
-- 	restia.utils.tree.get(tree, {"foo", "bar"})
-- @function tree.get
function utils.tree.get(head, route)
	for i, key in ipairs(route) do
		head = head[key]
		if not head then
			return nil
		end
	end
	return head.__value
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
function utils.deepconcat(tab, separator)
	for key, value in ipairs(tab) do
		if type(value)=="table" then
			tab[key]=utils.deepconcat(value, separator)
		else
			tab[key]=tostring(value)
		end
	end
	return table.concat(tab, separator)
end

--- Returns a list containing the result of `debug.getinfo` for every level in
-- the current call stack. The table also contains its length at index `n`.
function utils.stack(level)
	local stack = {}
	for i=level+1, math.huge do
		local info = debug.getinfo(i)
		if info then
			table.insert(stack, info)
		else
			stack.n = i
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
-- @tparam[opt] string filter A string to match filenames against for filtering
-- @treturn function Iterator over the file names
-- @usage
-- 	for file in utils.files 'views' do
-- 		print('found view: ', file)
-- 	end
--
-- 	for image in utils.files(".", "%.png$") do
-- 		print('found image: ', image)
-- 	end
function utils.files(dir, filter)
	if type(filter)=="string" then
		return coroutine.wrap(files), dir, function(name)
			if name:find(filter) then
				coroutine.yield(name)
			end
		end
	else
		return coroutine.wrap(files), dir, coroutine.yield
	end
end

--- Deletes a file or directory recursively
-- @tparam string path The path to the file or directory to delete
function utils.delete(path)
	path = path:gsub('/+$', '')
	local mode = lfs.attributes(path, 'mode')
	if mode=='directory' then
		for entry in lfs.dir(path) do
			if not entry:match("^%.%.?$") then
				utils.delete(path..'/'..entry)
			end
		end
	end
	os.remove(path)
end

--- Copies a directory recursively
function utils.copy(from, to)
	local mode = lfs.attributes(from, 'mode')
	if mode == 'directory' then
		lfs.mkdir(to)
		for path in lfs.dir(from) do
			if path:sub(1, 1) ~= '.' then
				utils.copy(from.."/"..path, to.."/"..path)
			end
		end
	elseif mode == 'file' then
		local of, err = io.open(to, 'wb')
		if not of then
			error(err)
		end
		of:write(io.open(from, 'rb'):read('a'))
		of:close()
	end
end

function utils.mkdir(path)
	local slash = 0
	while slash do
		slash = path:find("/", slash+1)
		lfs.mkdir(path:sub(1, slash))
	end
end

--- Writes an arbitrarily nested sequence of strings to a file
-- @tparam table buffer A sequence containing strings or nested sequences
-- @tparam file file A file to write to
-- @treturn number The number of bytes that were written
function utils.writebuffer(buffer, file)
	local bytes = 0
	local close = false
	if type(file) == "string" then
		file = io.open(file, "wb")
		close = true
	end
	if type(buffer) == "string" then
		file:write(buffer)
		return #buffer
	else
		for i, chunk in ipairs(buffer) do
			bytes = bytes + utils.writebuffer(chunk, file)
		end
	end
	if close then
		file:close()
	end
	return bytes
end

function utils.frontmatter(text)
	local a, b = text:find('^%-%-%-+\n')
	local c, d = text:find('\n%-%-%-+\n', b)
	if b and c then
		return text:sub(b+1, c-1), text:sub(d+1, -1)
	else
		return nil, text
	end
end

return utils
