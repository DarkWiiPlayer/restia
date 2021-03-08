--- Loader for Skooma templates
-- @module restia.config.skooma

local skooma = require 'skooma'

local env = skooma.env -- This can safely get shadowed

local env = setmetatable({}, {__index = function(self, index)
	return _G[index] or env[index]
end})

env.render = skooma.serialize

--- Loads a Lua file with the Skooma environment and runs it.
-- Normally, the file should return a function
-- to follow restia template semantics.
-- @return The result of the template file.
-- @function load
return function(name)
	name = tostring(name)..'.skooma'
	local template = loadfile(name, "tb", env)()
	if template then
		return template
	end
end
