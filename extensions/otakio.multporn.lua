-- @id otakio.multporn
-- @name Multporn
-- @lang en
-- @version 1
-- @nsfw true
-- @baseUrl https://multporn.net
-- Native Otakio extension: Multporn (western adult comics, plain HTML).
-- Adapted from keiyoushi's Multporn (Apache-2.0).

local U = Engines.util
local BASE = "https://multporn.net"

local p = U.newParser({id = "OTAKIO_MULTPORN", name = "Multporn", baseUrl = BASE, lang = "en", version = 1, nsfw = true, engine = "native"}, {})

local function H()
	return {Referer = BASE .. "/"}
end

-- the site counts pages from 0
local function list(url, dt)
	local doc = Http.getDocument(url, H())
	local count = 0
	for _, item in ipairs(doc:select(".masonry-item")) do
		local a = item:selectFirst(".views-field-title a")
		local t = item:selectFirst(".views-field-title")
		local img = item:selectFirst("img")
		if a and t and U.addManga(dt, p, t:text(), a:attr("abs:href"), img and img:attr("abs:src") or nil) then
			count = count + 1
		end
	end
	dt.NoPages = count == 0 or doc:selectFirst(".pager-next a") == nil
end

function p:getPopularManga(page, dt)
	list(BASE .. "/best?page=" .. (page - 1), dt)
end

function p:getLatestManga(page, dt)
	list(BASE .. "/new?page=" .. (page - 1), dt)
end

function p:searchManga(query, page, dt)
	list(BASE .. "/search?page=" .. (page - 1) .. "&search_api_views_fulltext=" .. Http.encode(Engines.decodeSearch(query)), dt)
end

local function field(doc, label)
	local out = {}
	for _, f in ipairs(doc:select(".field")) do
		local l = f:selectFirst(".field-label")
		if l and string.find(l:text(), label .. ":", 1, true) then
			for _, a in ipairs(f:select(".links a")) do
				out[#out + 1] = U.trim(a:text())
			end
		end
	end
	return out
end

function p:getChapters(manga, dt)
	local url = U.absolute(BASE, manga.Link)
	local doc = Http.getDocument(url, H())
	local authors = field(doc, "Author")
	for _, cls in ipairs({"field-name-field-author", "field-name-field-authors-gr", "field-name-field-img-group"}) do
		for _, a in ipairs(doc:select("." .. cls .. " a")) do
			authors[#authors + 1] = U.trim(a:text())
		end
	end
	local seen, uniq = {}, {}
	for _, a in ipairs(authors) do
		if a ~= "" and not seen[a] then
			seen[a] = true
			uniq[#uniq + 1] = a
		end
	end
	local genres = field(doc, "Tags")
	for _, s in ipairs(field(doc, "Section")) do
		genres[#genres + 1] = s
	end
	local chars = field(doc, "Characters")
	dt.Description = Engines.buildInfo({Author = #uniq > 0 and table.concat(uniq, ", ") or nil, Genres = genres},
		#chars > 0 and ("Characters: " .. table.concat(chars, ", ")) or "")
	dt[#dt + 1] = {Name = "Chapter", Link = U.pathOf(url), Pages = {}, Manga = manga}
end

function p:prepareChapter(chapter, dt)
	local url = U.absolute(BASE, chapter.Link)
	local doc = Http.getDocument(url, H())
	for _, img in ipairs(doc:select(".jb-image img")) do
		local src = img:attr("abs:src")
		if src ~= "" then
			src = string.gsub(src, "/styles/juicebox_2k/public", "")
			src = string.match(src, "^[^?]*")
			dt[#dt + 1] = Http.image(src, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
