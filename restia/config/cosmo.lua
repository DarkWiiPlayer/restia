local cosmo = require 'cosmo'
local readfile = require 'restia.config.readfile'

return function(name)
	name = tostring(name) .. '.cosmo'
	local text = readfile(name)
	if text then
		return assert(cosmo.compile(text, name))
	else
		return nil
	end
end
