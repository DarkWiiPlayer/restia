--- Markdown auxiliary module.
-- Allows rendering markdown files directly into the document.
-- @module restia.markdown
-- @author DarkWiiPlayer
-- @license Unlicense

local markdown = {}

local lunamark = require "lunamark"

--- Parses markdown into HTML
-- @function parsemd
-- @local
-- @tparam string markdown
-- @treturn string
-- @usage parsemd 'some *fancy* text'
do local writer = lunamark.writer.html5.new{containers=true}
	markdown.parse = lunamark.reader.markdown.new(writer, {smart = true})
end

--- Parses a markdown file.
-- @tparam string path The markdown file to read
-- @treturn string
-- @usage parsemdfile 'documents/markdown/article.md'
local function parsemdfile(path)
	local file, err = io.open(path)
	if file then
		return markdown.parse(file:read("*a"))
	else
		return file, err
	end
end

local markdown_cache = {}

--- Renders a markdown file.
-- @fixme Do caching properly
-- @tparam string document Markdown file (without extension) to load
-- @tparam[opt=false] boolean cache Whether to cache the template
-- @usage
-- 	restia.markdown('content')
function markdown.load(document, cache)
	document = document .. '.md'
	if cache then
		markdown_cache[document] = markdown_cache[document] or parsemdfile(document)
		return markdown_cache[document]
	else
		return parsemdfile(document)
	end
end

return markdown
