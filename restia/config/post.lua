
--- Loader for YAML-Data using Lua-CYAML
-- @module restia.config.yaml

local restia = require 'restia'
local yaml = require 'lyaml'
local discount = require 'discount'
local readfile = require 'restia.config.readfile'

--- Loads a YAML-File and returns a corresponding Lua table.
-- May return non-table values for invalid YAML,
-- as CYAML supports other types than Object at
-- the top-level of the YAML file.
-- @treturn table YAML-Data
-- @function load
return function(file)
	local head, body = restia.utils.frontmatter(io.open(file):read('a'))
	return {
		head = head and yaml.load(head) or {};
		body = discount(body);
	}
end
