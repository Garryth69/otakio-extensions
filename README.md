# Otakio Extensions

**Source extensions** for [Otakio](https://github.com/Garryth69/otakio), a manga reader for the PS Vita. The app ships
without any source: they are installed from this repository, inside the app.

## Using it on the Vita

- **First launch:** on the last setup screen, pick **Install recommended sources**. It adds this repository and installs
  Otakio's own sources for your languages.
- **Any time:**
  1. Open **Extensions** and press **Select** → **Add repository**.
  2. Type `Garryth69/otakio-extensions` and confirm.
  3. In the **Available** tab, switch language with **Start** and install sources with **X**.

The app checks this repository for updates at startup. When an extension gets a new version here, the app's **Updates**
tab offers it with one click.

## Legal notice

- **No content is hosted here.** Each extension is a script that, on the user's console, reads public pages of a
  third-party website, the way a browser would.
- This project has no affiliation with the listed websites, publishers or authors. Site names only identify where an
  extension reads from.
- No extension works around anti-bot protection (Cloudflare and similar), paywalls or logins. Sites that require that
  are marked as down.
- **Removal requests:** see [REMOVAL.md](REMOVAL.md). Removed sources are listed in [REMOVED.md](REMOVED.md).
- Support the authors: buy official releases and use official services.

## Sources

| Language | Sources | 🟢 working |
|---|---:|---:|
| [Multi-language](SOURCES.md#multi-language) | 9 | 5 |
| [English](SOURCES.md#english) | 195 | 117 |
| [Portuguese (Brazil)](SOURCES.md#portuguese-brazil) | 42 | 27 |
| [Spanish](SOURCES.md#spanish) | 55 | 29 |
| [French](SOURCES.md#french) | 18 | 9 |
| [Italian](SOURCES.md#italian) | 13 | 8 |
| [Russian](SOURCES.md#russian) | 14 | 8 |
| [Japanese](SOURCES.md#japanese) | 9 | 8 |
| [Chinese](SOURCES.md#chinese) | 5 | 3 |
| **Total** | **360** | **214** |

**[Full list of sources, with site, status and type → SOURCES.md](SOURCES.md)**

The status comes from the daily automated check (`health.json`). On the Vita, each source's dot also adjusts itself
with use.

## Repository layout

| Path | Contents |
|---|---|
| `index.json` | catalog read by the app (id, name, language, version, file, status) |
| `extensions/` | published extensions, one `.lua` per source |
| `native/` | source code of the native extensions (sites with their own API or layout) |
| `SOURCES.md` | every source by language, with site, status and type (generated) |
| `health.json` | latest automated test result of each source, with `deadSince`/`lastOk` history |
| `removed.json`, `REMOVED.md` | sources taken out of the catalog, with date and reason |

### `index.json` format

```json
{
  "name": "Otakio Extensions", "format": 1, "minEngine": 1,
  "extensions": [
    {"id": "otakio.example", "name": "Example", "lang": "en", "version": 1, "nsfw": false,
      "engine": "native", "baseUrl": "https://example.com", "file": "extensions/otakio.example.lua",
      "origin": "otakio", "compat": "full", "health": "ok", "checked": "2026-11-03", "recommended": true}
  ]
}
```

`file` is relative to `index.json` (or `url`, absolute). The app reinstalls an extension when `version` goes up.
A multi-language extension (`"lang": "all"`) with one source per language can list them in `"langs": ["en", "es"]`
(native header `-- @langs en,es`): the app then shows it only under those languages.
Anyone can host their own repository in this format and add it in the app.

### How the extensions are made

Mihon/Tachiyomi extensions are Kotlin APKs for Android and don't run on the Vita. Otakio reimplements in Lua the
**themes** many sites share (Madara, MangaThemesia, Keyoapp, ZeistManga, FoolSlide, MangaCatalog, YiiManga,
VineTheme, HeanCms, Guya, PizzaReader, Grouple, GalleryAdults...). For those sites an extension is just a theme
configuration. Sites with their own structure have **native** extensions, hand-written in `native/`.

The catalog is generated, tested and pruned by tools in the app repository (`tools/gen_repo.py`,
`tools/probe_sources.py`, `tools/prune_repo.py`, `tools/gen_repo_readme.py`):
- keiyoushi-based sources follow keiyoushi (removed there = removed here);
- other sources are removed after 180 days down in a row.

## Credits

- **[keiyoushi/extensions-source](https://github.com/keiyoushi/extensions-source)** (Apache 2.0): the theme logic and the
  site list of the "keiyoushi theme" extensions were adapted from their Kotlin code.
- **[yuzono/tachiyomi-extensions](https://github.com/yuzono/tachiyomi-extensions)** and
  **[yuzono/cursed-manga-extensions](https://github.com/yuzono/cursed-manga-extensions)** (Apache 2.0): configurations of
  sites that use the same themes.
- **[Creckeryop/NOBORU-parsers](https://github.com/Creckeryop/NOBORU-parsers)**: the classic NOBORU parsers ("NOBORU
  parser") are downloaded straight from the original repository, not copied here.
- **The [Mihon](https://github.com/mihonapp/mihon)/Tachiyomi community**, for the extension and repository model.
- **Native extensions and Lua port:** Garryth69, with AI assistance (Claude, by Anthropic).

## License

[Apache 2.0](LICENSE). See [NOTICE.md](NOTICE.md) for third-party attributions.
