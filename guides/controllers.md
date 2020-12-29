# Using Controllers (or Handlers)

Restia does not assume a MVC-workflow, but supports it when needed. As such, it
does not have a specific concept for controllers, but allows grouping request
handlers into modules.

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

Unlike in frameworks like Rails, controllers aren't object instances and don't
store any state. This is intentional and should encourage passing state around
explicitly. If stateful controller instances are desired, these must be manually
implemented.

To achieve this, one has to build their own wrapper around
`restia.controller.xpcall` that creates an instance before calling a method on
it.
