# PaTi Addons – Verwaltung

Dieses öffentliche Repository enthält die Arbeitsregeln, den Entwicklungsstand und Verweise auf die einzelnen Addon-Repositories.

| Addon | Repository | Stand |
| --- | --- | --- |
| PaTiGroup | https://github.com/patpaskoch/PaTiGroup | manuelle Zielmarker, Ready Check und Pull-Countdown |
| PaTiQuest | https://github.com/patpaskoch/PaTiQuest | ausgewählte Quest und Ziele |
| PaTiDungeon | https://github.com/patpaskoch/PaTiDungeon | Instanz- und Gruppenstatus |
| PaTiShared | privat (kein WoW-Addon, in jedes Addon eingebettet) | gemeinsame UI-Quelle, 0.3.0 |
| PaTiHeal | https://github.com/patpaskoch/PaTiHeal | Gruppenanzeige und manuelle Klickzauber |
| PaTiTank | https://github.com/patpaskoch/PaTiTank | Gesundheits- und Bedrohungsanzeige |
| PaTiAuras | https://github.com/patpaskoch/PaTiAuras | Auren-/Buff-Anzeige (optional, eigenständig), 0.1.0 |
| PaTiAlerts | https://github.com/patpaskoch/PaTiAlerts | offene Probleme der anderen Addons (optionaler Empfänger), 0.1.0 |
| PaTiSuite | https://github.com/patpaskoch/PaTiSuite | optionales Steuerfenster: PaTi-Fenster anzeigen/ausblenden, 0.1.0 |

Die Addons werden in einem gemeinsamen Code-Ordner entwickelt und zum Testen in den WoW-AddOns-Ordner kopiert.
Stand und Release-Reife: [`SUITE_STATUS.md`](SUITE_STATUS.md) · Ingame-Tests:
[`docs/INGAME_TEST_STATUS.md`](docs/INGAME_TEST_STATUS.md) · Release, Beta, Veröffentlichung: [`docs/RELEASE.md`](docs/RELEASE.md).

## Engineering

- Regeln für alle Agenten und Menschen: [`AGENTS.md`](AGENTS.md)
- Doku: [`docs/`](docs/) — Architektur, Entwicklung, Tests, Übersetzungen, WoW-API, Release, Follow-ups
- Prüfungen: `tools/check.sh` (lokal und in CI), Release-ZIP: `tools/package.sh`
- Vorlagen für die Addon-Repos: `templates/ci.yml`, `templates/release.yml` (Entwurfs-Release bei Tag `vX.Y.Z`),
  `templates/ISSUE_TEMPLATE/bug_report.md`
