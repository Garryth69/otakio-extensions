-- @id otakio.hentaihere
-- @name HentaiHere
-- @lang en
-- @version 1
-- @nsfw true
-- @baseUrl https://hentaihere.com
-- Native Otakio extension: HentaiHere (plain HTML; the reader keeps its image list in a JSON script tag).
-- Adapted from keiyoushi's HentaiHere (Apache-2.0).

local U = Engines.util
local BASE = "https://hentaihere.com"

local p = U.newParser({id = "OTAKIO_HENTAIHERE", name = "HentaiHere", baseUrl = BASE, lang = "en", version = 1, nsfw = true, engine = "native"}, {})

local function H()
	return {Referer = BASE .. "/"}
end

local function list(url, dt)
	local doc = Http.getDocument(url, H())
	local count = 0
	for _, card in ipairs(doc:select("article.card[data-card]")) do
		local a = card:selectFirst("a")
		local h3 = card:selectFirst("h3")
		local img = card:selectFirst("img")
		local cover = img and img:attr("abs:src") or nil
		if a and h3 and U.addManga(dt, p, h3:text(), a:attr("abs:href"), cover and Http.image(cover, BASE .. "/") or nil) then
			count = count + 1
		end
	end
	dt.NoPages = count == 0 or doc:selectFirst("a[rel=next]") == nil
end

local function browse(sort, page)
	return BASE .. "/browse/" .. sort .. (page > 1 and ("/page-" .. page) or "")
end

function p:getPopularManga(page, dt)
	list(browse("most-viewed", page), dt)
end

function p:getLatestManga(page, dt)
	list(browse("newest", page), dt)
end

function p:searchManga(query, page, dt)
	list(BASE .. "/search?q=" .. Http.encode(Engines.decodeSearch(query)) .. "&page=" .. page, dt)
end

function p:getChapters(manga, dt)
	local doc = Http.getDocument(U.absolute(BASE, manga.Link), H())
	local function detail(label)
		for _, dtEl in ipairs(doc:select("dl[aria-label=Details] dt")) do
			if string.find(dtEl:text(), label, 1, true) then
				local dd = dtEl:nextElementSibling()
				return dd and U.trim(dd:text()) or nil
			end
		end
	end
	local tags = {}
	for _, a in ipairs(doc:select("ul[aria-label=Tags] a")) do
		tags[#tags + 1] = U.trim(a:text())
	end
	dt.Description = Engines.buildInfo({Author = detail("Artist") or detail("Author"), Genres = tags, Status = detail("Status")}, "")
	local og = doc:selectFirst("meta[property=og:image]")
	if og and og:attr("content") ~= "" then
		manga.NewImageLink = Http.image(og:attr("content"), BASE .. "/")
	end
	-- the chapter selector is oldest first, which is also Otakio's order
	for _, o in ipairs(doc:select("#preview-chapter option")) do
		local link = o:attr("abs:data-read")
		if link ~= "" then
			local name = U.trim(string.gsub(o:text(), "%(latest%)%s*$", ""))
			dt[#dt + 1] = {Name = name, Link = U.pathOf(link), Pages = {}, Manga = manga}
		end
	end
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link)
	local doc = Http.getDocument(url, H())
	local script = doc:selectFirst("script[data-reader-data]")
	local data = script and Json.decode(script:data()) or nil
	for _, src in ipairs(type(data) == "table" and type(data.images) == "table" and data.images or {}) do
		if type(src) == "string" and src ~= "" then
			dt[#dt + 1] = Http.image(src, url)
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
