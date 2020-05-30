accessors = require 'restia.accessors'

describe "The accessor generator", ->
	it "should return three tables", ->
		get, set, tab = accessors.new!
		assert.is.table get
		assert.is.table set
		assert.is.table tab

	-- TODO: Split this up nicely
	it "should work", ->
		get, set, tab = accessors.new { false }
		get.foo = stub.new!
		set.foo = stub.new!
		dummy = tab.foo
		tab.foo = 20
		assert.stub(get.foo).was_called.with(tab)
		assert.stub(set.foo).was_called.with(tab, 20)

	it "Should use a provided table", ->
		object = {}
		get, set, tab = accessors.new object
		assert.equal object, tab
