tabbed = (path) ->
	file = assert io.open path
	for line in file\lines! do
		if line\match('^%s*')\find(" ")
			return false
	true

files = {}
for file in assert(io.popen("git ls-files '*.lua' '*.moon'"))\lines!
	table.insert(files, file)

describe 'Source file', ->
	for file in *files
		describe file, ->
			it "Should not use spaces for indentation", ->
				assert.truthy tabbed(file)
