lfs = require 'lfs'

tabbed = (path) ->
	file = assert io.open path
	for line in file\lines! do
		if line\match('^%s*')\find(" ")
			return false
	true

scan = (root, files={}) ->
	for path in lfs.dir root
		unless path\find '^%.'
			path = root .. "/" .. path
			attributes = lfs.attributes(path)
			if attributes.mode == 'directory'
				scan path, files
			else
				table.insert(files, path) if path\find '.lua$'
	files

files = scan 'restia'
files = scan 'bin', files

describe 'lfs', ->
	it 'is available', ->
		assert.not.nil lfs

describe 'Lua file', ->
	for file in *files
		describe file, ->
			it "Should not use spaces for indentation", ->
				assert.truthy tabbed(file)
