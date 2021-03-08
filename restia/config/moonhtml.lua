--- Loader for MoonHTML files
-- @module restia.config.moonhtml


local template = require 'restia.template'

--- Loads and compiles a moonhtml template.
-- @treturn function template
-- @function load
return function(name)
	name = tostring(name) .. '.moonhtml'
	local file = io.open(name)
	if file then
		return assert(template.loadmoon(file:read("*a"), name))
	else
		return nil
	end
end
