local restia = require 'restia'
local I = restia.utils.unpipe

return function()
	return {
		['example.post'] = I[[
		|---
		|title: Example
		|date: 1970-01-01
		|---
		|This is an example post.
		]];
		['build'] = I[[
		|#!/bin/sh
		|lua build.lua --delete --copy css --copy javascript
		]];
		['templates'] = {
			['main.skooma'] = I[=====[
			|local function map(tab, fn)
			|	local new = {}
			|	for key, value in ipairs(tab) do
			|		new[key] = fn(value)
			|	end
			|	return new
			|end
			|
			|return function(content, attributes)
			|	local route = {}
			|	for segment in attributes.uri:gmatch("[^/]+") do
			|		table.insert(route, segment)
			|	end
			|
			|	return render.html(html{
			|		head {
			|			title(attributes.title);
			|			link{rel="stylesheet", href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.58/dist/themes/light.css"};
			|			script{type="module", src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.58/dist/shoelace.js"};
			|			script { type="module", [[
			|				document.querySelector("#navigation-button").addEventListener("click", event => {
			|					document.querySelector("#menu-drawer").open = true
			|				})
			|			]]};
			|		};
			|		body {
			|			style = "padding: 2em max(calc(50vw - 40em), 2em)";
			|			slDrawer {
			|				placement = "start";
			|				id = "menu-drawer";
			|				ul(map(require("posts"), function(post)
			|					return li(a{href=post.head.uri, post.head.title});
			|				end));
			|			};
			|			div {
			|				style="display: flex; flex-flow: row; gap: 1em; align-items: center;";
			|				slButton { slIcon {name = "list", slot="prefix"}, "Menu", id="navigation-button" };
			|				slBreadcrumb {
			|					map(route, slBreadcrumbItem);
			|				};
			|			};
			|			article {
			|				h1(attributes.title);
			|				content;
			|			}
			|		};
			|	})
			|end
			]=====];
		};
		['build.lua'] = I[[
		|local arrr = require 'arrr'
		|local restia = require 'restia'
		|local shapeshift = require 'shapeshift'
		|
		|local params do
		|	local is = shapeshift.is
		|	local parse = arrr {
		|		{ "Output directory", "--output", "-o", 'directory' };
		|		{ "Input directory", "--input", "-i", 'directory' };
		|		{ "Copy directory", "--copy", "-c", 'directory', 'repeatable' };
		|		{ "Delete everything first", "--delete", "-d" };
		|	}
		|	local validate = shapeshift.table {
		|		output = shapeshift.default("out", is.string);
		|		input = shapeshift.default(".", is.string);
		|		copy = shapeshift.default({}, shapeshift.all{
		|			is.table,
		|			shapeshift.each(is.string)
		|		});
		|		delete = shapeshift.default(false, shapeshift.is.boolean);
		|	}
		|	params = select(2, assert(validate(parse{...})))
		|end
		|
		|local config = restia.config.bind('config', {
		|	(require 'restia.config.readfile');
		|	(require 'restia.config.lua');
		|	(require 'restia.config.yaml');
		|})
		|package.loaded.config = config
		|
		|local templates = restia.config.bind('templates', {
		|	(require 'restia.config.skooma');
		|})
		|package.loaded.templates = templates
		|
		|local function render_post(file)
		|	local post = restia.config.post(from)
		|
		|	restia.utils.mkdir(to:gsub("[^/]+$", ""))
		|	local outfile = assert(io.open(to, 'wb'))
		|	outfile:write(body)
		|	outfile:close()
		|end
		|
		|local posts = {}
		|package.loaded.posts = posts
		|
		|local tree = {}
		|
		|for i, path in ipairs(params.copy) do
		|	restia.utils.deepinsert(tree, restia.utils.fs2tab(path), restia.utils.readdir(path))
		|end
		|
		|local validate_head do
		|	local is = shapeshift.is
		|	validate_head = shapeshift.table {
		|		__extra = 'keep';
		|		title = is.string;
		|		date = shapeshift.matches("%d%d%d%d%-%d%d%-%d%d");
		|		file = is.string;
		|	}
		|end
		|
		|local function parsedate(date)
		|	local year, month, day = date:match("(%d+)%-(%d+)%-(%d+)")
		|	return os.time {
		|		year = tonumber(year);
		|		month = tonumber(month);
		|		day = tonumber(day);
		|	}
		|end
		|
		|-- Load Posts
		|for file in restia.utils.files(params.input, "%.post$") do
		|	local post = restia.config.post(file:gsub("%.post$", ""))
		|	post.head.file = file
		|
		|	assert(validate_head(post.head))
		|
		|	post.head.timestamp = parsedate(post.head.date)
		|
		|	post.head.slug = post.head.title
		|		:gsub(' ', '_')
		|		:lower()
		|		:gsub('[^a-z0-9-_]', '')
		|
		|	post.head.uri = string.format("/%s/%s.html", post.head.date:gsub("%-", "/"), post.head.slug)
		|	post.path = restia.utils.fs2tab(post.head.uri)
		|
		|	table.insert(posts, post)
		|end
		|
		|table.sort(posts, function(a, b)
		|	return a.head.timestamp > b.head.timestamp
		|end)
		|
		|-- Render Posts
		|for idx, post in ipairs(posts) do
		|	local template if post.head.template then
		|		template = templates[post.head.template]
		|	elseif templates.main then
		|		template = templates.main
		|	end
		|
		|	local body if template then
		|		body = restia.utils.deepconcat(template(post.body, post.head))
		|	else
		|		body = post.body
		|	end
		|
		|	restia.utils.deepinsert(tree, post.path, body)
		|end
		|
		|if params.delete then
		|	restia.utils.delete(params.output)
		|end
		|
		|restia.utils.builddir(params.output, tree)
		]];
	}
end
