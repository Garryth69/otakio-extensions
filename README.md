# Otakio Extensions

Repositório de **extensões (fontes)** para o [Otakio](https://github.com/Garryth69/otakio), leitor de mangá para PS
Vita. O app não vem com nenhuma fonte: elas são instaladas a partir deste repositório, dentro do próprio app.

> *English:* Source extensions for the Otakio manga reader (PS Vita). Add this repository in the app
> (Extensions → Select → Add repository → `Garryth69/otakio-extensions`). No content is hosted here: each extension
> is a small Lua script that reads a third-party website on the user's console.

## Como usar no Vita

1. Instale o Otakio ([Releases do app](https://github.com/Garryth69/otakio/releases)).
2. No app, abra **Extensões** e aperte **Select** → **Adicionar repositório**.
3. Digite `Garryth69/otakio-extensions` e confirme.
4. Na aba **Disponíveis**, escolha o idioma com **Start** e instale as fontes com **X**.

O app procura atualizações deste repositório ao abrir: quando uma extensão muda de versão aqui, a aba
**Atualizações** do app avisa e atualiza com um clique.

> Enquanto este repositório estiver **privado**, o Vita não consegue baixá-lo (o GitHub exige login para conteúdo
> privado). Ele passa a funcionar no app quando for tornado público.

## Aviso legal

- **Nenhum conteúdo é hospedado aqui.** Cada extensão é um script que, no console do usuário, lê páginas públicas de
  um site de terceiros, como um navegador faria.
- Este projeto não tem afiliação com os sites listados, nem com editoras ou autores. Os nomes dos sites são usados
  apenas para identificar de onde a extensão lê.
- Nenhuma extensão contorna proteções anti-bot (Cloudflare etc.), paywalls ou logins. Sites que exigem isso ficam
  marcados como fora do ar.
- **Pedidos de remoção:** se você é responsável por um site ou obra e quer que a extensão correspondente seja
  removida, abra uma issue neste repositório. Ela será retirada.
- Apoie os autores: compre as edições oficiais e use os serviços oficiais.

## Resumo

| Idioma | Fontes | 🟢 funcionando |
|---|---:|---:|
| Multi-idioma | 10 | 5 |
| Inglês | 186 | 117 |
| Português (Brasil) | 42 | 31 |
| Espanhol | 56 | 30 |
| Francês | 18 | 9 |
| Italiano | 13 | 7 |
| **Total** | **325** | **199** |

Status: **🟢 funciona** (lista, capítulos e páginas testados) · **🟡 parcial** (algo falha) · **🔴 fora do ar**
(o site não responde ou bloqueia leitores) · **⚪ não testada**. O status abaixo vem do último teste automático
(`health.json`); no Vita, a bolinha de cada fonte também se ajusta sozinha conforme o uso.

## Fontes


### Multi-idioma (10)

| Fonte | Site | Status | Tipo | +18 |
|---|---|---|---|:---:|
| Comics Kingdom | wp.comicskingdom.com | 🟢 funciona | nativa (Otakio) |  |
| Grabber Zone | grabber.zone | 🟢 funciona | tema keiyoushi |  |
| MangaCrazy | mangacrazy.net | 🟢 funciona | tema keiyoushi | sim |
| MangaDex | mangadex.org | 🟢 funciona | nativa (Otakio) |  |
| Webtoons | www.webtoons.com | 🟢 funciona | nativa (Otakio) |  |
| HentaiRead | hentairead.com | ⚪ não testada | parser NOBORU | sim |
| nhentai | nhentai.to | ⚪ não testada | parser NOBORU | sim |
| AllPornComics.co | allporncomics.co | 🔴 fora do ar | tema keiyoushi | sim |
| Comics Valley | comicsvalley.com | 🔴 fora do ar | tema keiyoushi | sim |
| Manhwa-raw | manhwa-raw.com | 🔴 fora do ar | tema keiyoushi | sim |

### Inglês (186)

| Fonte | Site | Status | Tipo | +18 |
|---|---|---|---|:---:|
| 4PornComic | 4porncomic.com | 🟢 funciona | tema keiyoushi | sim |
| Akaza Scans | akazascans.org | 🟢 funciona | tema keiyoushi |  |
| AllPornComic.io | allporncomic.io | 🟢 funciona | tema keiyoushi | sim |
| AP Comics | apcomics.org | 🟢 funciona | tema keiyoushi | sim |
| Aqua Manga | aquareader.org | 🟢 funciona | tema keiyoushi |  |
| Arena Scans | arenascan.com | 🟢 funciona | tema keiyoushi |  |
| Aster Scans | asterscans.com | 🟢 funciona | tema keiyoushi |  |
| Asura Scans | asurascans.com | 🟢 funciona | nativa (Otakio) |  |
| Athrea Scans | athreascans.com | 🟢 funciona | tema keiyoushi |  |
| Battle In 5 Seconds After Meeting | www.deatte5.com | 🟢 funciona | tema keiyoushi |  |
| Bun Manga | bunmanga.com | 🟢 funciona | tema keiyoushi |  |
| Cocomic | cocomic.co | 🟢 funciona | tema keiyoushi |  |
| Cucumber Manga | cucumbermanga.com | 🟢 funciona | tema keiyoushi | sim |
| Danke fürs Lesen | danke.moe | 🟢 funciona | tema keiyoushi |  |
| Decadence Scans | reader.decadencescans.com | 🟢 funciona | tema keiyoushi |  |
| Diva Scans | divascans.org | 🟢 funciona | tema keiyoushi |  |
| Drake Scans | drakecomic.net | 🟢 funciona | tema keiyoushi |  |
| Elf Toon | elftoon.net | 🟢 funciona | tema keiyoushi |  |
| Eva Scans | evascans.net | 🟢 funciona | tema keiyoushi |  |
| Flame Comics | flamecomics.xyz | 🟢 funciona | nativa (Otakio) |  |
| Frieren Online | www.frieren.online | 🟢 funciona | tema keiyoushi |  |
| GakaMangas | gakamangas.com | 🟢 funciona | tema keiyoushi |  |
| GalaxyDegenScans | gdscans.com | 🟢 funciona | tema keiyoushi |  |
| GEDE Comix | gedecomix.com | 🟢 funciona | tema keiyoushi | sim |
| Grim Scans | grimscans.com | 🟢 funciona | tema keiyoushi |  |
| Guya | guya.cubari.moe | 🟢 funciona | tema keiyoushi |  |
| Hachirumi | hachirumi.com | 🟢 funciona | tema keiyoushi |  |
| Hentai Desi | hentaidesi.com | 🟢 funciona | tema keiyoushi | sim |
| Hentai1.io | hentai1.io | 🟢 funciona | tema keiyoushi | sim |
| Hentai20 | hentai20.io | 🟢 funciona | tema cursed | sim |
| Hentai20 (Unoriginal) | hentai20.lol | 🟢 funciona | tema keiyoushi | sim |
| HentaiXComic | hentaixcomic.com | 🟢 funciona | tema keiyoushi | sim |
| HentaiXDickgirl | hentaixdickgirl.com | 🟢 funciona | tema keiyoushi | sim |
| HentaiXYuri | hentaixyuri.com | 🟢 funciona | tema keiyoushi | sim |
| HM2D | doujindistrict.com | 🟢 funciona | tema keiyoushi | sim |
| Hunlight Comics | hunlightcomics.com | 🟢 funciona | tema keiyoushi |  |
| Jinmangas | mangafree.info | 🟢 funciona | tema keiyoushi |  |
| Kayn Scans | kaynscans.com | 🟢 funciona | tema keiyoushi |  |
| KeroScans | keroscans.net | 🟢 funciona | tema keiyoushi |  |
| Kewn Scans | kewnscans.org | 🟢 funciona | tema keiyoushi |  |
| Kingofshojo | kingofshojo.com | 🟢 funciona | tema codegeasse |  |
| KokoMangas | kokomangas.com | 🟢 funciona | tema keiyoushi |  |
| KSGroupScans | ksgroupscans.com | 🟢 funciona | tema keiyoushi |  |
| Lagoon Scans | lagoonscans.com | 🟢 funciona | tema keiyoushi |  |
| LHTranslation | lhtranslation.net | 🟢 funciona | tema keiyoushi |  |
| Lily Manga | lilymanga.net | 🟢 funciona | tema keiyoushi |  |
| Linkmanga | linkmanga.com | 🟢 funciona | tema codegeasse |  |
| Lovesjane Scans | lovesjane.site | 🟢 funciona | tema keiyoushi |  |
| Lua Scans | luacomic.org | 🟢 funciona | tema keiyoushi |  |
| Madara Scans | madarascans.net | 🟢 funciona | tema keiyoushi |  |
| Manga Dass | mangadass.com | 🟢 funciona | tema keiyoushi |  |
| Manga District | mangadistrict.com | 🟢 funciona | tema keiyoushi |  |
| Manga Eclipse | mangaeclipse.com | 🟢 funciona | tema keiyoushi |  |
| Manga Trend | mangatrend.org | 🟢 funciona | tema keiyoushi |  |
| Manga18Free | manga18free.com | 🟢 funciona | tema keiyoushi | sim |
| Mangaforfree.com | mangaforfree.com | 🟢 funciona | tema keiyoushi | sim |
| MangaK | mangak.io | 🟢 funciona | tema keiyoushi |  |
| Mangakakalot | www.kakamanga.com | 🟢 funciona | nativa (Otakio) |  |
| MangaManiacs | mangamaniacs.org | 🟢 funciona | tema codegeasse | sim |
| MangaOwl.io (unoriginal) | mangaowl.io | 🟢 funciona | tema keiyoushi |  |
| MangaPark.tv (unoriginal) | mangapark.tv | 🟢 funciona | tema keiyoushi | sim |
| Mangapill | mangapill.com | 🟢 funciona | nativa (Otakio) |  |
| MangaRead.org | www.mangaread.org | 🟢 funciona | tema keiyoushi |  |
| Mangasushi | mangasushi.org | 🟢 funciona | tema keiyoushi |  |
| Manhua Plus | manhuaplus.com | 🟢 funciona | tema keiyoushi |  |
| ManhuaHot | manhuahot.com | 🟢 funciona | tema keiyoushi |  |
| Manhuanext | manhuanext.com | 🟢 funciona | tema keiyoushi |  |
| Manhwa Reads | manhwareads.com | 🟢 funciona | tema keiyoushi |  |
| Manhwa Toon | www.manhwatoon.me | 🟢 funciona | tema keiyoushi |  |
| Manhwa18TX | manhwa18tx.com | 🟢 funciona | tema keiyoushi |  |
| ManhwaBuddy | manhwabuddy.com | 🟢 funciona | tema keiyoushi |  |
| Manhwaddict | manhwaddict.com | 🟢 funciona | tema keiyoushi |  |
| ManhwaDen | www.manhwaden.com | 🟢 funciona | tema keiyoushi | sim |
| ManhwaGalaxy | manhwagalaxy.com | 🟢 funciona | tema keiyoushi |  |
| ManhwaHub.to | manhwahub.to | 🟢 funciona | tema keiyoushi | sim |
| ManhwaNex | manhwanex.com | 🟢 funciona | tema keiyoushi |  |
| ManhwaOnline | manhwaonline.org | 🟢 funciona | tema keiyoushi |  |
| ManhwaUS | manhwaus.net | 🟢 funciona | tema keiyoushi | sim |
| MurimScan | www.murimscans.site | 🟢 funciona | tema keiyoushi |  |
| MyReadingComic | myreadingcomic.com | 🟢 funciona | tema keiyoushi | sim |
| OctopusManga | octopusmanga.com | 🟢 funciona | tema keiyoushi | sim |
| Omega Scans | omegascans.org | 🟢 funciona | tema keiyoushi | sim |
| Orchisasia | www.orchisasia.org | 🟢 funciona | tema keiyoushi | sim |
| Paritehaber | www.paritehaber.com | 🟢 funciona | tema keiyoushi | sim |
| Petrotechsociety | www.petrotechsociety.org | 🟢 funciona | tema keiyoushi | sim |
| Pornhwaz | www.pornhwaz.com | 🟢 funciona | tema keiyoushi | sim |
| Rackus | rackusreads.com | 🟢 funciona | tema keiyoushi |  |
| Read Berserk Manga | readberserk.com | 🟢 funciona | tema keiyoushi |  |
| Read Chainsaw Man Manga Online | ww6.readchainsawman.com | 🟢 funciona | tema keiyoushi | sim |
| Read Fairy Tail & Edens Zero Manga Online | ww9.readfairytail.com | 🟢 funciona | tema keiyoushi |  |
| Read Jujutsu Kaisen Manga Online | ww6.readjujutsukaisen.com | 🟢 funciona | tema keiyoushi |  |
| Read Kingdom Manga Online | ww6.readkingdom.com | 🟢 funciona | tema keiyoushi |  |
| Read Nanatsu no Taizai 7 Deadly Sins Manga Online | ww8.read7deadlysins.com | 🟢 funciona | tema keiyoushi |  |
| Read One Piece Manga Online | ww13.readonepiece.com | 🟢 funciona | tema keiyoushi |  |
| Read One-Punch Man Manga Online | ww7.readopm.com | 🟢 funciona | tema keiyoushi |  |
| Read Solo Leveling Manga Manhwa Online | ww4.readsololeveling.org | 🟢 funciona | tema keiyoushi |  |
| Read Tokyo Ghoul Re & Tokyo Ghoul Manga Online | ww12.tokyoghoulre.com | 🟢 funciona | tema keiyoushi |  |
| ReadManga18 | readmanga18.com | 🟢 funciona | tema keiyoushi | sim |
| Rizz Comic | rizzfables.com | 🟢 funciona | tema keiyoushi |  |
| RokariComics | rokaricomics.com | 🟢 funciona | tema keiyoushi |  |
| Ruby Comics | rubycomics.net | 🟢 funciona | tema keiyoushi | sim |
| S2Manga | s2read.com | 🟢 funciona | tema keiyoushi |  |
| Scythe Scans | scythescans.com | 🟢 funciona | tema keiyoushi |  |
| SeraphicDeviltry | seraphic-deviltry.com | 🟢 funciona | tema keiyoushi | sim |
| Thunder Scans | en-thunderscans.com | 🟢 funciona | tema keiyoushi |  |
| ToonGod (Unoriginal) | toongod.cc | 🟢 funciona | tema keiyoushi |  |
| Toonily.me | toontop.io | 🟢 funciona | tema keiyoushi | sim |
| Toonizy | toonizy.com | 🟢 funciona | tema keiyoushi |  |
| Top Manhua | mangatop.org | 🟢 funciona | tema keiyoushi |  |
| TritiniaScans | tritinia.org | 🟢 funciona | tema keiyoushi |  |
| Valir Scans | valirscans.org | 🟢 funciona | tema keiyoushi |  |
| Violet Scans | violetmanga.com | 🟢 funciona | tema keiyoushi |  |
| Weeb Central | weebcentral.com | 🟢 funciona | nativa (Otakio) |  |
| WitchScans | witchtoons.net | 🟢 funciona | tema keiyoushi |  |
| Writer Scans | writerscans.com | 🟢 funciona | tema keiyoushi |  |
| WuxiaWorld | wuxiaworld.site | 🟢 funciona | tema keiyoushi |  |
| YakshaComics | yakshacomics.com | 🟢 funciona | tema keiyoushi |  |
| Art Lapsa | artlapsa.com | 🟡 parcial | tema keiyoushi |  |
| Death Toll Scans | reader.deathtollscans.net | 🟡 parcial | tema keiyoushi |  |
| Eris Scans | erisscans.com | 🟡 parcial | tema keiyoushi |  |
| Genz Toons | genztoons.org | 🟡 parcial | tema keiyoushi |  |
| Hentai4Free | hentai4free.net | 🟡 parcial | tema keiyoushi | sim |
| KaliScan.org (unoriginal) | kaliscan.org | 🟡 parcial | tema keiyoushi |  |
| Kitsune Dawn | kitsunedawn.com | 🟡 parcial | tema keiyoushi | sim |
| Kun Manga Online | www.kunmanga.online | 🟡 parcial | tema keiyoushi |  |
| MadaraDex | madaradex.org | 🟡 parcial | tema keiyoushi |  |
| Manga 18x | manga18x.net | 🟡 parcial | tema keiyoushi | sim |
| Manhwa Comics | manhwacomics.com | 🟡 parcial | tema keiyoushi | sim |
| Mist Scans | mistscans.com | 🟡 parcial | tema keiyoushi |  |
| Nyanu Kafe | nyanukafe.com | 🟡 parcial | tema keiyoushi |  |
| Read Attack on Titan Shingeki no Kyojin Manga | ww12.readsnk.com | 🟡 parcial | tema keiyoushi |  |
| Read Black Clover Manga Online | ww10.readblackclover.com | 🟡 parcial | tema keiyoushi |  |
| RitharScans | ritharscans.com | 🟡 parcial | tema keiyoushi |  |
| Rose Squad Scans | rosesquadscans.aishiteru.org | 🟡 parcial | tema keiyoushi | sim |
| TimelessToons | timelesstoons.org | 🟡 parcial | tema keiyoushi |  |
| TopManhua.fan | www.topmanhua.fan | 🟡 parcial | tema keiyoushi |  |
| TopManhua.net | topmanhua.net | 🟡 parcial | tema keiyoushi |  |
| Zazamanga | www.zazamanga.com | 🟡 parcial | tema keiyoushi |  |
| Zinmanga | mangazin.org | 🟡 parcial | tema keiyoushi |  |
| Zinmanga.net | www.zinmanga.net | 🟡 parcial | tema keiyoushi |  |
| Hentai20 | hentai20.com | ⚪ não testada | parser NOBORU | sim |
| MangaHub | mangahub.io | ⚪ não testada | parser NOBORU |  |
| MangaTown | www.mangatown.com | ⚪ não testada | parser NOBORU |  |
| MyHentaiGallery | myhentaigallery.com | ⚪ não testada | parser NOBORU | sim |
| ReadComicsOnline | readcomicsonline.ru | ⚪ não testada | parser NOBORU |  |
| Readm | readm.today | ⚪ não testada | parser NOBORU |  |
| Reaper Scans | reaperscans.com | ⚪ não testada | parser NOBORU |  |
| AllPornComic | allporncomic.com | 🔴 fora do ar | tema keiyoushi | sim |
| Asmodeus Scans | asmotoon.com | 🔴 fora do ar | tema keiyoushi |  |
| Borat Scans | boratscans.com | 🔴 fora do ar | tema keiyoushi |  |
| BrainRotComics | brainrotcomics.com | 🔴 fora do ar | tema keiyoushi |  |
| CartoonPorn | cartoonporn.to | 🔴 fora do ar | tema keiyoushi | sim |
| Comic Asura | comicasura.net | 🔴 fora do ar | tema keiyoushi |  |
| DragonTea | dragontea.ink | 🔴 fora do ar | tema keiyoushi |  |
| Ero18x | ero18x.com | 🔴 fora do ar | tema keiyoushi | sim |
| GingeRTooN | gingertoon.com | 🔴 fora do ar | tema keiyoushi | sim |
| Gourmet Scans | gourmetsupremacy.com | 🔴 fora do ar | tema keiyoushi |  |
| Hades Scans | hadesscans.com | 🔴 fora do ar | tema keiyoushi |  |
| Kaizen Scan | kaizenscan.com | 🔴 fora do ar | tema keiyoushi | sim |
| Kissmanga.in | kissmanga.in | 🔴 fora do ar | tema keiyoushi |  |
| Lgbtics | lgbtics.com | 🔴 fora do ar | tema keiyoushi | sim |
| Luna Toons | lunatoons.net | 🔴 fora do ar | tema keiyoushi |  |
| MangaGG | mangagg.com | 🔴 fora do ar | tema keiyoushi |  |
| Mangatellers | reader.mangatellers.gr | 🔴 fora do ar | tema keiyoushi |  |
| Manhua Zonghe | www.manhuazonghe.com | 🔴 fora do ar | tema keiyoushi | sim |
| ManhuaUS | manhuaus.com | 🔴 fora do ar | tema keiyoushi |  |
| Manhwa18.today | www.manhwa18.today | 🔴 fora do ar | tema keiyoushi | sim |
| Manhwa68 | manhwa68.com | 🔴 fora do ar | tema keiyoushi | sim |
| ManhwaManhua | manhwamanhua.com | 🔴 fora do ar | tema keiyoushi | sim |
| Manhwatop | manhwatop.com | 🔴 fora do ar | tema keiyoushi |  |
| MeiToon | meitoon.org | 🔴 fora do ar | tema keiyoushi |  |
| NovelCrow | novelcrow.com | 🔴 fora do ar | tema keiyoushi | sim |
| Rage Scans | ragescans.com | 🔴 fora do ar | tema keiyoushi |  |
| Raven Scans | ravenscans.org | 🔴 fora do ar | tema keiyoushi |  |
| Setsu Scans | setsuscans.com | 🔴 fora do ar | tema keiyoushi |  |
| Siren Scans | sirenscans.org | 🔴 fora do ar | tema keiyoushi |  |
| Sleepy Translations | sleepytranslations.com | 🔴 fora do ar | tema keiyoushi |  |
| ToonGod | www.toongod.org | 🔴 fora do ar | tema keiyoushi |  |
| Toonily | toonily.com | 🔴 fora do ar | tema keiyoushi |  |
| Tower Of God Manga Online | w82.thetowerofgod.com | 🔴 fora do ar | tema keiyoushi |  |
| WebtoonScan | webtoonscan.com | 🔴 fora do ar | tema keiyoushi |  |
| WebtoonXYZ | www.webtoon.xyz | 🔴 fora do ar | tema keiyoushi |  |
| Wildtoon | wildtoon.com | 🔴 fora do ar | tema keiyoushi | sim |
| Yaoihub | yaoihub.org | 🔴 fora do ar | tema keiyoushi | sim |
| YaoiScan | yaoiscan.com | 🔴 fora do ar | tema keiyoushi |  |
| YaoiScan (Unoriginal) | yaoiscan.me | 🔴 fora do ar | tema keiyoushi |  |

### Português (Brasil) (42)

| Fonte | Site | Status | Tipo | +18 |
|---|---|---|---|:---:|
| Amuy | apenasmaisumyaoi.com | 🟢 funciona | tema keiyoushi |  |
| Apenas Uma Fã | apenasuma-fa.blogspot.com | 🟢 funciona | tema keiyoushi |  |
| Arthur Scan | arthurscan.xyz | 🟢 funciona | tema keiyoushi |  |
| Boruto Explorer | leitor.borutoexplorer.com.br | 🟢 funciona | tema keiyoushi |  |
| Café com Yaoi | cafecomyaoi.com.br | 🟢 funciona | tema keiyoushi |  |
| Coven Scan | covendasbruxonas.com | 🟢 funciona | tema keiyoushi | sim |
| Euphoria Scan | euphoriascan.com | 🟢 funciona | tema keiyoushi | sim |
| Fleur Blanche | fbsquadx.com | 🟢 funciona | tema keiyoushi | sim |
| GALAX Scans | galaxscanlator.blogspot.com | 🟢 funciona | tema keiyoushi |  |
| Hanami Heaven | hanamiheaven.org | 🟢 funciona | tema keiyoushi | sim |
| Hanmokku Scan | hanmokkuscan.blogspot.com | 🟢 funciona | tema keiyoushi |  |
| Hentai Teca | hentaiteca.online | 🟢 funciona | tema keiyoushi | sim |
| Hot Cabaret Scan | hotcabaretscan.com | 🟢 funciona | tema keiyoushi |  |
| HQ Now | www.hq-now.com | 🟢 funciona | nativa (Otakio) |  |
| Hunters Scan | readhunters.xyz | 🟢 funciona | tema keiyoushi |  |
| Inkapk | inkapk.net | 🟢 funciona | tema keiyoushi | sim |
| Kami Sama Explorer | leitor.kamisama.com.br | 🟢 funciona | tema keiyoushi |  |
| Ler 999 | ler999.blogspot.com | 🟢 funciona | tema keiyoushi |  |
| Manga Livre.to | mangalivre.to | 🟢 funciona | tema keiyoushi |  |
| MangaFlix | mangaflix.net | 🟢 funciona | nativa (Otakio) |  |
| MangoToons | mangotoons.com | 🟢 funciona | nativa (Otakio) |  |
| Monte Tai | montetaiscanlator.xyz | 🟢 funciona | tema keiyoushi |  |
| Nebulosa Scan | nebulosascan.com | 🟢 funciona | tema keiyoushi |  |
| Nocturne Summer | nocfsb.com | 🟢 funciona | tema keiyoushi |  |
| Pink Rosa | scanpinkrosa.blogspot.com | 🟢 funciona | tema keiyoushi |  |
| Tankou Hentai | tankouhentai.com | 🟢 funciona | tema keiyoushi | sim |
| ToonBR | beta.toonbr.com | 🟢 funciona | nativa (Otakio) |  |
| Traduções do Lipe | traducoesdolipe.blogspot.com | 🟢 funciona | tema keiyoushi |  |
| Tsundoku Traduções | tsundoku.com.br | 🟢 funciona | tema keiyoushi |  |
| Yaoi Fan Club | yaoifanclub.com | 🟢 funciona | tema keiyoushi |  |
| Yuri on Air | yurionair.top | 🟢 funciona | tema keiyoushi |  |
| Acervo Hentai | acervohentai.com | 🟡 parcial | tema keiyoushi | sim |
| FlowerManga.net | flowermangas.net | 🟡 parcial | tema keiyoushi |  |
| MR Tenzus | mrtenzus.com | 🟡 parcial | tema keiyoushi | sim |
| Pink Sea Unicorn | psunicorn.com | 🟡 parcial | tema keiyoushi | sim |
| Little Tyrant | tiraninha.world | 🔴 fora do ar | tema keiyoushi |  |
| MiniTwo Scan | minitwoscan.com | 🔴 fora do ar | tema keiyoushi |  |
| Ninja Scan | ninjacomics.xyz | 🔴 fora do ar | tema keiyoushi |  |
| Portal Yaoi | portalyaoi.com | 🔴 fora do ar | tema keiyoushi | sim |
| Temaki mangás | temakimangas.blogspot.com | 🔴 fora do ar | tema keiyoushi | sim |
| Tia Manhwa | tiamanhwa.com | 🔴 fora do ar | tema keiyoushi | sim |
| XXX Yaoi | 3xyaoi.com | 🔴 fora do ar | tema yuzono | sim |

### Espanhol (56)

| Fonte | Site | Status | Tipo | +18 |
|---|---|---|---|:---:|
| Asia Lotus | asialotuss.com | 🟢 funciona | tema keiyoushi | sim |
| BarManga | archiviumbar.com | 🟢 funciona | tema keiyoushi |  |
| Bymichi Scan | bymichiby.com | 🟢 funciona | tema keiyoushi | sim |
| Cerberus Series | legionscans.com/wp | 🟢 funciona | tema keiyoushi |  |
| Dark Room Fansub | lector-darkroomfansub.blogspot.com | 🟢 funciona | tema keiyoushi | sim |
| Dat-Gar Scan | datgarscanlation.blogspot.com | 🟢 funciona | tema keiyoushi |  |
| DoujinsHell | doujinshell.net | 🟢 funciona | tema keiyoushi | sim |
| Hades no Fansub | lectorhades.latamtoon.com | 🟢 funciona | tema keiyoushi |  |
| House Of Otakus | houseofotakusv2.xyz | 🟢 funciona | tema keiyoushi |  |
| InfraFandub | infrafandub.com | 🟢 funciona | tema keiyoushi |  |
| Inmortal Scan | scan-inmortal.com | 🟢 funciona | tema keiyoushi |  |
| Inventario Oculto | inventariooculto.com | 🟢 funciona | tema keiyoushi |  |
| Kazoku Den | www.kazokuden.com | 🟢 funciona | tema keiyoushi |  |
| LeerCapitulo | www.leercapitulo.co | 🟢 funciona | nativa (Otakio) |  |
| LeerManhwas | leermanhwas.com | 🟢 funciona | tema keiyoushi | sim |
| Lolivault | lector.lolivault.net | 🟢 funciona | tema keiyoushi | sim |
| Marmota | marmota.me | 🟢 funciona | tema keiyoushi |  |
| NekoScans | nekoproject.org | 🟢 funciona | tema keiyoushi |  |
| Olympus Biblioteca | olympusbiblioteca.com | 🟢 funciona | nativa (Otakio) |  |
| Pzykosis666HFansub | lector.pzykosis666hfansub.com | 🟢 funciona | tema keiyoushi | sim |
| Rakuen Translations | rakuentranslations.com | 🟢 funciona | tema keiyoushi |  |
| RichtoScan | r1.richtoon.top | 🟢 funciona | tema keiyoushi |  |
| SeraphicDeviltry | spanish.seraphic-deviltry.com | 🟢 funciona | tema keiyoushi | sim |
| Taurus Fansub | lectortaurus.com | 🟢 funciona | tema keiyoushi |  |
| TmoManhwa | tmomanhwa.com | 🟢 funciona | tema keiyoushi | sim |
| TopComicPorno | topcomicporno.com | 🟢 funciona | tema keiyoushi | sim |
| Uchuujin Projects | uchuujinmangas.com | 🟢 funciona | tema keiyoushi |  |
| UnderTranslations | undertranslations.com | 🟢 funciona | tema keiyoushi |  |
| Yuri-Online | yuri-online.com | 🟢 funciona | tema keiyoushi |  |
| ZonaTMO | zonatmo.to | 🟢 funciona | nativa (Otakio) |  |
| ApollComics | apollcomics.es | 🟡 parcial | tema keiyoushi | sim |
| Bloom Scans | bloomscans.com | 🟡 parcial | tema keiyoushi |  |
| Manga  TV | mangatv.net | 🟡 parcial | tema keiyoushi |  |
| ManhwaOnline | manhwa-online.com | 🟡 parcial | tema keiyoushi | sim |
| Menudo-Fansub | www.menudo-fansub.com | 🟡 parcial | tema keiyoushi |  |
| Monopoly Scan | monopolymanhua.com | 🟡 parcial | tema keiyoushi |  |
| Mundo Manhwa | mundomanhwa.com | 🟡 parcial | tema keiyoushi | sim |
| Ragnarok Scanlation | ragnarokscanlation.org | 🟡 parcial | tema keiyoushi |  |
| SamuraiScan | samurai.j5z.xyz | 🟡 parcial | tema keiyoushi |  |
| TopComicPorno.net | topcomicporno.net | 🟡 parcial | tema keiyoushi | sim |
| HeavenManga | heavenmanga.com | ⚪ não testada | parser NOBORU | sim |
| InManga | inmanga.com | ⚪ não testada | parser NOBORU |  |
| LeoManga | leomanga.me | ⚪ não testada | parser NOBORU |  |
| LeoMangas | leomangas.xyz | ⚪ não testada | parser NOBORU |  |
| MangaDoor | mangadoor.com | ⚪ não testada | parser NOBORU |  |
| Submanga | submangas.net | ⚪ não testada | parser NOBORU |  |
| VerComicsPorno | vercomicsporno.xxx | ⚪ não testada | parser NOBORU | sim |
| Bega Translation | begatranslation.com | 🔴 fora do ar | tema keiyoushi |  |
| BokugenTranslation | bokugents.com | 🔴 fora do ar | tema keiyoushi |  |
| DragonTranslation.org | dragontranslation.org | 🔴 fora do ar | tema yuzono |  |
| Manga Romance | mangaromance19.com | 🔴 fora do ar | tema keiyoushi |  |
| Mangas No Sekai | mangasnosekai.com | 🔴 fora do ar | tema keiyoushi |  |
| Manhwa-Latino | manhwa-latino.com | 🔴 fora do ar | tema keiyoushi |  |
| MHScans | mhscans.com | 🔴 fora do ar | tema keiyoushi |  |
| Toon-es | toon-es.com | 🔴 fora do ar | tema keiyoushi | sim |
| Ver Manhwas | vermanhwa.com | 🔴 fora do ar | tema keiyoushi | sim |

### Francês (18)

| Fonte | Site | Status | Tipo | +18 |
|---|---|---|---|:---:|
| AralosBD | aralosbd.fr | 🟢 funciona | nativa (Otakio) |  |
| Blue Solo | bluesolo.org | 🟢 funciona | tema keiyoushi |  |
| FMTEAM | fmteam.fr | 🟢 funciona | tema keiyoushi |  |
| Harmony-Scan | harmony-scan.fr | 🟢 funciona | tema keiyoushi |  |
| Hentai-Scantrad | hentai-scantrad.org | 🟢 funciona | tema keiyoushi | sim |
| HistoireDHentai | hhentai.fr | 🟢 funciona | tema keiyoushi | sim |
| Lelmanga | www.lelmanga.com | 🟢 funciona | tema keiyoushi |  |
| Manga-Corporation | manga-corporation.com | 🟢 funciona | tema keiyoushi |  |
| Scantrad Union | scantrad-union.com | 🟢 funciona | nativa (Otakio) |  |
| HentaiZone | hentaizone.xyz | 🟡 parcial | tema keiyoushi | sim |
| Pantheon Scan | pantheon-scan.com | 🟡 parcial | tema keiyoushi |  |
| Ma Brute | mabrute.com | 🔴 fora do ar | tema keiyoushi | sim |
| Manga-Scantrad | manga-scantrad.io | 🔴 fora do ar | tema keiyoushi |  |
| MangaHub.fr | mangahub.fr | 🔴 fora do ar | tema keiyoushi |  |
| Sushi-Scan | sushiscan.net | 🔴 fora do ar | tema keiyoushi |  |
| Sushiscan.fr | sushiscan.fr | 🔴 fora do ar | tema keiyoushi |  |
| Toon FR | toonfr.com | 🔴 fora do ar | tema keiyoushi | sim |
| YaoiScan | yaoiscan.fr | 🔴 fora do ar | tema keiyoushi | sim |

### Italiano (13)

| Fonte | Site | Status | Tipo | +18 |
|---|---|---|---|:---:|
| AnimeShinigami | www.animeshinigami.com | 🟢 funciona | tema keiyoushi |  |
| GTO The Great Site | reader.gtothegreatsite.net | 🟢 funciona | tema keiyoushi |  |
| LupiTeam | lupiteam.net | 🟢 funciona | tema keiyoushi |  |
| MangaWorld | www.mangaworld.mx | 🟢 funciona | nativa (Otakio) |  |
| Phoenix Scans | www.phoenixscans.com | 🟢 funciona | tema keiyoushi |  |
| TuttoAnimeManga | tuttoanimemanga.net | 🟢 funciona | tema keiyoushi |  |
| ZeurelScan | www.zeurelscan.com | 🟢 funciona | nativa (Otakio) |  |
| DDT Team | ddt.hastateam.com | 🔴 fora do ar | tema keiyoushi |  |
| Hasta Team | reader.hastateam.com | 🔴 fora do ar | tema keiyoushi |  |
| Juin Jutsu Team Reader | www.juinjutsureader.ovh | 🔴 fora do ar | tema keiyoushi |  |
| NIFTeam | read-nifteam.info | 🔴 fora do ar | tema keiyoushi |  |
| Shinobi Scans | shinobiscans.com | 🔴 fora do ar | tema keiyoushi |  |
| Walpurgi Scan | www.walpurgiscan.it | 🔴 fora do ar | tema keiyoushi |  |

## Estrutura do repositório

| Caminho | Conteúdo |
|---|---|
| `index.json` | catálogo lido pelo app (id, nome, idioma, versão, arquivo, status) |
| `extensions/` | as extensões publicadas, um `.lua` por fonte |
| `native/` | código-fonte das extensões nativas (sites com API ou layout próprio) |
| `health.json` | resultado do último teste automático de cada fonte |

### Formato do `index.json`

```json
{
  "name": "Otakio Extensions", "format": 1, "minEngine": 1,
  "extensions": [
    {"id": "otakio.mangapill", "name": "Mangapill", "lang": "en", "version": 1, "nsfw": false,
      "engine": "native", "baseUrl": "https://mangapill.com", "file": "extensions/otakio.mangapill.lua",
      "origin": "otakio", "compat": "full", "health": "ok", "checked": "2026-11-03"}
  ]
}
```

`file` é relativo ao `index.json` (ou `url`, absoluto). O app instala uma extensão de novo quando `version` aumenta.
Qualquer pessoa pode montar um repositório próprio nesse formato e adicioná-lo no app.

### Como as extensões são feitas

Extensões do Mihon/Tachiyomi são APKs Kotlin para Android e não rodam no Vita. O Otakio reimplementa em Lua os
**temas** que muitos sites compartilham (Madara, MangaThemesia, Keyoapp, ZeistManga, FoolSlide, MangaCatalog,
YiiManga, VineTheme, HeanCms, Guya, PizzaReader...). Para esses sites, a extensão é só uma configuração do tema.
Sites com estrutura própria têm extensões **nativas**, escritas à mão em `native/`.

O catálogo é gerado e testado pelas ferramentas do repositório do app
(`tools/gen_repo.py`, `tools/probe_sources.py`, `tools/gen_repo_readme.py`). Sites que fecharam de vez ficam fora do
catálogo (`CLOSED_SITES` em `tools/gen_repo.py`).

## Créditos

- **[keiyoushi/extensions-source](https://github.com/keiyoushi/extensions-source)** (Apache 2.0): a lógica dos
  temas e a lista de sites das extensões marcadas como "tema keiyoushi" foram adaptadas do código Kotlin deles.
- **[yuzono/tachiyomi-extensions](https://github.com/yuzono/tachiyomi-extensions)**,
  **[yuzono/cursed-manga-extensions](https://github.com/yuzono/cursed-manga-extensions)** e
  **[codegeasse1/codegeasse-mihon-extension](https://github.com/codegeasse1/codegeasse-mihon-extension)**:
  configurações de sites que usam os mesmos temas.
- **[Creckeryop/NOBORU-parsers](https://github.com/Creckeryop/NOBORU-parsers)**: os parsers clássicos do NOBORU
  ("parser NOBORU") são baixados direto do repositório original, sem cópia aqui.
- **Comunidade [Mihon](https://github.com/mihonapp/mihon)/Tachiyomi**, pelo modelo de extensões e repositórios.
- **Extensões nativas e adaptação para Lua:** Garryth69, com auxílio de IA (Claude, da Anthropic).

## Licença

[Apache 2.0](LICENSE). Veja [NOTICE.md](NOTICE.md) para as atribuições de código de terceiros.
