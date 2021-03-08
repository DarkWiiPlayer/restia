--- Loader for cosmo templates.
-- @module restia.config.cosmo

local cosmo = require 'cosmo'
local readfile = require 'restia.config.readfile'

--- Loads a cosmo template from a file and returns the compiled template.
-- Returns nil if no template can be found.
-- @treturn function Template
-- @function load
return function(name)
	name = tostring(name) .. '.cosmo'
	local text = readfile(name)
	if text then
		return assert(cosmo.compile(text, name))
	else
		return nil
	end
end
