-- @id otakio.asurascans
-- @name Asura Scans
-- @lang en
-- @version 1
-- @nsfw false
-- @baseUrl https://asurascans.com
-- Native Otakio extension: Asura Scans (popular English manhwa scanlator, public JSON API).

local U = Engines.util
local BASE = "https://asurascans.com"
local API = "https://api.asurascans.com/api"
local LIMIT = 20

local p = U.newParser({id = "OTAKIO_ASURASCANS", name = "Asura Scans", baseUrl = BASE, lang = "en", version = 1, engine = "native"}, {})

p.Filters = {
	{Name = "Sort", Type = "radio", Tags = {"Popular", "Latest", "Rating", "A-Z"}}
}
local SORT = {Popular = "popular", Latest = "latest", Rating = "rating", ["A-Z"] = "name"}

local function getJson(url)
	local body = Http.get(url, {Referer = BASE .. "/", Origin = BASE, Accept = "application/json"})
	local data = Json.decode(body, 4000)
	return type(data) == "table" and data or {}
end

local function str(v)
	return type(v) == "string" and v or nil
end

local function series(page, dt, sort, query)
	local url = API .. "/series?offset=" .. ((page - 1) * LIMIT) .. "&limit=" .. LIMIT .. "&sort=" .. sort
	if query and query ~= "" then
		url = url .. "&search=" .. Http.encode(query)
	end
	local data = getJson(url)
	for _, m in ipairs(type(data.data) == "table" and data.data or {}) do
		if str(m.public_url) and str(m.title) then
			U.addManga(dt, p, m.title, BASE .. m.public_url, str(m.cover) and Http.image(m.cover, BASE .. "/"))
		end
	end
	dt.NoPages = not (type(data.meta) == "table" and data.meta.has_more == true)
end

function p:getPopularManga(page, dt)
	series(page, dt, "popular")
end

function p:getLatestManga(page, dt)
	series(page, dt, "latest")
end

function p:searchManga(query, page, dt, tags)
	series(page, dt, SORT[tags and tags["Sort"] or ""] or "popular", Engines.decodeSearch(query))
end

local function number(n)
	if type(n) ~= "number" then
		return tostring(n)
	end
	if n == math.floor(n) then
		return string.format("%d", n)
	end
	return tostring(n)
end

function p:getChapters(manga, dt)
	-- manga.Link = /comics/<slug>-<random 8 chars>; the API wants the plain slug
	local public = string.match(manga.Link, "/comics/([^/?#]+)")
	if not public then
		return
	end
	local slug = string.gsub(public, "%-%w%w%w%w%w%w%w%w$", "")
	local info = getJson(API .. "/series/" .. slug)
	local s = type(info.series) == "table" and info.series or info
	if str(s.description) then
		local genres = {}
		for _, g in ipairs(type(s.genres) == "table" and s.genres or {}) do
			genres[#genres + 1] = str(g.name)
		end
		dt.Description = Engines.buildInfo({Author = str(s.author), Artist = str(s.artist), Status = str(s.status), Genres = genres},
			(string.gsub(s.description, "<[^>]+>", "")))
	end
	local now = U.date("!%Y-%m-%dT%H:%M:%S") or ""
	local list = getJson(API .. "/series/" .. slug .. "/chapters").data
	list = type(list) == "table" and list or {}
	-- the API lists newest first; Otakio stores oldest first. Premium/early-access chapters need an account.
	for i = #list, 1, -1 do
		local c = list[i]
		local locked = c.is_premium == true or (str(c.early_access_until) and c.early_access_until > now)
		if not locked then
			local name = "Chapter " .. number(c.number)
			if str(c.title) and c.title ~= "" then
				name = name .. " - " .. c.title
			end
			dt[#dt + 1] = {
				Name = name,
				Link = "/comics/" .. public .. "/chapter/" .. number(c.number),
				Date = str(c.published_at) and string.sub(c.published_at, 1, 10),
				Pages = {},
				Manga = manga
			}
		end
	end
end

function p:prepareChapter(chapter, dt)
	local body = Http.get(BASE .. chapter.Link, U.headers(self))
	-- Astro island props: "pages":[1,[[0,{"url":[0,"https://cdn..."], ...}], ...]]
	for props in string.gmatch(body, 'props="([^"]*)"') do
		if string.find(props, "&quot;pages&quot;", 1, true) then
			props = string.gsub(props, "&quot;", '"')
			props = string.gsub(props, "&amp;", "&")
			for url in string.gmatch(props, '"url":%[0,"([^"]+)"%]') do
				dt[#dt + 1] = Http.image(url, BASE .. "/")
			end
			return
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
