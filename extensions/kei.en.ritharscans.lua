-- Otakio extension (generated from keiyoushi/extensions-source: en/ritharscans)
Engines.Keyoapp {
	id = "KEI_ENRITHARSCANS",
	name = "RitharScans",
	baseUrl = "https://ritharscans.com",
	lang = "en",
	version = 6,
	nsfw = false,
	extension = "kei.en.ritharscans",
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
