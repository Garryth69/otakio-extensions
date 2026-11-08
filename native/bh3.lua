-- @id otakio.bh3
-- @name 崩坏3 (Honkai Impact 3rd)
-- @lang zh
-- @version 1
-- @nsfw false
-- @baseUrl https://comic.bh3.com
-- Native Otakio extension: the official Honkai Impact 3rd comics site (miHoYo), free to read.
-- Adapted from keiyoushi's BH3 (Apache-2.0).

local U = Engines.util
local BASE = "https://comic.bh3.com"

local p = U.newParser({id = "OTAKIO_BH3", name = "崩坏3 (Honkai Impact 3rd)", baseUrl = BASE, lang = "zh", version = 1, engine = "native"}, {})

local function H()
	return {Referer = BASE .. "/"}
end

local function books(dt, query)
	local doc = Http.getDocument(BASE .. "/book", H())
	for _, box in ipairs(doc:select("div.container")) do
		local id = box:attr("id")
		local titleEl = box:selectFirst("div.container-title")
		local title = titleEl and U.trim(titleEl:ownText() ~= "" and titleEl:ownText() or titleEl:text()) or ""
		if id ~= "" and title ~= "" and (not query or query == "" or string.find(title, query, 1, true)) then
			local img = box:selectFirst("img")
			U.addManga(dt, p, title, BASE .. "/book/" .. id, img and img:attr("abs:src") or nil)
		end
	end
	dt.NoPages = true
end

function p:getPopularManga(page, dt)
	books(dt)
end

p.getLatestManga = p.getPopularManga

function p:searchManga(query, page, dt)
	books(dt, Engines.decodeSearch(query))
end

function p:getChapters(manga, dt)
	local id = string.match(manga.Link or "", "/book/(%d+)")
	if not id then
		return
	end
	local doc = Http.getDocument(BASE .. "/book/" .. id, H())
	local desc = doc:selectFirst("div.detail_info1")
	dt.Description = desc and U.trim(desc:text()) or ""
	local cover = doc:selectFirst("img.cover")
	if cover and cover:attr("src") ~= "" then
		manga.NewImageLink = Http.image(cover:attr("abs:src"), BASE .. "/")
	end
	coroutine.yield(false)
	local list = Http.getJson(BASE .. "/book/" .. id .. "/get_chapter", H())
	list = type(list) == "table" and list or {}
	-- newest first in the API; Otakio stores oldest first
	for i = #list, 1, -1 do
		local c = list[i]
		if c.chapterid then
			dt[#dt + 1] = {
				Name = tostring(c.title or c.chapterid),
				Link = "/book/" .. id .. "/" .. tostring(c.chapterid),
				Date = type(c.timestamp) == "string" and string.sub(c.timestamp, 1, 10) or nil,
				Pages = {},
				Manga = manga
			}
		end
	end
end

function p:prepareChapter(chapter, dt)
	local url = BASE .. chapter.Link
	local doc = Http.getDocument(url, H())
	for _, img in ipairs(doc:select("img.comic_img")) do
		local src = img:attr("data-original")
		if src == "" then
			src = img:attr("src")
		end
		if src ~= "" then
			dt[#dt + 1] = Http.image(src, url)
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
