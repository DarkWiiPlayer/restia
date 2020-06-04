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

local get, set, request = restia.accessors.new()

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

return request
