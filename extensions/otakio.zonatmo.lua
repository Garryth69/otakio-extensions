-- @id otakio.zonatmo
-- @name ZonaTMO
-- @lang es
-- @version 1
-- @nsfw false
-- @baseUrl https://zonatmo.to
-- Native Otakio extension: ZonaTMO (large Spanish manga/manhwa catalog, WordPress JSON API).

local U = Engines.util
local BASE = "https://zonatmo.to"
local API = BASE .. "/wp-api/api"
local CDN = "https://cdn.zonatmo.to"
local PER_PAGE = 50

local p = U.newParser({id = "OTAKIO_ZONATMO", name = "ZonaTMO", baseUrl = BASE, lang = "es", version = 1, engine = "native"}, {})

local function getJson(url)
	local body = Http.get(url, {Referer = BASE .. "/", Accept = "application/json"})
	local data = Json.decode(body, 4000)
	return type(data) == "table" and data or {}
end

local function str(v)
	return type(v) == "string" and v or nil
end

local function cover(path)
	path = str(path) and U.trim(path) or ""
	if path == "" then
		return nil
	end
	if not string.find(path, "^https?://") then
		path = BASE .. "/wp-content/uploads/" .. string.gsub(path, "^/+", "")
	end
	return Http.image(path, BASE .. "/")
end

local function addList(dt, list)
	for _, m in ipairs(type(list) == "table" and list or {}) do
		local slug, title = str(m.slug), str(m.title)
		if slug and title and U.trim(slug) ~= "" then
			U.addManga(dt, p, U.trim(title), BASE .. "/manga/" .. U.trim(slug), cover(m.cover))
		end
	end
end

function p:getPopularManga(page, dt)
	local data = getJson(API .. "/tops/views/month?postType=any&postsPerPage=50").data
	addList(dt, type(data) == "table" and data.items)
	dt.NoPages = true
end

local function listing(page, dt, extra)
	local data = getJson(API .. "/listing/manga?page=" .. page .. extra).data
	data = type(data) == "table" and data or {}
	addList(dt, data.items)
	dt.NoPages = not (type(data.pagination) == "table" and data.pagination.has_next == true)
end

function p:getLatestManga(page, dt)
	listing(page, dt, "&orderBy=post_modified")
end

function p:searchManga(query, page, dt)
	listing(page, dt, "&search=" .. Http.encode(Engines.decodeSearch(query)))
end

function p:getChapters(manga, dt)
	local slug = string.match(manga.Link, "/manga/([^/?#]+)")
	if not slug then
		return
	end
	local info = getJson(API .. "/single/manga/" .. slug).data
	if type(info) == "table" then
		local authors = {}
		for _, a in ipairs(type(info.author) == "table" and info.author or {}) do
			authors[#authors + 1] = str(a.name)
		end
		dt.Description = Engines.buildInfo({Author = table.concat(authors, ", ")}, str(info.overview) or "")
	end
	local seen, page, total, out = {}, 1, 1, {}
	repeat
		local data = getJson(API .. "/single/manga/" .. slug .. "/chapters?page=" .. page .. "&postsPerPage=" .. PER_PAGE .. "&order=asc").data
		data = type(data) == "table" and data or {}
		if type(data.pagination) == "table" and tonumber(data.pagination.total_pages) then
			total = tonumber(data.pagination.total_pages)
		end
		for _, c in ipairs(type(data.items) == "table" and data.items or {}) do
			if c.id and not seen[c.id] and str(c.slug) then
				seen[c.id] = true
				local name = "#" .. tostring(c.chapter_number or "?")
				if str(c.title) and U.trim(c.title) ~= "" then
					name = name .. " - " .. U.trim(c.title)
				end
				out[#out + 1] = {
					n = tonumber(c.chapter_number) or -1,
					Name = name,
					Link = "/manga/" .. slug .. "/" .. c.slug,
					Date = str(c.release_date) and string.sub(c.release_date, 1, 10),
					Pages = {},
					Manga = manga
				}
			end
		end
		page = page + 1
	until page > total or page > 60
	-- Otakio stores oldest first; the API order is not strictly by number
	table.sort(out, function(a, b)
		return a.n < b.n
	end)
	for _, c in ipairs(out) do
		c.n = nil
		dt[#dt + 1] = c
	end
end

function p:prepareChapter(chapter, dt)
	local slug, ch = string.match(chapter.Link, "/manga/([^/]+)/([^/?#]+)")
	if not slug then
		return
	end
	local data = getJson(API .. "/single/manga/" .. slug .. "/" .. ch).data
	local c = type(data) == "table" and data.chapter
	if type(c) ~= "table" or not str(c.jit) then
		return
	end
	local images = type(c.images) == "table" and c.images or {}
	table.sort(images, function(a, b)
		return (tonumber(a.page_number) or 0) < (tonumber(b.page_number) or 0)
	end)
	for _, img in ipairs(images) do
		if str(img.image_url) then
			dt[#dt + 1] = Http.image(CDN .. "/manga/" .. c.jit .. "/" .. img.image_url, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
