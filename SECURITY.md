# Security policy

## Reporting a vulnerability

Please **do not open a public issue** for security problems, such as an extension that escapes the app sandbox,
a wrong or missing `sha256` in `index.json`, or a source that serves malicious content.

Report privately through GitHub:
**Security** tab → **Report a vulnerability** (GitHub Security Advisories).

For problems in the app itself, use the same form in the
[Otakio app repository](https://github.com/Garryth69/otakio/security).

## Integrity

Every extension file in `index.json` carries a `sha256` hash. The app refuses to install a file whose hash
does not match, so a tampered mirror or a modified download cannot inject code.

Takedown or opt-out requests from site owners are not security reports: see [REMOVAL.md](REMOVAL.md).
