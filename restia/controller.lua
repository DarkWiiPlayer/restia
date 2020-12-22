--- Loads configurations from files on demand.
-- @module restia.controller
-- @author DarkWiiPlayer
-- @license Unlicense

local restia = require 'restia'

local controller = {}

--- Handles the result of xpcall. Exits on error.
-- @param success Whether the function ran successfully.
-- @param ... A list of return values to be passed through.
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
-- @tparam function action The code that should run in "protected" mode to handle the request (a module name).
-- @tparam function handler The error handler, which may return a HTTP error code.
-- @return The return value of the action function.
function controller.xpcall(action, handler)
	return exit_on_failure(xpcall(function()
		return action(restia.request)
	end, handler))
end

--- Serves a controller. This is a higher-level wrapper to `controller.xpcall` that requires a module.
-- If no `action` is given, the module is assumed to return a handler function directly.
-- If the `action` is given, the module is treated as a table and deep-indexed with `action` to get the handler function.
-- @tparam string controllermodule The module name to `require` to get the controller.
-- @tparam[opt="error"] string errormodule The module name of the error handler.
-- @tparam[opt] string action The table path to the event handler.
-- @param ... Additional arguments to be passed to the handler.
function controller.serve(controllermodule, errormodule, action, ...)
	local handler = require('controller.'..controllermodule)
	if action then
		handler = restia.utils.deepindex(handler, action)
	end
	controller.xpcall(handler, require(errormodule or 'error'), ...)
end

return controller
