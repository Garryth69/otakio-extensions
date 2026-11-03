-- Otakio extension (generated from keiyoushi/extensions-source: en/kitsunedawn)
Engines.Keyoapp {
	id = "KEI_ENKITSUNEDAWN",
	name = "Kitsune Dawn",
	baseUrl = "https://kitsunedawn.com",
	lang = "en",
	version = 1,
	nsfw = true,
	extension = "kei.en.kitsunedawn",
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
