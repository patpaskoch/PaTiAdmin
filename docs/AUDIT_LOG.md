# PaTi Wochen-Audit – Log

Neuester Eintrag oben.

## 2026-11-08

### 1. Zusammenfassung
Der Lauf hat technisch funktioniert: Schreibrechte sind da, alle Prüfungen (`check.sh`) waren vorher und nachher grün. Der Lauf vom
2026-11-08 (erster Versuch, ohne Push) wurde nachgeholt: sieben Fehler in sieben Addons sind behoben, dazu neue Einträge in
FOLLOW_UPS. Im Internet gab es keine überprüfbaren neuen API-Änderungen. Eine gründliche neue Code-Durchsicht aller Repos war in
diesem Lauf nur oberflächlich möglich (Suche nach verbotenen Aufrufen); sie bleibt für den nächsten Lauf offen.

### 2. Findings im Code
**Sicherheit / Stabilität**
- PaTiAuras: „Standardwerte wiederherstellen“ lief auch im Kampf und verschob dabei gesicherte Buttons. Im Spiel: mögliche Fehlermeldung
  „Aktion blockiert“. ✅ behoben (PR PaTiAuras, F48).
- PaTiLead: eine beschädigte Marker-Liste oder Notiz im Speicherstand wurde ungeprüft benutzt. ✅ behoben.
- PaTiChronicle: ein Speicherstand mit Text statt Zahl als Version oder eine unvollständige Probe konnte den Login stören. ✅ behoben.
**Fehler**
- PaTiAlerts: Ein abgeschalteter Filter ließ sich nie wieder einschalten. ✅ behoben.
- PaTiAggro: Bei einem Gegner auf einem Spieler ohne Rolle stand der Rohtext „OTHER“ statt „anderer Spieler“. ✅ behoben.
- PaTiHeal: Beim Zielwechsel zwischen totem und lebendem Ziel blieb die Klickbelegung der Heilziel-Zeile ggf. falsch. ✅ behoben.
**Performance**
- PaTiChronicle: Die Todesprüfung fragte bei jedem Ereignis alle Mitglieder; jetzt nur noch, wenn das gemeldete Mitglied tot ist. ✅
- PaTiRota: Ein verstecktes Fenster wurde weiter gemalt. ✅ behoben (malt jetzt beim Anzeigen).
**Aufräumen**
- PaTiChronicle `Report.lua` hat 517 Zeilen (Grenze ~400). ⏳ offen (F46, kleines Refactoring später).

### 3. Neuigkeiten aus dem Internet
- Die Wiki-Seite „Patch 1.60.1/API changes“ ist leer ([Quelle](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes)); sie nennt für Forever
  Build 69913. Zum Live-Build 70790 und zu Hotfixes dieser Woche wurde nichts Belegbares gefunden. Keine Auswirkung auf unsere Addons erkennbar.

### 4. Umgesetzt
PRs je Repo auf Branch `audit/2026-11-08` (Links siehe Abschlussnachricht/GitHub): PaTiAlerts, PaTiAggro, PaTiAuras, PaTiHeal,
PaTiChronicle, PaTiLead, PaTiRota, PaTiAdmin (Doku + F37–F46, F48).

Nachtrag: Der automatische Codex-Review fand nach dem Merge zwei berechtigte Punkte; beide sind in Folge-PRs behoben (Chronicle: verschachtelte Probe-Zähler; Admin: Platzhalter F47 entfernt).

### 5. Nicht umgesetzt
- F37–F46 (Live-Build/Ordner, Belegungen-Reset, Plaketten-Höhe, Strata, Performance-Messung, PaTiLead Sprachwechsel im Kampf, PaTiDungeon Skizze,
  PaTiSocial, PaTiShared OnDragStop, Chronicle-Wachstum): nur als Todo, weil die Details aus dem ersten Versuch fehlen bzw. Messungen im Spiel nötig sind.
- Neue Code-Durchsicht aller Repos (Taint, Hot-Paths): nur oberflächlich (keine `COMBAT_LOG_EVENT_UNFILTERED`-, `SaveBindings`-, Makro-Aufrufe gefunden).

### 6. Was im Lauf nicht funktioniert hat
- Die Seite warcraft.wiki.gg ist im Netz dieser Sitzung nicht erreichbar; forevermastery.com lieferte keine Treffer. Patrick kann die Domains in den
  Netzwerk-Einstellungen freigeben, wenn er genauere News will.
- Die Todo-Texte F37–F46 stammen aus Stichworten der Aufgabe, nicht aus dem verlorenen ersten Lauf – bitte beim Anfassen prüfen.

### 7. Bitte im Spiel testen
- Filter in PaTiAlerts ab- und wieder anhaken (PT-ALERTS-045).
- Gegner auf Spieler ohne Rolle im Tank-Fenster ansehen: „anderer Spieler“ statt „OTHER“ (PT-TANK-065).
- Im Kampf „Standardwerte wiederherstellen“ in PaTiAuras klicken: nichts passiert, Hinweis erscheint (PT-AURAS-124).
- Totes und lebendes Ziel nacheinander anvisieren: Heilziel-Klick passt (PT-HEAL-173).
- Wipe-Test wiederholen (PT-CHRON-027).
- PaTiRota-Fenster verstecken/zeigen: sofort korrekt (PT-ROTA-071).
