-- Autoloader for scaffolds.
-- This is essentially just an autoloader for the submodules.
-- @module restia.scaffold
-- @author DarkWiiPlayer
-- @license Unlicense

local scaffold = {}

local name = ...

setmetatable(scaffold, {
	__index = function(self, key)
		local module = require(name..'.'..key)
		rawset(self, key, module)
		return module
	end
})

return scaffold
