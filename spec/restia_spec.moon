restia = require 'restia'

describe 'Restia', ->
	setup ->
		_G.ngx = { print: stub.new! }
		-- Normal globals doesn't work, since busted sanboxes those and restia already has a reference to the real global env
	
	describe 'templates', ->
		it 'should not error for simple cases', ->
			assert.has_no_errors -> restia.templates['spec/template']()
		it 'should call ngx.print', ->
			assert.has_no_errors -> restia.templates['spec/template']()
			assert.stub(ngx.print).was_called.with{'<!doctype html>'}

	describe 'compiled templates', ->
		it 'should not error for simple cases', ->
			assert.has_no_errors -> restia.templates['spec/ctemplate']()
		it 'should call ngx.print', ->
			assert.has_no_errors -> restia.templates['spec/ctemplate']()
			assert.stub(ngx.print).was_called.with{'<!doctype html>'}
	
	describe 'markdown module', ->
		it 'should parse strings', ->
			assert.is.truthy restia.markdown.parse('## foo')\match '<h2>foo</h2>'
		it 'should load files', ->
			assert.is.string restia.markdown.load 'spec/template'
