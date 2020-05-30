local accessors = require 'restia.accessors'

local get, set, request = accessors.new()

function get:params()
	if not ngx.ctx.params then
		ngx.ctx.params = ngx.req.get_uri_args()
	end

	return ngx.ctx.params
end

function get:method()
	return ngx.req.get_method()
end

return request
