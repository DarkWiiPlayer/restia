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

local commands = restia.commands
local utils = restia.utils
local c = restia.colors
local project = restia.bin.project

local I = utils.normalizeindent

local function uid()
	local id_u = io.popen("id -u")
	local id = tonumber(id_u:read())
	id_u:close()
	return id
end

local help = [[
Restia Commandline Utility
--------------------------

Available commands:
]]

local openresty = [[openresty -p . -c openresty.conf -g 'daemon off;' ]]

commands:add('new <directory>', [[
	Creates a new application in the selected directory.
	The default <directory> is 'application'.
]], function(name)
	name = name or 'application'
	utils.builddir(nil, {[name] = project.new()})
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
		filename = directory:gsub("/$", ""):gsub("$", "/man1/restia.1")
		local output = assert(io.open(filename, "w"))
		print("Installing manpage as " .. filename)
		output:write(restia.bin.manpage)
		output:close()
	end
end)

commands:add('help', [[
	Prints this help and exits.
]], function()
	print(help)
	for idx, command in ipairs(commands) do
		print((c('%{green}'..command.name):gsub('<.->', c.blue)))
		print((command.description:gsub('<.->', c.blue)))
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
