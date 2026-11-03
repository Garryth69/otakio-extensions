-- @id otakio.mangaflix
-- @name MangaFlix
-- @lang pt-BR
-- @version 1
-- @nsfw false
-- @baseUrl https://mangaflix.net
-- Native Otakio extension: MangaFlix (Brazilian manga/manhwa catalog, public JSON API).

local U = Engines.util
local BASE = "https://mangaflix.net"
local API = "https://api.mangaflix.net/v1"

local p = U.newParser({id = "OTAKIO_MANGAFLIX", name = "MangaFlix", baseUrl = BASE, lang = "pt-BR", version = 1, engine = "native"}, {})

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
		if str(m._id) and str(m.name) then
			local poster = type(m.poster) == "table" and str(m.poster.default_url)
			U.addManga(dt, p, m.name, BASE .. "/br/manga/" .. m._id, poster and Http.image(poster, BASE .. "/"))
		end
	end
	dt.NoPages = true
end

function p:getPopularManga(page, dt)
	for _, section in ipairs(getJson(API .. "/browse").data or {}) do
		if section.key == "most-read" then
			addList(dt, section.items)
		end
	end
	dt.NoPages = true
end

function p:getLatestManga(page, dt)
	addList(dt, getJson(API .. "/latest-releases?selected_language=pt-br").data)
end

function p:searchManga(query, page, dt)
	local data = getJson(API .. "/search/mangas?query=" .. Http.encode(Engines.decodeSearch(query)) .. "&selected_language=pt-br").data
	addList(dt, type(data) == "table" and data.works)
end

function p:getChapters(manga, dt)
	local id = string.match(manga.Link, "/manga/([^/?#]+)")
	if not id then
		return
	end
	local d = getJson(API .. "/mangas/" .. id).data
	if type(d) ~= "table" then
		return
	end
	local genres = {}
	for _, g in ipairs(type(d.genres) == "table" and d.genres or {}) do
		genres[#genres + 1] = str(g.name)
	end
	dt.Description = Engines.buildInfo({Genres = genres}, str(d.description) or "")
	local chapters = {}
	for _, c in ipairs(type(d.chapters) == "table" and d.chapters or {}) do
		if str(c._id) then
			local num = str(c.number) or ""
			chapters[#chapters + 1] = {
				n = tonumber(num) or 0,
				Name = (str(c.name) and c.name ~= "") and c.name or ("Capítulo " .. num),
				Link = "/br/manga/" .. c._id,
				Date = str(c.iso_date) and string.sub(c.iso_date, 1, 10)
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
	local d = getJson(API .. "/chapters/" .. id .. "?selected_language=pt-br").data
	for _, img in ipairs(type(d) == "table" and type(d.images) == "table" and d.images or {}) do
		if str(img.default_url) then
			dt[#dt + 1] = Http.image(img.default_url, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
