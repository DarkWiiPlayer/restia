local restia = require 'restia'

local I = restia.utils.unpipe

local project = {}

function project.controller()
	return I[[
		|local views = require("views")
		|
		|require('restia.controller').xpcall(function(req)
		|	return ngx.say(views.front{ domain = req.host })
		|end, require 'error')
	]]
end

function project.new(options)
	local dir = {
		['.gitignore'] =
		I[============[
			|*_temp
			|*.pid
		]============];
		['.secret'] = {
			key = restia.utils.randomhex(64);
			[".gitignore"] = "*\n!.gitignore";
		};
		['openresty.conf'] =
		I[===========[
			|error_log logs/error.log	info;
			|pid openresty.pid;
			|
			|worker_processes auto;
			|events {
			|	worker_connections	1024;
			|}
			|
			|http {
			|	lua_code_cache off; # Change this for production
			|
			|	lua_package_path 'lib/?.lua;lib/?/init.lua;lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua;;';
			|	lua_package_cpath 'lib/?.so;lib/?/init.so;lua_modules/lib/lua/5.1/?.so;lua_modules/lib/lua/5.1/?/init.so;;';
			|
			|	log_format	main
			|	'$remote_addr - $remote_user [$time_local] "$request" '
			|	'$status $body_bytes_sent "$http_referer" '
			|	'"$http_user_agent" "$http_x_forwarded_for"';
			|
			|	access_log logs/access.log main;
			|	keepalive_timeout 65;
			|
			|	default_type text/html;
			|	charset utf-8;
			|
			|	init_by_lua_block {
			|		-- Preload modules
			|		local restia = require 'restia'
			|		require 'config'
			|		require 'views'
			|
			|		restia.template.require 'template.cosmo'
			|
			|		-- Error view to be preloaded lest the error handler fails
			|		-- (Openresty bug related to coroutines)
			|		local _ = require('views').error
			|	}
			|
			|	server {
			|		listen 8080;
			|
			|		include config/*.conf;
			|		include locations/*;
			|	}
			|}
		]===========];
		locations = {
			root = I[[
				|location = / {
				|	content_by_lua_file "controllers/front.lua";
				|}
				|location / {
				|	if (-f controllers$uri.lua) { content_by_lua_file controllers$uri.lua; }
				|
				|	root static;
				|	try_files $uri =404;
				|}
			]];
		};
		static = { [".gitignore"] = "" };
		lib = {
			['error.lua'] =
			I[===========[
				|local json = require 'cjson'
				|local views = require 'views'
				|local restia = require 'restia'
				|
				|return function(message)
				|	ngx.log(ngx.ERR, debug.traceback(message))
				|			if ngx.status < 300 then
				|			 ngx.status = 500
				|			end
				|	if not message
				|	then message = '(No error message given)'
				|	end
				|
				|	local err if ngx.var.dev=="true" then
				|		err = {
				|			code = ngx.status;
				|			message = message:match('^[^\n]+');
				|			description = debug.traceback(message, 3);
				|		}
				|	else
				|		err = {
				|			code = ngx.status;
				|			message = "There has been an error";
				|			description = "Please contact a site administrator if this error persists";
				|		}
				|	end
				|
				|	local content_type = ngx.header['content-type']
				|	if content_type == 'application/json' then
				|		ngx.say(json.encode(err))
				|	elseif content_type == 'text/plain' then
				|		ngx.say("Error ",err.code,"\n---------\n",err.description)
				|	else
				|		if views.error then
				|			err.message = restia.utils.escape(err.message)
				|			err.description = restia.utils.escape(err.description)
				|			ngx.say(views.error(err))
				|		else
				|			ngx.say('error '..tostring(ngx.status))
				|		end
				|	end
				|	return ngx.HTTP_INTERNAL_SERVER_ERROR
				|end
			]===========];
		};
		controllers = {
			['front.lua'] = project.controller();
		};
		views = {
			['front.cosmo.moonhtml'] = I[[
				|strings = require('config').i18n[ngx.var.lang]
				|h1 strings.title
				|h2 "$domain"
			]];
			['error.cosmo.moonhtml'] = I[[
				|h1 "ERROR $code"
				|h2 "$message"
				|p -> pre "$description"
			]];
		};
		models = {};
		['readme.md'] = I[[
			|Restia Application
			|================================================================================
			|
			|<!-- Start writing your project description here -->
		]];
		['license.md'] = I[[
			|All rights reserved
			|<!-- TODO: Make project open source :D -->
		]];
		['config.ld'] = I[[
			|title = "Restia Application"
			|project = "Restia Application"
			|format = 'discount'
			|topics = {
			|	'readme.md',
			|	'license.md',
			|}
			|file = {
			|	'lib';
			|}
			|all = true
		]];
		lib = {
			['views.lua'] = I[[
				|local restia = require "restia"
				|local views = restia.config.bind "views"
				|
				|restia.template.inject(function(_ENV)
				|	setfenv(1, _ENV)
				|	function render(name, ...)
				|		print(restia.utils.deepindex(views, name):render(...))
				|	end
				|end)
				|
				|return views
			]];
			['config.lua'] = I[[
				|local restia = require "restia"
				|local config = restia.config.bind "config"
				|config.secret = restia.config.bind ".secret"
				|return config
			]];
			template = {
				['cosmo.lua'] = I[==========[
					|function each(name, inner)
					|	print(name.."[[")
					|		inner()
					|	print("]]")
					|end
				]==========]
			};
		};
		spec = {
			views = {
				['load_spec.moon'] =
				I[===========[
					|restia = require 'restia'
					|utils = require 'restia.utils'
					|
					|describe 'View', ->
					|	before_each ->
					|	_G.ngx = {print: ->}
					|	for file in utils.files 'views'
					|		describe file, ->
					|		it 'should load', ->
					|		assert.truthy require("restia.config").bind('views')[file\gsub('^views/', '')\gsub('%..-$', '')]
				]===========];
			};
			i18n = {
				['locale_spec.moon'] =
				I[===========[
					|default = 'en'
					|additional = { 'de', 'es' }
					|
					|i18n	= require('restia').config.bind("config/i18n")
					|
					|describe "Default locale", ->
					|	it "should exist", ->
					|		assert i18n[default]
					|
					|rsub = (subset, superset={}, prefix='') ->
					|	for key in pairs(subset)
					|		switch type(subset[key])
					|			when "string"
					|				it "Should contain the key "..prefix..tostring(key), ->
					|					assert.is.string superset[key]
					|			when "table"
					|				rsub subset[key], superset[key], prefix..tostring(key)..'.'
					|
					|
					|describe "Additional locale", ->
					|	for name in *additional
					|		describe '"'..name..'"', ->
					|			locale = i18n[name]
					|			it "should exist", -> assert.is.table locale
					|			rsub(i18n[default], locale)
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
				|types { # Or just include nginx' default types file :D
				|	text/html html;
				|	text/css css;
				|	application/js js;
				|}
			]===]
		};
		['.busted'] = 
		I[==========[
			|return {
			|	_all = {
			|		lpath = 'lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua;lib/?.lua;lib/?/init.lua';
			|		cpath = 'lua_modules/lib/lua/5.1/?.lua;lua_modules/lib/lua/5.1/?/init.lua';
			|	};
			|}
		]==========];
		['.luacheckrc'] = [[std = 'ngx_lua']];

		logs = { ['.gitignore'] = "*\n!.gitignore" };

		-- Create local rock tree
		['.luarocks'] = {['default-lua-version.lua'] = 'return "5.1"'};
		lua_modules = {['.gitignore'] = '*\n!.gitignore'};

		-- Shell script to install dependancies
		dependancies = [[luarocks install restia --dev]];
	}
	return dir
end

return project
