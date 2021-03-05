local skooma = require 'skooma'

local env = skooma.env -- This can safely get shadowed
local env = setmetatable({}, {__index = function(self, index)
	return _G[index] or env[index]
end})

return function(name)
	name = tostring(name)..'.skooma'
	local template = loadfile(name, "tb", env)
	if template then
		return function(...)
			return skooma.serialize.html(template(...))
		end
	end
end
