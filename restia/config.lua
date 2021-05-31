--- Loads configurations from files on demand.
-- @module restia.config
-- @author DarkWiiPlayer
-- @license Unlicense

local lfs = require 'lfs'

local utils = require 'restia.utils'

-- vim: set noexpandtab :miv --

local readfile = require 'restia.config.readfile'

local config = {}

local __metatable = {}
function __metatable:__index(index)
	if type(index)~="string" then return nil end
	local path = self.__dir..'/'..index
	local attributes = lfs.attributes(path)
	if attributes and attributes.mode=='directory' then
		return config.bind(path, self.__loaders)
	else
		for i, loader in ipairs(self.__loaders) do
			local result = loader(path)
			if result then
				rawset(self, index, result)
				return result
			end
		end
		return nil, "Could not load: "..tostring(index)
	end
end

function __metatable:__pairs()
	local _, dir = lfs.dir(self.__dir)
	local function next_config(dir)
		local file = dir:next()
		if file then
			local name = file:match("[^%.]+")
			if self[name] then
				return name, self[name]
			else
				return next_config(dir)
			end
		else
			return nil -- End of iteration
		end
	end
	return next_config, dir
end

config.pairs = __metatable.__pairs

--- Binds a table to a config directory.
-- The returned table maps keys to configurations, which are handled by
-- different "loaders". loaders are handlers that try loading a config entry in
-- a certain format and are tried  sequentially until one succeeds. If no
-- loader matches, nil is returned.
-- @tparam string dir Path to the directory to look in.
-- @tparam table loaders A table of loaders to use when attempting to load a configuration entry.
-- @treturn table config A table that maps to the config directory
-- @usage
-- 	local main_config = config.bind 'configurations'
-- 	main_config.foo.bar
-- 	-- Loads some file like foo.json or foo.yaml
-- 	-- in the configurations directory
function config.bind(dir, loaders)
	if type(loaders)~="table" then
		error("Attempt to bind config directory without any loaders", 2)
	end
	return setmetatable({__dir=dir, __loaders=loaders}, __metatable)
end

return config
