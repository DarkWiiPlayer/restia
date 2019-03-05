--- Restia
-- @module restia

local moonxml = require "moonxml"
local lunamark = require "lunamark"

local restia = {}

--- Helper function that takes a markdown string and parses it as HTML
-- @function parsemd
-- @local
-- @tparam string markdown
local parsemd do
	local writer = lunamark.writer.html5.new{containers=true}
	parsemd = lunamark.reader.markdown.new(writer, {smart = true})
end

--- Parses a markdown file
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

	env.stylesheet = function(url)
		link({rel='stylesheet', href=url, type='text/css'})
	end
	debug.setfenv(env.stylesheet, env)

	function env.embed(something)
		return type(something)=='function' and something() or print(tostring(something))
	end
	debug.setfenv(env.embed, env)

	function env.html5()
		print('<!doctype html5>')
	end
	debug.setfenv(env.html5, env)

	function env.ulist(list)
		ul(function()
			for index, item in ipairs(list) do
				li(item)
			end
		end)
	end
	debug.setfenv(env.ulist, env)

	function env.olist(list)
		ol(function()
			for index, item in ipairs(list) do
				li(item)
			end
		end)
	end
	debug.setfenv(env.ulist, env)

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
