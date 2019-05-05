--- Main module.
-- Sets up an xhMoon environment and adds the utility functions.
-- @module restia
-- @author DarkWiiPlayer
-- @license Unlicense

local moonxml = require "moonxml"
local lunamark = require "lunamark"

local restia = {}
local ngx_html = moonxml.html:derive()

--- Parses markdown into HTML
-- @function parsemd
-- @local
-- @tparam string markdown
-- @treturn string
-- @usage parsemd 'some *fancy* text'
local parsemd do
	local writer = lunamark.writer.html5.new{containers=true}
	parsemd = lunamark.reader.markdown.new(writer, {smart = true})
end

--- Parses a markdown file.
-- @tparam string path The markdown file to read
-- @treturn string
-- @usage parsemdfile 'documents/markdown/article.md'
local function parsemdfile(path)
	local file, err = io.open(path)
	if file then
		return parsemd(file:read("*a"))
	else
		return file, err
	end
end

--- Utility Functions.
-- General functionality of restia.
-- @section functions

local template_cache = {}

--- Renders a template in moonhtml format
-- @tparam string template Template file (without extension) to load
-- @tparam[opt=true] boolean cache Whether to cache the template
-- @usage
-- 	restia.template('layout')('argument 1', 'argument 2', 'etc.')
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
-- @fixme Do caching properly
-- @tparam string document Markdown file (without extension) to load
-- @tparam[opt=true] boolean cache Whether to cache the template
-- @usage
-- 	restia.markdown('content')
function restia.markdown(document, cache)
	document = document .. '.md'
	if cache == nil then
		cache = true
	end
	local result
	if cache then
		markdown_cache[document] = markdown_cache[document] or parsemdfile(document)
		return markdown_cache[document]
	else
		return parsemdfile(document)
	end
end

--- HTML Builder Environment.
-- Automatically has access to the Restia library in the global variable 'restia'.
-- @section moonxml

do local env = ngx_html.environment
	env.print = function(...) ngx.print(...) end
	env.restia = restia

	--- Embeds a stylesheet into the document.
	-- @tparam string uri The URI to the stylesheet
	-- @function stylesheet
	-- @usage
	-- 	stylesheet 'styles/site.css'
	env.stylesheet = function(uri)
		link({rel='stylesheet', href=uri, type='text/css'})
	end
	debug.setfenv(env.stylesheet, env)

	--- Renders an object into the document.
	-- If the object is a function, it is called with the additional arguments to render.
	-- If the object is anything else, it is converted to a string and printed.
	-- @param object The object to render
	-- @function render
	-- @usage
	-- 	render(restia.template 'hello') -- Renders a function
	-- 	render(restia.markdown 'world') -- Renders a string
	function env.render(object, ...)
		return type(object)=='function' and object(...) or print(tostring(object))
	end
	debug.setfenv(env.render, env)

	--- Renders a HTML5 doctype in place.
	-- @function html5
	-- @usage
	-- 	html5()
	function env.html5()
		print('<!doctype html5>')
	end
	debug.setfenv(env.html5, env)

	--- Renders an unordered list.
	-- List elements can be any valid MoonHTML data object,
	-- including functions and tables.
	-- They get passed directly to the `li` function call.
	-- @tparam table list A sequence containing the list elements
	-- @function ulist
	-- @usage
	-- 	ulist {
	-- 		'Hello'
	-- 		'World'
  -- 		->
	-- 			br 'foo'
	-- 			print 'bar'
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
	-- @function vtable
	-- @usage
	-- 	vtable(
	-- 		{'Name', 'Balance', header = true},
	-- 		{'John', '500 €'}
	-- 	)
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

	--- Renders a table. Expects a sequence of keys as its first argument.
	-- Additional options can also be passed into the first table.
	-- Following arguments will be interpreted as key/value maps.
	-- @tparam table opt A sequence containing the keys to be rendered.
	-- @param ... A list of tables
	-- @function ttable
	-- @usage
	-- 	ttable(
	-- 		{'name', 'age', 'address', number: true, header: true, caption: -> h1 'People'}
	-- 		{name: "John Doe", age: -> i 'unknown', address: -> i 'unknown'}
	-- 	)
	function env.ttable(opt, ...)
		-- Header defaults to true
		if opt.header==nil then opt.header=true end
		local rows = {...}

		node('table', function()
			if opt.caption then
				caption(opt.caption)
			end

			if opt.header then
				tr(function()
					if opt.number then th '#' end
					for idx,header in ipairs(opt) do
						th(tostring(header))
					end
				end)
			end

			for i,row in ipairs(rows) do
				tr(function()
					if opt.number then td(i) end
					for idx,key in ipairs(opt) do
						td(row[key])
					end
				end)
			end
		end)
	end
	debug.setfenv(env.ttable, env)
end

restia.string = {markdown = parsemd}

return restia
