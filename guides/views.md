# Writing Views (or templates)

Templating—more precisely, HTML templating—is a core requirement for most web
applications. Different frameworks and templating engines have different
aproaches to this:

Some stick very close to the target syntax and look like a
more powerful version of string interpolation. Examples of this are Embedded
Ruby (ERB), PHP but also many more modern technologies such as Svelte or Vue.

Another aproach is to build a completely new domain-specific language to build
an HTML document without writing any HTML directly. Examples for this are Rubys
HAML or Lapis' HTML builder.

-----

By default, Restia supports three (plus one) types of templates:

**Cosmo** is a very powerful yet safe templating language that lets you embed
data directly in HTML (or any other text format) without allowing any direct
code execution. Inserting values, looping over arrays and even calling
predefined functions is supported.

	<h4>User Listing:</h4>
	<ul>
		$users[[
			<li>$name &lt;$mail&gt; (<a href="/users/$id">profile</a>)</li>
		]]
	</ul>

**MoonHTML** is a DSL based on Moonscript that allows generating HTML completely
programatically. It is very similar to HAML in many aspects, instead that you're
writing code by default instead of having to escape it with special syntax.

	h4 "User Listing:"
	ul ->
		for user in *users
			li ->
				print escape "#{user.name} <#{mail}> ("
				a href: "/users/#{user.id}", "profile"
				print ")"

These two can also be combined into **Multistage Templates**, which are MoonHTML
templates that get rendered immediately when they are loaded, and then compiled
as cosmo templates.

	h4 "User Listing:"
	ul ->
		print "$users[["
			print escape "$name <$mail> ("
			a href: "/users/$id", "profile"
			print ")"
		print "]]"

**Skooma** is a more functional aproach to HTML generation. It exposes pure
functions that return HTML nodes

	local function render_user(user)
		return li(
			user.name,
			' <', user.mail, '>',
			' (', a{href = "/users/" .. user.id, "profile"}, ')'
		)
	end

	return function(users)
		return {
			h4 "User Listing:",
			ul(map(render_user, users))
		}
	end

Since skooma "templates" are just Lua code, you can also write them in any
language that compiles to Lua, like for example moonscript:

	render_user ==>
		li @name, ' <', @mail, '> (', a("profile", href: "/users/#{@id}"), ")"
	
	(users) -> { h4 "User Listing:", ul map render_user, users }
