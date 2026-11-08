-- @id otakio.desu
-- @name Desu
-- @lang ru
-- @version 1
-- @nsfw false
-- @baseUrl https://desu.uno
-- Native Otakio extension: Desu (Russian manga catalog, public JSON API). Adapted from keiyoushi's Desu (Apache-2.0).
-- The API asks clients to identify themselves: net.lua sends the Otakio user agent to desu.uno.

local U = Engines.util
local BASE = "https://desu.uno"
local API = BASE .. "/api/manga/"

local p = U.newParser({id = "OTAKIO_DESU", name = "Desu", baseUrl = BASE, lang = "ru", version = 1, engine = "native"}, {})

local function getJson(url)
	local data = Http.getJson(url, {Referer = BASE .. "/", Accept = "application/json"})
	return type(data) == "table" and data or {}
end

local function str(v)
	return type(v) == "string" and v ~= "" and v or nil
end

local function list(dt, order, page, query)
	local url = API .. "/catalog/?limit=20&page=" .. page .. "&order_by=" .. order
	if query and query ~= "" then
		url = url .. "&search=" .. Http.encode(query)
	end
	local data = getJson(url)
	local count = 0
	for _, m in ipairs(type(data.mangas) == "table" and data.mangas or {}) do
		local title = str(m.russian) or str(m.name)
		if m.id and title then
			local cover = type(m.cover) == "table" and (str(m.cover.preview) or str(m.cover.x120)) or nil
			if U.addManga(dt, p, title, BASE .. "/manga/" .. tostring(m.id), cover) then
				count = count + 1
			end
		end
	end
	local nav = type(data.pagination) == "table" and data.pagination or {}
	local current, last = tonumber(nav.current_page), tonumber(nav.last_page)
	dt.NoPages = count == 0 or not (current and last and last > current)
end

function p:getPopularManga(page, dt)
	list(dt, "popular", page)
end

function p:getLatestManga(page, dt)
	list(dt, "updated", page)
end

function p:searchManga(query, page, dt)
	list(dt, "popular", page, Engines.decodeSearch(query))
end

local function idOf(manga)
	return string.match(manga.Link or "", "(%d+)/?$")
end

function p:getChapters(manga, dt)
	local id = idOf(manga)
	if not id then
		return
	end
	local m = getJson(API .. id .. "/").manga
	if type(m) == "table" then
		local genres, authors = {}, {}
		for _, g in ipairs(type(m.genres) == "table" and m.genres or {}) do
			genres[#genres + 1] = str(g.russian) or str(g.name)
		end
		for _, a in ipairs(type(m.authors) == "table" and m.authors or {}) do
			authors[#authors + 1] = str(a.name)
		end
		dt.Description = Engines.buildInfo({Genres = genres, Author = table.concat(authors, ", "), Status = str(m.trans_status) or str(m.status)}, str(m.description) or "")
	end
	coroutine.yield(false)
	local chapters = getJson(API .. id .. "/chapters").chapters
	chapters = type(chapters) == "table" and chapters or {}
	-- the API lists the newest chapter first; Otakio stores them oldest first
	for i = #chapters, 1, -1 do
		local c = chapters[i]
		if c.id and c.is_readable ~= false then
			local name = tostring(c.volume or "?") .. ". Глава " .. tostring(c.number or "?")
			if str(c.title) then
				name = name .. " " .. c.title
			end
			local ts = tonumber(c.publish_date)
			dt[#dt + 1] = {
				Name = name,
				Link = "/" .. id .. "/chapters/" .. tostring(c.id),
				Date = ts and Clock and Clock.date and Clock.date("%Y-%m-%d", ts) or nil,
				Pages = {},
				Manga = manga
			}
		end
	end
end

function p:prepareChapter(chapter, dt)
	local data = getJson(API .. string.gsub(chapter.Link, "^/", "")).chapter
	local pages = type(data) == "table" and type(data.pages) == "table" and data.pages or {}
	for _, pg in ipairs(pages) do
		if str(pg.url) then
			dt[#dt + 1] = Http.image(pg.url, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
