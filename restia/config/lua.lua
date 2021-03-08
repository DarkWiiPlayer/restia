--- Loader for Lua files
-- @module restia.config.lua

--- Loads and compiles a Lua file and runs it.
-- Returns the result of running the Lua file.
-- If running the code immediately is not desired,
-- it has to be returned as a function.
-- @return The result of the Lua file after running it
-- @function load
return function(name)
	local f = loadfile(name..'.lua')
	return f and f() or nil
end
