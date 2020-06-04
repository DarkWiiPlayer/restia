local restia = require 'restia'

local get, set, request = restia.accessors.new()

function get:params()
	if not ngx.ctx.params then
		ngx.ctx.params = restia.utils.deepen(ngx.req.get_uri_args())
	end

	return ngx.ctx.params
end

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
function get:headers()
	if not ngx.ctx.headers then
		ngx.ctx.headers = setmetatable(ngx.req.get_headers(), __headers)
	end

	return ngx.ctx.headers
end

function get:type()
	return self.headers.content_type
end

function get:host()
	return ngx.var.host
end

return request
