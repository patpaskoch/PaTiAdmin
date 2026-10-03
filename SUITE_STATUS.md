# Entwicklungsstand

Stand: 2026-10-02 (Suite-Umbau). „Im Spiel bestätigt“ heißt: vom Besitzer im Client getestet. Die einzelnen
Ingame-Tests mit Ergebnis stehen in `INGAME_TESTING.md` jedes Addons, Übersicht:
[`docs/INGAME_TEST_STATUS.md`](docs/INGAME_TEST_STATUS.md). Alles andere ist nur per Code, Unit-Tests und CI geprüft —
grüne CI heißt nicht, dass es im Spiel funktioniert. Release-Regeln, Beta-Kriterien und Freeze:
[`docs/RELEASE.md`](docs/RELEASE.md). Tests: [`docs/TESTING.md`](docs/TESTING.md).

## Aufteilung der Suite (2026-10-02)

Jedes Addon hat genau eine Aufgabe ([`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md#addon-responsibilities)):
PaTiHeal = heilen · PaTiAuras = Buffs/Auren · PaTiTank = Tank/Aggro · PaTiRota = Rotation · PaTiGroup = Gruppe
beobachten · PaTiLead = Gruppe führen · PaTiQuest = Quests · PaTiDungeon = Dungeon-Kontext · PaTiSocial =
Kommunikation · PaTiAlerts = Probleme · PaTiSuite = Steuerfenster. PaTiShared und PaTiAdmin sind keine Spieler-Addons.

## Release-Reife

| Addon | Version (TOC) | Code | CI | Paket (ZIP geprüft) | Doku | Fresh Install | WoW-Test | Beta |
|---|---|---|---|---|---|---|---|---|
| PaTiHeal | 0.6.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ teilweise (Klickzauber, Migration, Sprache) | Nein |
| PaTiAuras | 0.1.0 | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ teilweise; Waffenbuff-Erkennung, Abwählen, PaTiAlerts bestätigt | Nein |
| PaTiTank | 0.1.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiRota | 0.1.0 (neu) | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiGroup | 0.1.0 (neu, Party Awareness) | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiLead | 0.4.0 + [Unreleased] (früher PaTiGroup) | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiQuest | 0.1.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiDungeon | 0.1.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiAlerts | 0.1.0 | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ nur `/pal test` | Nein |
| PaTiSocial | 0.1.0 | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ teilweise (Laden, Icon, Buttons, Layout, Emote) | Nein |
| PaTiSuite | 0.1.0 (Steuerung) | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ teilweise (Ein-/Ausblenden, Farben, Hover) | Nein |

✅ = erledigt und geprüft · ⏳ = offen. Lizenz: MIT in allen dreizehn Repos. Icons: PaTiSuite-Set in allen elf Addons;
im Spiel bestätigt 2026-10-02 für **8 von 11** (Heal, Auras, Tank, Quest, Dungeon, Alerts, Social, Suite). Offen: PaTiGroup
(Gruppen-Icon übernommen — die alte Bestätigung gilt nach dem Umbau nicht mehr, PT-GROUP-203), PaTiRota und PaTiLead
(eigene Grafik des Owners 2026-10-02, PT-ROTA-062, PT-LEAD-003).

## Alle Addons
- Eigenständig: keine Abhängigkeit untereinander (TOC-Prüfung erzwingt das), eigene SavedVariables, eigene Slash-Befehle
- PaTiShared-Oberfläche 0.3.0 eingebettet; `•••`-Menü mit Einstellungen, Sperren, Ein-/Ausklappen (gespeichert),
  Testmodus, Ausblenden; Position gespeichert; Sprachen enUS/deDE (zhCN/zhTW/koKR → Englisch außer Menütexten)
- Fenster: einstellbare Deckkraft (30–100 %, Standard 75 %), Registrierung für das optionale PaTiSuite-Steuerfenster.
  Neu 2026-10-02, ungetestet: ruhigerer Fenstertitel (kleiner, grau, leicht transparent; PT-SUITE-150–153)
- Befehle: allein = ein-/ausblenden, `show hide test lock unlock reset settings debug version`
- Release: ZIP mit genau einem Ordner (inkl. Icon, ohne `assets/`/LICENSE), Entwurfs-Release per Tag `vX.Y.Z`,
  Bug-Report-Vorlage; Release-Workflow noch nie gelaufen (erst mit dem ersten Tag)
- Behoben 2026-10-02: in PaTiAlerts, PaTiDungeon, PaTiQuest, PaTiTank zeigte der erste Einstellungsabschnitt „GENERAL“
  (F30) — jetzt „Allgemein“, im Spiel noch nicht gesehen

## PaTiHeal
- Funktion: Gruppenrahmen (Leben, Mana, Tank-Streifen), Klickzauber für neun Kombinationen mit Rangwahl, eigene HoTs und
  Schilde (Schamane, Priester) mit Aufladungen/Timer rechts oder unten, bannbare Debuffs, Klick-Reinigen über die
  normale Klickbelegung. Einzige Quelle für eigene HoTs/Schilde (PaTiAuras hat keine Heilung mehr)
- Neu 2026-10-02, ungetestet: **Heal-Target-Rahmen** direkt über dem eigenen Balken (fester SecureUnitButton,
  `unit=target`, dieselben Klickbelegungen; Sichtbarkeit im Kampf über Secure State Driver — im Forever-Client noch
  nicht bestätigt, sonst nur außerhalb des Kampfes; PT-HEAL-130–147); Fensterhöhe folgt den Gruppenmitgliedern
  (PT-HEAL-057–059)
- Architektur: Logic (rein) · SpellBook · Dispels · Profiles · HoTs · TargetFrame · Settings · PaTiHeal.lua (~610 Zeilen, F13)
- Tests: 43 Unit-Tests
- Im Spiel bestätigt: Laden ohne Lua-Fehler, alte Belegung übernommen, Links- und Shift+Rechts-Klickzauber,
  Einstellungen, Sprachwahl nach `/reload`; 2026-09-30 Linksklick auf den eigenen Frame; Icon
- Offen im Spiel: Heal-Target, Ränge, bannbare Debuffs, HoTs/Schilde, Klick-Reinigen, Kampfverhalten, Spell-IDs

## PaTiAuras
- Funktion: eigene Buffs, Procs, Aufspüren, Gruppenbuffs (auch solo, Click-to-Buff auf das nächste fehlende
  Mitglied), konkrete Waffenbuffs (Felsbeißer) mit Klick; jede Aura einzeln abwählbar; Profile Schamane, Priester
- Entfernt 2026-10-02: Heilungs-Kategorie (HoTs/Schilde → PaTiHeal; alte Einstellungen werden ignoriert, PT-AURAS-180–182)
- Neu 2026-10-02, ungetestet: Kategorie-Layout vertikal (Standard, wie bisher) oder horizontal (Spalten;
  PT-AURAS-190–199)
- Waffenbuffs: moderne API zuerst — **vom Owner bestätigt 2026-10-02** (052–055, 057, 158, 159); Rechtsklick-Entfernen
  für Waffen wegen Blizzard-Fehler entfernt; Aufspüren ungetestet (PT-AURAS-170–176)
- Tests: 128 Unit-Tests
- Im Spiel bestätigt: `C_UnitAuras` und `issecretvalue`, Priester-IDs für Selbst- und Gruppenbuffs, Beobachten-Menü,
  Felsbeißer-Erkennung und Abwählen, PaTiAlerts-Warnung, Icon
- Offen im Spiel: Layout, Click-to-Buff, Kampf, Schamanen-IDs, Aufspüren

## PaTiTank
- Funktion: eigene Gesundheit, Ziel, Bedrohung; Aggro-Kontrolle mit nummerierten Problem-Gegnern (Panel und Namensschild),
  PaTiAlerts-Ausgabe. Anklickbare Panel-Zeilen: technisch blockiert (F17)
- Tests: 34 Unit-Tests · Im Spiel bestätigt: Icon · Offen: alles Übrige

## PaTiRota (TOC 0.1.0, neu 2026-10-02)
- Funktion: bis zu zehn Skill-Plätze in eigener Prioritätsreihenfolge (Name/ID oder aus dem Zauberbuch ziehen),
  Abklingzeiten, GCD, „nicht nutzbar“/„nicht gelernt“/„unklar“, der höchste bereite Skill hervorgehoben. Jeder Platz
  hat einen festen Secure-Button (ein Klick = genau dieser Zauber); nichts zaubert von selbst, kein wechselnder Button
- Im Spiel bestätigt 2026-10-03: `/prota debug` (PT-ROTA-004), feste Buttons wirken (PT-ROTA-040). Im Kampf zeigte die
  Anzeige „unklar“ (❌ PT-ROTA-031, 033) — Adapter-Fix (modern, dann legacy; Diagnose je API), Retest offen
- Tests: 21 Unit-Tests · Offen im Spiel: alles (PT-ROTA-001–062), Cooldown-API und GCD-Referenz (`/prota debug`)

## PaTiGroup (TOC 0.1.0, neu 2026-10-02) — Party Awareness
- Funktion: Tank, Heiler (tot/offline), Ziel des Tanks mit Zielmarker, Rollenübersicht; Party und Schlachtzug; nur
  Anzeige, keine Secure-Frames, aktualisiert sich auch im Kampf. Rollen nur von WoW, nie geraten
- Tests: 13 Unit-Tests · Offen im Spiel: alles (PT-GROUP-200–251); ob Rollen ohne Gruppensuche gemeldet werden

## PaTiLead (früher PaTiGroup, umbenannt 2026-10-02)
- Funktion: acht Marker + Entfernen, Reset All, Ready Check, Pull, Ziel/Leitung/Rollen, Notiz; Tastenbelegung im
  WoW-Menü; keine automatische Belegung, kein Makro. `/plead`, `/patilead`; eigene `PaTiLeadDB` (alte Einstellungen
  bewusst nicht übernommen)
- Tests: 15 Unit-Tests · Offen im Spiel: alles (PT-LEAD-001–103; alte PT-GROUP-Tests archiviert)

## PaTiQuest, PaTiDungeon
- Funktion: ausgewählte Quest mit Zielen · Instanz, Gruppe, Kampfstatus
- Tests: 7 bzw. 8 Unit-Tests · Im Spiel bestätigt: Icon · Offen: alles Übrige

## PaTiAlerts
- Funktion: offene Probleme aus PaTiTank (Aggro), PaTiAuras (Buffs, Waffenbuffs, Gruppenbuffs), PaTiHeal (bannbare
  Debuffs; der Heal-Target-Rahmen meldet nichts); optionaler Empfänger
- Tests: 18 Unit-Tests · Im Spiel bestätigt: `/pal test`, Icon · Offen: echte Alerts der anderen Addons

## PaTiSocial (TOC 0.1.0) — „Party Social“
- Funktion: frei belegbare Schnellbuttons für Emotes und kurze Nachrichten; ein Klick = eine Aktion
- Tests: 14 Unit-Tests
- Im Spiel bestätigt 2026-10-02: lädt ohne Fehler, Icon, Anzahl der Buttons, horizontal/vertikal, Emote-Button
- Offen im Spiel: Nachrichten (Sagen/Gruppe), Einstellungen pro Button, PaTiSuite; `/psocial debug`-Ausgabe

## PaTiSuite (TOC 0.1.0)
- Funktion: optionales Steuerfenster — installierte PaTi-Fenster einzeln oder alle ein-/ausblenden; Reihenfolge
  Heal, Auras, Tank, Rota, Group, Lead, Quest, Dungeon, Social, Alerts; im Kampf gesperrte Fenster (Heal, Auras, Rota,
  Lead) werden genannt und nicht angefasst. Schema 4: alte PaTiGroup-Sichtbarkeit → PaTiLead (PT-SUITE-035–037)
- Tests: 32 Unit-Tests
- Im Spiel bestätigt: einzelnes Ein-/Ausblenden, Alle anzeigen/ausblenden, Statusfarben, Hover, Icon
- Offen im Spiel: Sichtbarkeit über `/reload`, horizontal, Tooltips, neue Einträge

## PaTiShared 0.4.0 (Entwicklungsquelle, kein WoW-Addon, wird nicht veröffentlicht)
- Fenster, Menü, Modal (mit `AddNote`), Button, Dropdown, Checkbox, Popup, Tooltip, Badge, Aura-Icon; 12 Unit-Tests
- Neu 2026-10-02, ungetestet: ruhigerer Fenstertitel (`UI.WindowHeader`), in alle elf Runtime-Addons synchronisiert

## Hardening Stufe 1 (2026-10-02, ohne Verhaltensänderung am Secure-Code)
- Migrationen in allen elf Addons robust gegen kaputte Saves (Robustheits- und Idempotenz-Tests); kaputte gespeicherte
  Fensterposition → Standard; Anzeige-Fenster im Kampf verschiebbar (PT-SUITE-154); `/debug` zeigt den letzten
  abgefangenen Fehler (Heal, Auras, Tank, Rota, Lead); Reset-Semantik dokumentiert. Stufe 2 erst nach dem Ingame-Test (F32)

## Themes (2026-10-03)
- PaTiShared 0.4.0 in allen elf Addons; „Standard wiederherstellen“ in PaTiSuite setzt das Theme aller Fenster auf
  Default (PT-SUITE-168); offene Popups zeichnen sich beim Wechsel neu. Bekannte Grenzen: Tooltip-Rahmen bleibt
  Blizzard, WoForever ohne Verzierung (Entscheidung nach dem visuellen Test). **Code-Freeze** für Themes bis zum
  Ingame-Test.
- Drei Themes in PaTiShared: Default (wie bisher), WoForever (warmes Braun, Gold/Bronze), Dracula (Lila/Pink/Cyan);
  nur Farben. Jedes Addon speichert sein Theme selbst (Einstellungen → Fenster → Theme); PaTiSuite schaltet alle um.
  Im Spiel bestätigt 2026-10-03: Live-Themewechsel (PT-SUITE-167).
  Offen im Spiel: PT-SUITE-160–166, PT-HEAL-152

## Nächster Schritt
- Ordner im WoW-AddOns-Verzeichnis: alten `PaTiGroup/` ersetzen, `PaTiLead/` und `PaTiRota/` neu
- Zuerst prüfen: Laden aller Addons, `/ph debug` (Heal-Target-Treiber), `/prota debug`, `/pg debug`
- Offene Liste: `tools/ingame-status.sh --list open` und `--list retest`
