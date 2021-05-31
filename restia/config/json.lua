--- Loader for JSON-Data using Lua-CJSON
-- @module restia.config.json

local json = require 'cjson'
local readfile = require 'restia.cofnig.readfile'

--- Loads a JSON-File and returns a corresponding Lua table.
-- May return non-table values for invalid JSON,
-- as CJSON supports other types than Object at
-- the top-level of the JSON file.
-- @treturn table JSON-Data
-- @function load
return function(file)
	local raw = readfile(file..'.json')
	if raw then
		return json.decode(raw)
	end
end
