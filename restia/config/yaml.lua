local yaml = require 'lyaml'
local readfile = require 'restia.config.readfile'

return function(file)
	local raw = readfile(file..'.yml') or readfile(file..'.yaml')
	if raw then
		return yaml.load(raw)
	end
end
