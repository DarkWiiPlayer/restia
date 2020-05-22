restia = require 'restia'

readfile = =>
	file = io.open(@)
	content = file\read "*a"
	file\close!
	content

describe 'Restia', ->
	describe 'uncompiled templates', ->
		it 'should not error for simple cases', ->
			assert.has_no_errors -> restia.template.loadmoon(readfile('spec/template.moonhtml'), 'foo')()
		it 'Should return a table', ->
			assert.is.table restia.template.loadmoon(readfile('spec/template.moonhtml'), '')()

	describe 'compiled templates', ->
		it 'should not error for simple cases', ->
			assert.has_no_errors -> restia.template.loadlua(readfile('spec/ctemplate.moonhtml.lua'), 'foo')()
		it 'Should return a table', ->
			assert.is.table  restia.template.loadlua(readfile('spec/ctemplate.moonhtml.lua'), '')()
