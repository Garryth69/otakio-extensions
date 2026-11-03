-- @id otakio.aralosbd
-- @name AralosBD
-- @lang fr
-- @version 1
-- @nsfw false
-- @baseUrl https://aralosbd.fr
-- Native Otakio extension: AralosBD (French comics/BD and webcomics, JSON API).

local U = Engines.util
local BASE = "https://aralosbd.fr"

local p = U.newParser({id = "OTAKIO_ARALOSBD", name = "AralosBD", baseUrl = BASE, lang = "fr", version = 1, engine = "native"}, {})

local function getJson(url)
	local body = Http.get(url, {Referer = BASE .. "/", Accept = "application/json"})
	local data = Json.decode(body, 4000)
	return type(data) == "table" and data or {}
end

local function str(v)
	return type(v) == "string" and v or nil
end

local function search(page, dt, s)
	local data = getJson(BASE .. "/manga/search?s=" .. s .. ";page:" .. (page - 1))
	for _, m in ipairs(type(data.mangas) == "table" and data.mangas or {}) do
		if m.id and str(m.title) then
			U.addManga(dt, p, m.title, BASE .. "/manga/display?id=" .. tostring(m.id), str(m.icon) and Http.image(BASE .. "/" .. m.icon, BASE .. "/"))
		end
	end
	dt.NoPages = not (tonumber(data.page_count) and page < tonumber(data.page_count))
end

function p:getPopularManga(page, dt)
	search(page, dt, "sort:allviews;limit:24;-id:3;order:desc")
end

function p:getLatestManga(page, dt)
	search(page, dt, "sort:id;limit:24;-id:3;order:desc")
end

function p:searchManga(query, page, dt)
	search(page, dt, "sort:id;order:desc;text:" .. Http.encode(Engines.decodeSearch(query)))
end

local function clean(s)
	s = string.match(s, "^(.-)%-%-%-") or s
	s = string.gsub(s, "%[([^%]]+)%]%(([^)]+)%)", "%2")
	s = string.gsub(s, "%*+%s*([^%*]*)%s*%*+", "%1")
	s = string.gsub(s, ":+[%a]+:", "")
	return U.trim(s)
end

function p:getChapters(manga, dt)
	local id = string.match(manga.Link, "[?&]id=(%d+)")
	if not id then
		return
	end
	local m = getJson(BASE .. "/manga/api?get=manga&id=" .. id)
	local authors, tags = {}, {}
	for _, a in ipairs(type(m.authors) == "table" and m.authors or {}) do
		authors[#authors + 1] = str(a.name)
	end
	for _, t in ipairs(type(m.tags) == "table" and m.tags or {}) do
		tags[#tags + 1] = str(t.tag)
	end
	dt.Description = Engines.buildInfo({Author = table.concat(authors, ", "), Genres = tags},
		clean((str(m.description) or "") .. "\n\n" .. (str(m.fulldescription) or "")))
	local list = getJson(BASE .. "/manga/api?get=chapters&manga=" .. id)
	local out = {}
	for i, c in ipairs(list) do
		if tonumber(c.chapter_released) == 1 and c.chapter_id then
			local num = tostring(c.chapter_number or "")
			-- numbers can look like 2.5.1: sort on the dotted parts
			local key = {}
			for part in string.gmatch(num, "%d+") do
				key[#key + 1] = tonumber(part)
			end
			out[#out + 1] = {
				key = key,
				i = i,
				Name = num .. (str(c.chapter_title) and (" - " .. c.chapter_title) or ""),
				Link = "/manga/chapter?id=" .. tostring(c.chapter_id),
				Date = str(c.chapter_release_time) and string.sub(c.chapter_release_time, 1, 10)
			}
		end
	end
	-- Otakio stores oldest first
	table.sort(out, function(a, b)
		for k = 1, math.max(#a.key, #b.key) do
			local x, y = a.key[k] or -1, b.key[k] or -1
			if x ~= y then
				return x < y
			end
		end
		return a.i < b.i
	end)
	for _, c in ipairs(out) do
		dt[#dt + 1] = {Name = c.Name, Link = c.Link, Date = c.Date, Pages = {}, Manga = manga}
	end
end

function p:prepareChapter(chapter, dt)
	local id = string.match(chapter.Link, "[?&]id=(%d+)")
	local data = id and getJson(BASE .. "/manga/api?get=pages&chapter=" .. id) or {}
	for _, link in ipairs(type(data.links) == "table" and data.links or {}) do
		if str(link) then
			dt[#dt + 1] = Http.image(BASE .. "/" .. string.gsub(link, "^/+", ""), BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
