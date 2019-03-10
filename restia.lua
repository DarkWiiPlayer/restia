--- Restia
-- @module restia

local moonxml = require "moonxml"
local lunamark = require "lunamark"

local restia = {}

--- Helper function that takes a markdown string and parses it as HTML
-- @function parsemd
-- @local
-- @tparam string markdown
-- @treturn nil
local parsemd do
	local writer = lunamark.writer.html5.new{containers=true}
	parsemd = lunamark.reader.markdown.new(writer, {smart = true})
end

--- Parses a markdown file
-- @treturn string
local function parsemdfile(path)
	local file, err = io.open(path)
	if file then
		return parsemd(file:read("*a"))
	else
		return file, err
	end
end

--- HTML Builder Environment
-- @section moonxml

local ngx_html = moonxml.html:derive()
do local env = ngx_html.environment
	env.print = function(...) ngx.print(...) end
	env.restia = restia

	--- Embeds a stylesheet into the document.
	-- @tparam string uri The URI to the stylesheet
	-- @treturn nil
	-- @function stylesheet
	env.stylesheet = function(uri)
		link({rel='stylesheet', href=uri, type='text/css'})
	end
	debug.setfenv(env.stylesheet, env)

	--- Renders an object into the document.
	-- If the object is a function, it is called with the additional arguments to render.
	-- If the object is anything else, it is converted to a string and printed.
	-- @param object The object to render
	-- @treturn nil
	-- @function render
	function env.render(object, ...)
		return type(object)=='function' and object(...) or print(tostring(object))
	end
	debug.setfenv(env.render, env)

	--- Renders a HTML5 doctype in place.
	-- @treturn nil
	-- @function html5
	function env.html5()
		print('<!doctype html5>')
	end
	debug.setfenv(env.html5, env)

	--- Renders an unordered list.
	-- List elements can be any valid MoonHTML data object,
	-- including functions and tables.
	-- They get passed directly to the `li` function call.
	-- @tparam table list A sequence containing the list elements
	-- @treturn nil
	-- @function ulist
	-- @usage
	-- 	ulist {
	-- 		'Hello',
	-- 		'World',
	-- 		function()
	-- 			br 'foo'
	-- 			print 'bar'
	-- 		end,
	-- 		'That was a list'
	-- 	}
	function env.ulist(list)
		ul(function()
			for index, item in ipairs(list) do
				li(item)
			end
		end)
	end
	debug.setfenv(env.ulist, env)

	--- Renders an ordered list. Works like ulist.
	-- @tparam table list A sequence containing the list elements
	-- @treturn nil
	-- @function olist
	-- @see ulist
	function env.olist(list)
		ol(function()
			for index, item in ipairs(list) do
				li(item)
			end
		end)
	end
	debug.setfenv(env.ulist, env)

	--- Renders a table (vertical).
	-- @param ... A list of rows (header rows can be marked by setting the `header` key)
	-- @treturn nil
	-- @function vtable
	function env.vtable(...)
		local rows = {...}
		node('table', function()
			for rownum, row in ipairs(rows) do
				fun = row.header and th or td
				tr(function()
					for colnum, cell in ipairs(row) do
						fun(cell)
					end
				end)
			end
		end)
	end
	debug.setfenv(env.vtable, env)
end

--- Utility Functions
-- @section functions

local template_cache = {}

--- Renders a template in moonhtml format
function restia.template(template, cache)
	template = template .. '.moonhtml'
	if cache == nil then
		cache = true
	end
	local result
	if cache then
		template_cache[template] = template_cache[template] or assert(ngx_html:loadmoonfile(template))
		return template_cache[template]
	else
		return assert(ngx_html:loadmoonfile(template))
	end
end

local markdown_cache = {}

--- Renders a markdown file
-- FIXME: Do caching properly
function restia.markdown(template, cache)
	template = template .. '.md'
	if cache == nil then
		cache = true
	end
	local result
	if cache then
		template_cache[template] = template_cache[template] or parsemdfile(template)
		return template_cache[template]
	else
		return parsemdfile(template)
	end
end

restia.string = {markdown = parsemd}

return restia
