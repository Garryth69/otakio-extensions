-- @id otakio.heavenmanga
-- @name HeavenManga
-- @lang es
-- @version 1
-- @nsfw false
-- @baseUrl https://heavenmanga.com
-- Native Otakio extension: HeavenManga (HTML grid; chapters from the series page's JSON table; the reader keeps its
-- page list in a "pUrl" script array). Replaces the NOBORU parser. Adapted from keiyoushi's HeavenManga (Apache-2.0).

local U = Engines.util
local BASE = "https://heavenmanga.com"

local p = U.newParser({id = "OTAKIO_HEAVENMANGA", name = "HeavenManga", baseUrl = BASE, lang = "es", version = 1, engine = "native"}, {})

local function H(extra)
	local h = {Referer = BASE .. "/"}
	for k, v in pairs(extra or {}) do
		h[k] = v
	end
	return h
end

local function grid(url, dt)
	local doc = Http.getDocument(url, H())
	local count = 0
	for _, card in ipairs(doc:select("div.page-item-detail")) do
		local a = card:selectFirst("a")
		local name = card:selectFirst("div.manga-name")
		local img = card:selectFirst("img")
		local cover = img and img:attr("abs:src") or ""
		if a and name and U.addManga(dt, p, name:text(), a:attr("abs:href"), cover ~= "" and cover or nil) then
			count = count + 1
		end
	end
	dt.NoPages = count == 0 or doc:selectFirst("ul.pagination a[rel=next]") == nil
end

function p:getPopularManga(page, dt)
	grid(BASE .. "/top?orderby=views&pages=" .. page, dt)
end

function p:getLatestManga(page, dt)
	-- the front page's update list names chapters ("/manga/<slug>/<chapter>"): one entry per series, novels left out
	local doc = Http.getDocument(page == 1 and BASE or (BASE .. "?pages=" .. page), H())
	local count = 0
	for _, item in ipairs(doc:select("div#loop-content div.list-group-item")) do
		if not string.find(item:text(), "Novela", 1, true) then
			local a = item:selectFirst("a")
			local href = a and a:attr("abs:href") or ""
			local series = string.match(href, "^(.-/manga/[^/]+)")
			if series then
				local t = a:selectFirst(".captitle")
				local cover = string.gsub(series, "/manga/", "/uploads/manga/") .. "/cover/cover_250x350.jpg"
				if U.addManga(dt, p, U.trim(t and t:text() or a:text()), series, cover) then
					count = count + 1
				end
			end
		end
	end
	dt.NoPages = count == 0 or doc:selectFirst("ul.pagination a[rel=next]") == nil
end

function p:searchManga(query, page, dt)
	query = Engines.decodeSearch(query)
	local url = BASE .. "/buscar?query=" .. Http.encode(query) .. (page > 1 and ("&pages=" .. page) or "")
	local doc = Http.getDocument(url, H())
	local count = 0
	for _, el in ipairs(doc:select("div.c-tabs-item__content")) do
		local a = el:selectFirst("h4 a")
		local img = el:selectFirst("img")
		local cover = img and (img:attr("abs:data-src") ~= "" and img:attr("abs:data-src") or img:attr("abs:src")) or ""
		if a and U.addManga(dt, p, a:text(), a:attr("abs:href"), cover ~= "" and cover or nil) then
			count = count + 1
		end
	end
	dt.NoPages = count == 0 or doc:selectFirst("ul.pagination a[rel=next]") == nil
end

local function chapterNumber(slug)
	return tonumber(string.match(tostring(slug), "^(%d+%.?%d*)")) or 0
end

function p:getChapters(manga, dt)
	local url = U.absolute(BASE, manga.Link)
	local doc = Http.getDocument(url, H())
	local genres = {}
	for _, a in ipairs(doc:select("div.genres-content a")) do
		genres[#genres + 1] = U.trim(a:text())
	end
	local desc = {}
	for _, para in ipairs(doc:select("div.description-summary p")) do
		desc[#desc + 1] = U.trim(para:text())
	end
	dt.Description = Engines.buildInfo({Genres = genres}, table.concat(desc, "\n"))
	local img = doc:selectFirst("div.summary_image img")
	local cover = img and (img:attr("abs:data-src") ~= "" and img:attr("abs:data-src") or img:attr("abs:src")) or ""
	if cover ~= "" then
		manga.NewImageLink = cover
	end
	-- the chapter table (a DataTables endpoint on the series page)
	local q = Http.form({
		{"columns[0][data]", "number"}, {"columns[0][orderable]", "true"},
		{"columns[1][data]", "created_at"}, {"columns[1][searchable]", "true"},
		{"order[0][column]", "1"}, {"order[0][dir]", "desc"}, {"start", "0"}, {"length", "10000"}
	})
	local data = Http.getJson(url .. "?" .. q, H({["X-Requested-With"] = "XMLHttpRequest", Accept = "application/json"}))
	local list = {}
	for _, c in ipairs(type(data) == "table" and type(data.data) == "table" and data.data or {}) do
		if c.id and c.slug then
			list[#list + 1] = c
		end
	end
	-- oldest first, as Otakio stores chapters
	table.sort(list, function(a, b)
		return chapterNumber(a.slug) < chapterNumber(b.slug)
	end)
	for _, c in ipairs(list) do
		local date = type(c.created_at) == "string" and string.sub(c.created_at, 1, 10) or nil
		dt[#dt + 1] = {Name = "Capítulo " .. tostring(c.slug), Link = "/manga/ver/" .. tostring(c.id), Date = date, Pages = {}, Manga = manga}
	end
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link)
	local html = Http.get(url, H()) or ""
	local raw = string.match(html, "pUrl%s*=%s*(%b[])")
	if not raw then
		return
	end
	raw = string.gsub(raw, ",%s*([%]}])", "%1")
	local ok, pages = pcall(Json.decode, raw)
	for _, pg in ipairs(ok and type(pages) == "table" and pages or {}) do
		local src = type(pg) == "table" and pg.imgURL
		if type(src) == "string" and src ~= "" then
			dt[#dt + 1] = Http.image(src, url)
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
