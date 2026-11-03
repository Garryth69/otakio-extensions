-- Otakio extension (generated from keiyoushi/extensions-source: en/artlapsa)
Engines.Keyoapp {
	id = "KEI_ENARTLAPSA",
	name = "Art Lapsa",
	baseUrl = "https://artlapsa.com",
	lang = "en",
	version = 8,
	nsfw = false,
	extension = "kei.en.artlapsa",
	altNameSelector = "details[data-testid=series-other-names] li.select-all",
	artistSelector = "dt:contains(Artist) + dd",
	authorSelector = "dt:contains(Author) + dd",
	genreSelector = "div:has(>h1) a[href*='/genres/']",
	latestUpdatesNextPageSelector = "a[href*='?page=']",
	paidChapterSelector = "img[alt~=Coin], img[src*=star-circle]",
	searchMangaSelector = "main#main-content [wire:key*='serie']",
	statusSelector = "a[aria-label=Status]",
	typeSelector = "a[aria-label=Type]",
}
