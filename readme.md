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

Usage
--------------------------------------------------------------------------------

Currently there are only two functions in the module:

- `restia.template`
Renders a template in [MoonXML][moonxml] format (similar to lapis builder syntax)
- `restia.markdown`
Renders a markdown file (using [Lunamark][lunamark])

Restia also adds a few utility functions to the MoonXML environment.

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

