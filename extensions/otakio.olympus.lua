-- @id otakio.olympus
-- @name Olympus Biblioteca
-- @lang es
-- @version 1
-- @nsfw false
-- @baseUrl https://olympusbiblioteca.com
-- Native Otakio extension: Olympus Scanlation / Biblioteca (Spanish, JSON API).

local U = Engines.util
local BASE = "https://olympusbiblioteca.com"

local p = U.newParser({id = "OTAKIO_OLYMPUS", name = "Olympus Biblioteca", baseUrl = BASE, lang = "es", version = 1, engine = "native"}, {})

local function api(path)
	local data = Http.getJson(BASE .. path, U.headers(p, {Accept = "application/json"}))
	return type(data) == "table" and data or {}
end

local function addSeries(dt, list)
	for _, m in ipairs(list or {}) do
		if m.type == nil or m.type == "comic" then
			U.addManga(dt, p, m.name or "", "/series/comic-" .. tostring(m.slug), m.cover ~= Json.null and m.cover or nil)
		end
	end
end

local function paged(dt, data)
	addSeries(dt, data.data)
	dt.NoPages = not (data.current_page and data.last_page and data.current_page < data.last_page)
end

function p:getPopularManga(page, dt)
	paged(dt, api("/api/rankings?page=" .. page .. "&period=total_ranking"))
end

function p:getLatestManga(page, dt)
	paged(dt, api("/api/new-chapters?page=" .. page))
end

local seriesCache
function p:searchManga(query, page, dt)
	seriesCache = seriesCache or (api("/api/series/list").data or {})
	local q = string.lower(Engines.decodeSearch(query))
	local found = {}
	for _, m in ipairs(seriesCache) do
		if string.find(string.lower(m.name or ""), q, 1, true) then
			found[#found + 1] = m
		end
	end
	local first = (page - 1) * 20
	addSeries(dt, {unpack(found, first + 1, math.min(#found, first + 20))})
	dt.NoPages = first + 20 >= #found
end

function p:getChapters(manga, dt)
	local slug = string.match(manga.Link, "comic%-(.+)$")
	if not slug then
		return
	end
	local detail = api("/api/series/" .. slug .. "?type=comic").data or {}
	local genres = {}
	for _, g in ipairs(detail.genres ~= Json.null and detail.genres or {}) do
		genres[#genres + 1] = g.name
	end
	local status = type(detail.status) == "table" and detail.status.name or nil
	dt.Description = Engines.buildInfo({Status = status, Genres = genres}, detail.summary ~= Json.null and detail.summary or "")
	if detail.cover and detail.cover ~= Json.null then
		manga.NewImageLink = detail.cover
	end
	local list, page, total = {}, 1, 1
	repeat
		local data = api("/api/series/" .. slug .. "/chapters?page=" .. page .. "&direction=desc&type=comic")
		for _, c in ipairs(data.data or {}) do
			list[#list + 1] = c
		end
		total = data.meta and tonumber(data.meta.total) or #list
		page = page + 1
	until #(data.data or {}) == 0 or #list >= total or page > 60
	for i = #list, 1, -1 do
		local c = list[i]
		dt[#dt + 1] = {
			Name = "Capítulo " .. tostring(c.name),
			Link = "/capitulo/" .. tostring(c.id) .. "/comic-" .. slug,
			Date = c.published_at ~= Json.null and c.published_at and string.sub(c.published_at, 1, 10) or nil,
			Pages = {},
			Manga = manga
		}
	end
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link)
	local doc = Http.getDocument(url, U.headers(self))
	for _, img in ipairs(doc:select("main.strip div.panel > img, section img.object-contain")) do
		local src = img:attr("abs:src")
		if src ~= "" then
			dt[#dt + 1] = Http.image(src, BASE .. "/")
		end
	end
	if #dt == 0 then
		-- reader rendered client side: page list is in the Nuxt payload
		local id = string.match(chapter.Link, "/capitulo/(%d+)/comic%-(.+)$")
		local slug = select(2, string.match(chapter.Link, "/capitulo/(%d+)/comic%-(.+)$"))
		local data = id and api("/api/capitulo/" .. slug .. "/" .. id .. "?type=comic") or {}
		local pages = data.chapter and data.chapter.pages or {}
		for _, src in ipairs(pages) do
			dt[#dt + 1] = Http.image(src, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
