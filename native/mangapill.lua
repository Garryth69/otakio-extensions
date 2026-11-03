-- @id otakio.mangapill
-- @name Mangapill
-- @lang en
-- @version 1
-- @nsfw false
-- @baseUrl https://mangapill.com
-- Native Otakio extension: Mangapill (large English manga catalog, fast mirror of official chapters).

local U = Engines.util
local BASE = "https://mangapill.com"

local p = U.newParser({id = "OTAKIO_MANGAPILL", name = "Mangapill", baseUrl = BASE, lang = "en", version = 1, engine = "native"}, {})

p.Filters = {
	{Name = "Type", Type = "radio", Tags = {"All", "Manga", "Manhwa", "Manhua", "One-Shot", "Doujinshi"}},
	{Name = "Status", Type = "radio", Tags = {"All", "Publishing", "Finished", "On Hiatus", "Discontinued"}}
}

local function image(src)
	return src and src ~= "" and Http.image(src, BASE .. "/") or nil
end

local function addGrid(dt, doc, selector)
	for _, el in ipairs(doc:select(selector)) do
		local a = el:selectFirst("a[href^='/manga/']")
		local title = el:selectFirst("div.line-clamp-2")
		local img = el:selectFirst("img")
		if a and title then
			U.addManga(dt, p, title:text(), a:attr("abs:href"), image(img and img:attr("data-src")))
		end
	end
end

function p:getPopularManga(page, dt)
	local doc = Http.getDocument(BASE .. "/", U.headers(self))
	addGrid(dt, doc, "div:has(h4:contains(Trending)) > .grid > div:not([class])")
	dt.NoPages = true
end

function p:getLatestManga(page, dt)
	local doc = Http.getDocument(BASE .. "/chapters", U.headers(self))
	addGrid(dt, doc, ".grid > div:not([class])")
	dt.NoPages = true
end

local function option(tags, name)
	local v = tags and tags[name]
	if not v or v == "All" then
		return ""
	end
	return string.lower(v)
end

function p:searchManga(query, page, dt, tags)
	local url = BASE .. "/search?" .. Http.form({
		{"q", Engines.decodeSearch(query)},
		{"type", option(tags, "Type")},
		{"status", option(tags, "Status")},
		{"page", tostring(page)}
	})
	local doc = Http.getDocument(url, U.headers(self))
	addGrid(dt, doc, ".grid > div:not([class])")
	dt.NoPages = doc:selectFirst("a.btn.btn-sm") == nil
end

function p:getChapters(manga, dt)
	local doc = Http.getDocument(U.absolute(BASE, manga.Link), U.headers(self))
	local img = doc:selectFirst("div.container > div:first-child > div:first-child > img")
	if img and img:attr("data-src") ~= "" then
		manga.NewImageLink = image(img:attr("data-src"))
	end
	dt.Description = Engines.buildInfo({
		Status = U.trim(doc:select("div.container > div:first-child > div:last-child > div:nth-child(3) > div:nth-child(2) > div"):text()),
		Genres = doc:select("a[href*=genre]"):eachText()
	}, doc:select("div.container > div:first-child > div:last-child > div:nth-child(2) > p"):text())
	-- the site lists newest first; Otakio stores oldest first
	local links = doc:select("#chapters > div > a")
	for i = #links, 1, -1 do
		local a = links[i]
		dt[#dt + 1] = {Name = U.trim(a:text()), Link = U.pathOf(a:attr("abs:href")), Pages = {}, Manga = manga}
	end
end

function p:prepareChapter(chapter, dt)
	local doc = Http.getDocument(U.absolute(BASE, chapter.Link), U.headers(self))
	for _, img in ipairs(doc:select("picture img")) do
		local src = img:attr("data-src")
		if src ~= "" then
			dt[#dt + 1] = image(src)
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
