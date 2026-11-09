-- @id otakio.mangadex
-- @name MangaDex
-- @lang all
-- @version 2
-- @nsfw false
-- @baseUrl https://mangadex.org
-- Native Otakio extension using the official MangaDex JSON API.

local MD = Parser:new("MangaDex", "https://mangadex.org", "DIF", "OTAKIO_MANGADEX", 1)
local api = "https://api.mangadex.org"
local cdn = "https://uploads.mangadex.org"
local limit = 24

-- Otakio UI language -> preferred MangaDex chapter languages (first = highest priority)
local PREFERRED = {
	PortugueseBR = {"pt-br", "pt", "en"},
	Spanish = {"es-la", "es", "en"},
	Russian = {"ru", "en"},
	French = {"fr", "en"},
	Italian = {"it", "en"},
	German = {"de", "en"},
	Turkish = {"tr", "en"},
	Polish = {"pl", "en"},
	Vietnamese = {"vi", "en"},
	Romanian = {"ro", "en"},
	Japanese = {"ja", "en"},
	SimplifiedChinese = {"zh", "zh-hk", "en"},
	TraditionalChinese = {"zh-hk", "zh", "en"}
}

local function languages()
	-- the Browse language filter first (Otakio 1.1.2+), then the interface language
	local browse = BrowseLanguageIsos and BrowseLanguageIsos()
	if browse and #browse > 0 then
		return browse
	end
	local lang = Settings.Language
	if lang == "Default" and GetSystemLanguageName then
		lang = GetSystemLanguageName()
	end
	return PREFERRED[lang] or {"en"}
end

MD.Filters = {
	{Name = "Sort By", Type = "radio", Tags = {"Best Match", "Latest Upload", "Most Follows", "Recently Added", "Title Ascending", "Rating"}},
	{Name = "Demographic", Type = "check", Tags = {"Shounen", "Shoujo", "Seinen", "Josei"}},
	{Name = "Publication Status", Type = "check", Tags = {"Ongoing", "Completed", "Hiatus", "Cancelled"}},
	{Name = "Only chapters in my language", Type = "radio", Tags = {"Yes", "No"}}
}

local SORT = {
	["Best Match"] = "order[relevance]=desc",
	["Latest Upload"] = "order[latestUploadedChapter]=desc",
	["Most Follows"] = "order[followedCount]=desc",
	["Recently Added"] = "order[createdAt]=desc",
	["Title Ascending"] = "order[title]=asc",
	["Rating"] = "order[rating]=desc"
}

local function ratings()
	if Settings.NSFW then
		return "contentRating[]=safe&contentRating[]=suggestive&contentRating[]=erotica"
	end
	return "contentRating[]=safe&contentRating[]=suggestive"
end

local function pickTitle(attrs)
	local t = attrs.title or {}
	local langs = languages()
	for _, l in ipairs(langs) do
		if t[l] then
			return t[l]
		end
	end
	if t.en then
		return t.en
	end
	for _, alt in ipairs(attrs.altTitles or {}) do
		for _, l in ipairs(langs) do
			if alt[l] then
				return alt[l]
			end
		end
	end
	for _, v in pairs(t) do
		return v
	end
	return "?"
end

local function listManga(self, page, dt, query)
	local url = api .. "/manga?limit=" .. limit .. "&offset=" .. ((page - 1) * limit) .. "&includes[]=cover_art&" .. ratings() .. "&" .. query
	local data = Http.getJson(url) or {}
	for _, m in ipairs(data.data or {}) do
		local cover = ""
		for _, rel in ipairs(m.relationships or {}) do
			if rel.type == "cover_art" and rel.attributes then
				cover = cdn .. "/covers/" .. m.id .. "/" .. rel.attributes.fileName .. ".256.jpg"
			end
		end
		local manga = CreateManga(pickTitle(m.attributes or {}), m.id, cover, self.ID, "https://mangadex.org/title/" .. m.id, "https://mangadex.org/title/" .. m.id)
		if manga then
			dt[#dt + 1] = manga
		end
	end
	dt.NoPages = (data.total or 0) <= page * limit
end

local function langFilter()
	local out = {}
	for _, l in ipairs(languages()) do
		out[#out + 1] = "availableTranslatedLanguage[]=" .. l
	end
	return table.concat(out, "&")
end

function MD:getPopularManga(page, dt)
	listManga(self, page, dt, "order[followedCount]=desc&" .. langFilter())
end

function MD:getLatestManga(page, dt)
	listManga(self, page, dt, "order[latestUploadedChapter]=desc&" .. langFilter())
end

function MD:searchManga(search, page, dt, tags)
	local q = "title=" .. Http.encode(Engines.decodeSearch(search))
	local useLang = true
	if tags then
		q = q .. "&" .. (SORT[tags["Sort By"] or ""] or SORT["Best Match"])
		for _, d in ipairs(tags["Demographic"] or {}) do
			q = q .. "&publicationDemographic[]=" .. d:lower()
		end
		for _, s in ipairs(tags["Publication Status"] or {}) do
			q = q .. "&status[]=" .. s:lower()
		end
		useLang = tags["Only chapters in my language"] ~= "No"
	end
	if useLang then
		q = q .. "&" .. langFilter()
	end
	listManga(self, page, dt, q)
end

function MD:getChapters(manga, dt)
	local info = Http.getJson(api .. "/manga/" .. manga.Link .. "?includes[]=author&includes[]=artist") or {}
	local attrs = (info.data or {}).attributes or {}
	local desc = attrs.description or {}
	local text = ""
	for _, l in ipairs(languages()) do
		if desc[l] then
			text = desc[l]
			break
		end
	end
	if text == "" then
		text = desc.en or ""
	end
	local authors = {}
	for _, rel in ipairs((info.data or {}).relationships or {}) do
		if rel.type == "author" and rel.attributes then
			authors[#authors + 1] = rel.attributes.name
		end
	end
	local genres = {}
	for _, tag in ipairs(attrs.tags or {}) do
		local name = tag.attributes and tag.attributes.name and tag.attributes.name.en
		if name then
			genres[#genres + 1] = name
		end
	end
	dt.Description = Engines.buildInfo({Author = table.concat(authors, ", "), Status = attrs.status, Genres = genres}, (text:gsub("%[(.-)%]%((.-)%)", "%1")))

	local langs = languages()
	local priority = {}
	local query = {}
	for i, l in ipairs(langs) do
		priority[l] = i
		query[#query + 1] = "translatedLanguage[]=" .. l
	end
	local chapters = {}
	local offset = 0
	while true do
		local url = api .. "/manga/" .. manga.Link .. "/feed?limit=500&offset=" .. offset .. "&order[volume]=asc&order[chapter]=asc&" .. table.concat(query, "&") .. "&" .. ratings() .. "&contentRating[]=pornographic"
		local data = Http.getJson(url) or {}
		local items = data.data or {}
		for _, c in ipairs(items) do
			local a = c.attributes or {}
			if not a.externalUrl and (a.pages or 1) > 0 then
				chapters[#chapters + 1] = {
					id = c.id,
					number = tonumber(a.chapter) or -1,
					chapter = a.chapter,
					volume = a.volume,
					title = a.title,
					lang = a.translatedLanguage,
					prio = priority[a.translatedLanguage] or 99
				}
			end
		end
		offset = offset + #items
		if #items == 0 or offset >= (data.total or 0) then
			break
		end
		coroutine.yield(false)
	end
	-- keep one chapter per number, preferring the user's language
	local best = {}
	local order = {}
	for _, c in ipairs(chapters) do
		local key = c.chapter or c.id
		if not best[key] then
			order[#order + 1] = key
			best[key] = c
		elseif c.prio < best[key].prio then
			best[key] = c
		end
	end
	for _, key in ipairs(order) do
		local c = best[key]
		local name = (c.volume and ("Vol." .. c.volume .. " ") or "") .. "Ch." .. (c.chapter or "?")
		if c.title and c.title ~= "" then
			name = name .. " - " .. c.title
		end
		if #langs > 1 and c.lang ~= langs[1] then
			name = name .. " [" .. c.lang .. "]"
		end
		dt[#dt + 1] = {Name = name, Link = c.id, Pages = {}, Manga = manga}
	end
end

function MD:prepareChapter(chapter, dt)
	local data = Http.getJson(api .. "/at-home/server/" .. chapter.Link) or {}
	local ch = data.chapter
	if not ch or not data.baseUrl then
		return
	end
	-- data-saver images are smaller JPEGs (still sharper than the Vita screen):
	-- faster to download/decode and much lighter on video memory
	local useSaver = ch.dataSaver ~= nil and #ch.dataSaver > 0
	local list = useSaver and ch.dataSaver or ch.data
	for _, file in ipairs(list or {}) do
		dt[#dt + 1] = data.baseUrl .. (useSaver and "/data-saver/" or "/data/") .. ch.hash .. "/" .. file
	end
end

function MD:loadChapterPage(link, dt)
	dt.Link = link
end
