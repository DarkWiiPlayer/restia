Restia
================================================================================

Restia is a library that aims to make developing web-applications in Lua easier.

### What do I need to get started?

	restia new .
	restia run &

That's it. You can now open it in your browser at localhost:8080 or start
hacking the code right away :)

### What makes it different?

Unlike with frameworks like Rails or Lapis, the developer stays in control.

Restia is your tool, not your overlord.
It aims to help where it can, without forcing the shape of your final product.

You might have heared about "convention over configuration".
But that's not really true; the configuration is there, it's just encoded as
defaults in the framework itself, making it harder to customize.

Restia keeps this *convention* part out of the library and, instead, generates
configurations that represent these conventions.
The effect is the same, but it makes it easier to change things.

I call this aproach

> "Convention encoded in generated configuration over headache"

### What makes it *special*?

**Simplicity** — Restia is built to be simple, which makes it easy to extend

**Control** — Restia doesn't tell you what to do; it gives you its idea of a
project layout and lets you do whatever you want with it.

**Modularity** — Not everything is a web app; maybe you just need the
templating? or the config loading? no problem, it's split into modules!

**Self-Contained** — Thanks to Luarocks being awesome, installing restia
separately for just the project is trivial. The template project makes it even
easier!

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
	restia new .
	restia run &

After that you will have a template project in the current directory and restia
running in the background.

You can now start looking at the project directory, make changes and reload
restia with

	restia test
	restia reload

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

- Add support for moonhtml+cosmo multistage templates
- Add support for cosmo templates
- Integrate templates with config
- Add `config` module
- Rewrite template loading to use a table and render on demand ;)
- Rewrite template loading to use buffer and render instantly
- Add executable for scaffolding, running tests, starting a server, etc.
- Switch to moonxml initializers
- Add `ttable` function for more complex tables
- Add `vtable` function for vertical tables
- Add `olist` function for ordered lists
- Add `ulist` function for unordered lists
- Add `html5` function for html 5 doctype
- Add `template` function for MoonHTML templates
- Add `markdown` function for Markdown Templates (using [Lunamark][lunamark])

----

License: [The Unlicense][unlicense]

[moonxml]:    https://github.com/darkwiiplayer/moonxml "MoonXML"
[lunamark]:   https://github.com/jgm/lunamark "Lunamark"
[unlicense]:  https://unlicense.org "The Unlicense"
[ldoc]:       https://github.com/stevedonovan/LDoc, "LDoc - A Lua Documentation Tool"

