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

local I = utils.normalize_indent

local help = [[
Restia Commandline Utility
--------------------------

Available commands:
]]

local nginx = [[nginx -p . -c openresty.conf -g 'daemon off;' ]]

commands:add('new <directory>', [[
	Creates a new application in the selected directory.
	The default <directory> is 'application'.
]], function(name)
	local dir = {
		['.gitignore'] =
		I[============[
			*_temp
			*.pid
		]============];
		['.secret'] = {
			key = utils.randomhex(64);
			[".gitignore"] = "*\n!.gitignore";
		};
		['openresty.conf'] =
		I[===========[
			error_log logs/error.log	info;
			pid openresty.pid;

			worker_processes auto;
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
					local restia = require 'restia'
					require 'config'
					require 'views'

					restia.template.require 'template.cosmo'

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
		]===========];
		locations = {
			root = I[[
				location = / {
					content_by_lua_file "controllers/front.lua";
				}
				location / {
					if (-f controllers/$uri.lua) { content_by_lua_file controllers/$uri.lua; }

					root static;
					try_files $uri =404;
				}
			]];
		};
		['lib/error.lua'] =
		I[===========[
			local json = require 'cjson'
			local views = require 'views'
			local restia = require 'restia'

			return function(message)
				ngx.log(ngx.ERR, debug.traceback(message))
					  if ngx.status < 300 then
						 ngx.status = 500
					  end
				if not message
				then message = '(No error message given)'
				end

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
				elseif content_type == 'text/plain' then
					ngx.say("Error ",err.code,"\n---------\n",err.message,"\n",err.description)
				else
					if views.error then
						err.message = restia.utils.escape(err.message)
						err.description = restia.utils.escape(err.description)
						views.error:print(err)
					else
						ngx.say('error '..tostring(ngx.status))
					end
				end
				return ngx.HTTP_INTERNAL_SERVER_ERROR
			end
		]===========];
		controllers = {
			['front.lua'] =
			I[===========[
				local views = require("views")

				require('restia.controller').xpcall(function(req)
					return ngx.say(views.front{ domain = ngx.var.host })
				end, require 'error')
			]===========];
		};
		views = {
			['front.cosmo.moonhtml'] = I[[
				strings = require('config').i18n[ngx.var.lang]
				h1 strings.title
				h2 "$domain"
			]];
			['error.cosmo.moonhtml'] = I[[
				h1 "ERROR $code"
				h2 "$message"
				p -> pre "$description"
			]];
		};
		models = {};
		['readme.md'] = I[[
			Restia Application
			================================================================================

			<!-- Start writing your project description here -->
		]];
		['license.md'] = I[[
			All rights reserved
			<!-- TODO: Make project open source :D -->
		]];
		['config.ld'] = I[[
			title = "Restia Application"
			project = "Restia Application"
			format = 'discount'
			topics = {
				'readme.md',
				'license.md',
			}
			file = {
				'lib';
			}
			all = true
		]];
		lib = {
			['views.lua'] = I[[
				local restia = require "restia"
				local views = restia.config.bind "views"

				restia.template.inject(function(_ENV)
					setfenv(1, _ENV)
					function render(name, ...)
						print(restia.utils.deep_index(views, name):render(...))
					end
				end)

				return views
			]];
			['config.lua'] = I[[
				local restia = require "restia"
				local config = restia.config.bind "config"
				config.secret = restia.config.bind ".secret"
				return config
			]];
			template = {
				['cosmo.lua'] = I[==========[
					function each(name, inner)
						print(name.."[[")
							inner()
						print("]]")
					end
				]==========]
			};
		};
		spec = {
			views = {
				['load_spec.moon'] =
				I[===========[
					restia = require 'restia'
					utils = require 'restia.utils'

					describe 'View', ->
						before_each ->
						_G.ngx = {print: ->}
						for file in utils.files 'views'
							describe file, ->
							it 'should load', ->
							assert.truthy require("restia.config").bind('views')[file\gsub('^views/', '')\gsub('%..-$', '')]
				]===========];
			};
			i18n = {
				['locale_spec.moon'] =
				I[===========[
					default = 'en'
					additional = { 'de', 'es' }

					i18n	= require('restia').config.bind("config/i18n")

					describe "Default locale", ->
						it "should exist", ->
							assert i18n[default]

					rsub = (subset, superset={}, prefix='') ->
						for key in pairs(subset)
							switch type(subset[key])
								when "string"
									it "Should contain the key "..prefix..tostring(key), ->
										assert.is.string superset[key]
								when "table"
									rsub subset[key], superset[key], prefix..tostring(key)..'.'


					describe "Additional locale", ->
						for name in *additional
							describe '"'..name..'"', ->
								locale = i18n[name]
								it "should exist", -> assert.is.table locale
								rsub(i18n[default], locale)
				]===========];
			};
		};
		config = {
			i18n = {
				['en.yaml'] = 'title: My Website';
				['de.yaml'] = 'title: Meine Webseite';
				['es.yaml'] = 'title: Mi Pagina Web';
			};
			['settings.conf'] = "set $lang en;\nset $dev true;";
			['types.conf'] = I[===[
				types { # Or just include nginx' default types file :D
					text/html html;
					text/css css;
					application/js js;
				}
			]===]
		};
		['.busted'] = 
		I[==========[
			return {
				_all = {
					lpath = 'lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua';
					cpath = 'lua_modules/lib/lua/5.1/?.lua;lua_modules/lib/lua/5.1/?/init.lua';
				};
			}
		]==========];
		['.luacheckrc'] = [[std = 'ngx_lua']];

		logs = { ['.gitignore'] = "*\n!.gitignore" };

		-- Create local rock tree
		['.luarocks'] = {['default-lua-version.lua'] = 'return "5.1"'};
		lua_modules = {['.gitignore'] = '*\n!.gitignore'};

		-- Shell script to install dependancies
		dependancies = [[luarocks install restia --dev]];
	}
	name = name or 'application'
	utils.build_dir(nil, {[name] = dir})
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
