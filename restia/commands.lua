local utils = require 'restia.utils'

local commands = {}

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
				restia.template file\gsub('%..-$', '')
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
			['locations.conf'] = table.concat({
				'location = / {\n\tcontent_by_lua_file "controllers/front.lua";\n}';
				'location /static {\n\tdeny all;\n}';
				'location /favicon.png {\n\talias static/favicon.png;\n}';
				'location ~ ^/(styles|javascript|images)/(.*) {\n\talias static/$1/$2;\n}';
			}, '\n\n');
			controllers = {
				['front.lua'] = 'local restia = require "restia"\n\nrestia.template "views/front"';
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
