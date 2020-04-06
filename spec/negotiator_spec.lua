local negotiator = require 'restia.negotiator'

describe("Content negotiator", function()
	it("Should parse headers correctly", function()
		local accepted = negotiator.parse 'text/html' [1]
		assert.same({q=1, s=3, type='text/html'}, accepted)
	end)

	it("Should order types alphabetically", function()
		-- To make the ordering of headers with equal Q-value more deterministic
		local accepted = negotiator.parse 'c/*, b/*, a/*'
		for k,v in ipairs(accepted) do
			accepted[k] = v.type
		end
		assert.same({'a/*', 'b/*', 'c/*'}, accepted)
	end)

	it("Should respect Q-values", function()
		local accepted = negotiator.parse 'text/html, application/xhtml+xml, application/xml;q=0.9, image/webp, */*;q=0.8'
		for k,v in ipairs(accepted) do
			accepted[k] = v.type
		end
		assert.same({
			'application/xhtml+xml',
			'image/webp',
			'text/html',
			'application/xml',
			'*/*'
		}, accepted)
	end)

	it("Should return valid patterns", function()
		local patterns = negotiator.patterns '*/*, application/*, text/html, hack/%s+$'
		for k,v in ipairs(patterns) do
			patterns[k] = v.pattern
		end
		assert.same({
			'^hack/%%s%+%$$',
			'^text/html$',
			'^application/.+',
			'.+/.+'
		}, patterns)
	end)

	it("Should pick the prefered option", function()
		assert.same({"text/html", "FOO"}, {negotiator.pick('text/*', {
			['application/js'] = "BAR";
			['text/html'] = "FOO";
			['image/png'] = "BAZ";
		})})
	end)
end)
