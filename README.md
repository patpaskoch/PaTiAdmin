# PaTi Addons – Verwaltung

Dieses öffentliche Repository ist der zentrale Einstieg der PaTiSuite: Arbeitsregeln, Entwicklungsstand und
Verweise auf alle Repositories.

## Spieler-Addons

Jedes Addon wird einzeln installiert und funktioniert allein; keines braucht ein anderes. PaTiAlerts und PaTiSuite
sind optionale Ergänzungen.

| Repo | Zweck |
| --- | --- |
| [PaTiSuite](https://github.com/patpaskoch/PaTiSuite) | optionales Steuerfenster: PaTi-Fenster anzeigen/ausblenden |
| [PaTiHeal](https://github.com/patpaskoch/PaTiHeal) | **Heilen:** Gruppen- und Heal-Target-Rahmen, Klickzauber, eigene HoTs/Schilde, bannbare Debuffs |
| [PaTiAuras](https://github.com/patpaskoch/PaTiAuras) | **Buffs/Auren:** eigene Buffs, Procs, Aufspüren, Gruppenbuffs, Waffenbuffs, Click-to-Buff |
| [PaTiTank](https://github.com/patpaskoch/PaTiTank) | **Tank:** Ziel, Bedrohung, Aggro-Kontrolle, Namensschild-Nummern |
| [PaTiRota](https://github.com/patpaskoch/PaTiRota) | **Rotation:** eigene Skill-Reihenfolge, Abklingzeiten, nächster bereiter Skill, feste Zauber-Buttons |
| [PaTiGroup](https://github.com/patpaskoch/PaTiGroup) | **Gruppe beobachten:** Tank, Heiler, Rollen, Ziel des Tanks mit Zielmarker |
| [PaTiLead](https://github.com/patpaskoch/PaTiLead) | **Gruppe führen:** Zielmarker, Ready Check, Pull-Countdown (früher PaTiGroup) |
| [PaTiQuest](https://github.com/patpaskoch/PaTiQuest) | **Quests:** ausgewählte Quest und ihre Ziele |
| [PaTiDungeon](https://github.com/patpaskoch/PaTiDungeon) | **Dungeon-Kontext:** Instanz-, Gruppen- und Kampfstatus |
| [PaTiSocial](https://github.com/patpaskoch/PaTiSocial) | **Kommunikation:** „Party Social“, Schnellbuttons für Emotes und kurze Nachrichten |
| [PaTiAlerts](https://github.com/patpaskoch/PaTiAlerts) | **Probleme:** zentrales Fenster für offene Probleme aus PaTiTank, PaTiAuras, PaTiHeal (optional) |

## Entwicklungs-Repositories

Werden von Spielern nicht separat installiert.

| Repo | Zweck |
| --- | --- |
| [PaTiAdmin](https://github.com/patpaskoch/PaTiAdmin) | dieses Repo: Regeln, Doku, Prüf-Tools, CI-Vorlagen, Stand — kein WoW-Addon |
| PaTiShared (privat) | Entwicklungsquelle der gemeinsamen UI-Komponenten, Version 0.3.0; bereits in jedes Addon eingebettet (`Shared/`) |

Die Addons werden in einem gemeinsamen Code-Ordner entwickelt und zum Testen in den WoW-AddOns-Ordner kopiert.
Stand und Release-Reife: [`SUITE_STATUS.md`](SUITE_STATUS.md) · Ingame-Tests:
[`docs/INGAME_TEST_STATUS.md`](docs/INGAME_TEST_STATUS.md) · Release, Beta, Veröffentlichung: [`docs/RELEASE.md`](docs/RELEASE.md).

## Engineering

- Regeln für alle Agenten und Menschen: [`AGENTS.md`](AGENTS.md)
- Doku: [`docs/`](docs/) — Architektur, Entwicklung, Tests, Übersetzungen, WoW-API, Release, Follow-ups
- Prüfungen: `tools/check.sh` (lokal und in CI), Release-ZIP: `tools/package.sh`
- Vorlagen für die Addon-Repos: `templates/ci.yml`, `templates/release.yml` (Entwurfs-Release bei Tag `vX.Y.Z`),
  `templates/ISSUE_TEMPLATE/bug_report.md`
