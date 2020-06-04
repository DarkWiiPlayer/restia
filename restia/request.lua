local restia = require 'restia'

local get, set, request = restia.accessors.new()

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
