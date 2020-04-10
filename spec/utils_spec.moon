-- vim: set filetype=moon :miv --

restia = require 'restia'

describe "utils.deepen", ->
	it "Should clone a normal table", ->
		tab = {
			"first",
			"second",
			[(a)->a]: 'functin',
			string: 'string'
		}
		assert.same(tab, restia.utils.deepen(tab))

	it "Should spread string keys with dots", ->
		assert.same({foo: {bar: 'baz'}}, restia.utils.deepen{['foo.bar']: 'baz'})

	it "Should convert numeric indices", ->
		assert.same({foo: {'baz'}}, restia.utils.deepen{['foo.1']: 'baz'})

describe "utils.escape", ->
	it "Should do nothing to normal strings", ->
		assert.equal "hello", restia.utils.escape("hello")
	it "Should escape ampersands", ->
		assert.equal "&amp;hello", restia.utils.escape("&hello")
	it "Should escape angle brackets", ->
		assert.equal "&lt;hello&gt;", restia.utils.escape("<hello>")
	it "Should escape quotation marks", ->
		assert.equal "&quot;G&#039;day&quot;", restia.utils.escape([["G'day"]])
