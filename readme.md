![Restia](logo.svg) [![License](https://img.shields.io/github/license/darkwiiplayer/restia)](https://unlicense.org/)
================================================================================

[![forthebadge](https://forthebadge.com/images/badges/built-with-love.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/uses-badges.svg)](https://forthebadge.com)

Restia is a library that aims to make developing web-applications in Lua easier.

### What do I need to get started?

	restia new .
	restia run &

That's it. You can now open it in your browser at localhost:8080 or start
hacking the code right away :)

### What makes it different?

Compared to other frameworks like Rails or Lapis,
restia tries less to offer a complete package,
but a good base to plug existing modules into.

**Restia is your tool, not your overlord.**
It aims to help where it can, without forcing the shape of your final product.

Many modern frameworks claim to do "convention over configuration".
But that name is misleading; the configuration is there,
it's just hidden within framework defaults.

Restia keeps this *convention* part out of the library
and, instead, generates configurations that represent these conventions.
The effect is almost the same, but it makes it easier to change things.

I (jokingly) call this aproach

> "Convention encoded in generated configuration over headache"

### What makes it *special*?

<details>
<summary>Simplicity</summary>
Restia is built to be simple, which makes it easy to extend.
</details>


<details>
<summary>Control</summary>
Restia doesn't tell you what to do; it gives you its idea of a
project layout and lets you do whatever you want with it.
</details>


<details>
<summary>Modularity</summary>
Not everything is a web app; maybe you just need the
templating? or the config loading? no problem, it's split into modules!
</details>


<details>
<summary>Self-Contained</summary>
Thanks to Luarocks being awesome, installing restia separately for just
the project is trivial. The template project makes it even easier!
</details>

Work in Progress
--------------------------------------------------------------------------------

In its current state, it should be obvious to anyone that Restia is still in
development and nowhere near production ready.

Currently this is mostly a personal project intended for my own use.
Suggestions are still welcome, of course.

If you want to use Restia for your own project,
be warned that API changes are likely to happen unannounced during the
zero-versions (`0.x.y`).

Building the Documentation
--------------------------------------------------------------------------------

Lua doesn't install its documentation with luarocks, so it has to be built
manually or read online. To build it, simply install [ldoc](ldoc), clone the
restia repository and run `ldoc .` in its top level directory. The docs will
be generated in the `doc` folder by default.

Usage
--------------------------------------------------------------------------------

### Getting started

If you're on the fence about installing restia system-wide, you can do the
following:

	mkdir trying_out_restia && cd trying_out_restia
	mkdir .luarocks lua_modules
	luarocks
	# Confirm the default rock-tree is now lua_modules
	luarocks --lua-version 5.1 install restia --dev
	lua_modules/bin/restia new .
	lua_modules/bin/restia run &

After that you will have a template project in the current directory and restia
running in the background.

You can now start looking at the project directory, make changes and reload
restia with

	lua_modules/bin/restia test
	lua_modules/bin/restia reload

### Executable

The `restia` executable is a convenient script that takes care of generating new
project trees and running them, as well as some simple helper functionalities
like running tests, reloading the server, etc.

To get an overview of the available commands, run `restia help`.

### Library

Restias main features as of now are:
- Integration of moonhtml templates
- A very generic config loader with optional support for json, yaml, etc.

See the documentation for more information on this.

Modules
--------------------------------------------------------------------------------

### Config

The `restia.config` module takes care of everything configuration-relatedi.
Its main function is `bind`, which binds a directory to a table.
Indexing the returned table will iterate through a series of loader functions,
which each attempt to load the config entry in a certain way, like loading a
yaml file or binding a subdirectory.

See the documentation of the `restia.config` module for more information.

### Secret

The `restia.secret` module is a config table bound to the `.secret` directory
with some additional functions for encryption/decryption. It assumes a special
`key` file to exist in `.secret`, which should contain the servers secret key.

### Template

The `restia.template` module wraps the `moonxml` templating library and adds a
series of convenient functions for common HTML structures.

### Controller

The `restia.controller` module provides a simple helper function
that accepts the main controller code and an error handler.
It acts very similar to `xpcall`,
but in case of error,
it runs the message handler
and instantly terminates the request.

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

For Linux\* users, there's a script to generate a manpage in the `manpage/`
directory in the project tree.

\* Not just GNU/Linux, but also all the weird minimalist musl+busybox setups :)

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
- Preload cosmo-moonhtml templates in `init_by_lua`, which runs before 2. happens
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

- All commit messages must be meaningful. (No "updated file X", etc.)
- Commits must consist of (Atomic) changes that fit together.
- PGP-Signing commits is not mandatory, but encouraged.

After submitting a larger change, feel free to add your name to the
"contributors.lua" file. Please PGP-sign at least that commit though.

All newly added code should be documented. The project uses [LDoc][ldoc] to
generate documentation, so its format should be used.

Changelog
--------------------------------------------------------------------------------

### Development

- Add `restia.template.require` function
- Add `restia.controller` module
- Add `restia.secret` module
- Add support for moonhtml+cosmo multistage templates
- Add support for cosmo templates
- Integrate templates with config
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

[moonxml]:    https://github.com/darkwiiplayer/moonxml "MoonXML"
[lunamark]:   https://github.com/jgm/lunamark "Lunamark"
[unlicense]:  https://unlicense.org "The Unlicense"
[ldoc]:       https://github.com/stevedonovan/LDoc, "LDoc - A Lua Documentation Tool"

