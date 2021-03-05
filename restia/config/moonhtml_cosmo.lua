local template = require 'restia.template'
local cosmo = require 'cosmo'

return function(name)
	name = tostring(name) .. '.cosmo.moonhtml'
	local file = io.open(name)
	if file then
		local prerendered = utils.deepconcat(assert(template.loadmoon(file:read("*a"), name)):render())
		return setmetatable(
		{raw=assert(cosmo.compile(prerendered)), name=name:gsub('%.moonhtml$', '')},
		template.metatable
		)
	else
		return nil
	end
end
