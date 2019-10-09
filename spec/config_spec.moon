-- vim: set noexpandtab :miv --

config = require 'restia.config'

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

	describe 'JSON loader', ->
		it 'should load lua-cjson', ->
			assert.has_no_errors ->
				require 'cjson'
		it 'should find and parse JSON files', ->
			assert.same {works: true}, fixtures.json

	describe 'YAML loader', ->
		it 'should load lua-yaml', ->
			assert.has_no_errors ->
				require 'lyaml'
		it 'should find and parse YAML files', ->
			assert.same {works: true}, fixtures.yaml

	describe 'Recursive Loader', ->
		it 'should load lua-file-sysyem', ->
			assert.has_no_errors ->
				require 'lfs'
		it 'should recurse over directories', ->
			assert.not.nil fixtures.sub
			assert.not.nil fixtures.sub.top
