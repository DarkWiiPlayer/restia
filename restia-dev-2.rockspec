rockspec_format = "3.0"
package = "restia"
version = "dev-2"
source = {
	url = "git+https://github.com/DarkWiiPlayer/restia.git";
}
description = {
	summary = "Auxiliary library for dynamic web content in openresty";
	homepage = "https://darkwiiplayer.github.io/restia/";
	license = "Unlicense";
	labels = {
		"html";
		"openresty";
	 }
}
dependencies = {
	"lua ~> 5";
	"arrr";
	"cosmo";
	"lua-cjson";
	"lua-resty-cookie";
	"luafilesystem";
	"luaossl";
	"lunamark";
	"lyaml";
	"moonscript";
	"moonxml";
	"multipart";
	"protomixin";
	"warn";
	"xhmoon";
	"glass ~> 1.3.0";
}
build = {
	type = "builtin",
	modules = {
		['restia']                       = 'restia/init.lua';
		['restia.accessors']             = 'restia/accessors.lua';
		['restia.bin']                   = 'restia/bin/init.lua';
		['restia.bin.commands']          = 'restia/bin/commands.lua';
		['restia.bin.manpage']           = 'restia/bin/manpage.lua';
		['restia.colors']                = 'restia/colors.lua';
		['restia.contributors']          = 'contributors.lua';
		['restia.controller']            = 'restia/controller.lua';
		['restia.handler']               = 'restia/handler.lua';
		['restia.logbuffer']             = 'restia/logbuffer.lua';
		['restia.markdown']              = 'restia/markdown.lua';
		['restia.negotiator']            = 'restia/negotiator.lua';
		['restia.request']               = 'restia/request.lua';
		['restia.scaffold.app']          = 'restia/scaffold/app.lua';
		['restia.scaffold.init']         = 'restia/scaffold/init.lua';
		['restia.scaffold.blog']         = 'restia/scaffold/blog.lua';
		['restia.scaffold.static']       = 'restia/scaffold/static.lua';
		['restia.secret']                = 'restia/secret.lua';
		['restia.template']              = 'restia/template.lua';
		['restia.utils']                 = 'restia/utils.lua';
	};
	install = {
		bin = {
			restia = 'bin/restia.lua';
		};
	};
}
