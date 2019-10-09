--- Loads configurations from files on demand.
-- @module config

-- vim: set noexpandtab :miv --

--- Tries requiring a module.
-- Returns the module if successful or nil otherwise.
-- @tparam string modname The name of the module as would be passed to `require`
local function try_require(modname)
	local success, result = pcall(require, modname)
	if success then
		return result
	else
		return nil, result
	end
end

--- Reads a file.
-- Returns the files contents if successful or nil otherwise.
-- @tparam string path The path to the file to read
local function readfile(path)
	local f = io.open(path)
	if not f then return end
	local result = f:read("*a")
	f:close()
	return result
end

local config = {
	finders = {insert = table.insert};
}

--- Binds a table to a config directory.
-- The returned table maps keys to configurations, which are handled by different "finders". Finders are handlers that try loading a config entry in a certain format and are tried  sequentially until one succeeds. If no finder matches, nil is returned.
-- @tparam dir Path to the directory to look in.
-- @treturn table config A table that maps to the config directory
-- @usage
-- 	local main_config = config.bind 'configurations'
-- 	main_config.foo.bar
-- 	-- Loads some file like foo.json or foo.yaml
-- 	-- in the configurations directory
function config.bind(dir)
	return setmetatable({__dir=dir}, {__index = function(self, index)
		for i, finder in ipairs(config.finders) do
			local result = finder(self.__dir..'/'..index)
			if result then
				rawset(self, index, result)
				return result
			end
		end
	end})
end

local json = try_require 'cjson'
if json then
	config.finders:insert(function(file)
		local raw = readfile(file..'.json')
		if raw then
			return json.decode(raw)
		end
	end)
end

local yaml = try_require 'lyaml'
if yaml then
	config.finders:insert(function(file)
		local raw = readfile(file..'.yml') or readfile(file..'.yaml')
		if raw then
			return yaml.load(raw)
		end
	end)
end

local lfs = try_require 'lfs'
if lfs then
	config.finders:insert(function(dir)
		local attributes = lfs.attributes(dir)
		if attributes and attributes.mode=='directory' then
			return config.bind(dir)
		end
	end)
end

config.finders:insert(readfile)

return config
