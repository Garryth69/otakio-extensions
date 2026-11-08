# Removal requests

This repository hosts no manga, comics or images. Each extension is a small script that reads a third-party website's
public pages on the user's own console. Still, if you run a website or own the rights to works shown through one of
these extensions and want it taken out, we will remove it.

## How to ask

Open an issue in this repository titled **Removal request: <site name>** with:

1. the website (domain) and the extension name as listed in [SOURCES.md](SOURCES.md);
2. your relation to it (site owner/operator or rights holder, or someone acting for them);
3. optionally, the reason (copyright, the site prefers not to be read by third-party apps, the site closed, etc.).

If you would rather not post details publicly, open an issue titled **Removal request: private contact** without any
details, and the maintainer will reply with a private channel.

## What happens

- **Owner request:**
  - the extension is removed from `index.json` with the next update;
  - the site is added to the opt-out list (`OPT_OUT` in `tools/prune_repo.py` in the
    [app repository](https://github.com/Garryth69/otakio)) so that a regeneration does not bring it back;
  - the removal is logged in [REMOVED.md](REMOVED.md).
- **Copyright notice about specific works:** this repository contains no works. Removing the site's extension is the
  only action available here, and we do it on request.
- **Upstream removals:** sources based on [keiyoushi/extensions-source](https://github.com/keiyoushi/extensions-source)
  are also removed here when keiyoushi removes them.
- **Copies already installed:** the app keeps working with them on the device, but marks them *Removed from repository*
  so users can uninstall them. The app never downloads a removed extension again.
