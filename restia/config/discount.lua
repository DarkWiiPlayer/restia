local discount = require 'discount'

return function(name)
	name = tostring(name) .. '.md'
	local file = io.open(name)
	if file then
		local html = discount(file:read("*a"))
		return function()
			return html
		end
	else
		return nil
	end
end
