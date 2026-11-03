-- @id otakio.leercapitulo
-- @name LeerCapitulo
-- @lang es
-- @version 1
-- @nsfw false
-- @baseUrl https://www.leercapitulo.co
-- Native Otakio extension: LeerCapitulo (large Spanish manga/manhwa/comic catalog).

local U = Engines.util
local BASE = "https://www.leercapitulo.co"

local p = U.newParser({id = "OTAKIO_LEERCAPITULO", name = "LeerCapitulo", baseUrl = BASE, lang = "es", version = 1, engine = "native"}, {})

p.Filters = {
	{Name = "Tipo", Type = "radio", Tags = {"Todos", "Manga", "Manhwa", "Manhua", "Comic"}},
	{Name = "Estado", Type = "radio", Tags = {"Todos", "Ongoing", "Completed", "Paused", "Cancelled"}}
}

local function image(src)
	return src and src ~= "" and Http.image(src, BASE .. "/") or nil
end

local function cards(doc, dt, selector, nameSelector)
	for _, el in ipairs(doc:select(selector)) do
		local a = el:selectFirst(nameSelector)
		local img = el:selectFirst("img")
		if a then
			U.addManga(dt, p, a:text(), a:attr("abs:href"), image(img and img:attr("abs:src")))
		end
	end
end

function p:getPopularManga(page, dt)
	cards(Http.getDocument(BASE .. "/", U.headers(self)), dt, ".lc-slide", "a.lc-slide-name")
	dt.NoPages = true
end

function p:getLatestManga(page, dt)
	cards(Http.getDocument(BASE .. "/", U.headers(self)), dt, "article.lc-release", "a.lc-release-title")
	dt.NoPages = true
end

local function option(tags, name)
	local v = tags and tags[name]
	return (v and v ~= "Todos") and string.lower(v) or nil
end

function p:searchManga(query, page, dt, tags)
	local params = {}
	local q = Engines.decodeSearch(query)
	if q ~= "" then
		params[#params + 1] = {"q", q}
	end
	if option(tags, "Tipo") then
		params[#params + 1] = {"type", option(tags, "Tipo")}
	end
	if option(tags, "Estado") then
		params[#params + 1] = {"status", option(tags, "Estado")}
	end
	if page > 1 then
		params[#params + 1] = {"page", tostring(page)}
	end
	local doc = Http.getDocument(BASE .. "/manga/?" .. Http.form(params), U.headers(self))
	cards(doc, dt, "article.lc-card", "a.lc-card-name")
	dt.NoPages = doc:selectFirst("a.page-link[rel=next]") == nil
end

function p:getChapters(manga, dt)
	local doc = Http.getDocument(U.absolute(BASE, manga.Link), U.headers(self))
	local img = doc:selectFirst(".lc-cover-lg img")
	if img then
		manga.NewImageLink = image(img:attr("abs:src"))
	end
	local desc = doc:selectFirst("#sinopsis p:not(.lc-muted)")
	dt.Description = Engines.buildInfo({}, desc and desc:text() or "")
	-- the site lists newest first; Otakio stores oldest first
	local rows = doc:select("a.lc-chapter-row")
	for i = #rows, 1, -1 do
		local a = rows[i]
		local n = a:selectFirst(".n")
		local d = a:selectFirst(".d")
		dt[#dt + 1] = {Name = n and n:text() or U.trim(a:text()), Link = U.pathOf(a:attr("abs:href")), Date = d and d:text() or nil, Pages = {}, Manga = manga}
	end
end

function p:prepareChapter(chapter, dt)
	local doc = Http.getDocument(U.absolute(BASE, chapter.Link), U.headers(self))
	for _, img in ipairs(doc:select("#lcPages img[data-src]")) do
		dt[#dt + 1] = image(img:attr("abs:data-src"))
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
