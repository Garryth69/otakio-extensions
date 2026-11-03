-- Otakio extension (generated from keiyoushi/extensions-source: pt/temakimangas)
Engines.ZeistManga {
	id = "KEI_PTBRTEMAKIMANGAS",
	name = "Temaki mangás",
	baseUrl = "https://temakimangas.blogspot.com",
	lang = "pt-BR",
	version = 1,
	nsfw = true,
	extension = "kei.pt.temakimangas",
	mangaDetailsSelector = "header",
	mangaDetailsSelectorGenres = "dt:contains(Genre) + dd a",
	mangaDetailsSelectorStatus = "[data-status]",
	mangaDetailsSelectorThumbnail = ".thumb",
	pageListSelector = "#reader div.separator",
	popularMangaSelector = "#PopularPosts2 article",
	popularMangaSelectorTitle = "h3",
	popularMangaSelectorUrl = "h3 a",
}
