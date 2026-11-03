-- @id otakio.flamecomics
-- @name Flame Comics
-- @lang en
-- @version 2
-- @nsfw false
-- @baseUrl https://flamecomics.xyz
-- Native Otakio extension: Flame Comics (Next.js data routes).

local U = Engines.util
local BASE = "https://flamecomics.xyz"
local CDN = "https://cdn.flamecomics.xyz/uploads/images/series/"

local p = U.newParser({id = "OTAKIO_FLAMECOMICS", name = "Flame Comics", baseUrl = BASE, lang = "en", version = 2, engine = "native"}, {})

local buildId

local function nn(v)
	if v == Json.null then
		return nil
	end
	return v
end

---GET /_next/data/<buildId>/<path>; the build id changes on every deploy, so refresh it once on a miss
local function data(path)
	for attempt = 1, 2 do
		if not buildId or attempt == 2 then
			local home = Http.get(BASE, U.headers(p))
			coroutine.yield(false)
			buildId = string.match(home, '"buildId"%s*:%s*"([^"]+)"')
		end
		if buildId then
			local result = Http.getJson(BASE .. "/_next/data/" .. buildId .. "/" .. path, U.headers(p))
			if type(result) == "table" and result.pageProps then
				return result.pageProps
			end
		end
	end
	return {}
end

-- the CDN "thumbnails" are full-size WebPs (several MB); the site's own Next.js resizer returns ~40 KB
local function cover(s)
	local url = CDN .. tostring(s.series_id) .. "/" .. tostring(s.cover) .. "?" .. tostring(nn(s.last_edit) or "")
	return BASE .. "/_next/image?url=" .. Http.encode(url) .. "&w=384&q=75"
end

local function addSeries(dt, list, query)
	query = query and string.lower(query)
	for _, s in ipairs(list or {}) do
		if nn(s.series_id) and (not query or string.find(string.lower(s.title or ""), query, 1, true)) then
			U.addManga(dt, p, s.title or "", "/series/" .. tostring(s.series_id), cover(s))
		end
	end
	dt.NoPages = true
end

function p:getPopularManga(page, dt)
	local list = data("browse.json").series or {}
	table.sort(list, function(a, b)
		return (tonumber(nn(a.popularityRank)) or 1e9) < (tonumber(nn(b.popularityRank)) or 1e9)
	end)
	addSeries(dt, list)
end

function p:getLatestManga(page, dt)
	addSeries(dt, data("latest.json").allSeries)
end

function p:searchManga(query, page, dt)
	addSeries(dt, data("browse.json").series, Engines.decodeSearch(query))
end

function p:getChapters(manga, dt)
	local id = string.match(manga.Link, "/series/(%d+)")
	if not id then
		return
	end
	local props = data("series/" .. id .. ".json?id=" .. id)
	local s = props.series or {}
	local function join(list)
		return type(list) == "table" and table.concat(list, ", ") or nil
	end
	local desc = nn(s.description) and Html.parse(s.description):text() or ""
	dt.Description = Engines.buildInfo({Author = join(s.author), Artist = join(s.artist), Status = nn(s.status), Genres = nn(s.tags)}, desc)
	if nn(s.cover) then
		manga.NewImageLink = cover(s)
	end
	local chapters = props.chapters or {}
	table.sort(chapters, function(a, b)
		return (tonumber(a.chapter) or 0) < (tonumber(b.chapter) or 0)
	end)
	for _, c in ipairs(chapters) do
		-- "1.00" -> "1", "12.50" -> "12.5"
		local num = string.gsub(string.format("%.2f", tonumber(c.chapter) or 0), "%.?0+$", "")
		local name = "Chapter " .. num
		if nn(c.title) and c.title ~= "" then
			name = name .. " - " .. c.title
		end
		dt[#dt + 1] = {Name = name, Link = "/series/" .. id .. "/" .. tostring(c.token), Date = tonumber(c.release_date) and U.date("%Y-%m-%d", tonumber(c.release_date)) or nil, Pages = {}, Manga = manga}
	end
end

function p:prepareChapter(chapter, dt)
	local id, token = string.match(chapter.Link, "/series/(%d+)/([^/]+)")
	if not id then
		return
	end
	local c = data("series/" .. id .. "/" .. token .. ".json?id=" .. id .. "&token=" .. token).chapter or {}
	local keys = {}
	for k in pairs(c.images or {}) do
		keys[#keys + 1] = k
	end
	table.sort(keys, function(a, b)
		return (tonumber(a) or 0) < (tonumber(b) or 0)
	end)
	for _, k in ipairs(keys) do
		dt[#dt + 1] = Http.image(CDN .. id .. "/" .. token .. "/" .. c.images[k].name .. "?" .. tostring(c.release_date or ""), BASE .. "/")
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
