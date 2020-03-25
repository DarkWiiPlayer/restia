--- Template module.
-- Sets up an xhMoon environment and adds the utility functions.
-- @module restia.template
-- @author DarkWiiPlayer
-- @license Unlicense

local template = {}

local moonxml = require "moonxml"

local restia_html

template.metatable = {
	__index = template;
	__call=function(self, ...)
		local meta = getmetatable(self) -- effectively, this very table
		local old_call = meta.__call -- aka. this function
		meta.__call = meta.__call2 or old_call -- see below
		self:print(...)
		meta.__call = old_call -- reset to original
	end;
	__call2=function(self, ...)
		return self.raw(...)
	end;
}

--- Stores required modules just like `package.loaded` does for normal Lua modules.
template.loaded = {}

--- Requires a module in a similar way to Luas `require` function,
-- but evaluates the code in the MoonXML language environment.
-- This allows writing specialized MoonHTML macros to avoid
-- code duplication in views. As with `requier`, `package.path` is
-- used to look for Lua modules.
-- @tparam string modname The name of the module.
-- @return module The loaded module. In other words, the return value of the evaluated Lua file.
function template.require(modname)
  ngx.log(ngx.INFO, '🎆 Trying to require '..modname)
  if not template.loaded[modname] then
    local filename = modname:gsub('%.', package.config:sub(1,1))
    for path in package.path:gmatch('[^;]+') do
      ngx.log(ngx.INFO, 'Trying '..path)
      local filepath = path:gsub("?", filename)
      local f = io.open(filepath)
      if f then
        f:close()
        local module = restia_html:loadluafile(filepath)
        template.loaded[modname] = module() or true
        break
      end
    end
    if not template.loaded[modname] then
      error("Could not require modul "..modname)
    end
  end
  return template.loaded[modname]
end

--- Loads a template from lua code.
-- The code may be compiled bytecode.
function template.loadlua(code, filename)
	local temp, err = restia_html:loadlua(code, filename)
	if temp then
		return setmetatable({raw=temp}, template.metatable)
	else
		return nil, err
	end
end

--- Loads a template from moonscript code.
function template.loadmoon(code, filename)
	local temp, err = restia_html:loadmoon(code, filename)
	if temp then
		return setmetatable({raw=temp}, template.metatable)
	else
		return nil, err
	end
end

--- Renders the template to a buffer table
function template:render(...)
	local buff = {}
	local _print = restia_html.environment.print

	restia_html.environment.print = function(...)
		for i=1,select('#', ...) do
			table.insert(buff, (select(i, ...)))
		end
	end
	local res = self.raw(...)
	if res then table.insert(buff, res) end
	restia_html.environment.print = _print

	return buff
end

--- Renders a table and directly sends it to nginx
function template:print(...)
	ngx.print(self:render(...))
end

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
			link({rel='stylesheet', href=uri, type='text/css', media='print', onload='this.media=`all`'})
		else
			--link({rel='preload', href=uri, type='text/css', onload='this.rel="stylesheet"'})
			link({rel='stylesheet', href=uri, type='text/css'})
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

	--- Renders a script tag from Lua code to be used by fengari.
	-- @tparam string code The content of the script tag (Lua code).
	-- @function lua
	-- @usage
	-- 	lua [[
	-- 		print "Hello, World!"
	-- 	]]
	function lua(code)
		script(function() print(code) end, {type = 'application/lua'})
	end

	--- Renders a script tag from Moonscript code to be used by fengari.
	-- The code is first stripped of additional indentation and converted to Lua.
	-- @tparam string code The content of the script tag (Moonscript code).
	-- @function moon
	-- @usage
	-- 	lua [[
	-- 		print "Hello, World!"
	-- 	]]
	function moon(code)
		local utils = require 'restia.utils'
		local moonscript = require 'moonscript.base'
		lua(assert(moonscript.to_lua(utils.normalize_indent(code))))
	end
end)

return template
