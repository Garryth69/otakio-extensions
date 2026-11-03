-- @id otakio.hqnow
-- @name HQ Now
-- @lang pt-BR
-- @version 1
-- @nsfw false
-- @baseUrl https://www.hq-now.com
-- Native Otakio extension: HQ Now (comics/HQs in Brazilian Portuguese, GraphQL API).

local U = Engines.util
local BASE = "https://www.hq-now.com"
local GRAPHQL = "https://admin.hq-now.com/graphql"

local p = U.newParser({id = "OTAKIO_HQNOW", name = "HQ Now", baseUrl = BASE, lang = "pt-BR", version = 1, engine = "native"}, {})

local function query(operation, q, variables)
	local body = Http.post(GRAPHQL, {operationName = operation, query = q, variables = variables}, {Referer = BASE .. "/", Origin = BASE}, "json")
	coroutine.yield(false)
	local data = Json.decode(body, 2000)
	return type(data) == "table" and type(data.data) == "table" and data.data[operation] or {}
end

local function slug(s)
	return (string.gsub(string.gsub(string.lower(s or ""), "[^%w]+", "-"), "^%-+", ""))
end

local function addList(dt, list)
	for _, hq in ipairs(list) do
		local cover = hq.hqCover ~= Json.null and hq.hqCover or nil
		U.addManga(dt, p, hq.name or "", "/hq/" .. tostring(hq.id) .. "/" .. slug(hq.name), cover)
	end
	dt.NoPages = true
end

function p:getPopularManga(page, dt)
	addList(dt, query("getHqsByFilters", [[
query getHqsByFilters($orderByViews: Boolean, $limit: Int, $loadCovers: Boolean) {
  getHqsByFilters(orderByViews: $orderByViews, limit: $limit, loadCovers: $loadCovers) { id name hqCover }
}]], {orderByViews = true, loadCovers = true, limit = 300}))
end

function p:getLatestManga(page, dt)
	addList(dt, query("getRecentlyUpdatedHqs", "query getRecentlyUpdatedHqs { getRecentlyUpdatedHqs { id name hqCover } }"))
end

function p:searchManga(q, page, dt)
	addList(dt, query("getHqsByName", "query getHqsByName($name: String!) { getHqsByName(name: $name) { id name } }", {name = Engines.decodeSearch(q)}))
end

function p:getChapters(manga, dt)
	local id = tonumber(string.match(manga.Link, "/hq/(%d+)"))
	if not id then
		return
	end
	local hq = query("getHqsById", [[
query getHqsById($id: Int!) {
  getHqsById(id: $id) { id name synopsis status publisherName hqCover capitulos { name id number } }
}]], {id = id})[1]
	if not hq then
		return
	end
	local nn = function(v)
		return v ~= Json.null and v or nil
	end
	dt.Description = Engines.buildInfo({Author = nn(hq.publisherName), Status = nn(hq.status)}, nn(hq.synopsis) or "")
	if nn(hq.hqCover) then
		manga.NewImageLink = hq.hqCover
	end
	-- the API lists chapters oldest first, as Otakio stores them
	for _, c in ipairs(hq.capitulos or {}) do
		local name = "#" .. tostring(c.number)
		if nn(c.name) and c.name ~= "" then
			name = name .. " - " .. c.name
		end
		dt[#dt + 1] = {Name = name, Link = "/hq-reader/" .. hq.id .. "/" .. slug(hq.name) .. "/chapter/" .. tostring(c.id) .. "/page/1", Pages = {}, Manga = manga}
	end
end

function p:prepareChapter(chapter, dt)
	local id = tonumber(string.match(chapter.Link, "/chapter/(%d+)"))
	local c = id and query("getChapterById", "query getChapterById($chapterId: Int!) { getChapterById(chapterId: $chapterId) { pictures { pictureUrl } } }", {chapterId = id}) or {}
	for _, pic in ipairs(c.pictures or {}) do
		if type(pic.pictureUrl) == "string" then
			dt[#dt + 1] = Http.image(pic.pictureUrl, BASE .. "/")
		end
	end
end

function p:loadChapterPage(link, dt)
	dt.Link = link
end
