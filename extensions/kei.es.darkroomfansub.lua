-- Otakio extension (generated from keiyoushi/extensions-source: es/darkroomfansub)
Engines.ZeistManga {
	id = "KEI_ESDARKROOMFANSUB",
	name = "Dark Room Fansub",
	baseUrl = "https://lector-darkroomfansub.blogspot.com",
	lang = "es",
	version = 3,
	nsfw = true,
	extension = "kei.es.darkroomfansub",
	mangaDetailsSelector = "#main",
	mangaDetailsSelectorDescription = "#synopsis",
	mangaDetailsSelectorGenres = "a[rel=tag]",
	mangaDetailsSelectorInfo = "#extra-info > dl",
	mangaDetailsSelectorInfoDescription = "dd",
	mangaDetailsSelectorInfoTitle = "dt",
	pageListSelector = "article#reader div.separator",
	supportsLatest = false,
}
