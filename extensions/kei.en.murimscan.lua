-- Otakio extension (generated from keiyoushi/extensions-source: en/murimscan)
Engines.ZeistManga {
	id = "KEI_ENMURIMSCAN",
	name = "MurimScan",
	baseUrl = "https://www.murimscans.site",
	lang = "en",
	version = 37,
	nsfw = false,
	extension = "kei.en.murimscan",
	mangaDetailsSelector = "main",
	mangaDetailsSelectorGenres = "dl.flex:contains(Genre) a[rel=tag], dl.flex:contains(Type) a[rel=tag]",
	mangaDetailsSelectorInfo = "dl.flex",
	mangaDetailsSelectorInfoDescription = "dd",
	mangaDetailsSelectorInfoTitle = "dt",
	pageListSelector = ".post-body, .check-box",
	supportsLatest = false,
}
