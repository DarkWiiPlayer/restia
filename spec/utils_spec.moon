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
