# Writing Controllers (or Handlers)

Restia does not assume a MVC-workflow, but supports it when needed.

## Single-Function Request Handlers

A controller module can return a single function that will handle a specific
request, usually mapped to a single route. This is often enough for simple cases
and special pages that don't fit neatly into an MVC design, like landing pages,
legal notices, etc.

When `restia.handler.serve` is called without an action argument, it will
default to this behaviour.

A typical location could look like this:

	-- locations/landing
	location = / {
		content_by_lua_block {
			restia.handler.serve("controllers.landing", "error")
		}
	}

with a corresponding controller module:

	-- controllers/landing.lua
	return function(req)
		return ngx.say("Welcome to my website!")
	end

Note that `restia.handler.serve` automatically passes `restia.request` as the
first argument to the handler. This happens regardless of whether an action is
specified.

## Multi-Action Controllers

A controller module may also return a table containing several actions. To pick
what action to call, an additional string argument must be passed to the
`restia.handler.serve` function, which describes the table path to the
request handler.

Note that nested tables are possible, as `restia.utils.deepindex` is used to
interpret this action path.

This will, in most cases, be set up in the location block, which might look as
follows:

	-- locations/user
	location = /user {
		content_by_lua_block {
			restia.handler.serve("controllers.landing", "error", "list")
		}
	}
	location ~ ^/user/(\d+)/(profile|posts)$ {
		content_by_lua_block {
			restia.handler.serve("controllers.landing", "error", ngx.var[2], ngx.var[1])
		}
	}

And the controller module might look somewhat like this:

	-- controllers/user.lua
	local user = {}

	function user.list(req)
		-- List all users
	end

	function user.profile(req, id)
		-- Render a users profile
	end

	-- ...

Note that the `ngx.var[1]` gets passed through to the event handler after the
request object. While the request handler could get this data itself through the
`ngx` module, this way makes its interface more explicit and reusable.

## Stateful Controllers

Most MVC frameworks implement controllers as classes: every new request gets a
new controller object to encapsulate its state. Restia provides a simple wrapper
to achieve this with the `restia.handler.controller` function, which takes the
name of a module containing the controller class, the name of a module
containing an error handler, an action name and additional arguments to be
passed to the action.

Since Lua has no proper classes or objects out of the box, Restia assumes the
controller module will return a plain function or callable object that it will
call without any arguments to return a new controller instance. It will then
index the object with the method name and call the returned function, passing
the method as the first argument.

	-- controllers/user.lua
	local class = {}

	function class:set_user()
		local id = restia.request.params.user_id
		self.unser = db.get_user(id)
	end

	function class:list()
		-- List all users
	end

	function class:profile()
		self:set_user()
		-- Render a users profile
	end

	local function new()
		return setmetatable({}, class)
	end

	return new

Note that this function does *not* pass `restia.request` as an argument to the
method. The controller object is expected to access the request module on its
own, either directly or through metaprogramming.
