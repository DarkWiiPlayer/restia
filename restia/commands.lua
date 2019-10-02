local utils = require 'restia.utils'

local commands = {}

function commands:add(name, description, fn)
	self[name:match('^[^ ]+')] = fn
	table.insert(self, {name=name, description=description})
end

return commands
