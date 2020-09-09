-- vim: set noexpandtab :miv --

config = require 'restia.config'

try_require = =>
	pcall(-> require @)

disabled = (loader, mod) => pending loader.." (missing module #{mod})"

describe 'config', ->
	setup ->
		export fixtures = config.bind 'spec/fixtures/config'

	it 'should default to nil', ->
		assert.has_no_errors ->
			fixtures.foobar

	it 'should find files', ->
		assert.not.nil fixtures.top

	it 'should load plain files as text', ->
		assert.equal 'hello\n', fixtures.top

	if try_require('cjson')
		describe 'JSON loader', ->
			it 'should find and parse JSON files', ->
				assert.same {works: true}, fixtures.json
	else
		disabled 'JSON loader', 'cjson'

	if try_require('yaml')
		describe 'YAML loader', ->
			it 'should find and parse YAML files', ->
				assert.same {works: true}, fixtures.yaml
	else
		disabled 'YAML loader', 'yaml'

	if try_require('lfs')
		describe 'Recursive Loader', ->
			it 'should recurse over directories', ->
				assert.not.nil fixtures.sub
				assert.not.nil fixtures.sub.top
		describe 'Pairs function', ->
			it 'is available as a metamethod', ->
				assert.equal config.pairs, getmetatable(fixtures).__pairs
			it 'iterates over config elements', ->
				result = [ name for name, entry in config.pairs(fixtures) ]
				table.sort(result)
				assert.same {"json", "sub", "top", "yaml"}, result
	else
		disabled 'Recursive Loader', 'lfs'
		disabled 'Pairs function', 'lfs'
