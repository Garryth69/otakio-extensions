-- @id otakio.toonbr
-- @name ToonBR
-- @lang pt-BR
-- @version 1
-- @nsfw false
-- @baseUrl https://beta.toonbr.com
-- Native Otakio extension: ToonBR (Brazilian manhwa/manga catalog, public JSON API).

local U = Engines.util
local BASE = "https://beta.toonbr.com"
local API = "https://api.toonbr.com/api"
local CDN = "https://cdn2.toonbr.com"
local LIMIT = 60

local p = U.newParser({id = "OTAKIO_TOONBR", name = "ToonBR", baseUrl = BASE, lang = "pt-BR", version = 1, engine = "native"}, {})

local function getJson(url)
	local body = Http.get(url, {Referer = BASE .. "/", Origin = BASE, Accept = "application/json"})
	local data = Json.decode(body, 4000)
	return type(data) == "table" and data or {}
end

local function str(v)
	return type(v) == "string" and v or nil
end

local function addList(dt, list)
	for _, m in ipairs(type(list) == "table" and list or {}) do
		if str(m.slug) and str(m.title) then
			U.addManga(dt, p, m.title, BASE .. "/manga/" .. m.slug, str(m.coverImage) and Http.image(CDN .. m.coverImage, BASE .. "/"))
		end
	end
end

function p:getPopularManga(page, dt)
	addList(dt, getJson(API .. "/manga/popular?limit=" .. LIMIT))
	dt.NoPages = true
end

function p:getLatestManga(page, dt)
	addList(dt, getJson(API .. "/manga/latest?limit=" .. LIMIT))
	dt.NoPages = true
end

function p:searchManga(query, page, dt)
	local data = getJson(API .. "/manga?page=" .. page .. "&limit=" .. LIMIT .. "&search=" .. Http.encode(Engines.decodeSearch(query)))
	local list = type(data.data) == "table" and data.data or {}
	addList(dt, list)
	dt.NoPages = #list < LIMIT
end

local function numberText(v)
	if type(v) ~= "number" then
		return nil
	end
	if v == math.floor(v) then
		return string.format("%d", v)
	end
	return tostring(v)
end

function p:getChapters(manga, dt)
	local slug = string.match(manga.Link, "/manga/([^/?#]+)")
	if not slug then
		return
	end
	local m = getJson(API .. "/manga/" .. slug)
	local status = ({ONGOING = "Em andamento", COMPLETED = "Completo"})[m.status or ""]
	dt.Description = Engines.buildInfo({Status = status}, str(m.description) or "")
	local chapters = {}
	for _, c in ipairs(type(m.chapters) == "table" and m.chapters or {}) do
		if str(c.id) then
			local num = numberText(c.chapterNumber)
			chapters[#chapters + 1] = {
				n = type(c.chapterNumber) == "number" and c.chapterNumber or 0,
				Name = num and ("Capítulo " .. num) or (str(c.title) or "?"),
				Link = "/read/" .. c.id,
				Date = str(c.publishedAt) and string.sub(c.publishedAt, 1, 10)
			}
		end
	end
	-- Otakio stores oldest first
	table.sort(chapters, function(a, b)
		return a.n < b.n
	end)
	for _, c in ipairs(chapters) do
		dt[#dt + 1] = {Name = c.Name, Link = c.Link, Date = c.Date, Pages = {}, Manga = manga}
	end
end

function p:prepareChapter(chapter, dt)
	local id = string.match(chapter.Link, "([^/]+)$")
	local c = getJson(API .. "/chapter/" .. id)
	for _, pg in ipairs(type(c.pages) == "table" and c.pages or {}) do
		if str(pg.imageUrl) then
			dt[#dt + 1] = Http.image(CDN .. pg.imageUrl, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
