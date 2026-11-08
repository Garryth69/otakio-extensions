-- @id otakio.dongmanmanhua
-- @name 咚漫 (Dongman Manhua)
-- @lang zh
-- @version 1
-- @nsfw false
-- @baseUrl https://www.dongmanmanhua.cn
-- Native Otakio extension: Dongman Manhua, the official Chinese WEBTOON site (free episodes).
-- Adapted from keiyoushi's DongmanManhua (Apache-2.0).

local U = Engines.util
local BASE = "https://www.dongmanmanhua.cn"

local p = U.newParser({id = "OTAKIO_DONGMANMANHUA", name = "咚漫 (Dongman Manhua)", baseUrl = BASE, lang = "zh", version = 1, engine = "native"}, {})

local function H()
	return {Referer = BASE .. "/"}
end

local function addFrom(dt, links)
	local seen = {}
	for _, a in ipairs(links) do
		local href = a:attr("abs:href")
		local subj = a:selectFirst("p.subj")
		if href ~= "" and subj and not seen[href] then
			seen[href] = true
			local img = a:selectFirst("img")
			U.addManga(dt, p, subj:text(), href, img and img:attr("abs:src") or nil)
		end
	end
end

function p:getPopularManga(page, dt)
	local doc = Http.getDocument(BASE .. "/dailySchedule", H())
	addFrom(dt, doc:select("div#dailyList .daily_section li a, div.daily_lst.comp li a"))
	dt.NoPages = true
end

function p:getLatestManga(page, dt)
	local doc = Http.getDocument(BASE .. "/dailySchedule?sortOrder=UPDATE&webtoonCompleteType=ONGOING", H())
	addFrom(dt, doc:select("div#dailyList li > a"))
	dt.NoPages = true
end

function p:searchManga(query, page, dt)
	local url = BASE .. "/search?keyword=" .. Http.encode(Engines.decodeSearch(query)) .. (page > 1 and ("&page=" .. page) or "")
	local doc = Http.getDocument(url, H())
	addFrom(dt, doc:select("div.card_wrap.search ul li a"))
	dt.NoPages = doc:selectFirst("div.more_area, div.paginate a[onclick] + a") == nil
end

function p:getChapters(manga, dt)
	local url = U.absolute(BASE, manga.Link)
	local doc = Http.getDocument(url, H())
	local info = doc:selectFirst("#_asideDetail")
	local header = doc:selectFirst(".detail_header .info")
	local genres = {}
	for _, g in ipairs(header and header:select(".genre") or {}) do
		genres[#genres + 1] = U.trim(g:text())
	end
	local author = header and header:selectFirst(".author, .author_area")
	local summary = info and info:selectFirst("p.summary")
	local dayInfo = info and info:selectFirst("p.day_info")
	dt.Description = Engines.buildInfo({
		Genres = genres,
		Author = author and U.trim(author:ownText()) or nil,
		Status = dayInfo and U.trim(dayInfo:text()) or nil
	}, summary and summary:text() or "")
	-- every page of the episode list, newest first; Otakio stores oldest first
	local out, pages = {}, 0
	while doc and pages < 60 do
		pages = pages + 1
		for _, li in ipairs(doc:select("ul#_listUl li")) do
			local a = li:selectFirst("a")
			local name = li:selectFirst("span.subj span")
			if a and a:attr("href") ~= "" then
				local date = li:selectFirst("span.date")
				out[#out + 1] = {Name = name and name:text() or U.trim(a:text()), Link = U.pathOf(a:attr("abs:href")), Date = date and U.trim(date:text()) or nil}
			end
		end
		local nextLink = doc:selectFirst("div.paginate a[onclick] + a")
		if nextLink and nextLink:attr("href") ~= "" and nextLink:attr("href") ~= "#" then
			coroutine.yield(false)
			doc = Http.getDocument(nextLink:attr("abs:href"), H())
		else
			doc = nil
		end
	end
	for i = #out, 1, -1 do
		local c = out[i]
		dt[#dt + 1] = {Name = c.Name, Link = c.Link, Date = c.Date, Pages = {}, Manga = manga}
	end
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link)
	local doc = Http.getDocument(url, H())
	for _, img in ipairs(doc:select("div#_imageList > img")) do
		local src = img:attr("data-url")
		if src ~= "" then
			dt[#dt + 1] = Http.image(src, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
