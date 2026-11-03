-- @id otakio.weebcentral
-- @name Weeb Central
-- @lang en
-- @version 1
-- @nsfw false
-- @baseUrl https://weebcentral.com
-- Native Otakio extension: Weeb Central (large English catalog, successor of MangaSee).

local U = Engines.util
local BASE = "https://weebcentral.com"
local LIMIT = 32

local p = U.newParser({id = "OTAKIO_WEEBCENTRAL", name = "Weeb Central", baseUrl = BASE, lang = "en", version = 1, engine = "native"}, {})

p.Filters = {
	{Name = "Sort", Type = "radio", Tags = {"Best Match", "Popularity", "Latest Updates", "Alphabet", "Recently Added"}}
}

local function cover(el)
	local source = el:selectFirst("source")
	if source and source:attr("srcset") ~= "" then
		return (string.gsub(source:attr("srcset"), "small", "normal"))
	end
	local img = el:selectFirst("img")
	return img and img:attr("abs:src")
end

local function search(page, dt, text, sort)
	local url = BASE .. "/search/data?" .. Http.form({
		{"text", U.trim(string.gsub(text or "", "[!#:(),%-]", " "))},
		{"sort", sort},
		{"order", "Descending"},
		{"official", "Any"},
		{"limit", tostring(LIMIT)},
		{"offset", tostring((page - 1) * LIMIT)},
		{"display_mode", "Full Display"}
	})
	local doc = Http.getDocument(url, U.headers(p))
	for _, a in ipairs(doc:select("article > section > a")) do
		local title = a:selectFirst("div:not([class]):last-child") or a
		U.addManga(dt, p, title:text(), a:attr("abs:href"), cover(a))
	end
	dt.NoPages = doc:selectFirst("button") == nil
end

function p:getPopularManga(page, dt)
	search(page, dt, "", "Popularity")
end

function p:getLatestManga(page, dt)
	search(page, dt, "", "Latest Updates")
end

function p:searchManga(query, page, dt, tags)
	search(page, dt, Engines.decodeSearch(query), tags and tags["Sort"] or "Best Match")
end

function p:getChapters(manga, dt)
	local url = U.absolute(BASE, manga.Link)
	local doc = Http.getDocument(url, U.headers(self))
	local sections = doc:select("section[x-data] > section")
	local left, right = sections[1], sections[2]
	if left then
		local img = cover(left)
		if img then
			manga.NewImageLink = Http.image(img, BASE .. "/")
		end
		local desc = right and right:selectFirst("li:has(strong:contains(Description)) > p")
		dt.Description = Engines.buildInfo({
			Author = U.trim(left:select("ul > li:has(strong:contains(Author)) > span > a"):text()),
			Status = U.trim(left:select("ul > li:has(strong:contains(Status)) > a"):text()),
			Genres = left:select("ul > li:has(strong:contains(Tag)) a"):eachText()
		}, desc and desc:text() or "")
	end
	local seriesId = string.match(manga.Link, "/series/([^/]+)")
	if not seriesId then
		return
	end
	local list = Http.getDocument(BASE .. "/series/" .. seriesId .. "/full-chapter-list", U.headers(self))
	local out = {}
	for _, a in ipairs(list:select("div[x-data] > a")) do
		local name = a:selectFirst("span.flex > span")
		local time = a:selectFirst("time[datetime]")
		out[#out + 1] = {Name = name and name:text() or U.trim(a:text()), Link = U.pathOf(a:attr("abs:href")), Date = time and string.sub(time:attr("datetime"), 1, 10)}
	end
	for i = #out, 1, -1 do
		local c = out[i]
		dt[#dt + 1] = {Name = c.Name, Link = c.Link, Date = c.Date, Pages = {}, Manga = manga}
	end
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link) .. "/images?is_prev=False&reading_style=long_strip"
	local doc = Http.getDocument(url, U.headers(self))
	for _, img in ipairs(doc:select("section[x-data*=scroll] > img, img[x-bind]")) do
		local src = img:attr("abs:src")
		if src ~= "" then
			dt[#dt + 1] = Http.image(src, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
