-- vim: set filetype=moon :miv --

restia = require 'restia'

describe "utils.deepinsert", ->
	it "should sound wrong", ->
		assert.truthy "It sure does"

	it "should work for non-recursive string cases", ->
		tab = {}
		restia.utils.deepinsert(tab, "foo", "bar")
		assert.equal "bar", tab.foo
		restia.utils.deepinsert(tab, "[1]", "bar")
		assert.equal "bar", tab[1]

	it "should work for recursive string cases", ->
		tab = {}
		assert restia.utils.deepinsert(tab, "foo.bar.baz", "hello")
		assert.equal "hello", tab.foo.bar.baz
		assert restia.utils.deepinsert(tab, "[1][2][3]", "world")
		assert.equal "world", tab[1][2][3]
	
	it "should work for table paths", ->
		tab = {}
		assert restia.utils.deepinsert(tab, {"foo", "bar", "baz"}, "hello")
		assert.equal "hello", tab.foo.bar.baz

	it "should error for incorrect path types", ->
		assert.nil restia.utils.deepinsert({}, (->), true)
		assert.nil restia.utils.deepinsert({}, (20), true)

describe "utils.deepindex", ->
	it "should work for non-recursive cases", ->
		assert.equal "yes", assert restia.utils.deepindex({foo: "yes"}, "foo")
		assert.equal "first", assert restia.utils.deepindex({"first"}, "[1]")

	it "should work for recursive cases", ->
		assert.equal "yes", assert restia.utils.deepindex({foo: {bar: {baz: "yes"}}}, "foo.bar.baz")
		assert.equal "third", assert restia.utils.deepindex({{{"third"}}}, "[1][1][1]")

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

describe "utils.tree", ->
	describe "insert", ->
		it "should insert a node into a tree", ->
			assert.same { foo: { bar: { __value: "test" } } }, restia.utils.tree.insert({}, {"foo", "bar"}, "test")
	describe "get", ->
		it "should retreive a key from a tree", ->
			assert.equal "test", restia.utils.tree.get({ foo: { bar: { __value: "test" } } }, { "foo", "bar" })

describe "utils.mixin", ->
	it "should return the first table", ->
		first = {}
		assert.equal first, restia.utils.mixin first, { foo: "foo" }
	it "should mix in flat values", ->
		assert.same { foo: "foo", bar: "bar" }, restia.utils.mixin { foo: "foo" }, { bar: "bar" }
	it "should mix in recursively", ->
		assert.same { foo: { bar: "bar", baz: "baz" } },
			restia.utils.mixin { foo: { bar: "bar" } }, { foo: { baz: "baz" } }
	it "should mix tables over non-tables", ->
		assert.same { foo: { "bar" } },
			restia.utils.mixin { foo: 20 }, { foo: { "bar" } }
