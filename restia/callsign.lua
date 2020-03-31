--- A very simple helper function.
-- @usage
-- 	local msg = restia.callsign ()
--
-- 	msg:error 'You have made a mistake'
-- 	msg:info 'No actions have been committed'
--
-- 	for _, m in pairs(msg) do
-- 		print(m.class, m.message)
-- 	end

local meta = {}

function meta:__index(key)
	if type(key) == "string" then
		self[key] = function(self, message)
			table.insert(self, { class=key, message=message })
		end
		return self[key]
	end
end

return function()
	return setmetatable({}, meta)
end
