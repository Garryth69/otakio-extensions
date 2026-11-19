-- @id otakio.keroscans
-- @name KeroScans
-- @lang en
-- @version 1
-- @nsfw false
-- @baseUrl https://keroscans.net
-- Native Otakio extension: KeroScans (its own site: /series grid of <article> cards, chapters in pages of the series
-- page's "partial=chapters" fragment, plain <img> pages). Only free chapters are listed. Replaces the VineTheme-based
-- kei.en.keroscans. Adapted from keiyoushi's Keroscans (Apache-2.0).

local U = Engines.util
local BASE = "https://keroscans.net"

local p = U.newParser({id = "OTAKIO_KEROSCANS", name = "KeroScans", baseUrl = BASE, lang = "en", version = 1, engine = "native"}, {})

local function H(extra)
	local h = {Referer = BASE .. "/"}
	for k, v in pairs(extra or {}) do
		h[k] = v
	end
	return h
end

local function cards(url, dt)
	local doc = Http.getDocument(url, H())
	local count = 0
	for _, art in ipairs(doc:select("article")) do
		local a = art:selectFirst("a")
		local title = a and a:selectFirst("h3")
		local img = a and a:selectFirst(".ks-cover img")
		if title and U.addManga(dt, p, title:text(), a:attr("abs:href"), img and img:attr("abs:src") or nil) then
			count = count + 1
		end
	end
	dt.NoPages = count == 0 or doc:selectFirst('nav[aria-label="Pagination"] a[rel="next"]') == nil
end

function p:getPopularManga(page, dt)
	cards(BASE .. "/series?sort=popular&page=" .. page, dt)
end

function p:getLatestManga(page, dt)
	cards(BASE .. "/series?sort=latest&page=" .. page, dt)
end

function p:searchManga(query, page, dt)
	local q = Engines.decodeSearch(query)
	if #q < 3 then
		cards(BASE .. "/series?page=" .. page, dt)
	else
		cards(BASE .. "/search?" .. Http.form({{"q", q}, {"page", tostring(page)}}), dt)
	end
end

local function addRows(doc, list)
	for _, li in ipairs(doc:select('#chapter-list ol li[data-access="free"], ol[data-chapter-rows] li[data-access="free"], li[data-access="free"]')) do
		local a = li:selectFirst("a")
		if a and a:attr("href") ~= "" then
			local time = li:selectFirst("time")
			list[#list + 1] = {Name = "Chapter " .. a:attr("data-chapter-number"), Link = a:attr("href"), Date = time and string.sub(time:attr("datetime"), 1, 10) or nil}
		end
	end
	return doc:selectFirst("[data-chapter-more-wrap]") ~= nil
end

function p:getChapters(manga, dt)
	local url = U.absolute(BASE, manga.Link)
	local doc = Http.getDocument(url, H())
	local info = {Genres = doc:select('ul[aria-label="Genres"] li'):eachText()}
	for _, row in ipairs(doc:select('aside[aria-label="Series details"] dl div')) do
		local k, v = row:selectFirst("dt"), row:selectFirst("dd")
		if k and v then
			local key = U.trim(k:text())
			if key == "Author" or key == "Artist" or key == "Status" then
				info[key] = U.trim(v:text())
			end
		end
	end
	local summary = doc:selectFirst(".ks-sp__summary")
	dt.Description = Engines.buildInfo(info, summary and U.trim(summary:wholeText()) or "")
	local cover = doc:selectFirst('section[aria-label="Cover"] img')
	if cover and cover:attr("abs:src") ~= "" then
		manga.NewImageLink = Http.image(cover:attr("abs:src"), BASE .. "/")
	end
	-- newest first, ten a page; locked (paid) chapters are left out
	local list = {}
	local more = addRows(doc, list)
	local page = 2
	while more and page <= 200 do
		coroutine.yield(false)
		local body = Http.get(url .. "?page=" .. page .. "&partial=chapters", H({Referer = url, ["X-Requested-With"] = "XMLHttpRequest"}))
		more = addRows(Html.parse("<div id=\"chapter-list\"><ol>" .. body .. "</ol></div>", url), list)
		page = page + 1
	end
	local seen = {}
	for i = #list, 1, -1 do
		local c = list[i]
		if not seen[c.Link] then
			seen[c.Link] = true
			dt[#dt + 1] = {Name = c.Name, Link = c.Link, Date = c.Date, Pages = {}, Manga = manga}
		end
	end
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link)
	local doc = Http.getDocument(url, H())
	for _, img in ipairs(doc:select("ol.ks-pages li.ks-page img")) do
		local src = img:attr("abs:src")
		if src ~= "" then
			dt[#dt + 1] = Http.image(src, url)
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end

return p
