-- @id otakio.comicskingdom
-- @name Comics Kingdom
-- @lang all
-- @version 1
-- @nsfw false
-- @baseUrl https://wp.comicskingdom.com
-- Native Otakio extension: Comics Kingdom (classic newspaper comic strips: Popeye, Hagar, The Phantom...).
-- Each "chapter" groups 100 strips in publication order.

local U = Engines.util
local BASE = "https://wp.comicskingdom.com"
local API = BASE .. "/wp-json/wp/v2"
local PER_MANGA = 20
local PER_CHAPTER = 100

local function getJson(url)
	local body = Http.get(url, {Accept = "application/json"})
	local data = Json.decode(body, 4000)
	return type(data) == "table" and data or {}
end

local function str(v)
	return type(v) == "string" and v or nil
end

local function plain(html)
	html = string.gsub(html or "", "<[^>]+>", "")
	html = string.gsub(html, "&#8217;", "'")
	html = string.gsub(html, "&#8211;", "-")
	html = string.gsub(html, "&amp;", "&")
	html = string.gsub(html, "&quot;", '"')
	return U.trim(html)
end

local function build(lang, name, id, ckLang)
	local p = U.newParser({id = id, name = name, baseUrl = BASE, lang = lang, version = 1, engine = "native"}, {})

	local function list(page, dt, extra)
		local url = API .. "/ck_feature?per_page=" .. PER_MANGA .. "&page=" .. page .. "&ck_language=" .. ckLang
			.. "&_fields=id,link,title,content,meta,yoast_head" .. extra
		local data = getJson(url)
		local n = 0
		for _, m in ipairs(data) do
			local slug = str(m.link) and string.match(m.link, "/([^/]+)/?$")
			if m.id and slug and type(m.title) == "table" then
				n = n + 1
				local cover = str(m.yoast_head) and string.match(m.yoast_head, 'thumbnailUrl":"(%S-)","dateP')
				U.addManga(dt, p, plain(m.title.rendered), BASE .. "/" .. slug .. "?id=" .. m.id, cover and (string.gsub(cover, "\\/", "/")))
			end
		end
		dt.NoPages = n < PER_MANGA
	end

	function p:getPopularManga(page, dt)
		list(page, dt, "&orderBy=relevance")
	end

	function p:getLatestManga(page, dt)
		list(page, dt, "&orderBy=modified")
	end

	function p:searchManga(query, page, dt)
		list(page, dt, "&search=" .. Http.encode(Engines.decodeSearch(query)))
	end

	function p:getChapters(manga, dt)
		local slug, mid = string.match(manga.Link, "/([^/?]+)%?id=(%d+)")
		if not slug then
			return
		end
		local m = getJson(API .. "/ck_feature/" .. mid .. "?_fields=id,link,title,content,meta")
		if type(m.content) == "table" then
			local byline = type(m.meta) == "table" and str(m.meta.ck_byline_on_app) or nil
			dt.Description = Engines.buildInfo({Author = byline and U.trim((string.gsub(byline, "^%s*By", "")))}, plain(m.content.rendered))
		end
		-- the strip count comes from the public comic page (schema.org "totalItems")
		local page = str(m.link) and Http.get(m.link, U.headers(self)) or ""
		local total = 0
		for n in string.gmatch(page, '"totalItems":(%d+)') do
			if tonumber(n) > 0 and total == 0 then
				total = tonumber(n)
			end
		end
		local chapters = math.ceil(total / PER_CHAPTER)
		-- oldest strips first, as Otakio stores chapters
		for i = 1, chapters do
			local last = math.min(i * PER_CHAPTER, total)
			dt[#dt + 1] = {
				Name = string.format("%d-%d", (i - 1) * PER_CHAPTER + 1, last),
				Link = "/ck_comic?orderBy=date&order=asc&ck_feature=" .. slug .. "&page=" .. i,
				Pages = {},
				Manga = manga
			}
		end
	end

	function p:prepareChapter(chapter, dt)
		local data = getJson(API .. chapter.Link .. "&per_page=" .. PER_CHAPTER .. "&_fields=id,date,assets,link")
		for _, c in ipairs(data) do
			local url = type(c.assets) == "table" and type(c.assets.single) == "table" and str(c.assets.single.url)
			if url then
				dt[#dt + 1] = url
			end
		end
	end

	function p:loadChapterPage(link, dt)
		dt.Link = link
	end
	return p
end

build("es", "Comics Kingdom (ES)", "OTAKIO_COMICSKINGDOM_ES", "spanish")
build("en", "Comics Kingdom", "OTAKIO_COMICSKINGDOM_EN", "english")
