--- Loads configurations from files on demand.
-- @module restia.controller
-- @author DarkWiiPlayer
-- @license Unlicense

-- vim: set noexpandtab :miv --

local controller = {}

--- Handles the result of xpcall. Exits on error.
local function exit_on_failure(success, ...)
	if success then
		return ...
	else
		return ngx.exit(tonumber(...) or ngx.status)
	end
end

--- Similar to Luas `xpcall`, but exits the nginx request in case of error.
-- A custom message handler takes care of logging and rendering an error message.
-- This function is still very much work in progress and its behavior may change.
-- @tparam function code The code that should run in "protected" mode
-- @tparam function handler The error handler, which may return a HTTP error code
function controller.xpcall(fn, handler)
	return exit_on_failure(xpcall(function()
		return fn(ngx.req.get_method())
	end, handler))
end

return controller
