-- vim: set filetype=moon :miv --

restia = require 'restia'

describe "utils.deepinsert", ->
	it "should sound wrong", ->
		assert.truthy "It sure does"

	it "should work for non-recursive cases", ->
		tab = {}
		restia.utils.deepinsert(tab, "foo", "bar")
		assert.equal "bar", tab.foo
		restia.utils.deepinsert(tab, "[1]", "bar")
		assert.equal "bar", tab[1]

	it "should work for recursive cases", ->
		tab = {}
		restia.utils.deepinsert(tab, "foo.bar.baz", "hello")
		assert.equal "hello", tab.foo.bar.baz
		restia.utils.deepinsert(tab, "[1][2][3]", "world")
		assert.equal "world", tab[1][2][3]

	it "should error for non-string paths", ->
		assert.nil restia.utils.deepinsert({}, (->), true)
		assert.nil restia.utils.deepinsert({}, (20), true)
		assert.nil restia.utils.deepinsert({}, ({}), true)

describe "utils.deepen", ->
	it "should flat-clone a normal table", ->
		tab = {
			"first",
			"second",
			[(a)->a]: 'function',
			string: 'string'
		}
		assert.same(tab, restia.utils.deepen(tab))

	it "should spread string keys with dots", ->
		assert.same({foo: {bar: 'baz'}}, restia.utils.deepen{['foo.bar']: 'baz'})

	it "should treat numbers as strings when using dots", ->
		assert.same({foo: {['1']: 'baz'}}, restia.utils.deepen{['foo.1']: 'baz'})

	it "should convert numeric indices", ->
		assert.same({foo: {'baz'}}, restia.utils.deepen{['foo[1]']: 'baz'})

describe "utils.escape", ->
	it "should do nothing to normal strings", ->
		assert.equal "hello", restia.utils.escape("hello")
	it "should escape ampersands", ->
		assert.equal "&amp;hello", restia.utils.escape("&hello")
	it "should escape angle brackets", ->
		assert.equal "&lt;hello&gt;", restia.utils.escape("<hello>")
	it "should escape quotation marks", ->
		assert.equal "&quot;G&#039;day&quot;", restia.utils.escape([["G'day"]])
