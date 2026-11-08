-- @id otakio.hentaienvy
-- @name HentaiEnvy
-- @lang en
-- @version 1
-- @nsfw true
-- @baseUrl https://hentaienvy.com
-- Native Otakio extension: HentaiEnvy (GalleryAdults engine, English galleries).
-- Adapted from keiyoushi's HentaiEnvy (Apache-2.0).

return Engines.GalleryAdults({
	id = "OTAKIO_HENTAIENVY", name = "HentaiEnvy", baseUrl = "https://hentaienvy.com", lang = "en", version = 1, nsfw = true,
	popularPath = "/language/english/popular/?page={page}",
	latestPath = "/language/english/?page={page}",
	searchPath = "/search/?key={q}&page={page}",
	itemSel = ".hnv-gallery-card", linkSel = "a.hnv-gallery-card__cover", imgSel = "a.hnv-gallery-card__cover img", titleSel = ".hnv-gallery-card__title",
	detailSel = "body", coverSel = ".hnv-gallery-cover img",
	tagsSel = "a.hnv-gallery-tag[href^='/tag/']", artistsSel = "a.hnv-gallery-tag[href^='/artist/']", parodiesSel = "a.hnv-gallery-tag[href^='/parody/']", tagNameSel = ".hnv-gallery-tag__name",
	thumbSel = ".hnv-gallery-thumb img"
})
