-- @id otakio.asmhentai
-- @name AsmHentai
-- @lang en
-- @version 1
-- @nsfw true
-- @baseUrl https://asmhentai.com
-- Native Otakio extension: AsmHentai (GalleryAdults engine, English galleries).
-- Adapted from keiyoushi's AsmHentai (Apache-2.0).

return Engines.GalleryAdults({
	id = "OTAKIO_ASMHENTAI", name = "AsmHentai", baseUrl = "https://asmhentai.com", lang = "en", version = 1, nsfw = true,
	popularPath = "/language/english/popular/?page={page}",
	latestPath = "/language/english/?page={page}",
	searchPath = "/search/?q={q}&page={page}",
	itemSel = ".preview_item", linkSel = ".image a", imgSel = ".image img", titleSel = ".caption",
	detailSel = ".book_page", tagsSel = "a[href^='/tag/']", artistsSel = "a[href^='/artist/']", parodiesSel = "a[href^='/parody/']", tagNameSel = ".tag",
	thumbSel = ".preview_thumb img", pageUri = "gallery", totalId = "t_pages", galleryId = "load_id"
})
