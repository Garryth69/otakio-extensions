-- @id otakio.mhscans
-- @name MHScans
-- @lang es
-- @version 1
-- @nsfw false
-- @baseUrl https://mhscans.com
-- Native Otakio extension: MHScans (its own site: a /library grid, chapters in pages of /comics/<slug>/chapters, plain
-- <img> pages in the reader). Replaces the Madara-based kei.es.mhscans. Adapted from keiyoushi's MHScans (Apache-2.0).

local U = Engines.util
local BASE = "https://mhscans.com"

local p = U.newParser({id = "OTAKIO_MHSCANS", name = "MHScans", baseUrl = BASE, lang = "es", version = 1, engine = "native"}, {})

local function H(extra)
	local h = {Referer = BASE .. "/"}
	for k, v in pairs(extra or {}) do
		h[k] = v
	end
	return h
end

local function library(page, dt, sort, query)
	local q = {}
	if query and query ~= "" then
		q[#q + 1] = {"q", query}
	end
	q[#q + 1] = {"sort", sort}
	q[#q + 1] = {"page", tostring(page)}
	local doc = Http.getDocument(BASE .. "/library?" .. Http.form(q), H())
	local count = 0
	for _, a in ipairs(doc:select("div.lib-grid > a[href^=/comics/]")) do
		-- novels have text chapters, never pages
		local kind = a:selectFirst("div.comic-cover ~ span")
		if not (kind and U.trim(kind:text()) == "Novel") then
			local title = a:selectFirst("p")
			local img = a:selectFirst("img")
			if title and U.addManga(dt, p, title:text(), a:attr("abs:href"), img and img:attr("abs:src") or nil) then
				count = count + 1
			end
		end
	end
	dt.NoPages = count == 0 or doc:selectFirst("nav.lib-pagination a[aria-label=Siguiente]") == nil
end

function p:getPopularManga(page, dt)
	library(page, dt, "views")
end

function p:getLatestManga(page, dt)
	library(page, dt, "updated")
end

function p:searchManga(query, page, dt)
	library(page, dt, "views", Engines.decodeSearch(query))
end

local STATUS = {["en emisión"] = "Ongoing", ["completado"] = "Completed", ["en hiato"] = "On hiatus", ["cancelado"] = "Cancelled"}

function p:getChapters(manga, dt)
	local url = U.absolute(BASE, manga.Link)
	local doc = Http.getDocument(url, H())
	local desc = doc:selectFirst("#comic-description")
	local status = doc:selectFirst(".comic-meta__status")
	local st = status and string.lower(U.trim(status:text())) or ""
	dt.Description = Engines.buildInfo({
		Status = STATUS[st] or (st ~= "" and U.trim(status:text()) or nil),
		Genres = doc:select(".comic-chips li"):eachText()
	}, desc and U.trim(desc:text()) or "")
	local cover = doc:selectFirst(".comic-hero__cover img")
	if cover and cover:attr("abs:src") ~= "" then
		manga.NewImageLink = Http.image(cover:attr("abs:src"), BASE .. "/")
	end
	-- chapters come newest first, a page at a time (paid chapters link to the login page and are left out)
	local list, seen = {}, {}
	for page = 1, 100 do
		coroutine.yield(false)
		local rows = Http.getDocument(url .. "/chapters?page=" .. page, H({Referer = url, ["X-Requested-With"] = "XMLHttpRequest"}))
		local added = 0
		for _, a in ipairs(rows:select("a[href^=/leer/][data-chapter-num]")) do
			local href = a:attr("href")
			if not seen[href] then
				seen[href] = true
				local title = a:selectFirst("[data-cl-title]")
				list[#list + 1] = {Name = U.trim(title and title:text() or a:attr("data-chapter-label")), Link = href}
				added = added + 1
			end
		end
		if added == 0 then
			break
		end
	end
	for i = #list, 1, -1 do
		local c = list[i]
		dt[#dt + 1] = {Name = c.Name, Link = c.Link, Pages = {}, Manga = manga}
	end
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link)
	local doc = Http.getDocument(url, H())
	for _, img in ipairs(doc:select("img.page-img")) do
		local src = img:attr("abs:data-src")
		if src == "" then
			src = img:attr("abs:src")
		end
		if src ~= "" then
			dt[#dt + 1] = Http.image(src, url)
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end

return p
