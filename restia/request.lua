--- A helper "object" that provides common request-related information as
-- attributes. Most functions are either fast or memoized, so the user does not
-- need to take care of caching values outside of very crytical code.
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

local request = {}

--- "Offers" a set of content types during content negotiation.
-- Given a set of possible content types, it tries figuring out what the client
-- wants and picks the most fitting content handler. Automatically runs the
-- handler and sends the result to the client. See `restia.negotiator.pick` for
-- how to pass the handlers.
-- @tparam table available A map from content-types to handlers. Either as a plain key-value map or as a sequence of key-value pairs in the form of two-element sequences.
function request:offer(available)
	local content_type, handler =
		restia.negotiator.pick(self.headers.accept, available)

	ngx.header["content-type"] = content_type
	if handler then
		return ngx.say(handler(self))
	else
		error("No suitable request handler found", 2)
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
			if self.type == "application/json" then
				local json = require 'cjson'
				ngx.req.read_body()
				ngx.ctx.params = json.decode(ngx.req.get_body_data())
			else
				ngx.req.read_body()
				ngx.ctx.params = restia.utils.deepen(ngx.req.get_post_args())
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
	return self.headers.content_type
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

return request
