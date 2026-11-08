-- @id otakio.ninehentai
-- @name 9Hentai
-- @lang en
-- @version 1
-- @nsfw true
-- @baseUrl https://9hentai.so
-- Native Otakio extension: 9Hentai (public JSON API; images on i.9hentai.so).
-- Adapted from keiyoushi's NineHentai (Apache-2.0).

local U = Engines.util
local BASE = "https://9hentai.so"
local IMG = "https://i.9hentai.so/images"

local p = U.newParser({id = "OTAKIO_NINEHENTAI", name = "9Hentai", baseUrl = BASE, lang = "en", version = 1, nsfw = true, engine = "native"}, {})

local function H()
	return {Referer = BASE .. "/", Origin = BASE, Accept = "application/json, text/plain, */*"}
end

local function api(path, body)
	local data = Json.decode(Http.post(BASE .. path, body, H(), "json") or "")
	return type(data) == "table" and data or {}
end

-- sort: 0 newest, 1 popular right now
local function search(text, page, sort, dt)
	local body = '{"search":{"text":' .. Json.encode(text or "") .. ',"page":' .. (page - 1) .. ',"sort":' .. sort ..
		',"pages":{"range":[0,2000]},"tag":{"items":{"included":[],"excluded":[]}}}}'
	local data = api("/api/getBook", body)
	local count = 0
	for _, m in ipairs(type(data.results) == "table" and data.results or {}) do
		if m.id and U.addManga(dt, p, tostring(m.title or m.id), BASE .. "/g/" .. m.id .. "/", Http.image(IMG .. "/" .. m.id .. "/cover.jpg", BASE .. "/")) then
			count = count + 1
		end
	end
	dt.NoPages = count == 0 or (tonumber(data.total_count) or 0) <= page
end

function p:getPopularManga(page, dt)
	search("", page, 1, dt)
end

function p:getLatestManga(page, dt)
	search("", page, 0, dt)
end

function p:searchManga(query, page, dt)
	search(Engines.decodeSearch(query), page, 0, dt)
end

local function joinTags(info, label)
	local out = {}
	for _, field in ipairs(info:select("div.field-name")) do
		if string.find(field:text(), label, 1, true) then
			for _, a in ipairs(field:select("a.tag")) do
				out[#out + 1] = U.trim(a:ownText() ~= "" and a:ownText() or a:text())
			end
		end
	end
	return out
end

function p:getChapters(manga, dt)
	local url = U.absolute(BASE, manga.Link)
	local doc = Http.getDocument(url, {Referer = BASE .. "/"})
	local info = doc:selectFirst("div#bigcontainer")
	if info then
		local artists = joinTags(info, "Artist:")
		local parody = joinTags(info, "Parody:")
		dt.Description = Engines.buildInfo({Author = #artists > 0 and table.concat(artists, ", ") or nil, Genres = joinTags(info, "Tag:"), Status = "Completed"},
			#parody > 0 and ("Parody: " .. table.concat(parody, ", ")) or "")
	end
	dt[#dt + 1] = {Name = "Chapter", Link = U.pathOf(url), Pages = {}, Manga = manga}
end

function p:prepareChapter(chapter, dt)
	local id = tonumber(string.match(chapter.Link or "", "/g/(%d+)"))
	if not id then
		return
	end
	local data = api("/api/getBookByID", '{"id":' .. id .. '}')
	local total = type(data.results) == "table" and tonumber(data.results.total_page) or 0
	for n = 1, total do
		dt[#dt + 1] = Http.image(IMG .. "/" .. id .. "/" .. n .. ".jpg", BASE .. "/")
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
