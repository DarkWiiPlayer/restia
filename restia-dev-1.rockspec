rockspec_format = "3.0"
package = "restia"
version = "dev-1"
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
	"cosmo";
	"lua-resty-cookie";
	"luafilesystem";
	"lua-cjson";
	"luaossl";
	"lunamark";
	"lyaml";
	"moonscript";
	"moonxml";
	"multipart";
	"warn";
	"xhmoon";
	"arrr";
}
build = {
	type = "builtin",
	modules = {
		['restia']               = 'restia/init.lua';
		['restia.accessors']     = 'restia/accessors.lua';
		['restia.bin']           = 'restia/bin/init.lua';
		['restia.bin.commands']  = 'restia/bin/commands.lua';
		['restia.bin.manpage']   = 'restia/bin/manpage.lua';
		['restia.callsign']      = 'restia/callsign.lua';
		['restia.colors']        = 'restia/colors.lua';
		['restia.config']        = 'restia/config.lua';
		['restia.contributors']  = 'contributors.lua';
		['restia.controller']    = 'restia/controller.lua';
		['restia.markdown']      = 'restia/markdown.lua';
		['restia.negotiator']    = 'restia/negotiator.lua';
		['restia.request']       = 'restia/request.lua';
		['restia.scaffold.app']  = 'restia/scaffold/app.lua';
		['restia.scaffold.init'] = 'restia/scaffold/init.lua';
		['restia.secret']        = 'restia/secret.lua';
		['restia.template']      = 'restia/template.lua';
		['restia.utils']         = 'restia/utils.lua';
	};
	install = {
		bin = {
			restia = 'bin/restia.lua';
		};
	};
}
