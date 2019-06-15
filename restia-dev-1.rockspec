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
	"lua ~> 5.1";
	"moonxml >= 3.2, < 4";
	"xhmoon >= 1.2.0 < 2";
	"moonscript";
	"lunamark";
}
build = {
	type = "builtin",
	modules = {
		restia = 'restia.lua'
	}
}
