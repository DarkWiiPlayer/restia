local json = require 'cjson'
local readfile = require 'restia.cofnig.readfile'

config.loaders:insert("json", function(file)
	local raw = readfile(file..'.json')
	if raw then
		return json.decode(raw)
	end
end)
