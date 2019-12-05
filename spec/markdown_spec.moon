restia = require 'restia'

describe 'markdown module', ->
	setup ->
		_G.ngx = { print: stub.new! }
		-- Normal globals doesn't work, since busted sanboxes those and restia already has a reference to the real global env
	it 'should parse strings', ->
		assert.is.truthy restia.markdown.parse('## foo')\match '<h2>foo</h2>'
	it 'should load files', ->
		assert.is.string restia.markdown.load 'spec/template'
