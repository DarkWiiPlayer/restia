local utils = require 'restia.utils'

return {
  new = function(name)
    name = name or 'application'
    utils.build_dir(nil, {
      [name] = {
        lua_modules = {};
        ['locations.conf'] = table.concat({
          'location = / {\n\tcontent_by_lua_file "controllers/front.lua";\n}';
          'location /static {\n\tdeny all;\n}';
          'location /favicon.png {\n\talias static/favicon.png;\n}';
          'location ~ ^/(styles|javascript|images)/(.*) {\n\talias static/$1/$2;\n}';
        }, '\n\n');
        controllers = {
          ['front.lua'] = 'local restia = require "restia"\n\nrestia.template "views/front" ()';
        };
        views = {
          ['front.moonhtml'] = 'h1 "Hello World!"';
        };
        models = {};
        lib = {};
      };
    })
  end
}
