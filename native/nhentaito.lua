-- @id otakio.nhentaito
-- @name nhentai.to
-- @lang en
-- @version 1
-- @nsfw true
-- @baseUrl https://nhentai.to
-- Native Otakio extension: nhentai.to (GalleryAdults engine, English galleries).
-- Adapted from keiyoushi's NHentai.to (Apache-2.0).

return Engines.GalleryAdults({
	id = "OTAKIO_NHENTAITO", name = "nhentai.to", baseUrl = "https://nhentai.to", lang = "en", version = 1, nsfw = true,
	popularPath = "/search?q=*&sort=most-favorited&lang=english&page={page}",
	latestPath = "/search?q=*&sort=newest&lang=english&page={page}",
	searchPath = "/search?q={q}&lang=english&page={page}",
	itemSel = "div.gallery", linkSel = "a.cover", titleSel = ".caption", imgSel = "img", nextSel = "a.next",
	detailSel = "#bigcontainer", coverSel = "#cover img",
	tagsSel = "a[href^='/tag/']", artistsSel = "a[href^='/artist/']", parodiesSel = "a[href^='/parody/']", tagNameSel = ".name",
	thumbSel = "#thumbnail-container .thumb-container img",
	countPattern = "Pages:%s*<span class=\"tags\">%s*<a[^>]*>%s*<span class=\"name\">(%d+)"
})
