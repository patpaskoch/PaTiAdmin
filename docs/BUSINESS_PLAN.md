# Addon-Businessplan

Stand: 2026-10-31. Hier stehen Ziel, Einnahmeregeln, Kennzahlen und Risiken. Die Schritte stehen in den
[Launch-Issues](https://github.com/patpaskoch/PaTiAdmin/issues?q=label%3Alaunch), die Abläufe in
[`PUBLISHING.md`](PUBLISHING.md). Dieses Repo ist öffentlich: echte Einnahmen und Kontodaten gehören nicht hierher.

## Kurzfassung

- **Stand:** Alle zwölf Addons sind unveröffentlicht und ohne Tag oder Release.
- **Geschäftsmodell:** Verkaufen ist nicht erlaubt. Die Addons bleiben kostenlos, Einnahmen kommen nur aus Spenden
  außerhalb des Spiels und aus den Rewards der Plattformen.
- **Ziel:** Bis etwa 6 Monate nach dem Launch hat PaTiSuite eine aktive Forever-Nutzergruppe. Geld ist ein Nebeneffekt.
- **Nächster harter Termin:** WoW Forever Live am 04.11.2026, 15:00 PST (05.11., 00:00 Uhr Wien; Quelle: Fanseite,
  nicht Blizzard). Vorher ist kein Ingame-Test möglich.

## Regeln

Blizzards [UI Add-On Development Policy](https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534):

| Erlaubt | Nicht erlaubt |
|---|---|
| Spendenlink auf Addon-Seiten und im GitHub-Repo | Addon, Download oder Zusatzdienst gegen Geld |
| Rewards der Plattformen | „Premium“-Version oder bezahlte Zusatzfunktionen |
| | Spendenaufruf im Addon |
| | Werbung im Addon |

## Einnahmen

| Quelle | Erwartung | Sicherheit |
|---|---|---|
| Ko-fi | wenige Euro bis niedrig zweistellig pro Monat (Schätzung aus `LAUNCH.md`) | Annahme, keine Daten |
| CurseForge Rewards | Punkte aus einem Monatspool, abhängig von der Beliebtheit; Opt-in nötig | [Drittquelle](https://www.switchbladegaming.com/minecraft/curseforge-vs-modrinth/): 0,05 $ pro Punkt; in der Author Console prüfen |
| Wago | unbekannt | nichts gefunden; im Developer-Bereich prüfen |
| GitHub Sponsors | optional, später | offen |

**Einziger Marktwert bisher:** [ForeverVendor](https://www.curseforge.com/wow/addons/forevervendor) stand am 31.10. bei
841 Downloads. Das ist ein Einzelwert vor dem Live-Start und keine Prognose.

**Kosten:** keine Fixkosten und keine bezahlte Werbung. Die Investition ist die Zeit für Tests, Support und Pflege.
Ab der ersten Einnahme eine private Liste führen und die Steuerfrage klären.

## Plattformen

Laut einer [Fanseite](https://wowforevertierlist.com/es/addons/how-to-install) führen CurseForge und Wago Forever 1.60.1.
Für CurseForge belegt das auch ein dort gelistetes Addon. Für WoWInterface ist es offen. Bestätigt ist es pro Plattform
erst, wenn Forever beim ersten Upload auswählbar ist.

## Kennzahlen

Das sind Startziele und keine Prognosen. Nach 4 Wochen anhand echter Zahlen neu setzen.

| Kennzahl | Ziel 4 Wochen nach Welle 1 |
|---|---|
| Downloads über alle Plattformen | 500 |
| Lua-Fehler in den Hauptpfaden | 0 offen |
| Antwort auf Fehlerberichte | innerhalb weniger Tage |

## Risiken

| Risiko | Antwort |
|---|---|
| Live-Client verhält sich anders als die Beta | Smoke-Test zuerst, bei Lua-Fehler stoppen |
| Launch-Fenster verpasst, weil die Tests dauern | auf die Hauptpfade der Welle 1 begrenzen; das Beta-Gate bleibt bestehen |
| Moderation dauert länger als erwartet | GitHub-Release zuerst, Plattformen folgen |
| Blizzard ändert APIs oder Regeln | Regeln vor Veröffentlichung erneut lesen; kleine Addons, keine Automatik |
| Support kostet mehr Zeit als geplant | gestaffelte Wellen, eine Ankündigung pro Kanal und Welle |
| Forever-Publikum bleibt klein | keine Fixkosten; nach 4 Wochen entscheiden, ob Welle 2 und 3 lohnen |
