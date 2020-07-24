--- Loads configurations from files on demand.
-- @module restia.config
-- @author DarkWiiPlayer
-- @license Unlicense

require 'warn'

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

local config = {}

--- A list containing the default loaders.
-- Each loader is also saved with a string key describing it;
-- this allows more easily copying a selection of default loaders
-- into a custom loader chain or wrap them in filters.
config.loaders = {}

function config.loaders:insert(name, func)
	table.insert(self, func)
	self[name] = func
end

--- Binds a table to a config directory.
-- The returned table maps keys to configurations, which are handled by different "loaders". loaders are handlers that try loading a config entry in a certain format and are tried  sequentially until one succeeds. If no loader matches, nil is returned.
-- @tparam string dir Path to the directory to look in.
-- @tparam table loaders A table of loaders to use when attempting to load a configuration entry.
-- @treturn table config A table that maps to the config directory
-- @usage
-- 	local main_config = config.bind 'configurations'
-- 	main_config.foo.bar
-- 	-- Loads some file like foo.json or foo.yaml
-- 	-- in the configurations directory
function config.bind(dir, loaders)
	loaders = loaders or config.loaders
	return setmetatable({__dir=dir}, {__index = function(self, index)
		if type(index)~="string" then return nil end
		for i, loader in ipairs(loaders) do
			local result = loader(self.__dir..'/'..index)
			if result then
				rawset(self, index, result)
				return result
			end
		end
	end})
end

--- Config loaders.
-- Functions that turn the entry name into a filename and attempt to load with some specific mechanism.
-- @section loaders

--- Binds a subdirectory
-- @function dir
-- @tparam string name Treated as a directory name as is
local lfs = try_require 'lfs'
if lfs then
	config.loaders:insert("dir", function(dir)
		local attributes = lfs.attributes(dir)
		if attributes and attributes.mode=='directory' then
			return config.bind(dir)
		end
	end)
else
	warn("Could not require lfs; directory recursion disabled")
end

--- Loads a file as plain text.
-- @function raw
-- @tparam string name Used as is without extension.
config.loaders:insert("raw", readfile)

--- Loads and runs a Lua file and returns its result.
-- @function loadlua
-- @tparam string name The extension `.lua` is added.
config.loaders:insert("lua", function(name)
	local f = loadfile(name..'.lua')
	return f and f() or nil
end)

--- Loads a JSON document and returns it as a table using cjson.
-- @function json
-- @tparam string name The extension `.json` is added.
local json = try_require 'cjson'
if json then
	config.loaders:insert("json", function(file)
		local raw = readfile(file..'.json')
		if raw then
			return json.decode(raw)
		end
	end)
else
	warn("Could not load cjson; all builtin json parsing disabled")
end

--- Loads a YAML file and returns it as a table using lyaml.
-- @function yaml
-- @tparam string name The extensions `.yaml` and `.yml` are both tried.
local yaml = try_require 'lyaml'
if yaml then
	config.loaders:insert("yaml", function(file)
		local raw = readfile(file..'.yml') or readfile(file..'.yaml')
		if raw then
			return yaml.load(raw)
		end
	end)
else
	warn("Could not load lyaml; all builtin yaml parsing disabled")
end

local cosmo = try_require 'cosmo'
if cosmo then
	--- Loads a cosmo template.
	-- This returns the plain cosmo template, which has to be
	-- manually printed to the client with `ngx.say`.
	-- @function cosmo
	-- @tparam string name The extension `.cosmo` is added.
	config.loaders:insert("cosmo", function(name)
		name = tostring(name) .. '.cosmo'
		local file = io.open(name)
		if file then
			return setmetatable(
				{raw=assert(cosmo.compile(file:read("*a"), name)), name=name},
				template.metatable
			)
		else
			return nil
		end
	end)
end

local template = try_require 'restia.template'
if template then
	if cosmo then
		--- Multistage template for compiled moonhtml + cosmo.
		-- Loads and renders a precompiled moonhtml template, then compiles the resulting string as a cosmo template.
		-- The resulting template renders a string which has to manually be sent to the client with `ngx.say`.
		-- @function lua_moonhtml_cosmo
		-- @tparam string name The extension `.cosmo.moonhtml.lua` is added.
		config.loaders:insert("lua_moonhtml_cosmo", function(name)
			name = tostring(name) .. '.cosmo.moonhtml.lua'
			local file = io.open(name)
			if file then
				local prerendered = utils.deepconcat(assert(template.loadlua(file:read("*a"), name)):render())
				return setmetatable(
					{raw=assert(cosmo.compile(prerendered)), name=name:gsub('%.moonhtml%.lua$', '')},
					template.metatable
				)
			else
				return nil
			end
		end)

		--- Multistage template for uncompiled moonhtml + cosmo.
		-- Loads and renders a moonhtml template, then compiles the resulting string as a cosmo template.
		-- The resulting template renders a string which has to manually be sent to the client with `ngx.say`.
		-- @function moonhtml_cosmo
		-- @tparam string name The extension `.cosmo.moonhtml` is added.
		config.loaders:insert("moonhtml_cosmo", function(name)
			name = tostring(name) .. '.cosmo.moonhtml'
			local file = io.open(name)
			if file then
				local prerendered = utils.deepconcat(assert(template.loadmoon(file:read("*a"), name)):render())
				return setmetatable(
					{raw=assert(cosmo.compile(prerendered)), name=name:gsub('%.moonhtml$', '')},
					template.metatable
				)
			else
				return nil
			end
		end)
	else
		warn("Could not load cosmo; All cosmo templating features disabled")
	end

	--- Loads a preompiled moonhtml template.
	-- Loads the file as a Lua file with the moonhtml environment using `restia.template`.
	-- @function lua_moonhtml
	-- @tparam string name The extension `.moonhtml.lua` is added.
	config.loaders:insert("lua_moonhtml", function(name)
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
	config.loaders:insert("moonhtml", function(name)
		name = tostring(name) .. '.moonhtml'
		local file = io.open(name)
		if file then
			return assert(template.loadmoon(file:read("*a"), name))
		else
			return nil
		end
	end)
else
	warn("Could not load restia.template; All builtin templating disabled")
end

return config
