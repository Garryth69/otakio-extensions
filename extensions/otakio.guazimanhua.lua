-- @id otakio.guazimanhua
-- @name 瓜子漫画 (Guazi Manhua)
-- @lang zh
-- @version 1
-- @nsfw false
-- @baseUrl https://www.guazimanhua.com
-- Native Otakio extension: Guazi Manhua (Chinese manhua catalog, plain HTML).
-- Adapted from keiyoushi's Guazimanhua (Apache-2.0).

local U = Engines.util
local BASE = "https://www.guazimanhua.com"

local p = U.newParser({id = "OTAKIO_GUAZIMANHUA", name = "瓜子漫画 (Guazi Manhua)", baseUrl = BASE, lang = "zh", version = 1, engine = "native"}, {})

local function H()
	return {Referer = BASE .. "/"}
end

local function list(url, dt)
	local doc = Http.getDocument(url, H())
	local count = 0
	for _, card in ipairs(doc:select("article.card")) do
		local a = card:selectFirst("h3 a")
		local cover = card:selectFirst("a.cover-wrap")
		local img = card:selectFirst("img.cover")
		if a and cover and U.addManga(dt, p, a:text(), cover:attr("abs:href"), img and img:attr("abs:src") or nil) then
			count = count + 1
		end
	end
	local hasNext = false
	for _, a in ipairs(doc:select("nav.pager a")) do
		if U.trim(a:text()) == ">" then
			hasNext = true
		end
	end
	dt.NoPages = count == 0 or not hasNext
end

function p:getPopularManga(page, dt)
	list(BASE .. "/category.php?sort=hits&page=" .. page, dt)
end

function p:getLatestManga(page, dt)
	list(BASE .. "/category.php?sort=update&page=" .. page, dt)
end

function p:searchManga(query, page, dt)
	list(BASE .. "/category.php?keyword=" .. Http.encode(Engines.decodeSearch(query)) .. "&sort=hits&page=" .. page, dt)
end

function p:getChapters(manga, dt)
	local doc = Http.getDocument(U.absolute(BASE, manga.Link), H())
	local function text(css)
		local el = doc:selectFirst(css)
		return el and U.trim(el:text()) or nil
	end
	local author
	for _, div in ipairs(doc:select("div.cinema-strip > div")) do
		local label = div:selectFirst("span")
		if label and U.trim(label:text()) == "作者" then
			local b = div:selectFirst("b")
			author = b and U.trim(b:text()) or nil
		end
	end
	dt.Description = Engines.buildInfo({Author = author, Genres = {text("p.mobile-comic-tags")}, Status = text("p.mobile-comic-meta")}, text("p.mobile-comic-desc") or "")
	local cover = doc:selectFirst("img.mobile-comic-cover")
	if cover and cover:attr("src") ~= "" then
		manga.NewImageLink = Http.image(cover:attr("abs:src"), BASE .. "/")
	end
	local links = doc:select("section.mobile-comic-all-chapters div.mobile-chapter-grid a")
	-- the grid lists the newest chapter first; Otakio stores them oldest first
	for i = links:size(), 1, -1 do
		local a = links[i]
		if a:attr("href") ~= "" then
			dt[#dt + 1] = {Name = U.trim(a:text()), Link = U.pathOf(a:attr("abs:href")), Pages = {}, Manga = manga}
		end
	end
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link)
	local doc = Http.getDocument(url, H())
	for _, img in ipairs(doc:select("section.reader-images img")) do
		local src = img:attr("data-src") ~= "" and img:attr("abs:data-src") or img:attr("abs:src")
		if src ~= "" then
			dt[#dt + 1] = Http.image(src, url)
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
