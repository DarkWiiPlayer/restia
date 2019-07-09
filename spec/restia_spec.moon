restia = require 'restia'

describe 'Restia', ->
	setup ->
		export ngx = { print: stub.new! }
	
	describe 'templates', ->
		it 'should work', ->
			assert.is.function restia.template 'spec/template'
	
	describe 'markdown', ->
		it 'should work', ->
			assert.is.string restia.markdown 'spec/template'
