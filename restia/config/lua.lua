return function(name)
	local f = loadfile(name..'.lua')
	return f and f() or nil
end
