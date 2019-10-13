--- Template module.
-- Sets up an xhMoon environment and adds the utility functions.
-- @module restia
-- @author DarkWiiPlayer
-- @license Unlicense

local moonxml = require "moonxml"
local templates = {}

local restia_html

setmetatable(templates, {__index = function(self, name)
	if rawget(self, '__prefix') then
		name = tostring(self.__prefix)..name
	end

	local file, template, err
	file = io.open(name .. '.moonhtml.lua')
	if file then
		template, err = restia_html:loadlua(file:read('*a'), tostring(name)..'.moonhtml.lua')
	else
		file = io.open(name .. '.moonhtml')
		if file then
			template, err = restia_html:loadmoon(file:read('*a'), name..'.moonhtml')
		end
	end

	if not template and err then
		print("Error loading template "..name..": "..tostring(err))
		return nil
	end

	rawset(self, name, function(...)
		local buff = {}
		local _print = restia_html.environment.print

		restia_html.environment.print = function(...)
			for i=1,select('#', ...) do
				table.insert(buff, (select(i, ...)))
			end
		end
		template(...)

		ngx.print(buff)
		restia_html.environment.print = _print
	end)

	return rawget(self, name)
end})

--- HTML Builder Environment.
-- Automatically has access to the Restia library in the global variable 'restia'.
-- @section moonxml

restia_html = moonxml.html:derive(function(_ENV)
	function print(...)
		ngx.print(...)
	end

	--- Embeds a stylesheet into the document.
	-- @tparam string uri The URI to the stylesheet
	-- @tparam boolean async Load the stylesheet asynchronously and apply it once it's loaded
	-- @function stylesheet
	-- @usage
	-- 	stylesheet 'styles/site.css'
	-- 	stylesheet 'styles/form.css', true
	stylesheet = function(uri, async)
		if async then
			link({rel='stylesheet', href=uri, type='text/css'})
		else
			--link({rel='preload', href=uri, type='text/css', onload='this.rel="stylesheet"'})
			link({rel='stylesheet', href=uri, type='text/css', media='print', onload='this.media="all"'})
		end
	end

	--- Renders an object into the document.
	-- If the object is a function, it is called with the additional arguments to render.
	-- If the object is anything else, it is converted to a string and printed.
	-- @param object The object to render
	-- @function render
	-- @usage
	-- 	render(restia.template 'hello') -- Renders a function
	-- 	render(restia.markdown 'world') -- Renders a string
	function render(object, ...)
		return type(object)=='function' and object(...) or print(tostring(object))
	end

	--- Renders a HTML5 doctype in place.
	-- @function html5
	-- @usage
	-- 	html5()
	function html5()
		print('<!doctype html>')
	end

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
	function ulist(list)
		ul(function()
			for index, item in ipairs(list) do
				li(item)
			end
		end)
	end

	--- Renders an ordered list. Works like ulist.
	-- @tparam table list A sequence containing the list elements
	-- @function olist
	-- @see ulist
	function olist(list)
		ol(function()
			for index, item in ipairs(list) do
				li(item)
			end
		end)
	end

	--- Renders a table (vertical).
	-- @param ... A list of rows (header rows can be marked by setting the `header` key)
	-- @function vtable
	-- @usage
	-- 	vtable(
	-- 		{'Name', 'Balance', header = true},
	-- 		{'John', '500 €'}
	-- 	)
	function vtable(...)
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
	function ttable(opt, ...)
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
end)

return templates
