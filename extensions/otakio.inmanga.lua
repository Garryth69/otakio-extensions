-- @id otakio.inmanga
-- @name InManga
-- @lang es
-- @version 1
-- @nsfw false
-- @baseUrl https://inmanga.com
-- Native Otakio extension: InManga (ASP.NET endpoints: a POST search returning HTML cards, a JSON chapter list,
-- a page index whose ids name the files on the image CDN). Replaces the NOBORU parser.

local U = Engines.util
local BASE = "https://inmanga.com"
local CDN = "https://cdn1.intomanga.com"

local p = U.newParser({id = "OTAKIO_INMANGA", name = "InManga", baseUrl = BASE, lang = "es", version = 1, engine = "native"}, {})

local SORT = {["Vistos"] = "1", ["Relevancia"] = "2", ["Recién actualizado"] = "3", ["Recién agregado"] = "4", ["Nombre"] = "5", ["Más capítulos"] = "6", ["Menos capítulos"] = "7"}
local STATUS = {["Todos"] = "0", ["En emisión"] = "1", ["Finalizado"] = "2"}

p.Filters = {
	{Name = "Ordenar por", Type = "radio", Tags = {"Vistos", "Relevancia", "Recién actualizado", "Recién agregado", "Nombre", "Más capítulos", "Menos capítulos"}},
	{Name = "Estado", Type = "radio", Tags = {"Todos", "En emisión", "Finalizado"}}
}

local function H(extra)
	local h = {Referer = BASE .. "/", ["X-Requested-With"] = "XMLHttpRequest"}
	for k, v in pairs(extra or {}) do
		h[k] = v
	end
	return h
end

local PAGE_SIZE = 10

local function consult(page, dt, query, sortBy, status)
	local body = {
		{"filter[generes][]", "-1"},
		{"filter[queryString]", query or ""},
		{"filter[skip]", tostring((page - 1) * PAGE_SIZE)},
		{"filter[take]", tostring(PAGE_SIZE)},
		{"filter[sortby]", sortBy or "1"},
		{"filter[broadcastStatus]", status or "0"},
		{"filter[onlyFavorites]", "false"},
		{"d", ""}
	}
	local doc = Http.postDocument(BASE .. "/manga/getMangasConsultResult", body, H(), BASE .. "/")
	local count = 0
	for _, a in ipairs(doc:select("a.manga-result")) do
		local h4 = a:selectFirst("h4")
		local img = a:selectFirst("img")
		local cover = img and img:attr("abs:data-src") or ""
		if h4 and U.addManga(dt, p, U.trim(h4:text()), a:attr("abs:href"), cover ~= "" and cover or nil) then
			count = count + 1
		end
	end
	dt.NoPages = count < PAGE_SIZE
end

function p:getPopularManga(page, dt)
	consult(page, dt, "", "1")
end

function p:getLatestManga(page, dt)
	consult(page, dt, "", "3")
end

function p:searchManga(query, page, dt, tags)
	tags = tags or {}
	consult(page, dt, Engines.decodeSearch(query), SORT[tags["Ordenar por"] or ""] or "2", STATUS[tags["Estado"] or ""] or "0")
end

-- links look like /ver/manga/<Name>/<manga id>
local function mangaId(link)
	return string.match(tostring(link or ""), "/([%x%-]+)/?$")
end

function p:getChapters(manga, dt)
	local id = mangaId(manga.Link)
	if not id then
		return
	end
	local doc = Http.getDocument(U.absolute(BASE, manga.Link), {Referer = BASE .. "/"})
	local body = doc:selectFirst("div.panel-body")
	dt.Description = Engines.buildInfo({}, body and U.trim(body:text()) or "")
	-- {"data": "<the JSON result, as a string>"}
	local outer = Http.getJson(BASE .. "/chapter/getall?mangaIdentification=" .. id, H())
	local inner = type(outer) == "table" and type(outer.data) == "string" and Json.decode(outer.data, 20000) or nil
	local list = {}
	for _, c in ipairs(type(inner) == "table" and type(inner.result) == "table" and inner.result or {}) do
		if type(c.Identification) == "string" then
			list[#list + 1] = c
		end
	end
	table.sort(list, function(a, b)
		return (tonumber(a.Number) or 0) < (tonumber(b.Number) or 0)
	end)
	local slug = string.match(manga.Link, "/ver/manga/([^/]+)/") or "manga"
	for _, c in ipairs(list) do
		local num = tostring(c.FriendlyChapterNumberUrl or c.FriendlyChapterNumber or c.Number)
		dt[#dt + 1] = {
			Name = "Capítulo " .. tostring(c.FriendlyChapterNumber or num),
			Link = "/ver/manga/" .. slug .. "/" .. num .. "/" .. c.Identification,
			Date = type(c.RegistrationDate) == "string" and string.sub(c.RegistrationDate, 1, 10) or nil,
			Pages = {},
			Manga = manga
		}
	end
end

function p:prepareChapter(chapter, dt)
	local chapterId = mangaId(chapter.Link)
	local id = mangaId(chapter.Manga and chapter.Manga.Link)
	if not chapterId or not id then
		return
	end
	local doc = Http.getDocument(BASE .. "/chapter/chapterIndexControls?identification=" .. chapterId, H())
	local referer = U.absolute(BASE, chapter.Link)
	-- the page selector lists each page's file id in reading order
	for _, o in ipairs(doc:select("select#PageList option")) do
		local file = o:attr("value")
		if file ~= "" then
			dt[#dt + 1] = Http.image(CDN .. "/i/m/" .. string.lower(id) .. "/c/" .. string.lower(chapterId) .. "/o/" .. file .. ".jpg", referer)
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
