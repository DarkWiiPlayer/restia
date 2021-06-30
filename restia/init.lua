-- Main module.
-- This is essentially just an autoloader for the submodules.
-- @module restia
-- @author DarkWiiPlayer
-- @license Unlicense
-- @usage
-- local restia = require 'restia'
-- assert(restia.template == require 'restia.template')

local utils = require 'restia.utils'
return utils.deepmodule(...)
