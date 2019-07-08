#!/usr/bin/env lua
----------
-- ## Restia on the command line.
-- Generates scaffolding for new projects.
-- @author DarkWiiPlayer
-- @license Unlicense
-- @script restia

commands = require 'restia.commands'

commands[...](select(2, ...))
