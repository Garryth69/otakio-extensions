-- @id otakio.hentaifox
-- @name HentaiFox
-- @lang en
-- @version 1
-- @nsfw true
-- @baseUrl https://hentaifox.com
-- Native Otakio extension: HentaiFox (GalleryAdults engine, English galleries).
-- Adapted from keiyoushi's HentaiFox (Apache-2.0).

return Engines.GalleryAdults({
	id = "OTAKIO_HENTAIFOX", name = "HentaiFox", baseUrl = "https://hentaifox.com", lang = "en", version = 1, nsfw = true,
	popularPath = "/language/english/popular/pag/{page}/",
	latestPath = "/language/english/pag/{page}/",
	searchPath = "/search/?q={q}+english&page={page}",
	tagsSel = "ul.tags a", artistsSel = "ul.artists a", parodiesSel = "ul.parodies a"
})
