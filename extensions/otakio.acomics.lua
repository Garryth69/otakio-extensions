-- @id otakio.acomics
-- @name AComics
-- @lang ru
-- @version 1
-- @nsfw false
-- @baseUrl https://acomics.ru
-- Native Otakio extension: AComics (Russian webcomics hosting, authors publish their own comics; one image per issue).
-- Adapted from keiyoushi's AComics (Apache-2.0).

local U = Engines.util
local BASE = "https://acomics.ru"

local p = U.newParser({id = "OTAKIO_ACOMICS", name = "AComics", baseUrl = BASE, lang = "ru", version = 1, engine = "native"}, {})

local function H()
	return {Referer = BASE .. "/"}
end

local function list(dt, url)
	local doc = Http.getDocument(url, H())
	local count = 0
	for _, el in ipairs(doc:select("section.serial-card")) do
		local a = el:selectFirst("h2 > a")
		local img = el:selectFirst("a > img")
		local cover = img and (img:attr("data-real-src") ~= "" and img:attr("abs:data-real-src") or img:attr("abs:src")) or nil
		if a and U.addManga(dt, p, a:text(), a:attr("abs:href") .. "/about", cover) then
			count = count + 1
		end
	end
	dt.NoPages = count == 0 or doc:selectFirst("a.infinite-scroll") == nil
end

local function catalog(sort, page)
	local url = BASE .. "/comics?sort=" .. sort .. "&ratings[]=1&ratings[]=2&ratings[]=3&ratings[]=4&ratings[]=5&type=0&updatable=0&subscribe=0&issue_count=2"
	if page > 1 then
		url = url .. "&skip=" .. ((page - 1) * 10)
	end
	return url
end

function p:getPopularManga(page, dt)
	list(dt, catalog("subscr_count", page))
end

function p:getLatestManga(page, dt)
	list(dt, catalog("last_update", page))
end

function p:searchManga(query, page, dt)
	query = Engines.decodeSearch(query)
	local url = BASE .. "/search?keyword=" .. Http.encode(query)
	if page > 1 then
		url = url .. "&skip=" .. ((page - 1) * 10)
	end
	list(dt, url)
end

function p:getChapters(manga, dt)
	local doc = Http.getDocument(U.absolute(BASE, manga.Link), H())
	local article = doc:selectFirst("article.common-article") or doc
	local genres, authors = {}, {}
	for _, a in ipairs(article:select("p.serial-about-badges a.category")) do
		genres[#genres + 1] = U.trim(a:text())
	end
	for _, a in ipairs(article:select("p.serial-about-authors a")) do
		authors[#authors + 1] = U.trim(a:ownText())
	end
	local desc = article:selectFirst("section.serial-about-text")
	dt.Description = Engines.buildInfo({Genres = genres, Author = table.concat(authors, ", ")}, desc and desc:text() or "")
	-- issues are numbered 1..count: "Количество выпусков: N"
	local count
	for _, el in ipairs(article:select("p")) do
		if string.find(el:text(), "Количество выпусков", 1, true) then
			count = tonumber(string.match(el:ownText(), "(%d+)") or string.match(el:text(), "(%d+)%s*$"))
			break
		end
	end
	local comicPath = string.gsub(manga.Link, "/about$", "")
	for i = 1, count or 0 do
		dt[#dt + 1] = {Name = tostring(i), Link = comicPath .. "/" .. i, Pages = {}, Manga = manga}
		if i % 500 == 0 then
			coroutine.yield(false)
		end
	end
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link)
	local doc = Http.getDocument(url, H())
	local img = doc:selectFirst("img.issue")
	if img then
		dt[#dt + 1] = Http.image(img:attr("abs:src"), url)
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
