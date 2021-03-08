--- Loader for markdown files using lua-discount
-- @module restia.config.discount

local discount = require 'discount'

--- Loads a markdown file and converts it into HTML.
-- Returns a function that returns a static string
-- to keep compatible with restia template semantics.
-- HTML-Conversion only happens once during loading.
-- @treturn function Template
-- @function load
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
