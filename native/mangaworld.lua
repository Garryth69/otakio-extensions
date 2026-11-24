-- @id otakio.mangaworld
-- @name MangaWorld
-- @lang it
-- @version 2
-- @nsfw false
-- @baseUrl https://www.mangaworld.me
-- Native Otakio extension: MangaWorld (the largest Italian manga catalog).

local U = Engines.util
local BASE = "https://www.mangaworld.me"

local p = U.newParser({id = "OTAKIO_MANGAWORLD", name = "MangaWorld", baseUrl = BASE, lang = "it", version = 2, engine = "native"}, {})

p.Filters = {
	{Name = "Tipologia", Type = "radio", Tags = {"Tutti", "Manga", "Manhwa", "Manhua", "Oneshot"}},
	{Name = "Stato", Type = "radio", Tags = {"Tutti", "In corso", "Finito", "In pausa"}}
}
local STATUS = {["In corso"] = "ongoing", Finito = "completed", ["In pausa"] = "paused"}

local function image(src)
	return src and src ~= "" and Http.image(src, BASE .. "/") or nil
end

local function list(url, dt)
	local doc = Http.getDocument(url, U.headers(p))
	local n = 0
	-- cards of the archive and of the home page (2026 layout); the old grid as a fallback
	for _, el in ipairs(doc:select("article.card, div.comics-grid .entry")) do
		local a = el:selectFirst("a.card-cover, a.thumb, a")
		local img = a and a:selectFirst("img")
		local title = a and a:attr("title") or ""
		if title == "" then
			local t = el:selectFirst(".card-title a")
			title = t and U.trim(t:text()) or ""
		end
		if a and title ~= "" then
			n = n + 1
			U.addManga(dt, p, title, (string.gsub(a:attr("abs:href"), "/$", "")), image(img and img:attr("abs:src")))
		end
	end
	dt.NoPages = n < 16
end

function p:getPopularManga(page, dt)
	list(BASE .. "/archive?sort=most_read&page=" .. page, dt)
end

function p:getLatestManga(page, dt)
	list(BASE .. "/?page=" .. page, dt)
end

function p:searchManga(query, page, dt, tags)
	local params = {{"page", tostring(page)}}
	local q = Engines.decodeSearch(query)
	if q ~= "" then
		params[#params + 1] = {"keyword", q}
	end
	local t = tags and tags["Tipologia"]
	if t and t ~= "Tutti" then
		params[#params + 1] = {"type", string.lower(t)}
	end
	local s = tags and STATUS[tags["Stato"] or ""]
	if s then
		params[#params + 1] = {"status", s}
	end
	list(BASE .. "/archive?" .. Http.form(params), dt)
end

local function listStyle(url)
	if string.find(url, "style=list", 1, true) then
		return url
	end
	if string.find(url, "style=pages", 1, true) then
		return (string.gsub(url, "style=pages", "style=list"))
	end
	return url .. (string.find(url, "?", 1, true) and "&" or "?") .. "style=list"
end

function p:getChapters(manga, dt)
	local doc = Http.getDocument(U.absolute(BASE, manga.Link), U.headers(self))
	local info = doc:selectFirst("div.manga-info, div.comic-info")
	if info then
		local img = doc:selectFirst(".manga-cover img, .comic-info .thumb > img")
		if img then
			manga.NewImageLink = image(img:attr("abs:src"))
		end
		local author = info:selectFirst("a[href*=author=]")
		local status = info:selectFirst("a[href*=status=]")
		dt.Description = Engines.buildInfo({
			Author = author and author:text() or nil,
			Status = status and status:text() or nil,
			Genres = info:select("li a[href*=genre=], div.meta-data a.badge"):eachText()
		}, doc:select("p.manga-plot, div#noidungm"):text())
	end
	local out = {}
	for i, el in ipairs(doc:select("li.ch-row, .chapters-wrapper .chapter")) do
		if i % 100 == 0 then
			coroutine.yield(false) -- 1000+ chapters (One Piece): keep the screen moving
		end
		local a = el:selectFirst("a.ch, a.chap")
		if a then
			local nameEl = el:selectFirst(".ch-name, span.d-inline-block")
			local name = nameEl and nameEl:text() or U.trim(a:text())
			out[#out + 1] = {
				n = tonumber(string.match(string.lower(name), "capitolo%s+([%d%.]+)")),
				i = i,
				Name = name,
				Link = U.pathOf(listStyle(a:attr("abs:href")))
			}
		end
	end
	-- the site lists newest first; Otakio stores oldest first
	table.sort(out, function(a, b)
		if a.n and b.n and a.n ~= b.n then
			return a.n < b.n
		end
		return a.i > b.i
	end)
	for _, c in ipairs(out) do
		dt[#dt + 1] = {Name = c.Name, Link = c.Link, Pages = {}, Manga = manga}
	end
end

function p:prepareChapter(chapter, dt)
	local doc = Http.getDocument(U.absolute(BASE, chapter.Link), U.headers(self))
	for _, img in ipairs(doc:select("img.reader-page, div#page img.page-image")) do
		dt[#dt + 1] = image(img:attr("abs:src"))
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
