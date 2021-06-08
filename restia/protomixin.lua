--- Resolves a missing key in a table to one of its mixins (in order)
local function resolve(tab, key)
	local mt = getmetatable(tab)
	for i=mt.mixins,0,-1 do
		if mt[i][key] then
			return mt[i][key]
		end
	end
end

--- Adds a new mixin to an object.
-- Creates the object if it's nil.
local function new(parent, target)
	target = type(target)=="table" and target or {}
	local mt = getmetatable(target)
	if mt and mt.mixins then
		mt.mixins = mt.mixins+1
		mt[mt.mixins] = parent
		return target
	else
		return setmetatable(target, {mixins=0,[0]=parent, __index=resolve, __call=new})
	end
end

return { new=new, resolve=resolve }
