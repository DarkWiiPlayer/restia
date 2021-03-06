--- Handles content negotiation with the client.
-- @module restia.negotiator
-- @author DarkWiiPlayer
-- @license Unlicense

local unpack = unpack or table.unpack or error("No unpack function found!")

local negotiator = {}

--- Parses an "accept" header and returns its entries.
-- Values are returned as: `{q = <Q-Value>, s = <Specificity>, type = <content type>}`
-- where specificity can be 1 for `*/*`, 2 for `<type>/*` or 3 for `<type>/<subtype>`
-- @tparam string accept The full HTTP Accept header
function negotiator.parse(accept)
	local accepted = {}
	for param in accept:gmatch('[^, ]+') do
		local m, n = param:match("([^/]+)/([^;]+)")
		local s = m=='*' and 1 or n=='*' and 2 or 3
		local q = tonumber(param:match(';q=([%d.]+)')) or 1
		table.insert(accepted, {q=q, s=s, type=m..'/'..n})
	end

	table.sort(accepted, function(a, b)
		return a.q>b.q
			or a.q==b.q and a.s>b.s
			or a.q==b.q and a.s==b.s and a.type < b.type
	end)
	return accepted
end

--- Escapes all the special pattern characters in a string
-- @tparam string pattern A string to escape
local function escape(pattern)
	return pattern:gsub('[%^%$%(%)%%%.%[%]%+%-%?%*]', function(char) return '%'..char end)
end

--- Takes a content type string and turns the string into patterns to match said type(s)
-- @tparam string accept A single content-type
local function pattern(accept)
	local s, t = accept.s, accept.type
	if s == 1 then
		return '.+/.+'
	elseif s == 2 then
		return "^"..escape(t:match('^[^/]+/'))..".+"
	elseif s == 3 then
		return "^"..escape(t).."$"
	else
		error("Specificity must be between 1 and 3, got "..tostring(s))
	end
end

--- Works like `negotiator.parse` but adds a `pattern` field to them.
function negotiator.patterns(accept)
	local accepted = negotiator.parse(accept)
	for k,value in ipairs(accepted) do
		accepted[k].pattern = pattern(value)
	end
	return accepted
end

--- Picks a value from a content-type -> value map respecting an accept header.
-- When handlers are given as a sequence of tuples or strings, it checks them in
-- order and prefers lower indices when more than one element matches.  This is
-- to allow prioritizing computationally cheaper content representations when
-- clients can accept both.  @tparam string accept A full HTTP Accept header
-- @tparam table available A table of content types
-- @return type value
-- @usage
-- -- Check in order and use first match
-- type, content = restia.negotiator.pick(headers.accept, {
-- 	{'text/plain', "Hello!"},
-- 	{'text/html', "<h1>Hello!</h1>"}
-- })
-- -- Check out of order and use first match
-- type, content = restia.negotiator.pick(headers.accept, {
-- 	['text/plain'] = "Hello!"
-- 	['text/html'] = "<h1>Hello!</h1>",
-- })
-- -- Return a fitting content type
-- type = restia.negotiator.pick(headers.accept, {
-- 	'appliaction/json', 'text/html', 'application/yaml'
-- })
-- -- Returns a fallback
-- type, content =
-- 	restia.negotiator.pick(headers.accept, {}, "text/plain", "Hello!")
function negotiator.pick(accept, available, ...)
	for i, entry in ipairs(negotiator.patterns(accept)) do
		if type(available[1])=="table" then
			for j, pair in ipairs(available) do
				local name, value = unpack(pair)
				if name:find(entry.pattern) then
					return name, value
				end
			end
		elseif type(available[1])=="string" then
			for j, name in ipairs(available) do
				if name:find(entry.pattern) then
					return name
				end
			end
		else
			for name, value in pairs(available) do
				if name:find(entry.pattern) then
					return name, value
				end
			end
		end
	end
	return ...
end

return negotiator
