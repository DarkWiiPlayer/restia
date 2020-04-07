restia = require 'restia'

readfile = =>
	file = io.open(@)
	content = file\read "*a"
	file\close!
	content

describe 'Restia', ->
	setup ->
		_G.ngx = { say: stub.new! }
		-- Normal globals doesn't work, since busted sanboxes those and restia already has a reference to the real global env

	describe 'uncompiled templates', ->
		it 'should not error for simple cases', ->
			assert.has_no_errors -> restia.template.loadmoon(readfile('spec/template.moonhtml'), 'foo')()
		it 'should call ngx.say', ->
			assert.has_no_errors -> restia.template.loadmoon(readfile('spec/template.moonhtml'), 'foo')()
			assert.stub(ngx.say).was_called.with{'<!doctype html>'}

	describe 'compiled templates', ->
		it 'should not error for simple cases', ->
			assert.has_no_errors -> restia.template.loadlua(readfile('spec/ctemplate.moonhtml.lua'), 'foo')()
		it 'should call ngx.say', ->
			assert.has_no_errors -> restia.template.loadlua(readfile('spec/ctemplate.moonhtml.lua'), 'foo')()
			assert.stub(ngx.say).was_called.with{'<!doctype html>'}
