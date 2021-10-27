local restia = require 'restia'
local I = restia.utils.unpipe

return function()
	return {
		build = I[[
		|#!/bin/sh
		|lua build.lua --delete --copy css --copy javascript
		]];
		["build.lua"] = I[[
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
		|local layouts = restia.config.bind('layouts', {
		|	(require 'restia.config.skooma');
		|})
		|package.loaded.layouts = layouts
		|
		|local tree = {}
		|
		|-- Render skooma files in pages/ into html files
		|-- preserving directory structure
		|for file in restia.utils.files('pages', "%.skooma$") do
		|	local template = restia.config.skooma(file:gsub("%.skooma$", ''))
		|	restia.utils.deepinsert(
		|		tree,
		|		restia.utils.fs2tab(
		|			file
		|			:gsub("^pages/", "")
		|			:gsub("%.skooma$", ".html")
		|		),
		|		layouts.main(template())
		|	)
		|end
		|
		|for i, path in ipairs(params.copy) do
		|	restia.utils.deepinsert(tree, restia.utils.fs2tab(path), restia.utils.readdir(path))
		|end
		|
		|if params.delete then
		|	restia.utils.delete(params.output)
		|end
		|
		|restia.utils.builddir(params.output, tree)
		]];
		config = {
			["page.yaml"] = I[[
			|title: Test Website
			]];
		};
		layouts = {
			["main.skooma"] = I[[
			|local config = require 'config'
			|
			|return function(content)
			|	return render.html(
			|		html(
			|			head(
			|				title(config.page.title)
			|			),
			|			body (
			|				content
			|			)
			|		)
			|	)
			|end
			]];
		};
		pages = {
			["index.skooma"] = I[[
			|return function()
			|	return p 'Hello, World!'
			|end
			]];
		};
	}
end
