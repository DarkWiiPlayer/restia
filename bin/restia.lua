#!/usr/bin/env lua
----------
-- ## Restia on the command line.
-- Generates scaffolding for new projects.
-- Call `restia help` to get a detailed list of commands.
-- @author DarkWiiPlayer
-- @license Unlicense
-- @script restia

math.randomseed(os.time())

local restia = require 'restia'
local arrr = require 'arrr'

local commands = restia.bin.commands
local c = restia.colors

local function uid()
	local id_u = io.popen("id -u")
	local id = tonumber(id_u:read())
	id_u:close() return id
end

local builtin_scaffolds = {
	app = "Generic web-application using Openresty";
}

local help = [[
Restia Commandline Utility
--------------------------

Available commands:
]]

local openresty = [[openresty -p . -c openresty.conf -g 'daemon off;' ]]

commands:add('new <scaffold>', [[
	Generates a builtin scaffold
	(shortcut for restia scaffold restia.scaffold.<scaffold>)
]], function(name, ...)
	if name and builtin_scaffolds[name] then
		commands.scaffold("restia.scaffold."..tostring(name), ...)
	else
		print("Builtin Scaffolds:")
		for scaffold, description in pairs(builtin_scaffolds) do
			print("", c.yellow(scaffold) .. ": " .. description)
		end
	end
end)

commands:add('test <lua> <configuration>', [[
	Runs several tests:
	- 'openresty -t' to check the openresty configuration
	- 'luacheck' for static analisys of the projects Lua files
	- 'busted'	 to run the projects tests
	<lua> is the lua version to run busted with. default is 'luajit'.
	<configuration> defaults to 'openresty.conf'.
]], function(lua, configuration)
	lua = lua or 'luajit'
	configuration = configuration or 'openresty.conf'
	os.exit(
		os.execute(openresty:gsub('openresty.conf', configuration)..'-t')
		and os.execute('luacheck --exclude-files lua_modules/* --exclude-files .luarocks/* -q .')
		and os.execute('busted --lua '..lua..' .')
		or 1
	)
end)

commands:add('run <configuration>', [[
	Runs an application in the current directory.
	Default for <configuration> is 'openresty.conf'.
]], function(config)
	config = config or 'openresty.conf'
	os.execute(openresty:gsub('openresty.conf', config)..' -q')
end)

commands:add('reload <configuration>', [[
	Reload the configuration of a running server.
	Default for <configuration> is 'openresty.conf'.
]], function(config)
	config = config or 'openresty.conf'
	os.execute(openresty:gsub('openresty.conf', config)..'-s reload')
end)

commands:add('compile <resource> <output>', [[
	Compiles an resource (most commonly a template).
	<resource> Config path to the resource
	<output> The output file to save the rendered resource to.
	--root <root> The config root to bind to
	--arguments <path> Config path to an argument to pass to the resource
	The default argument is the config root.
	THe default config root is the current directory.
]], function(...)
	local options = arrr {
		{ "Binds to another root directory", "-root", "-r", "root" };
		{ "Passes this config entry as argument to the resource", "--arguments", "-a", "path" };
	} { ... }
	local config = restia.config.bind(options.root or ".")
	local outfile = options[2] or options[1]:match("[^%.]+$")
	local resource = restia.utils.deepindex(config, options[1])
	if not resource then
		error("Could not find resource: "..options[1])
	end
	local arguments = options.arguments and restia.utils.deepindex(config, options.arguments) or config
	local result = resource(arguments)
	if type(result)=="table" then
		result = restia.utils.deepconcat(result)
	elseif type(result)=="function" then
		result = string.dump(result)
	end
	restia.utils.builddir { [outfile] = result }
end)

commands:add('manpage <directory>', [[
	Installs restias manpage.
	<directory> Where to install the manpage.
	Defaults to:
	- /usr/local/man when executed as root
	- ~/.local/share/man
	(Remember to run mandb afterwards to update the database)
]], function(directory)
	if not directory then
		if uid() == 0 then
			directory = '/usr/local/man'
		else
			directory = os.getenv("HOME") .. '/.local/share/man'
		end
	end

	if directory == "-" then
		print(restia.bin.manpage)
	else
		local filename = directory:gsub("/$", ""):gsub("$", "/man1/restia.1")
		local output = assert(io.open(filename, "w"))
		print("Installing manpage as " .. filename)
		output:write(restia.bin.manpage)
		output:close()
	end
end)

commands:add('scaffold <module> <scaffold-options>', [[
	Generates a new scaffold from a module.
]], function(name, ...)
	if not name then
		return commands.help("scaffold")
	end
	local tree = require(name){...}
	restia.utils.builddir(".", tree)
end)

commands:add('help <command>', [[
	Prints help and exits.
]], function(name)
	if name then
		local found = false
		for idx, command in ipairs(commands) do
			if command.name:find(name) then
				print((c('%{green}'..command.name):gsub('<.->', c.blue):gsub('%-%-%a+', c.yellow)))
				print((command.description:gsub('<.->', c.blue):gsub('%-%-%a+', c.yellow)))
				found = true
			end
		end
		if not found then
			print("No restia command matching your query: "..c.yellow(name))
		end
	else
		print(help)
		for idx, command in ipairs(commands) do
			print((c('%{green}'..command.name):gsub('<.->', c.blue):gsub('%-%-%a+', c.yellow)))
			print((command.description:gsub('<.->', c.blue):gsub('%-%-%a+', c.yellow)))
		end
	end
end)

local command = commands[...]

if command then
	command(select(2, ...))
else
	if (...) then
		print('Unknown command: '..c.red(...))
	else
		commands.help()
	end
end
