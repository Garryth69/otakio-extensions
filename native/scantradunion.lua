-- @id otakio.scantradunion
-- @name Scantrad Union
-- @lang fr
-- @version 1
-- @nsfw false
-- @baseUrl https://scantrad-union.com
-- Native Otakio extension: Scantrad Union (French scanlation hub shared by many teams).

local U = Engines.util
local BASE = "https://scantrad-union.com"
local SEARCH_DATA = "YXNwX2dlbiU1QiU1RD10aXRsZSZjdXN0b21zZXQlNUIlNUQ9bWFuZ2E="

local p = U.newParser({id = "OTAKIO_SCANTRADUNION", name = "Scantrad Union", baseUrl = BASE, lang = "fr", version = 1, engine = "native"}, {})

-- the image server refuses requests that carry a Referer header
local function image(src)
	return src and src ~= "" and src or nil
end

local function title(s)
	return U.trim((string.gsub(s or "", "^%s*%[Partenaire%]", "")))
end

function p:getPopularManga(page, dt)
	local doc = Http.getDocument(BASE .. "/projets/", U.headers(self))
	for _, a in ipairs(doc:select(".index-top3-a")) do
		local bg = a:selectFirst(".index-top3-bg")
		local style = bg and bg:attr("style") or ""
		local cover = string.match(style, "url%('([^']+)'%)") or string.match(style, "url%(([^)]+)%)")
		U.addManga(dt, p, title(a:select(".index-top3-title"):text()), a:attr("abs:href"), image(cover))
	end
	dt.NoPages = true
end

function p:getLatestManga(page, dt)
	local doc = Http.getDocument(BASE .. "/", U.headers(self))
	for _, el in ipairs(doc:select(".dernieresmaj .colonne")) do
		local a = el:selectFirst("a.text-truncate")
		local img = el:selectFirst("img.attachment-thumbnail")
		if a then
			U.addManga(dt, p, title(a:text()), a:attr("abs:href"), image(img and img:attr("abs:src")))
		end
	end
	dt.NoPages = true
end

function p:searchManga(query, page, dt)
	local url = BASE .. "/?" .. Http.form({
		{"s", Engines.decodeSearch(query)},
		{"asp_active", "1"},
		{"p_asid", "1"},
		{"p_asp_data", SEARCH_DATA}
	})
	local doc = Http.getDocument(url, U.headers(self))
	for _, el in ipairs(doc:select("article.post-outer")) do
		local a = el:selectFirst("a.index-post-header-a")
		local img = el:selectFirst("img.wp-post-image")
		if a then
			U.addManga(dt, p, title(a:text()), a:attr("abs:href"), image(img and img:attr("abs:src")))
		end
	end
	dt.NoPages = true
end

function p:getChapters(manga, dt)
	local doc = Http.getDocument(U.absolute(BASE, manga.Link), U.headers(self))
	local img = doc:selectFirst(".projet-image img")
	if img then
		manga.NewImageLink = image(img:attr("abs:src"))
	end
	local labels = doc:select(".label.label-primary")
	dt.Description = Engines.buildInfo({
		Author = doc:select("div.project-details a[href*=auteur]"):text(),
		Status = labels[3] and U.trim(labels[3]:text()) or nil
	}, doc:select(".sContent"):text())
	local items = doc:select(".links-projects li")
	-- the site lists newest first; Otakio stores oldest first
	for i = #items, 1, -1 do
		local li = items[i]
		local url
		for _, b in ipairs(li:select(".btnlel")) do
			local href = b:attr("abs:href")
			if not url and string.find(href, BASE .. "/read/", 1, true) == 1 then
				url = href
			end
		end
		if not url then
			local b = li:selectFirst(".btnlel")
			url = b and b:attr("abs:href") or ""
		end
		if url ~= "" then
			local num = U.trim((string.gsub(li:select(".chapter-number"):text(), "^#", "")))
			local name = U.trim(li:select(".chapter-name"):text())
			local full = num
			if name ~= "" then
				full = (full ~= "" and (full .. " - ") or "") .. name
			end
			dt[#dt + 1] = {Name = full ~= "" and full or "?", Link = U.pathOf(url), Pages = {}, Manga = manga}
		end
	end
end

function p:prepareChapter(chapter, dt)
	local doc = Http.getDocument(U.absolute(BASE, chapter.Link), U.headers(self))
	local seen = {}
	for _, img in ipairs(doc:select("#webtoon a img")) do
		local src = img:attr("abs:data-src")
		if src == "" then
			src = img:attr("abs:src")
		end
		if src ~= "" and not seen[src] then
			seen[src] = true
			dt[#dt + 1] = image(src)
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
