restia = require 'restia'

describe 'Restia', ->
	setup ->
		_G.ngx = { print: stub.new! }
		-- Normal globals doesn't work, since busted sanboxes those and restia already has a reference to the real global env
	
	describe 'templates', ->
		it 'should not error for simple cases', ->
			assert.has_no_errors -> restia.template 'spec/template'
		it 'should call ngx.print', ->
			assert.has_no_errors -> restia.template 'spec/template'
			assert.stub(ngx.print).was_called.with('<!doctype html>')
	
	describe 'markdown', ->
		it 'should work', ->
			assert.is.string restia.markdown 'spec/template'
