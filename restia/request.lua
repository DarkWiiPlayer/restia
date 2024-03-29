--- A helper "object" that provides common request-related information as
-- attributes. Most functions are either reasonably fast or memoized, so the
-- user does not need to take care of caching values outside of very critical
-- code.
-- @module restia.request
-- @author DarkWiiPlayer
-- @license Unlicense
-- @usage
-- 	local req = restia.request
-- 	-- restia.controller.xpcall passes this as its first argument automatically
-- 	if req.method == "GET" then
-- 		ngx.say(json.encode({message="Greetings from "..params.host.."!"}))
-- 	else
-- 		ngx.say(json.encode(req.params))
-- 	end

local restia = require 'restia'
local cookie = require 'resty.cookie'
local multipart = require 'multipart'

local request = {}

--- "Offers" a set of content types during content negotiation.
-- Given a set of possible content types, it tries figuring out what the client
-- wants and picks the most fitting content handler. Automatically runs the
-- handler and sends the result to the client.
-- Alternatively, when given a list of strings as arguments, it will pick a
-- suitable content type from them and return it.
-- For the most part, this is a wrapper around `restia.negotiator.pick` and
-- follows the same semantics in its "available" argument.
-- When no content-type matches, an error is raised.
-- @tparam table available A map from content-types to handlers. Either as a plain key-value map or as a sequence of key-value pairs in the form of two-element sequences.
-- @param ... Additional arguments to be passed to the content handlers
function request:offer(available, ...)
	assert(self.headers, "Request object has no headers!")

	if type(available) == "table" then
		local content_type, handler =
			restia.negotiator.pick(self.headers.accept, available)
		ngx.header["content-type"] = content_type
		if handler then
			local result = handler(self, ...)
			return ngx.say(tostring(result))
		else
			error("No suitable request handler found", 2)
		end
	else
		return restia.negotiator.pick(self.headers.accept, {available, ...}, nil, "No suitable content type supported")
	end
end

local get, set = restia.accessors.new(request)

--- Getters
-- @section getters

--- Returns the request parameters.
-- @function params
-- @treturn table A table containing the request parameters.
function get:params()
	if not ngx.ctx.params then
		if self.method == "GET" then
			ngx.ctx.params = restia.utils.deepen(ngx.req.get_uri_args())
		elseif self.method == "POST" then
			ngx.req.read_body()
			if self.type == "application/json" then
				local json = require 'cjson'
				ngx.ctx.params = json.decode(ngx.req.get_body_data())
			elseif self.type == "application/x-www-form-urlencoded" then
				ngx.ctx.params = restia.utils.deepen(ngx.req.get_post_args())
			elseif self.type == "multipart/form-data" then
				local body_file = ngx.req.get_body_file()
				local data
				if body_file then
					local file = io.open(body_file)
					data = file:read("a")
					file:close()
				else
					data = ngx.req.get_body_data()
				end
				return multipart(data, self.headers.content_type):get_all()
			else
				error("Don't know how to handle type: "..self.type, 2)
			end
		end
	end

	return ngx.ctx.params
end

--- Returns the HTTP method of the current request.
-- @function method
-- @treturn string Method The request method
function get:method()
	return ngx.req.get_method()
end

local __headers = {
	__index = function(self, index)
		if type(index)=="string" and index:find("_") then
			return self[index:gsub("_", "-")]
		end
	end;
}
--- Returns a table containing all headers.
-- For missing headers, it tries replacing underscores with dashes.
-- @function headers 
-- @treturn table Headers
function get:headers()
	if not ngx.ctx.headers then
		ngx.ctx.headers = setmetatable(ngx.req.get_headers(), __headers)
	end

	return ngx.ctx.headers
end

--- An alias for headers.content_type.
-- @function type
-- @treturn string Content type header
function get:type()
	return (self.headers.content_type:match('^[^;]+')) -- Only up to the first comma :D
end

--- Returns the current hostname or address.
-- @function host
-- @treturn string Hostname or Address
function get:host()
	return ngx.var.host
end

--- Returns the path part of the current request URI
-- @function path
-- @treturn string Path part of the URI
function get:path()
	return ngx.var.uri
end

--- Wraps the lua-resty-cookie module and returns a cookie object for the current request.
-- @function cookie
-- @return Cookie object
function get:cookie()
	if not ngx.ctx.cookie then
		ngx.ctx.cookie = assert(cookie:new())
	end

	return ngx.ctx.cookie
end

return request
