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

Documentation
--------------------------------------------------------------------------------
The documentation is currently not hosted online. It can be generated easily by
cloning the git repository and running [LDoc][ldoc].

Usage
--------------------------------------------------------------------------------

Currently there are only two functions:

- `restia.template`
Renders a template in [MoonXML][moonxml] format (similar to lapis builder syntax)
- `restia.markdown`
Renders a markdown file (using [Lunamark][lunamark])

Planned features
--------------------------------------------------------------------------------

- More MoonXML utility methods (lists, tables, etc.)
- Some High-Level functionality (Security-related, etc.)

Contributing
--------------------------------------------------------------------------------

In general, all meaningful contributions are welcome
under the following conditions:

- All commit messages must be meaningful. (No "updated file X", etc.)
- Commits must consist of (Atomic) changes that fit together.
- PGP-Signing commits is not mandatory, but encouraged.

After submitting a larger change, feel free to add your name to the
"contributors.lua" file. Please PGP-sign at least that commit though.

Changelog
--------------------------------------------------------------------------------

### Development (0.1)

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

