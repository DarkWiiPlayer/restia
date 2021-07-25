--- A base class for stateful controllers à la Rails
-- @classmod restia.controller
-- @usage
-- local users = controller:new()
-- function users:get_user(id)
-- 	-- get a user from somewhere
-- end
-- function users:show(req)
-- 	get_user(req.params.id)
-- 	-- do stuff here
-- end
-- return users

local request = require 'restia.request'
local protomixin = require 'restia.protomixin'

--- Creates a new (empty) controller
-- @function new

local controller = protomixin.new(request, {new=protomixin.new})

return controller
