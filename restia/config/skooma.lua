--- Loader for Skooma templates
-- @module restia.config.skooma

local skooma = require 'restia.skooma'

--- Loads a Lua file with the Skooma environment and runs it.
-- Normally, the file should return a function
-- to follow restia template semantics.
-- @return The result of the template file.
-- @function load
return function(name)
	name = tostring(name)..'.skooma'
	local template = loadfile(name, "tb", skooma.default)
	template = template and template()
	if template then
		return template
	end
end
