![Restia](logo.svg) [![License: Unlicense](https://img.shields.io/github/license/darkwiiplayer/restia)](https://unlicense.org/)
================================================================================

[![Built with ♥](https://forthebadge.com/images/badges/built-with-love.svg)](https://forthebadge.com)
[![Uses Badges](https://forthebadge.com/images/badges/uses-badges.svg)](https://forthebadge.com)

**The** *(Too bold?)* **new public domain web framework for Lua**

### What is Restia?

A framework that aims to make developing web-applications in Lua easier.
It has been designed to be used as just a library to better fit into
existing applications. Restia runs inside Openresty to achieve top
performance, but can easily be adapted to use different host APIs.

### What makes it different?

* **Simplicity**: Restia has a small codebase and clear structure.
* **Modularity**: You can use the whole thing—or just a single function.
* **No Elves**: Things don't "just happen" unless you tell them to.
* **Performance**: Low overhead means short code paths means fast code.

### What makes it *special*?

<details>
<summary>Powerful Templating</summary>

The MoonXML templating engine, inspired by the Lapis web framework,
takes away much of the complexity of writing HTML templates by hand.

[Cosmo][cosmo] templates, on the other hand, are blazing fast.

You can even chain them as "multistage templates":
Restia will load a MoonXML template once and interpret the result
as a cosmo template that you can then render repeatedly.
Convenient *and* performant!

For even more modularity, Skooma ditches the separation between code and
templates entirely. A document tree is constructed through pure functions and
later rendered into actual HTML text. This two-stage process allows building
transformation pipelines (read: "middleware") without having to parse HTML.
<hr>
</details>

<details>
<summary>Flexible Configuration</summary>

In Lua, structured Data is represented in tables.

Restia extends this pattern to your configuration data:
Bind a directory and get a table that abstracts your complex file hierarchy
and many different file types into one uniform structure that you already
know how to use.

Even templates can be accessed this way, and with only a few lines of code,
custom config loaders can be added for new file formats.
<hr>
</details>

<details>
<summary>No magical state transfer</summary>

Restia doesn't take care of the plumbing behind the scenes.
Data should be passed around explicitly as function arguments to avoid
over-sharing—both for security and predictability.

It's up to the developer to selectively override this and introduce global state
where necessary.
<hr>
</details>

### Cool! How do I start?

Assuming you have [openresty][openresty] installed:

	luarocks install restia --dev --lua-version 5.1
	restia new app
	restia run &

That's it.
You can now open it in your browser at `localhost:8080`
or start hacking the code right away :)

Work in Progress
--------------------------------------------------------------------------------

In its current state, it should be obvious to anyone that Restia is still in
development and nowhere near production ready.

If you want to use Restia for your own project,
be warned that API changes are likely to happen unannounced during the
zero-versions (`0.x.y`).

How do I build cool stuff?
--------------------------------------------------------------------------------

- Run your application in the background with `restia run &` as you code.
- Check out `getting-started.md` in this repo for a detailed explanation.
- Just inspect the source tree, specially `controllers`, `views` and `config`.
- Read the documentation for detailed descriptions of what everything does.
- Wear sunglasses. 😎<!--Does this look like a tan trenchcoat situation to you?-->

Some Examples
--------------------------------------------------------------------------------

### Hello, World!

For a simple hello-world page one would usually set up a plain nginx route that
just prints a string.

	location = /hello { content_by_lua_block { ngx.say "Hello, World!" } }

However, for the sake of making a better example, here's how this could be done
using a few more Restia features:

In a controller at `controllers/hello.lua`

```lua
local views = require("views")

return function(req)
	return ngx.say(views.hello{ name = "World" })
end
```

This controller simply renders a template called `hello` with an additional
argument.

Then, in a view at `views/hello.cosmo.moonhtml`

	h1 "Hello, $name!"

This moonhtml will be rendered and turned into a cosmo template once when it is
first accessed, that is, the `config` module runs the moonhtml-cosmo-loader.
The resulting cosmo template will look like this:

	<h1>Hello, $name!</h1>

When a user accesses the route, the cosmo template gets rendered and the
variable `$name` is replaced with "World", giving us "Hello, World!".

This behavior is not mandatory: one can also write a `hello.moonhtml` template
that will get rendered anew for every request. This will decrease performance
though, since the MoonXML renderer is much more expensive.

### Simple Content Negotiation

Say you have some data like `{ name = "bob", hobby = "web-dev" }` and want to
present that information in different content types depending on the clients
`accept` header.

Assuming there's a "data" template in the vews directory,
the controller could look this:

```lua
local views = require 'views'
local json = require 'cjson'

local data = { name = "bob", hobby = "web-dev" }

return function(req)
	req:offer {
		{"application/json", function(req)
			return json.encode(data)
		end};
		{"text/html", function(req)
			return views.data(data)
		end};
	}
end
```

Scaffolding / Generators
--------------------------------------------------------------------------------

Restia has a simple scaffolding mechanism which essentially wraps the
`restia.utils.builddir` function within the `restia` executable.

The concept is simple: A scaffold generator is a Lua module that returns a
function. This function, when called, should return a table representing the
changes to be applied to the current directory.

The `restia scaffold` command accepts a module name and a list of extra
arguments to be passed to the generator script as a table, to be evaluated
internally.

More advanced scaffolds may choose to provide their own help flag.

The `restia new` command is a shortcut to builtin Restia generators that
internally calls `restia scaffold` prepending `'restia.scaffold.'` to the module
name.

Modules
--------------------------------------------------------------------------------

These are the most important modules that get most of the work done:

### Request

Restia provides some convenience for request-handling in the `restia.request`
module. This module is passed automatically to every request handler wrapped
in `restia.controller.xpcall` as its first argument.

It wraps openresty functions to access request data and adds functionality to
many of them, allowing the user to e.g. easily read and set cookies or access
request parameters in a variety of formats.

### Config

The `restia.config` module takes care of everything configuration-related.
Its main function is `bind`, which binds a directory to a table.
Indexing the returned table will iterate through a series of loader functions,
which each attempt to load the config entry in a certain way, like loading a
yaml file or binding a subdirectory.

See the documentation of the `restia.config` module for more information.

### Template

The `restia.template` module wraps the `moonxml` templating library and adds a
series of convenient functions for common HTML structures.

### Controller

The `restia.controller` module provides helper functions to find and call
request handlers. It supports both a *one handler per file* approach, where the
controller module returns a function, or a more rails-like system where each
controller has several actions (that is, the module returns a table).

The module also takes care of catching errors and running a handler that can
take care of reporting the error in a suitable manner.

### Secret

The `restia.secret` module is a config table bound to the `.secret` directory
with some additional functions for encryption/decryption. It assumes a special
`key` file to exist in `.secret`, which should contain the servers secret key.

Building the Documentation
--------------------------------------------------------------------------------

Restia doesn't install its documentation with luarocks, so it has to be built
manually or read [online][doc]. To build it, simply install [ldoc][ldoc], clone
the restia repository and run `ldoc .` in its top level directory. The docs will
be generated in the `doc` folder by default.

Docker
--------------------------------------------------------------------------------

The repository includes a dockerfile and a convenient script `containerize` that
generates a docker image based on alpine linux.

A simple dockerfile to turn a restia application into a docker image could look
like this:

	# Build a minimal restia image
	from alpine
	# Necessary requirements
	run apk add curl openssh git linux-headers perl pcre libgcc openssl yaml
	# Pull openresty, luarocks, restia, etc. from the restia image
	copy --from=restia /usr/local /usr/local
	# Copy the restia application
	copy application /etc/application
	workdir /etc/application
	cmd restia run

Assuming that the application is in the `application` folder.

Note that the `containerize` script uses podman instead of docker; but it should
be possible to just replace it with `docker` and run the script.

Manpage
--------------------------------------------------------------------------------

For Linux\* users, there's a command to generate and install a manpage.

Simply run `restia manpage` as root to install system-wide or as another user to
installit locally in `$HOME/.local/share/man`.

\* Yes, Linux. There's also non-GNU linuxes out there using musl+busybox and
other GNU-alternatives.

Known Issues
--------------------------------------------------------------------------------

> attempt to yield across C-call boundary

This error occurs under certain conditions:

1. The code being run is being (directly or indirectly) `require`d
2. The code is running inside an openresty event that has replaced LuaJITs
	builtin `coroutine` module with openrestys custom versions of those
	functions.
3. Somewhere in the code a coroutine yields, no matter where it yields to (it
	doesn't have to yield outside the `require` call, which would understandably
	not work, but anywhere within the code being executed by `require`)

Note that this problem not only happens with `require`, but also custom message
handlers passed to `xpcall` when an error happens, but this is less likely to
happen, as error handlers usually shouldn't have any complex code that could
lead to more errors and thus shouldn't be running coroutines in the first place.

This problem isn't a bug in restia; it can be reproduced in vanilla openresty.

Typical situations when this happens:

- Moonscripts compiler makes use of coroutines, thus compiling moonscript code
  (for example, precompiling a cosmo-moonhtml template) in a module that gets
  `require`d.

Typical workarounds:

- Wrap code that uses coroutines in an init function and call `require
	'mymodule'.init()` (Sadly, this unavoidably leads to very ugly APIs)
- Preload cosmo-moonhtml templates in `init_by_lua`, which runs before 2.
	happens
- Precompile cosmo-moonscript templates so they don't need to be compiled when
	`require`ing a module

OpenResty issue: https://github.com/openresty/lua-nginx-module/issues/1292

Planned features
--------------------------------------------------------------------------------

- More MoonXML utility methods (lists, tables, etc.)
- Some High-Level functionality (Security-related, etc.)
- Portability (Currently only nginx is supported)

Contributing
--------------------------------------------------------------------------------

In general, all meaningful contributions are welcome
under the following conditions:

- All commit messages MUST be meaningful and [properlt formatted](https://chris.beams.io/posts/git-commit/).
- Commits SHOULD NOT group unrelated features.
- Exported functions MUST be documented in [LDoc][ldoc] style.
- Local functions SHOULD be documented as well.
- Contributors MUST appear in `contributors.lua`.
- Contributors MAY add custom fields to their `contributors.lua` entry.
- Commits modifying `contributors.lua` MUST be signed.

See [RFC2119][rfc2119] if you're wondering about the weird capitalization.

Changelog
--------------------------------------------------------------------------------

### Development

### Version 0.1.0

- Add 'static' scaffold
- Add 'blog' scaffold
- Add 'app' scaffold
- Add `restia.controller` class
- Add skooma loader for functional templating
- Add simple scaffolding/generators system
- Add `restia.utils.tree` submodule
- Add `restia.request` module
- Add `restia.accessors` module
- Add `restia.callsign` module (Name subject to future change)
- Add `restia.negotiator` module
- Add `restia.template.require` function
- Add `restia.handler` module (formerly `restia.controller`)
- Add `restia.secret` module
- Add support for moonhtml+cosmo multistage templates
- Add support for cosmo templates
- Integrate templates with `config`
- Add `restia.config` module
- Rewrite template loading to use a table and render on demand ;)
- Rewrite template loading to use buffer and render instantly
- Add executable for scaffolding, running tests, starting a server, etc.
- Switch to moonxml initializers
- Add `restia.template` module
	- Add `ttable` function for more complex tables
	- Add `vtable` function for vertical tables
	- Add `olist` function for ordered lists
	- Add `ulist` function for unordered lists
	- Add `html5` function for html 5 doctype

----

License: [The Unlicense][unlicense]

[cosmo]:      http://www.cosmo.luaforge.net/ "Cosmo Templating Engine"
[doc]:        https://darkwiiplayer.github.io/restia "Restia Documentation"
[ldoc]:       https://github.com/stevedonovan/LDoc "LDoc - A Lua Documentation Tool"
[lunamark]:   https://github.com/jgm/lunamark "Lunamark"
[moonxml]:    https://github.com/darkwiiplayer/moonxml "MoonXML"
[openresty]:  http://openresty.org/en/ "OpenResty"
[unlicense]:  https://unlicense.org "The Unlicense"
[rfc2119]:    https://tools.ietf.org/html/rfc2119 "Request for Comment 2119"
