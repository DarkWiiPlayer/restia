
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
-- @tparam string name Name of the file to load
-- @tparam[opt=".post"] string extension File extension to append to the file
-- @treturn table YAML-Data
-- @function load
return function(name, extension)
	local file = io.open(name .. (extension or '.post'))
	if file then
		local head, body = restia.utils.frontmatter(file:read('a'))
		return {
			head = head and yaml.load(head) or {};
			body = discount(body);
		}
	end
end
