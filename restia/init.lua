--- Main module.
-- Sets up an xhMoon environment and adds the utility functions.
-- @module restia
-- @author DarkWiiPlayer
-- @license Unlicense

local restia = {}

local name = ...

setmetatable(restia, {
	__index = function(self, key)
		local module = require(name..'.'..key)
		rawset(self, key, module)
		return module
	end
})

return restia
