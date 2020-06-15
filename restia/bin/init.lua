-- Bin module.
-- This is essentially just an autoloader for the submodules.
-- @module restia.bin
-- @author DarkWiiPlayer
-- @license Unlicense

local bin = {}

local name = ...

setmetatable(bin, {
	__index = function(self, key)
		local module = require(name..'.'..key)
		rawset(self, key, module)
		return module
	end
})

return bin
