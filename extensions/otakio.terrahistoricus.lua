-- @id otakio.terrahistoricus
-- @name Terra Historicus
-- @lang zh
-- @version 1
-- @nsfw false
-- @baseUrl https://comic.hypergryph.com
-- Native Otakio extension: Terra Historicus / Talos-II Historicus, the official free comics site of Hypergryph
-- (Arknights, Endfield). Public JSON API. Adapted from keiyoushi's TerraHistoricus (Apache-2.0).

local U = Engines.util
local BASE = "https://comic.hypergryph.com"
local TOPICS = {"terra-historicus", "talos-ii-historicus"}
local EPISODE_TYPES = {[2] = "番外", [3] = "贺图", [4] = "公告"}

local p = U.newParser({id = "OTAKIO_TERRAHISTORICUS", name = "Terra Historicus", baseUrl = BASE, lang = "zh", version = 1, engine = "native"}, {})

local function api(path)
	local data = Http.getJson(BASE .. path, {Referer = BASE .. "/", Accept = "application/json"})
	return type(data) == "table" and data.data or nil
end

local function str(v)
	return type(v) == "string" and v ~= "" and v or nil
end

local function addComics(dt, list, query)
	for _, c in ipairs(type(list) == "table" and list or {}) do
		local cid = str(c.cid) or str(c.comicCid)
		local title = str(c.title)
		if cid and title and (not query or query == "" or string.find(title, query, 1, true)) then
			U.addManga(dt, p, title, BASE .. "/api/comic/" .. cid, str(c.cover) or str(c.coverUrl))
		end
	end
end

-- one "page" per topic (Arknights, then Endfield)
function p:getPopularManga(page, dt)
	local topic = TOPICS[page]
	if topic then
		addComics(dt, api("/api/comic?topicKey=" .. topic))
	end
	dt.NoPages = page >= #TOPICS
end

function p:getLatestManga(page, dt)
	local topic = TOPICS[page]
	if topic then
		addComics(dt, api("/api/recentUpdate?topicKey=" .. topic))
	end
	dt.NoPages = page >= #TOPICS
end

function p:searchManga(query, page, dt)
	local topic = TOPICS[page]
	if topic then
		addComics(dt, api("/api/comic?topicKey=" .. topic), Engines.decodeSearch(query))
	end
	dt.NoPages = page >= #TOPICS
end

function p:getChapters(manga, dt)
	local cid = string.match(manga.Link or "", "/api/comic/([^/?#]+)")
	local comic = cid and api("/api/comic/" .. cid)
	if type(comic) ~= "table" then
		return
	end
	local intro = (str(comic.subtitle) and ("「" .. comic.subtitle .. "」\n") or "") .. (str(comic.introduction) or "")
	local genres = {}
	for _, k in ipairs(type(comic.keywords) == "table" and comic.keywords or {}) do
		genres[#genres + 1] = k
	end
	dt.Description = Engines.buildInfo({Author = table.concat(type(comic.authors) == "table" and comic.authors or {}, "、"), Genres = genres}, intro)
	if str(comic.cover) then
		manga.NewImageLink = Http.image(comic.cover, BASE .. "/")
	end
	local episodes = type(comic.episodes) == "table" and comic.episodes or {}
	-- the API lists the newest episode first; Otakio stores them oldest first
	for i = #episodes, 1, -1 do
		local e = episodes[i]
		if str(e.cid) then
			local name = str(e.title) or e.cid
			if EPISODE_TYPES[e.type] then
				name = EPISODE_TYPES[e.type] .. " " .. name
			elseif str(e.shortTitle) then
				name = e.shortTitle .. " " .. name
			end
			dt[#dt + 1] = {Name = name, Link = "/api/comic/" .. cid .. "/episode/" .. e.cid, Pages = {}, Manga = manga}
		end
	end
end

-- every page has its own short-lived image URL: the reader asks for it when it shows the page
function p:prepareChapter(chapter, dt)
	local episode = api(chapter.Link)
	local count = type(episode) == "table" and type(episode.pageInfos) == "table" and #episode.pageInfos or 0
	for i = 1, count do
		dt[#dt + 1] = chapter.Link .. "/page?pageNum=" .. i
	end
end

function p:loadChapterPage(link, dt)
	local data = api(link)
	if type(data) == "table" and str(data.url) then
		dt.Link = Http.image(data.url, BASE .. "/")
	end
end
