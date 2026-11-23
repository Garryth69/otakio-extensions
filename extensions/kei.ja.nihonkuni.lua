-- Otakio extension (generated from keiyoushi/extensions-source: ja/nihonkuni)
Engines.FMReader {
	id = "KEI_JANIHONKUNI",
	name = "NihonKuni",
	baseUrl = "https://nihonkuni.com",
	lang = "ja",
	version = 4,
	nsfw = false,
	extension = "kei.ja.nihonkuni",
	altName = "Alternative Name: ",
	altNameSelector = "li:has(.fa-clone) .info-field-value",
	infoElementSelector = "div.manga-detail-container",
	mangaDetailsSelectorDescription = ".description-text-content",
	mangaDetailsSelectorGenre = "li:has(.fa-tags) a.btn-danger",
	mangaDetailsSelectorThumbnail = "img.manga-cover-image",
	popularMangaNextPageSelector = ".page-link.next",
	popularMangaSelector = "div.manga-grid div.manga-card",
}
