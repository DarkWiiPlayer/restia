local template = require 'restia.template'

return function(name)
	name = tostring(name) .. '.moonhtml'
	local file = io.open(name)
	if file then
		return assert(template.loadmoon(file:read("*a"), name))
	else
		return nil
	end
end
