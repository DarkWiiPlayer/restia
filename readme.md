![Restia](logo.svg) [![License: Unlicense](https://img.shields.io/github/license/darkwiiplayer/restia)](https://unlicense.org/)
================================================================================

[![Built with ♥](https://forthebadge.com/images/badges/built-with-love.svg)](https://forthebadge.com)
[![Uses Badges](https://forthebadge.com/images/badges/uses-badges.svg)](https://forthebadge.com)

Restia is a library that aims to make developing web-applications in Lua easier.

### What do I need to get started?

  luarocks install restia --dev --lua-version 5.1
	restia new .
	restia run &

That's it. You can now open it in your browser at localhost:8080 or start
hacking the code right away :)

### What makes it different?

The key features that set restia apart from other frameworks like Rails or Lapis
are:

*Simplicity* —
Restia has a small codebase,
making it easy to understand and adapt.

*Modularity* —
The core library is modular.
That doesn't just mean it's split into files as one expects from any project;
all of the modules depend on as few other modules as possible,
allowing most of them to be included into completely unrelated projects.
Like the config loader? just throw it into your CLI application
that's not even related to web applications.
Like the HTML Templating engine? again, just plug it into your project and use
it.

*No Magic (Maybe some sorcery though)* —
Nothing in the core library happens "on its own"
as it does in other frameworks.
Restia encourages automation to be written out somewhere in the project,
making it easier to modify and reason about.

*Power* —
Restia was built to exist within the growing ecosystem of Lua and Openresty.
Instead of implementing everything from scratch,
it makes it easy to include components that already exist out there.
*Todo / Work in Progress: Documented API for custom config loaders*

**And most importantly**:

> Restia is your tool, not your overlord.

### What makes it *special*?

<details>
<summary>Powerful Templating</summary>
Making use of MoonXML, a templating engine very similar to that of the great Lapis
framework in combination with the very fast cosmo templating engine,
writing HTML has never been easier.
At the cost of some sligtly increased complexity,
multistage templates allow rendering MoonXML into a cosmo template
on startup for a combination of convenient development and performant runtime.
</details>

<details>
<summary>Flexible Configuration</summary>
Making use of metatables to dynamically load files in different formats at
runtime and making them available as table keys
allows the developer to forget about folders, files and file structure.
One can simply index through folders into files and their structure as if they
had always been just a tree of nested Lua tables.
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

Getting started
--------------------------------------------------------------------------------

After creating your project with `restia new`, should you start?

- Run your application in the background with `restia run &`
- Open `/views/front.moonhtml` and play around with your front page
- Open `/controllers/front.lua` and add some logic to it
- Run tests with `restia test`; Restia created a bunch of them for you in `/spec`
- Check out `getting-started.md` for more information :D

Building the Documentation
--------------------------------------------------------------------------------

Lua doesn't install its documentation with luarocks, so it has to be built
manually or read online. To build it, simply install [ldoc](ldoc), clone the
restia repository and run `ldoc .` in its top level directory. The docs will
be generated in the `doc` folder by default.

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

- Add `restia.negotiator` template
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

