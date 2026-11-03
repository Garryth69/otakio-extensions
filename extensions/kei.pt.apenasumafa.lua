-- Otakio extension (generated from keiyoushi/extensions-source: pt/apenasumafa)
Engines.ZeistManga {
	id = "KEI_PTBRAPENASUMAFA",
	name = "Apenas Uma Fã",
	baseUrl = "https://apenasuma-fa.blogspot.com",
	lang = "pt-BR",
	version = 2,
	nsfw = false,
	extension = "kei.pt.apenasumafa",
	mangaDetailsSelector = "#main",
	mangaDetailsSelectorArtist = "span#tartist",
	mangaDetailsSelectorAuthor = "span#tauther",
	mangaDetailsSelectorDescription = "#syn_bod",
	mangaDetailsSelectorGenres = "a[href*='search/label'].leading-none",
	mangaDetailsSelectorStatus = "div[class*=bg-green] span",
	mangaDetailsSelectorThumbnail = ".hidden img",
	pageListSelector = "#reader div.separator",
	supportsLatest = false,
}
