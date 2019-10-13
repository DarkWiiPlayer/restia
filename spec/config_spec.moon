-- vim: set noexpandtab :miv --

config = require 'restia.config'

try_require = =>
	pcall(-> require @)

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
		pending 'JSON loader', ->

	if try_require('yaml')
		describe 'YAML loader', ->
			it 'should find and parse YAML files', ->
				assert.same {works: true}, fixtures.yaml
	else
		pending 'YAML loader', ->

	if try_require('lfs')
		describe 'Recursive Loader', ->
			it 'should recurse over directories', ->
				assert.not.nil fixtures.sub
				assert.not.nil fixtures.sub.top
	else
		pending 'Recursive Loader', ->
