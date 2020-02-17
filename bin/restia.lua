#!/usr/bin/env lua
----------
-- ## Restia on the command line.
-- Generates scaffolding for new projects.
-- Call `restia help` to get a detailed list of commands.
-- @author DarkWiiPlayer
-- @license Unlicense
-- @script restia

math.randomseed(os.time())

local commands = require 'restia.commands'
local utils = require 'restia.utils'
local c = require 'restia.colors'

local help = [[
Restia Commandline Utility
--------------------------

Available commands:
]]

local nginx = [[nginx -p . -c openresty.conf -g 'daemon off;' ]]

local front_controller =
[===========[
require('restia.controller').xpcall(function()
	local views = require("views")
	local config = require("config")
	local secret = require("restia.secret")

	local title = foo

	return views.front(config.i18n[ngx.var.lang])
end, require 'error')
]===========]

local error_handler =
[===========[
local json = require 'cjson'
local views = require 'views'

return function(message)
   ngx.log(ngx.ERR, debug.traceback(message))
   ngx.status = 500

   local err if ngx.var.dev=="true" then
      err = {
         code = ngx.status;
         message = message:match('^[^\n]+');
         description = debug.traceback(message, 3);
      }
   else
      err = {
         code = ngx.status;
         message = "There has been an error";
         description = "Please contact a site administrator if this error persists";
      }
   end

   local content_type = ngx.header['content-type']
   if content_type == 'application/json' then
      ngx.say(json.encode(err))
   else
      if views.error then
         views.error(err)
      else
         ngx.say('error '..tostring(ngx.status))
      end
   end
   return ngx.HTTP_INTERNAL_SERVER_ERROR
end
]===========]

local test_views_load = [===========[
restia = require 'restia'
utils = require 'restia.utils'

describe 'View', ->
	before_each ->
		_G.ngx = {print: ->}
	for file in utils.files 'views'
		describe file, ->
			it 'should load', ->
				assert.truthy require("restia.config").bind('views')[file\gsub('^views/', '')\gsub('%..-$', '')]
]===========]

local openresty_conf =
[===========[
error_log logs/error.log	info;
pid openresty.pid;

events {
	worker_connections	1024;
}

http {
	lua_code_cache off; # Change this for production

	lua_package_path 'lib/?.lua;lib/?/init.lua;lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua;;';
	lua_package_cpath 'lib/?.so;lib/?/init.so;lua_modules/lib/lua/5.1/?.so;lua_modules/lib/lua/5.1/?/init.so;;';

	log_format	main
		'$remote_addr - $remote_user [$time_local] "$request" '
		'$status $body_bytes_sent "$http_referer" '
		'"$http_user_agent" "$http_x_forwarded_for"';

	access_log logs/access.log main;
	keepalive_timeout 65;

	default_type text/html;
	charset utf-8;

	init_by_lua_block {
		-- Preload modules
		require 'restia'
		require 'config'
		require 'views'

		-- Error view to be preloaded lest the error handler fails
		-- (Openresty bug related to coroutines)
		local _ = require('views').error
	}

	server {
		listen 8080;

		include config/*.conf;
		include locations/*;
	}
}
]===========]

local busted_conf =
[==========[
return {
	_all = {
		lpath = 'lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua';
		cpath = 'lua_modules/lib/lua/5.1/?.lua;lua_modules/lib/lua/5.1/?/init.lua';
	};
}
]==========]

local luacheck_conf =
[==========[
std = 'ngx_lua'
]==========]


commands:add('new <directory>', [[
	Creates a new application in the selected directory.
	The default <directory> is 'application'.
]], function(name)
	name = name or 'application'
	utils.build_dir(nil, {
		[name] = {
			['.gitignore'] = table.concat({
				'.*',
				'!.busted',
				'!.luacheckrc',
				'!.luarocks',
				'*_temp',
				'logs/*',
				'*.pid',
			}, "\n");
			['.secret'] = {
				key = utils.randomhex(64)
			};
			['openresty.conf'] = openresty_conf;
			locations = {
				root = 'location = / { content_by_lua_file "controllers/front.lua"; }\n'
				..'location / {\n\tlocation ~ ^/(.*) { content_by_lua_file controllers/$1.lua; }\n}';
				static =
					'\nlocation /favicon.png {\n\talias static/img/favicon.png;\n}' ..
					'\nlocation /favicon.ico {\n\talias static/img/favicon.ico;\n}' ..
					'\nlocation ^~ /src/ {\n\tdeny all;\n\talias static;\n\tlocation ~ ^/src/(css|js|img)/ {\n\t\tallow all;\n\t}\n}'
			};
			['error.lua'] = error_handler;
			controllers = {
				['front.lua'] = front_controller;
			};
			views = {
				['front.moonhtml'] = 'strings = ...\n\nh1 strings.title';
				['error.cosmo.moonhtml'] = table.concat({
					'h1 "ERROR $code"';
					'h2 "$message"';
					'p -> pre "$description"';
				}, '\n');
			};
			models = {};
			lib = {
				['views.lua'] = table.concat({
					'local restia = require "restia"';
					'return restia.config.bind "views"';
				}, "\n");
				['config.lua'] = table.concat({
					'local restia = require "restia"';
					'local config = restia.config.bind "config"';
					'config.secret = restia.config.bind ".secret"';
					'return config';
				}, "\n");
			};
			spec = {
				views = {
					['load_spec.moon'] = test_views_load;
				};
			};
			config = {
				i18n = {
					['en.yaml'] = 'title: My Website';
				};
				['settings.conf'] = [[set $lang en; set $dev true;]]
			};
			['.busted'] = busted_conf;
			['.luacheckrc'] = luacheck_conf;

			logs = {};

			-- Create local rock tree
			['.luarocks'] = {['default-lua-version.lua'] = 'return "5.1"'};
			lua_modules = {['.gitignore'] = '*\n!.gitignore'};

			-- Shell script to install dependancies
			dependancies = [[luarocks install restia --dev]];
		};
	})
end)

commands:add('test <lua> <configuration>', [[
	Runs several tests:
	- 'nginx -t' to check the nginx configuration
	- 'luacheck' for static analisys of the projects Lua files
	- 'busted'	 to run the projects tests
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
	os.execute(nginx:gsub('openresty.conf', config)..' -q')
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
