Restia
================================================================================

Restia is a library that aims to make developing web-applications in Lua easier.

It differs from frameworks like Lapis or Rails in that it is less opinionated and
does not provide any inversion of control;
the user still decides when to call restia and when not to, allowing for easier
integration into existing systems.

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

### Executable

To get an overview of the available commands, run `restia help`.

The fastest way to get started is to just run

	restia new app
	cd app
	restia test
	restia run

This will create some scaffolding for a web application and start the server.

### Library

Currently the library doesn't do all that much:

-	`restia.templates`
	A table that lazy-loads templates when indexed with a path.
	When called, it returns a function that renders a template in
	[MoonXML][moonxml] format (similar to lapis builder syntax).
	The special index `__prefix` can be used to set a search path
	for the moonthml files.
-	`restia.markdown`
	Renders a markdown file directly (using [Lunamark][lunamark])

Restia also adds a few utility functions to the MoonXML environment.
A full list can be found in the documentation.

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

