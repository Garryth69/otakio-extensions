-- @id otakio.zeurelscan
-- @name ZeurelScan
-- @lang it
-- @version 1
-- @nsfw false
-- @baseUrl https://www.zeurelscan.com
-- Native Otakio extension: ZeurelScan (Italian manga/webtoon scanlation team).

local U = Engines.util
local BASE = "https://www.zeurelscan.com"

local p = U.newParser({id = "OTAKIO_ZEURELSCAN", name = "ZeurelScan", baseUrl = BASE, lang = "it", version = 1, engine = "native"}, {})

-- the site's <head> carries a malformed <link rel="canonical" href="<link ...> that breaks the parser
local function getDocument(url)
	local body = Http.get(url, U.headers(p))
	body = string.gsub(body, "<link rel=\"canonical\"[^>]*>", "")
	return Html.parse(body, url)
end

local function image(src)
	return src and src ~= "" and Http.image(src, BASE .. "/") or nil
end

local function series(dt, query)
	local doc = getDocument(BASE .. "/series")
	query = query and string.lower(query) or ""
	for _, a in ipairs(doc:select("a.series-card")) do
		local title = U.trim(a:select("span.series-title"):text())
		if query == "" or string.find(string.lower(title), query, 1, true) then
			local img = a:selectFirst("img")
			U.addManga(dt, p, title, a:attr("abs:href"), image(img and img:attr("abs:src")))
		end
	end
	dt.NoPages = true
end

function p:getPopularManga(page, dt)
	series(dt)
end

function p:getLatestManga(page, dt)
	local doc = getDocument(BASE .. "/ultimi")
	local seen = {}
	for _, a in ipairs(doc:select("a.latest-row")) do
		local title = U.trim(a:select("span.latest-title"):text())
		-- rows link to the reader: /read/<slug>/<chapter>
		local slug = string.match(a:attr("abs:href"), "/read/([^/?#]+)")
		if slug and title ~= "" and not seen[slug] then
			seen[slug] = true
			local img = a:selectFirst("img.latest-thumb")
			U.addManga(dt, p, title, BASE .. "/serie/" .. slug, image(img and img:attr("abs:src")))
		end
	end
	dt.NoPages = true
end

function p:searchManga(query, page, dt)
	series(dt, Engines.decodeSearch(query))
end

local function field(info, label)
	local el = info:selectFirst("p:contains(" .. label .. ")")
	return el and U.trim(el:ownText()) or nil
end

function p:getChapters(manga, dt)
	local doc = getDocument(U.absolute(BASE, manga.Link))
	local info = doc:selectFirst("div.series-header")
	if info then
		local plot = info:selectFirst("p.series-plot")
		dt.Description = Engines.buildInfo({
			Author = field(info, "Autore"),
			Artist = field(info, "Artista"),
			Status = field(info, "Stato"),
			Genres = {field(info, "Genere")}
		}, plot and plot:text() or "")
	end
	local rows = doc:select("div.chapter")
	-- the site lists newest first; Otakio stores oldest first
	for i = #rows, 1, -1 do
		local a = rows[i]:selectFirst("a")
		if a then
			local text = U.trim(a:ownText())
			text = string.match(text, "#(.*)$") or text
			local num, title = string.match(text, "^%s*(.-)%s*–%s*(.-)%s*$")
			num = num or U.trim(text)
			local name = (title and title ~= "") and (num .. " - " .. title) or ("Capitolo " .. num)
			dt[#dt + 1] = {Name = name, Link = U.pathOf(a:attr("abs:href")), Pages = {}, Manga = manga}
		end
	end
end

function p:prepareChapter(chapter, dt)
	local doc = getDocument(U.absolute(BASE, chapter.Link))
	for _, img in ipairs(doc:select("div.reader img")) do
		dt[#dt + 1] = image(img:attr("abs:src"))
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
