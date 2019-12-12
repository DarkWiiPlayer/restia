-- Main module.
-- This is essentially just an autoloader for the submodules.
-- @module restia
-- @author DarkWiiPlayer
-- @license Unlicense
-- @usage
-- local restia = require 'restia'
-- assert(restia.template == require 'restia.template')

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
