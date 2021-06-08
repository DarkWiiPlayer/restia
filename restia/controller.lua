--- A base class for stateful controllers à la Rails
-- @module restia.controller

local request = require 'restia.request'
local protomixin = require 'restia.protomixin'

local controller = protomixin.new(request, {new=protomixin.new})

return controller
