-- @id otakio.mangakakalot
-- @name Mangakakalot
-- @lang en
-- @version 1
-- @nsfw false
-- @baseUrl https://www.kakamanga.com
-- Native Otakio extension: Mangakakalot (MangaBox theme), one of the largest English catalogs.

local U = Engines.util

local function normalize(q)
	q = string.lower(q or "")
	q = string.gsub(q, "[^%w]+", "_")
	q = string.gsub(q, "_+", "_")
	return (string.gsub(q, "^_+", ""):gsub("_+$", ""))
end

local function jsArray(script, name)
	local body = string.match(script, name .. "%s*=%s*%[([^%]]+)%]")
	local out = {}
	if body then
		for item in string.gmatch(body, "[^,]+") do
			item = string.gsub(U.trim(item), "^\"", "")
			item = string.gsub(item, "\"$", "")
			item = string.gsub(item, "\\/", "/")
			item = string.gsub(item, "/$", "")
			if item ~= "" then
				out[#out + 1] = item
			end
		end
	end
	return out
end

local function build(name, id, base)
	local p = U.newParser({id = id, name = name, baseUrl = base, lang = "en", version = 1, engine = "native"}, {})
	local LIST = "div.truyen-list > div.list-truyen-item-wrap, div.comic-list > .list-comic-item-wrap"
	local SEARCH = ".panel_story_list .story_item, div.list-truyen-item-wrap, div.list-comic-item-wrap"
	local NEXT = "a.page_select + a:not(.page_last), a.page-select + a:not(.page-last), div.group-page a:not([href]) + a:not(:contains(Last))"

	local function image(src)
		return src and src ~= "" and Http.image(src, base .. "/") or nil
	end

	local function list(url, selector, dt)
		local doc = Http.getDocument(url, U.headers(p))
		for _, el in ipairs(doc:select(selector)) do
			local a = el:selectFirst("h3 a")
			local img = el:selectFirst("img")
			if a then
				U.addManga(dt, p, a:text(), a:attr("abs:href"), image(img and img:attr("abs:src")))
			end
		end
		dt.NoPages = doc:selectFirst(NEXT) == nil
	end

	function p:getPopularManga(page, dt)
		list(base .. "/manga-list/hot-manga?page=" .. page, LIST, dt)
	end

	function p:getLatestManga(page, dt)
		list(base .. "/manga-list/latest-manga?page=" .. page, LIST, dt)
	end

	function p:searchManga(query, page, dt)
		list(base .. "/search/story/" .. normalize(Engines.decodeSearch(query)) .. "?page=" .. page, SEARCH, dt)
	end

	function p:getChapters(manga, dt)
		local url = U.absolute(base, manga.Link)
		local doc = Http.getDocument(url, U.headers(self))
		local info = doc:selectFirst("div.manga-info-top, div.panel-story-info")
		local img = doc:selectFirst("div.manga-info-pic img, span.info-image img")
		if img then
			manga.NewImageLink = image(img:attr("abs:src"))
		end
		local desc = doc:selectFirst("div#noidungm, div#panel-story-info-description, div#contentBox")
		if info then
			dt.Description = Engines.buildInfo({
				Author = info:select("li:contains(author) a, td:containsOwn(author) + td a"):text(),
				Status = U.trim(info:select("li:contains(status), td:containsOwn(status) + td"):text()),
				Genres = info:select("li:contains(genres) a, td:containsOwn(genres) + td a"):eachText()
			}, desc and desc:ownText() or "")
		end
		local slug = string.match(url, "/manga/([^/?#]+)")
		if not slug then
			return
		end
		local body = Http.get(base .. "/api/manga/" .. slug .. "/chapters?limit=-1", U.headers(self, {Referer = url, ["X-Requested-With"] = "XMLHttpRequest"}))
		local data = Json.decode(body, 4000)
		local chapters = type(data) == "table" and type(data.data) == "table" and data.data.chapters or {}
		-- the API lists newest first; Otakio stores oldest first
		for i = #chapters, 1, -1 do
			local c = chapters[i]
			if type(c.chapter_slug) == "string" then
				dt[#dt + 1] = {
					Name = type(c.chapter_name) == "string" and c.chapter_name or "Chapter",
					Link = "/manga/" .. slug .. "/" .. c.chapter_slug,
					Date = type(c.updated_at) == "string" and string.sub(c.updated_at, 1, 10) or nil,
					Pages = {},
					Manga = manga
				}
			end
		end
	end

	function p:prepareChapter(chapter, dt)
		local doc = Http.getDocument(U.absolute(base, chapter.Link), U.headers(self))
		local script = ""
		for _, s in ipairs(doc:select("script")) do
			local d = s:data()
			if string.find(d, "chapterImages", 1, true) then
				script = script .. d .. "\n"
			end
		end
		local cdns = jsArray(script, "cdns")
		local images = jsArray(script, "chapterImages")
		if #images > 0 and cdns[1] then
			for _, path in ipairs(images) do
				dt[#dt + 1] = image(cdns[1] .. "/" .. string.gsub(path, "^/+", ""))
			end
			return
		end
		for _, img in ipairs(doc:select("div.container-chapter-reader > img")) do
			dt[#dt + 1] = image(img:attr("abs:src"))
		end
	end

	function p:loadChapterPage(link, dt)
		dt.Link = link
	end
	return p
end

build("Mangakakalot", "OTAKIO_MANGAKAKALOT", "https://www.kakamanga.com")
