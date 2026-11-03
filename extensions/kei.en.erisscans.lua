-- Otakio extension (generated from keiyoushi/extensions-source: en/erisscans)
Engines.Keyoapp {
	id = "KEI_ENERISSCANS",
	name = "Eris Scans",
	baseUrl = "https://erisscans.com",
	lang = "en",
	version = 1,
	nsfw = false,
	extension = "kei.en.erisscans",
	altNameSelector = "div.font-medium:containsOwn(Alternative titles) ~ div span.select-all",
	artistSelector = "div[alt=Artist]",
	authorSelector = "div[alt=Author]",
	statusSelector = "div[alt=Status]",
	typeSelector = "div[alt='Series Type']",
}
