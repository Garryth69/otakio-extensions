-- @id otakio.vercomicsporno
-- @name VerComicsPorno
-- @lang es
-- @version 1
-- @nsfw true
-- @baseUrl https://vercomicsporno.xxx
-- Native Otakio extension: VerComicsPorno (WordPress blog; each post is one comic whose pages are the post's image
-- blocks). Replaces the NOBORU parser.

local U = Engines.util
local BASE = "https://vercomicsporno.xxx"

local p = U.newParser({id = "OTAKIO_VERCOMICSPORNO", name = "VerComicsPorno", baseUrl = BASE, lang = "es", version = 1, nsfw = true, engine = "native"}, {})

local function H()
	return {Referer = BASE .. "/"}
end

local function list(url, dt)
	local doc = Http.getDocument(url, H())
	local count = 0
	for _, card in ipairs(doc:select("div.page-item-detail")) do
		local a = card:selectFirst(".post-title a") or card:selectFirst("a")
		local img = card:selectFirst("img")
		local cover = img and img:attr("abs:src") or ""
		if a and U.addManga(dt, p, U.trim(a:text()), a:attr("abs:href"), cover ~= "" and cover or nil) then
			count = count + 1
		end
	end
	dt.NoPages = count == 0 or doc:selectFirst("a.next, .nav-previous a, a.nextpostslink, .wp-pagenavi a.larger") == nil
end

function p:getPopularManga(page, dt)
	list(BASE .. "/page/" .. page .. "/", dt)
end

function p:searchManga(query, page, dt)
	list(BASE .. "/page/" .. page .. "/?s=" .. Http.encode(Engines.decodeSearch(query)), dt)
end

function p:getChapters(manga, dt)
	local url = U.absolute(BASE, manga.Link)
	local doc = Http.getDocument(url, H())
	local tags = {}
	for _, a in ipairs(doc:select("a[rel=tag]")) do
		tags[#tags + 1] = U.trim(a:text())
	end
	dt.Description = Engines.buildInfo({Genres = tags, Status = "Completed"}, "")
	dt[1] = {Name = "Leer", Link = U.pathOf(url), Pages = {}, Manga = manga}
end

function p:prepareChapter(chapter, dt)
	local doc = Http.getDocument(U.absolute(BASE, chapter.Link), H())
	for _, img in ipairs(doc:select(".entry-content .wp-block-image img")) do
		local src = img:attr("abs:src")
		if src ~= "" then
			dt[#dt + 1] = Http.image(src, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
