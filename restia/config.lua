--- Loads configurations from files on demand.
-- @module restia.config
-- @author DarkWiiPlayer
-- @license Unlicense

local utils = require 'restia.utils'

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
		if type(index)~="string" then return nil end
		for i, finder in ipairs(config.finders) do
			local result = finder(self.__dir..'/'..index)
			if result then
				rawset(self, index, result)
				return result
			end
		end
	end})
end

--- Config finders.
-- Functions that turn the entry name into a filename and attempt to load with some specific mechanism.
-- @section finders

--- Loads a file as plain text.
-- @function readfile
-- @tparam string name Used as is without extension.
config.finders:insert(readfile)

--- Loads and runs a Lua file and returns its result.
-- @function loadlua
-- @tparam string name The extension `.lua` is added.
config.finders:insert(function(name)
	local f = loadfile(name..'.lua')
	return f and f() or nil
end)

--- Loads a JSON document and returns it as a table using cjson.
-- @function cjson
-- @tparam string name The extension `.json` is added.
local json = try_require 'cjson'
if json then
	config.finders:insert(function(file)
		local raw = readfile(file..'.json')
		if raw then
			return json.decode(raw)
		end
	end)
end

--- Loads a YAML file and returns it as a table using lyaml.
-- @function lyaml
-- @tparam string name The extensions `.yaml` and `.yml` are both tried.
local yaml = try_require 'lyaml'
if yaml then
	config.finders:insert(function(file)
		local raw = readfile(file..'.yml') or readfile(file..'.yaml')
		if raw then
			return yaml.load(raw)
		end
	end)
end

--- Binds a subdirectory
-- @function lfs
-- @tparam string name Treated as a directory name as is
local lfs = try_require 'lfs'
if lfs then
	config.finders:insert(function(dir)
		local attributes = lfs.attributes(dir)
		if attributes and attributes.mode=='directory' then
			return config.bind(dir)
		end
	end)
end

local cosmo = try_require 'cosmo'
local template = try_require 'restia.template'
if template then
	if cosmo then
		--- Loads a cosmo template.
		-- This returns the plain cosmo template, which has to be
		-- manually printed to the client with `ngx.say`.
		-- @function cosmo
		-- @tparam string name The extension `.cosmo` is added.
		config.finders:insert(function(name)
			name = tostring(name) .. '.cosmo'
			local file = io.open(name)
			if file then
				return setmetatable(
					{raw=assert(cosmo.compile(file:read("*a"), name))},
					template.metatable
				)
			else
				return nil
			end
		end)

		--- Multistage template for compiled moonhtml + cosmo.
		-- Loads and renders a precompiled moonhtml template, then compiles the resulting string as a cosmo template.
		-- The resulting template renders a string which has to manually be sent to the client with `ngx.say`.
		-- @function cosmo_moonhtml_lua
		-- @tparam string name The extension `.cosmo.moonhtml.lua` is added.
		config.finders:insert(function(name)
			name = tostring(name) .. '.cosmo.moonhtml.lua'
			local file = io.open(name)
			if file then
				local prerendered = utils.rconcat(assert(template.loadlua(file:read("*a"), name)):render())
				return setmetatable(
					{raw=assert(cosmo.compile(prerendered))},
					template.metatable
				)
			else
				return nil
			end
		end)

		--- Multistage template for uncompiled moonhtml + cosmo.
		-- Loads and renders a moonhtml template, then compiles the resulting string as a cosmo template.
		-- The resulting template renders a string which has to manually be sent to the client with `ngx.say`.
		-- @function cosmo_moonhtml
		-- @tparam string name The extension `.cosmo.moonhtml` is added.
		config.finders:insert(function(name)
			name = tostring(name) .. '.cosmo.moonhtml'
			local file = io.open(name)
			if file then
				local prerendered = utils.rconcat(assert(template.loadmoon(file:read("*a"), name)):render())
				return setmetatable(
					{raw=assert(cosmo.compile(prerendered))},
					template.metatable
				)
			else
				return nil
			end
		end)
	end

	--- Loads a preompiled moonhtml template.
	-- Loads the file as a Lua file with the moonhtml environment using `restia.template`.
	-- @function moonhtml_lua
	-- @tparam string name The extension `.moonhtml.lua` is added.
	config.finders:insert(function(name)
		name = tostring(name) .. '.moonhtml.lua'
		local file = io.open(name)
		if file then
			return assert(template.loadlua(file:read("*a"), name))
		else
			return nil
		end
	end)

	--- Loads a moonhtml template.
	-- Loads the file as a Moonscript file with the moonhtml environment using `restia.template`.
	-- @function moonhtml
	-- @tparam string name The extension `.moonhtml` is added.
	config.finders:insert(function(name)
		name = tostring(name) .. '.moonhtml'
		local file = io.open(name)
		if file then
			return assert(template.loadmoon(file:read("*a"), name))
		else
			return nil
		end
	end)
end

return config
