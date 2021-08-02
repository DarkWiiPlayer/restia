local skooma = require 'skooma'

local restia_skooma = {
	path = "?.skooma";
}

local function map(fn, tab)
	local result = {}
	for key, value in ipairs(tab) do
		result[key] = fn(value)
	end
	return result
end

local function index(self, index)
	local meta = getmetatable(self)
	return _G[index] or meta.__env[index]
end

local function newindex(self, index)
	error("Attempting to set global "..index.." in skooma environment", 2)
end

function restia_skooma.new()
	return setmetatable({map=map,render=skooma.serialize}, {__index=index, __newindex=newindex, __env=skooma.env})
end

restia_skooma.default = restia_skooma.new()

local skooma_load = skooma.load
table.insert(package.loaders or package.searchers, function(name)
	return skooma_load(restia_skooma.default, restia_skooma.path, name)
end)

return restia_skooma
