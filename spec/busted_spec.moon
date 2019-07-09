describe 'package.path', ->
	it 'should be set correctly', ->
		path = './?.lua;./?/init.lua'
		assert.equal path, package.path\sub(1, #path)
