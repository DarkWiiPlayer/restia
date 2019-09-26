local utils = require 'restia.utils'

local commands = {}

local nginx = [[nginx -p . -c openresty.conf -g 'daemon off;' ]]

local test_views_load =
[===========[
restia = require 'restia'
utils = require 'restia.utils'

describe 'View', ->
	before_each ->
		_G.ngx = {print: ->}
	for file in utils.files 'views'
		describe file, ->
			it 'should load', ->
				restia.template file\gsub('%..-$', '')
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

	lua_package_path 'lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua;;';
	lua_package_cpath 'lua_modules/lib/lua/5.1/?.so;lua_modules/lib/lua/5.1/?/init.so;;';

	log_format  main '$remote_addr - $remote_user [$time_local] "$request" '
	                 '$status $body_bytes_sent "$http_referer" '
	                 '"$http_user_agent" "$http_x_forwarded_for"';

	access_log logs/access.log main;
	keepalive_timeout 65;

	default_type text/html;
	charset utf-8;

  init_by_lua_block {
    require 'restia'
  }

	server {
		listen 8080;

    include routes/*;
	}
}
]===========]

function commands.new(name)
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
				['front.lua'] = 'local restia = require "restia"\n\nrestia.templates["views/front"]()';
			};
			views = {
				['front.moonhtml'] = 'h1 "Hello World!"';
			};
			models = {};
			lib = {};
			spec = {
				views = {
					['load_spec.moon'] = test_views_load;
				};
			};

			logs = {};

			-- Create local rock tree
			['.luarocks'] = {};
			lua_modules = {};
		};
	})
end

function commands.test()
	os.execute(nginx..'-t')
	print()
	os.execute('luacheck -q .')
	os.execute('busted')
end

function commands.run()
	os.execute(nginx)
end

commands.listing = {}
local idx = 1
for name, value in pairs(commands) do
	if type(value)=='function' then
		commands.listing[idx] = name
		idx = idx + 1
	end
end
return commands
