-- @id otakio.mangotoons
-- @name MangoToons
-- @lang pt-BR
-- @version 1
-- @nsfw false
-- @baseUrl https://mangotoons.com
-- Native Otakio extension: MangoToons (Brazilian manga/manhwa catalog, public JSON API).

local U = Engines.util
local BASE = "https://mangotoons.com"
local API = "https://api.mangotoons.com/api/v1"
local CDN = "https://cdn.mangotoons.com"
local LIMIT = 24

local p = U.newParser({id = "OTAKIO_MANGOTOONS", name = "MangoToons", baseUrl = BASE, lang = "pt-BR", version = 1, engine = "native"}, {})

local function getJson(url)
	local body = Http.get(url, {Referer = BASE .. "/", Origin = BASE, Accept = "application/json"})
	local data = Json.decode(body, 4000)
	return type(data) == "table" and data or {}
end

local function str(v)
	return type(v) == "string" and v or nil
end

local function absolute(url, base)
	if not str(url) then
		return nil
	end
	return string.sub(url, 1, 1) == "/" and base .. url or url
end

local function list(page, dt, extra)
	local data = getJson(API .. "/obras?pagina=" .. page .. "&limite=" .. LIMIT .. extra)
	for _, m in ipairs(type(data.obras) == "table" and data.obras or {}) do
		if m.id and str(m.nome) then
			local cover = absolute(m.imagem, BASE)
			U.addManga(dt, p, m.nome, BASE .. "/obra/" .. tostring(m.id), cover and Http.image(cover, BASE .. "/"))
		end
	end
	dt.NoPages = not (tonumber(data.pagina) and tonumber(data.total_paginas) and tonumber(data.pagina) < tonumber(data.total_paginas))
end

function p:getPopularManga(page, dt)
	list(page, dt, "&ordenar=populares")
end

function p:getLatestManga(page, dt)
	list(page, dt, "&ordenar=recentes")
end

function p:searchManga(query, page, dt)
	list(page, dt, "&busca=" .. Http.encode(Engines.decodeSearch(query)))
end

local function numberText(n)
	local v = tonumber(n)
	if not v then
		return tostring(n)
	end
	if v == math.floor(v) then
		return string.format("%d", v)
	end
	return tostring(v)
end

function p:getChapters(manga, dt)
	local id = string.match(manga.Link, "/obra/(%d+)")
	if not id then
		return
	end
	local m = getJson(API .. "/obras/" .. id)
	local tags = {}
	for _, t in ipairs(type(m.tags) == "table" and m.tags or {}) do
		tags[#tags + 1] = str(t)
	end
	dt.Description = Engines.buildInfo({Status = str(m.status), Genres = tags}, str(m.descricao) or "")
	local chapters = {}
	for _, c in ipairs(type(m.capitulos) == "table" and m.capitulos or {}) do
		if c.numero ~= nil then
			local num = numberText(c.numero)
			chapters[#chapters + 1] = {
				n = tonumber(c.numero) or -1,
				Name = "Capítulo " .. num,
				Link = "/obra/" .. id .. "/capitulo/" .. num,
				Date = str(c.published_at) and string.sub(c.published_at, 1, 10)
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
	local id, num = string.match(chapter.Link, "/obra/(%d+)/capitulo/([^/?#]+)")
	if not id then
		return
	end
	local data = getJson(API .. "/leitor/obras/" .. id .. "/capitulos/" .. num .. "/manifest")
	local pages = type(data.pages) == "table" and data.pages or {}
	table.sort(pages, function(a, b)
		return (tonumber(a.index) or 0) < (tonumber(b.index) or 0)
	end)
	for _, pg in ipairs(pages) do
		local url = absolute(pg.url, CDN)
		if url then
			dt[#dt + 1] = Http.image(url, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
