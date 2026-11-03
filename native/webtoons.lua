-- @id otakio.webtoons
-- @name Webtoons
-- @lang all
-- @version 2
-- @nsfw false
-- @baseUrl https://www.webtoons.com
-- Native Otakio extension: official WEBTOON site (English, Spanish, French and German catalogs).

local U = Engines.util
local BASE = "https://www.webtoons.com"
local MOBILE = "https://m.webtoons.com"
local DAYS = {"sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"}
local RANKINGS = {"trending", "popular", "originals", "canvas"}

local function build(lang, name, id)
	local p = U.newParser({id = id, name = name, baseUrl = BASE, lang = lang, version = 1, engine = "native"}, {})
	local cookie = "ageGatePass=true; locale=" .. lang .. "; needGDPR=false"

	local function get(url, referer)
		local body = Http.request({url = url, headers = {Referer = referer or (BASE .. "/")}, cookie = cookie})
		coroutine.yield(false)
		return body
	end

	local function list(url, dt)
		local doc = Html.parse(get(url), url)
		for _, a in ipairs(doc:select(".webtoon_list li a")) do
			local title = a:selectFirst(".title")
			local img = a:selectFirst("img")
			U.addManga(dt, p, title and title:text() or "", a:attr("abs:href"), img and img:attr("abs:src"))
		end
		return doc
	end

	function p:getPopularManga(page, dt)
		local ranking = RANKINGS[page]
		if not ranking then
			dt.NoPages = true
			return
		end
		list(BASE .. "/" .. lang .. "/ranking/" .. ranking, dt)
		dt.NoPages = page >= #RANKINGS
	end

	function p:getLatestManga(page, dt)
		local now = U.date("*t")
		local day = DAYS[now and now.wday or 2]
		list(BASE .. "/" .. lang .. "/originals/" .. day .. "?sortOrder=UPDATE", dt)
		dt.NoPages = true
	end

	function p:searchManga(query, page, dt)
		local url = BASE .. "/" .. lang .. "/search?keyword=" .. Http.encode(Engines.decodeSearch(query)) .. "&page=" .. page
		local doc = list(url, dt)
		dt.NoPages = doc:selectFirst("a.pagination[aria-current=true] + a") == nil
	end

	function p:getChapters(manga, dt)
		local url = U.absolute(BASE, manga.Link)
		local doc = Html.parse(get(url), url)
		local info = doc:selectFirst(".detail_header .info")
		local aside = doc:selectFirst("#_asideDetail")
		local author = info and info:selectFirst(".author_area, .author")
		dt.Description = Engines.buildInfo({
			Author = author and U.trim(author:ownText()) or nil,
			Genres = info and info:select(".genre"):eachText() or nil,
			Status = aside and U.trim(aside:select("p.day_info"):text()) or nil
		}, aside and aside:select("p.summary"):text() or "")
		local og = doc:selectFirst("head meta[property=og:image]")
		if og and og:attr("content") ~= "" then
			manga.NewImageLink = Http.image(og:attr("content"), BASE .. "/")
		end
		local titleNo = string.match(manga.Link, "title_no=(%d+)") or string.match(manga.Link, "titleNo=(%d+)")
		if not titleNo then
			return
		end
		local kind = string.find(manga.Link, "/canvas/", 1, true) and "canvas" or "webtoon"
		local api = MOBILE .. "/api/v1/" .. kind .. "/" .. titleNo .. "/episodes?pageSize=99999"
		if kind == "canvas" then
			api = api .. "&readingLanguageCode=" .. lang
		end
		local data = Json.decode(get(api, MOBILE .. "/"), 2000) or {}
		local episodes = data.result and data.result.episodeList or {}
		-- the API already returns oldest first, like Otakio stores chapters
		for _, ep in ipairs(episodes) do
			dt[#dt + 1] = {
				Name = Html.unescape(ep.episodeTitle or ""),
				Link = U.pathOf(ep.viewerLink or ""),
				Date = ep.exposureDateMillis and U.date("%Y-%m-%d", math.floor(ep.exposureDateMillis / 1000)) or nil,
				Pages = {},
				Manga = manga
			}
		end
	end

	function p:prepareChapter(chapter, dt)
		local url = U.absolute(BASE, chapter.Link)
		local doc = Html.parse(get(url), url)
		for _, img in ipairs(doc:select("div#_imageList > img")) do
			local src = img:attr("data-url")
			if src ~= "" then
				dt[#dt + 1] = Http.image(src, BASE .. "/")
			end
		end
	end

	function p:loadChapterPage(link, dt)
		dt.Link = link
	end
	return p
end

build("en", "Webtoons", "OTAKIO_WEBTOONS_EN")
build("es", "Webtoons (ES)", "OTAKIO_WEBTOONS_ES")
build("fr", "Webtoons (FR)", "OTAKIO_WEBTOONS_FR")
build("de", "Webtoons (DE)", "OTAKIO_WEBTOONS_DE")
