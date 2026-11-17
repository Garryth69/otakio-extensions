-- @id otakio.myhentaigallery
-- @name MyHentaiGallery
-- @lang en
-- @version 1
-- @nsfw true
-- @baseUrl https://myhentaigallery.com
-- Native Otakio extension: MyHentaiGallery (plain HTML; one gallery = one chapter, pages are the thumbnails'
-- /original/ files). Replaces the NOBORU parser. Adapted from keiyoushi's MyHentaiGallery (Apache-2.0).

local U = Engines.util
local BASE = "https://myhentaigallery.com"

local p = U.newParser({id = "OTAKIO_MYHENTAIGALLERY", name = "MyHentaiGallery", baseUrl = BASE, lang = "en", version = 1, nsfw = true, engine = "native"}, {})

local function H()
	return {Referer = BASE .. "/"}
end

local function list(url, dt)
	local doc = Http.getDocument(url, H())
	local count = 0
	for _, card in ipairs(doc:select("div.comic-inner")) do
		local a = card:selectFirst("a")
		local h2 = card:selectFirst("h2")
		local img = card:selectFirst("img")
		local cover = img and img:attr("abs:src") or ""
		if a and h2 and U.addManga(dt, p, h2:text(), a:attr("abs:href"), cover ~= "" and Http.image(cover, BASE .. "/") or nil) then
			count = count + 1
		end
	end
	dt.NoPages = count == 0 or doc:selectFirst("li.next") == nil
end

function p:getPopularManga(page, dt)
	list(BASE .. "/views/" .. page, dt)
end

function p:getLatestManga(page, dt)
	list(BASE .. "/gpage/" .. page, dt)
end

function p:searchManga(query, page, dt)
	list(BASE .. "/search/" .. page .. "?query=" .. Http.encode(Engines.decodeSearch(query)), dt)
end

function p:getChapters(manga, dt)
	local url = U.absolute(BASE, manga.Link)
	local doc = Http.getDocument(url, H())
	local info = doc:selectFirst("div.comic-header")
	local fields = {}
	for _, div in ipairs(info and info:select("div") or {}) do
		local label = string.lower(U.trim(div:ownText()))
		local vals = {}
		for _, a in ipairs(div:select("a")) do
			vals[#vals + 1] = U.trim(a:text())
		end
		if #vals > 0 then
			fields[label] = vals
		end
	end
	local function field(name)
		for label, vals in pairs(fields) do
			if string.find(label, name, 1, true) then
				return vals
			end
		end
		return {}
	end
	local extra = {}
	for _, name in ipairs({"parodies", "groups"}) do
		local vals = field(name)
		if #vals > 0 then
			extra[#extra + 1] = name:gsub("^%l", string.upper) .. ": " .. table.concat(vals, ", ")
		end
	end
	dt.Description = Engines.buildInfo({Author = table.concat(field("artists"), ", "), Genres = field("categories"), Status = "Completed"}, table.concat(extra, "\n"))
	dt[1] = {Name = "Chapter", Link = U.pathOf(url), Pages = {}, Manga = manga}
end

function p:prepareChapter(chapter, dt)
	local doc = Http.getDocument(U.absolute(BASE, chapter.Link), H())
	for _, img in ipairs(doc:select("div.comic-thumb img[src]")) do
		local src = string.gsub(img:attr("abs:src"), "/thumbnail/", "/original/")
		if src ~= "" then
			dt[#dt + 1] = Http.image(src, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
