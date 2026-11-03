-- Otakio extension (generated from keiyoushi/extensions-source: pt/pinkrosa)
Engines.ZeistManga {
	id = "KEI_PTBRPINKROSA",
	name = "Pink Rosa",
	baseUrl = "https://scanpinkrosa.blogspot.com",
	lang = "pt-BR",
	version = 3,
	nsfw = false,
	extension = "kei.pt.pinkrosa",
	mangaDetailsSelector = "#main",
	mangaDetailsSelectorAuthor = "#tauther",
	mangaDetailsSelectorDescription = "#syn_bod",
	mangaDetailsSelectorGenres = "a[href*=label][rel]",
	mangaDetailsSelectorStatus = "div[class*=bg-green] span",
	mangaDetailsSelectorThumbnail = ".hidden img",
	pageListSelector = "div.separator",
	supportsLatest = false,
}
