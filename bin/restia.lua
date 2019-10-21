#!/usr/bin/env lua
----------
-- ## Restia on the command line.
-- Generates scaffolding for new projects.
-- @author DarkWiiPlayer
-- @license Unlicense
-- @script restia

local commands = require 'restia.commands'
local utils = require 'restia.utils'
local c = require 'restia.colors'

local help = [[
Restia Commandline Utility
--------------------------

Available commands:
]]

local nginx = [[nginx -p . -c openresty.conf -g 'daemon off;' ]]

local test_views_load = [===========[
restia = require 'restia'
utils = require 'restia.utils'

describe 'View', ->
	before_each ->
		_G.ngx = {print: ->}
	for file in utils.files 'views'
		describe file, ->
			it 'should load', ->
				assert.truthy restia.templates[file\gsub('%..-$', '')]
]===========]

local openresty_conf =
[===========[
error_log logs/error.log;
error_log logs/error.log  notice;
error_log logs/error.log  info;
pid openresty.pid;

events {
	worker_connections	1024;
}

http {
	lua_code_cache off; # Change this for production

	lua_package_path 'lib/?.lua;lib/?/init.lua;lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua;;';
	lua_package_cpath 'lib/?.so;lib/?/init.so;lua_modules/lib/lua/5.1/?.so;lua_modules/lib/lua/5.1/?/init.so;;';

	log_format  main '$remote_addr - $remote_user [$time_local] "$request" '
	                 '$status $body_bytes_sent "$http_referer" '
	                 '"$http_user_agent" "$http_x_forwarded_for"';

	access_log logs/access.log main;
	keepalive_timeout 65;

	default_type text/html;
	charset utf-8;

	init_by_lua_block {
		local restia = require 'restia'
		local config = require 'restia.config'
		restia.templates.__prefix = 'views/'
		package.loaded.config = config.bind 'config'
	}

	server {
		listen 8080;

		include routes/*;
	}
}
]===========]

local busted_conf = [==========[
return {
  _all = {
    lpath = 'lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua';
    cpath = 'lua_modules/lib/lua/5.1/?.lua;lua_modules/lib/lua/5.1/?/init.lua';
  };
}
]==========]

commands:add('new <directory>', [[
	Creates a new application in the selected directory.
	The default <directory> is 'application'.
]], function(name)
	name = name or 'application'
	utils.build_dir(nil, {
		[name] = {
			['.gitignore'] = table.concat({
				'lua_modules/*',
				'.luarocks',
				'.secret/*',
				'logs/*',
				'*.pid',
			}, "\n");
			['.secret'] = {};
			['openresty.conf'] = openresty_conf;
			routes = {
				root = 'location = / {\n\tcontent_by_lua_file "controllers/front.lua";\n}';
				static = 'location /static {\n\tdeny all;\n}'
					..'\nlocation /favicon.png {\n\talias static/favicon.png;\n}'
					..'\nlocation ~ ^/(styles|javascript|images)/(.*) {\n\talias static/$1/$2;\n}';
			};
			controllers = {
				['front.lua'] = 'local restia = require "restia"\n\nrestia.templates["front"](require("config").i18n["en"])';
			};
			views = {
				['front.moonhtml'] = 'strings = ...\n\nh1 strings.title';
			};
			models = {};
			lib = {};
			spec = {
				views = {
					['load_spec.moon'] = test_views_load;
				};
			};
			config = {
				i18n = {
					['en.yaml'] = 'title: My Website';
				};
			};
			['.busted'] = busted_conf;

			logs = {};

			-- Create local rock tree
			['.luarocks'] = {['default-lua-version.lua'] = 'return "5.1"'};
			lua_modules = {};
		};
	})
end)

commands:add('test <lua> <configuration>', [[
	Runs several tests:
	- 'nginx -t' to check the nginx configuration
	- 'luacheck' for static analisys of the projects Lua files
	- 'busted'   to run the projects tests
	<lua> is the lua version to run busted with. default is 'luajit'.
	<configuration> defaults to 'openresty.conf'.
]], function(lua, configuration)
	lua = lua or 'luajit'
	configuration = configuration or 'openresty.conf'
  os.exit(
    os.execute(nginx:gsub('openresty.conf', configuration)..'-t')
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
	os.execute(nginx:gsub('openresty.conf', config))
end)

commands:add('reload <configuration>', [[
	Reload the configuration of a running server.
	Default for <configuration> is 'openresty.conf'.
]], function(config)
	config = config or 'openresty.conf'
	os.execute(nginx:gsub('openresty.conf', config)..'-s reload')
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
