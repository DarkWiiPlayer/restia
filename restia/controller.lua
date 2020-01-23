--- Loads configurations from files on demand.
-- @module restia.controller
-- @author DarkWiiPlayer
-- @license Unlicense

-- vim: set noexpandtab :miv --

--- Handles the result of xpcall. Exits on error.
local function handle(success, ...)
	if success then
		return ...
	else
		return ngx.exit(... or ngx.status)
	end
end

return function(fn, handler)
	return handle(xpcall(function()
		return fn(ngx.req.get_method())
	end, handler or function()
		ngx.status = 500
		ngx.say [[<h1>Error!</h1>]]
	end))
end
