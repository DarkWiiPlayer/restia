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

function get:host()
	return ngx.var.host
end

return request
