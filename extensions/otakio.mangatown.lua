-- @id otakio.mangatown
-- @name MangaTown
-- @lang en
-- @version 1
-- @nsfw false
-- @baseUrl https://www.mangatown.com
-- Native Otakio extension: MangaTown (plain HTML, one page per request).
-- Adapted from keiyoushi's Mangatown (Apache-2.0).

local U = Engines.util
local BASE = "https://www.mangatown.com"

local p = U.newParser({id = "OTAKIO_MANGATOWN", name = "MangaTown", baseUrl = BASE, lang = "en", version = 1, engine = "native"}, {})

local function H()
	return {Referer = BASE .. "/"}
end

local function list(url, dt)
	local doc = Http.getDocument(url, H())
	local count = 0
	for _, li in ipairs(doc:select("ul.manga_pic_list li")) do
		local a = li:selectFirst("a.manga_cover")
		local img = li:selectFirst("img")
		if a and a:attr("href") ~= "" then
			local title = a:attr("title")
			if title == "" and img then
				title = img:attr("alt")
			end
			if U.addManga(dt, p, title, a:attr("abs:href"), img and img:attr("abs:src") or nil) then
				count = count + 1
			end
		end
	end
	local hasNext = false
	for _, a in ipairs(doc:select("div.next-page a.next")) do
		if not string.find(a:attr("href"), "^javascript") then
			hasNext = true
		end
	end
	dt.NoPages = count == 0 or not hasNext
end

function p:getPopularManga(page, dt)
	list(BASE .. "/directory/0-0-0-0-0-0/" .. page .. ".htm", dt)
end

function p:getLatestManga(page, dt)
	list(BASE .. "/latest/" .. page .. ".htm", dt)
end

function p:searchManga(query, page, dt)
	list(BASE .. "/search?name=" .. Http.encode(Engines.decodeSearch(query)) .. "&page=" .. page, dt)
end

function p:getChapters(manga, dt)
	local doc = Http.getDocument(U.absolute(BASE, manga.Link), H())
	local info = doc:selectFirst("div.article_content")
	local fields = {}
	for _, li in ipairs(info and info:select("div.detail_content li") or {}) do
		local b = li:selectFirst("b")
		if b then
			local key = string.lower(U.trim(b:text()))
			local vals = {}
			for _, a in ipairs(li:select("a")) do
				vals[#vals + 1] = U.trim(a:text())
			end
			if #vals == 0 then
				vals[1] = U.trim(string.gsub(li:text(), "^[^:]*:", ""))
			end
			fields[key] = vals
		end
	end
	local function first(k)
		for key, v in pairs(fields) do
			if string.find(key, k, 1, true) then
				return table.concat(v, ", ")
			end
		end
	end
	local show = doc:selectFirst("span#show")
	local desc = show and string.gsub(U.trim(show:text()), "%s*HIDE$", "") or ""
	dt.Description = Engines.buildInfo({Author = first("author"), Genres = {first("genre")}, Status = first("status")}, desc)
	local cover = doc:selectFirst("div.detail_info img")
	if cover and cover:attr("src") ~= "" then
		manga.NewImageLink = cover:attr("abs:src")
	end
	local items = doc:select("ul.chapter_list li")
	-- the list is newest first; Otakio stores chapters oldest first
	for i = items:size(), 1, -1 do
		local li = items[i]
		local a = li:selectFirst("a")
		if a and a:attr("href") ~= "" then
			local extra = {}
			for _, s in ipairs(li:select("span")) do
				local cls = s:attr("class")
				if cls ~= "time" and cls ~= "new" then
					extra[#extra + 1] = U.trim(s:text())
				end
			end
			local name = U.trim(a:text())
			if #extra > 0 and extra[1] ~= "" then
				name = name .. " - " .. table.concat(extra, " ")
			end
			local time = li:selectFirst("span.time")
			dt[#dt + 1] = {Name = name, Link = U.pathOf(a:attr("abs:href")), Date = time and U.trim(time:text()) or nil, Pages = {}, Manga = manga}
		end
	end
end

local function viewerImage(doc)
	local img = doc:selectFirst("div#viewer img")
	if img then
		local src = img:attr("abs:src")
		if src ~= "" then
			return Http.image(src, BASE .. "/")
		end
	end
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link)
	local doc = Http.getDocument(url, H())
	local seen = {}
	for _, o in ipairs(doc:select("div.page_select select option")) do
		local v = o:attr("abs:value")
		if v ~= "" and not seen[v] and not string.find(string.lower(o:text()), "featured", 1, true) then
			seen[v] = true
			dt[#dt + 1] = v
		end
	end
	if #dt == 0 then
		-- webtoon chapters show every image at once
		for _, img in ipairs(doc:select("div#viewer img")) do
			local src = img:attr("abs:src")
			if src ~= "" then
				dt[#dt + 1] = Http.image(src, BASE .. "/")
			end
		end
	end
end

function p:loadChapterPage(link, dt)
	if type(link) == "string" and string.find(link, "mangatown%.com") then
		dt.Link = viewerImage(Http.getDocument(link, H()))
	else
		dt.Link = link
	end
end
