--- Loads configurations from files on demand.
-- @module restia.handler
-- @author DarkWiiPlayer
-- @license Unlicense

local restia = require 'restia'

local handler = {}

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
function handler.xpcall(action, handler)
	return exit_on_failure(xpcall(function()
		return action(restia.request)
	end, handler))
end

--- Serves a handler. This is a higher-level wrapper to `handler.xpcall` that requires a module or loads a file.
-- If no `action` is given, the module is assumed to return a handler function directly.
-- If the `action` is given, the module is treated as a table and deep-indexed with `action` to get the handler function.
-- @tparam string handlermodule Either a module name to `require` or filename to `loadfile` to get the handler.
-- @tparam[opt="error"] string errormodule The module name of the error handler.
-- @tparam[opt] string action Path to deep-index the handler module with to get handler function.
-- @param ... Additional arguments to be passed to the handler.
function handler.serve(handlermodule, errormodule, action, ...)
	local fn
	if handlermodule:find("%.lua$") then
		fn = assert(dofile(handlermodule))
	else
		fn = require(handlermodule)
	end
	if action then
		fn = restia.utils.deepindex(fn, action)
	end
	handler.xpcall(fn, require(errormodule or 'error'), ...)
end

return handler
