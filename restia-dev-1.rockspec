rockspec_format = "3.0"
package = "restia"
version = "dev-1"
source = {
	url = "git://github.com/DarkWiiPlayer/restia.git";
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
	"moonxml";
	"xhmoon";
	"moonscript";
	"lunamark";
	"luafilesystem";
	"lyaml";
	"cosmo";
	"busted";
	"luacheck";
	"luaossl";
	"warn";
}
build = {
	type = "builtin",
	modules = {
		['restia'] = 'restia/init.lua';
		['restia.accessors'] = 'restia/accessors.lua';
		['restia.callsign'] = 'restia/callsign.lua';
		['restia.colors'] = 'restia/colors.lua';
		['restia.commands'] = 'restia/commands.lua';
		['restia.config'] = 'restia/config.lua';
		['restia.controller'] = 'restia/controller.lua';
		['restia.markdown'] = 'restia/markdown.lua';
		['restia.negotiator'] = 'restia/negotiator.lua';
		['restia.request'] = 'restia/request.lua';
		['restia.secret'] = 'restia/secret.lua';
		['restia.template'] = 'restia/template.lua';
		['restia.utils'] = 'restia/utils.lua';
		['restia.contributors'] = 'contributors.lua';
	};
	install = {
		bin = {
			restia = 'bin/restia.lua';
		};
	};
}
