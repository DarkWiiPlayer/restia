--- Loads moonhtml-cosmo-multistage templates
-- @module restia.config.moonhtml_cosmo

local template = require 'restia.template'
local cosmo = require 'cosmo'

--- Loads a MoonHTML template, renders it immediately and
-- compiles it to a cosmo template.
-- @treturn function Template
-- @function load
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
