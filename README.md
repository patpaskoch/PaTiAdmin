# PaTi Addons – Verwaltung

Dieses öffentliche Repository enthält die Arbeitsregeln, den Entwicklungsstand und Verweise auf die einzelnen Addon-Repositories.

| Addon | Repository | Stand |
| --- | --- | --- |
| PaTiGroup | https://github.com/patpaskoch/PaTiGroup | manuelle Zielmarker, Ready Check und Pull-Countdown |
| PaTiQuest | https://github.com/patpaskoch/PaTiQuest | ausgewählte Quest und Ziele |
| PaTiDungeon | https://github.com/patpaskoch/PaTiDungeon | Instanz- und Gruppenstatus |
| PaTiShared | lokal: `C:\Users\patpa\code\PaTiShared` (kein WoW-Addon) | gemeinsame UI-Quelle, 0.2.0 |
| PaTiHeal | https://github.com/patpaskoch/PaTiHeal | Gruppenanzeige und manuelle Klickzauber |
| PaTiTank | https://github.com/patpaskoch/PaTiTank | Gesundheits- und Bedrohungsanzeige |
| PaTiAuras | https://github.com/patpaskoch/PaTiAuras | Auren-/Buff-Anzeige (optional, eigenständig), 0.1.0 |

Die Addons werden in `C:\Users\patpa\code` entwickelt und danach zum Testen in den WoW-AddOns-Ordner kopiert.

## Engineering

- Regeln für alle Agenten und Menschen: [`AGENTS.md`](AGENTS.md)
- Doku: [`docs/`](docs/) — Architektur, Entwicklung, Tests, Übersetzungen, WoW-API, Release, Follow-ups
- Prüfungen: `tools/check.sh` (lokal und in CI), Release-ZIP: `tools/package.sh`
- CI-Vorlage für die Addon-Repos: `templates/ci.yml`
