-- @id otakio.hentaiera
-- @name HentaiEra
-- @lang en
-- @version 1
-- @nsfw true
-- @baseUrl https://hentaiera.com
-- Native Otakio extension: HentaiEra (GalleryAdults engine, English galleries).
-- Adapted from keiyoushi's HentaiEra (Apache-2.0).

return Engines.GalleryAdults({
	id = "OTAKIO_HENTAIERA", name = "HentaiEra", baseUrl = "https://hentaiera.com", lang = "en", version = 1, nsfw = true,
	popularPath = "/language/english/popular/?page={page}",
	latestPath = "/language/english/?page={page}",
	searchPath = "/search/?key={q}&page={page}",
	titleSel = ".gallery_title",
	detailSel = ".gallery_first", coverSel = ".left_cover img",
	tagsSel = "a[href^='/tag/']", artistsSel = "a[href^='/artist/']", parodiesSel = "a[href^='/parody/']", tagNameSel = ".item_name",
	thumbSel = ".gthumb img", pageUri = "view"
})
