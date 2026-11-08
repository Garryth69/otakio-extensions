-- @id otakio.mangakatana
-- @name MangaKatana
-- @lang en
-- @version 1
-- @nsfw false
-- @baseUrl https://mangakatana.com
-- Native Otakio extension: MangaKatana (plain HTML; page list is a plain array in the reader script).
-- Adapted from keiyoushi's MangaKatana (Apache-2.0).

local U = Engines.util
local BASE = "https://mangakatana.com"

local p = U.newParser({id = "OTAKIO_MANGAKATANA", name = "MangaKatana", baseUrl = BASE, lang = "en", version = 1, engine = "native"}, {})

local function H()
	return {Referer = BASE .. "/"}
end

local function list(url, dt)
	local doc = Http.getDocument(url, H())
	local count = 0
	for _, item in ipairs(doc:select("div#book_list > div.item")) do
		local a = item:selectFirst("div.text > h3 > a")
		local img = item:selectFirst("img")
		if a and U.addManga(dt, p, U.trim(a:ownText() ~= "" and a:ownText() or a:text()), a:attr("abs:href"), img and img:attr("abs:src") or nil) then
			count = count + 1
		end
	end
	dt.NoPages = count == 0 or doc:selectFirst("a.next.page-numbers") == nil
end

function p:getPopularManga(page, dt)
	list(BASE .. "/manga/page/" .. page .. "?filter=1&order=numc", dt)
end

function p:getLatestManga(page, dt)
	list(BASE .. "/manga/page/" .. page, dt)
end

function p:searchManga(query, page, dt)
	list(BASE .. "/page/" .. page .. "?search=" .. Http.encode(Engines.decodeSearch(query)) .. "&search_by=book_name", dt)
end

function p:getChapters(manga, dt)
	local doc = Http.getDocument(U.absolute(BASE, manga.Link), H())
	local genres = {}
	for _, g in ipairs(doc:select(".genres > a")) do
		genres[#genres + 1] = U.trim(g:text())
	end
	local authors = {}
	for _, a in ipairs(doc:select(".author")) do
		authors[#authors + 1] = U.trim(a:text())
	end
	local desc = {}
	for _, s in ipairs(doc:select(".summary > p")) do
		desc[#desc + 1] = U.trim(s:text())
	end
	local status = doc:selectFirst(".value.status")
	dt.Description = Engines.buildInfo({Author = table.concat(authors, ", "), Genres = genres, Status = status and U.trim(status:text()) or nil}, table.concat(desc, "\n"))
	local cover = doc:selectFirst("div.media div.cover img")
	if cover and cover:attr("src") ~= "" then
		manga.NewImageLink = cover:attr("abs:src")
	end
	local links = doc:select("div.chapters div.chapter a")
	local dates = doc:select("div.chapters div.update_time")
	-- newest first on the site; Otakio stores chapters oldest first
	for i = links:size(), 1, -1 do
		local a = links[i]
		if a:attr("href") ~= "" then
			local d = dates[i]
			dt[#dt + 1] = {Name = U.trim(a:text()), Link = U.pathOf(a:attr("abs:href")), Date = d and U.trim(d:text()) or nil, Pages = {}, Manga = manga}
		end
	end
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link)
	local body = Http.get(url, H()) or ""
	-- the reader script fills the images from an array: obj.attr('data-src', NAME[i])
	local name = string.match(body, "data%-src['\"],%s*([%w_]+)")
	local arr = name and string.match(body, "var " .. name .. "=%[([^%[]*)%]")
	if not arr then
		return
	end
	for src in string.gmatch(arr, "'([^']*)'") do
		if src ~= "" then
			dt[#dt + 1] = Http.image(src, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
