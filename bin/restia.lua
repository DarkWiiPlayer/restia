#!/usr/bin/env lua
----------
-- ## Restia on the command line.
-- Generates scaffolding for new projects.
-- @author DarkWiiPlayer
-- @license Unlicense
-- @script restia

local commands = require 'restia.commands'
local c        = require 'restia.colors'

local help = [[
Restia Commandline Utility
--------------------------

Available commands:
]]..table.concat(commands.listing, '\n')

local command = commands[...]

if command then
	command(select(2, ...))
else
	if (...) then
		print('Unknown command: '..c.red(...))
	else
		print(help)
	end
end
