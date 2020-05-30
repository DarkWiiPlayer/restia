--- Implements OO-like "attributes" using metatables.
-- @module restia.attributes
-- @author DarkWiiPlayer
-- @license Unlicense
local module = {}

--- Returns a pair of accessor tables and the object
-- @tparam table new The object to be proxied. If missing, a new table is created.
-- @treturn table get Table of getter methods
-- @treturn table set Table of setter methods
-- @treturn table new The new proxied object
-- @usage
-- 	local get, set, obj = restia.attributes.new { foo = 1 }
--		function set:bar(value) self.foo=value end
--		function get:bar() return self.foo end
--		obj.bar = 20 -- calls the setter method
--		print(obj.bar) -- calls the getter method, prints 20
--		print(obj.foo) -- accesses the field directly, also prints 20
--		print(obj.baz) -- raises an unknown property error
function module.new(new)
	if type(new)~="table" then new={} end
	local get, set = {}, {}
	local proxy = setmetatable(new, {
		__index = function(self, index)
			if get[index] then
				return get[index](self)
			else
				error("Attempting to get unknown property: '"..index.."'", 2)
			end
		end;
		__newindex = function(self, index, value)
			if set[index] then
				return set[index](self, value)
			else
				error("Attempting to set unknown property: '"..index.."'", 2)
			end
		end;
	})
	return get, set, proxy
end

return module
