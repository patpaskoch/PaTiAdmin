# Entwicklungsstand

Stand: 2026-09-30. „Im Spiel bestätigt“ heißt: vom Besitzer im Client getestet. Die einzelnen Ingame-Tests mit
Ergebnis stehen in `INGAME_TESTING.md` jedes Addons, Übersicht:
[`docs/INGAME_TEST_STATUS.md`](docs/INGAME_TEST_STATUS.md). Alles andere ist nur per Code,
Unit-Tests, Smoke-Tests mit Mocks und CI geprüft — grüne CI heißt nicht, dass es im Spiel funktioniert.
Release-Regeln, Beta-Kriterien und Freeze: [`docs/RELEASE.md`](docs/RELEASE.md). Tests: [`docs/TESTING.md`](docs/TESTING.md).

## Release-Reife

| Addon | Version (TOC) | Code | CI | Paket (ZIP geprüft) | Doku | Fresh Install | WoW-Test | Beta |
|---|---|---|---|---|---|---|---|---|
| PaTiHeal | 0.6.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ teilweise (Klickzauber, Migration, Sprache) | Nein |
| PaTiAuras | 0.1.0 | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ teilweise; Waffenbuff-Fix 2026-10-02 ungetestet | Nein |
| PaTiTank | 0.1.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiGroup | 0.4.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiQuest | 0.1.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiDungeon | 0.1.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiAlerts | 0.1.0 (neu) | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ nur `/pal test` | Nein |
| PaTiSuite | 0.1.0 (neu, Steuerung) | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ teilweise (Ein-/Ausblenden, Farben, Hover) | Nein |

✅ = erledigt und geprüft · ⏳ = offen. Lizenz: MIT in allen zehn Repos. Icons: PaTiSuite-Set in allen acht Addons (inkl. PaTiSuite)
(`Media/icon.tga` im Spiel, `assets/` für Plattformen) — im Spiel noch nicht gesehen.

## Alle sieben Addons
- Eigenständig: keine Abhängigkeit untereinander (TOC-Prüfung erzwingt das), eigene SavedVariables, eigene Slash-Befehle
- PaTiShared-Oberfläche 0.3.0 eingebettet; `•••`-Menü mit Einstellungen, Sperren, Ein-/Ausklappen (gespeichert),
  Testmodus, Ausblenden; Position gespeichert; Sprachen enUS/deDE (zhCN/zhTW/koKR → Englisch außer Menütexten)
- Fenster: einstellbare Deckkraft (30–100 %, Standard 75 %), Registrierung für das optionale PaTiSuite-Steuerfenster.
  Einrasten wurde nach dem Spieltest (funktionierte nicht) wieder entfernt
- Befehle: allein = ein-/ausblenden, `show hide test lock unlock reset settings debug version`
- Release: ZIP mit genau einem Ordner (inkl. Icon, ohne `assets/`/LICENSE), Entwurfs-Release per Tag `vX.Y.Z`,
  Bug-Report-Vorlage; Release-Workflow noch nie gelaufen (erst mit dem ersten Tag)

## PaTiHeal
- Funktion: Gruppenrahmen (Leben, Mana, Tank-Streifen), Klickzauber für neun Kombinationen mit Rangwahl, eigene HoTs und
  Schilde (Schamane, Priester) mit Aufladungen/Timer rechts oder unten, bannbare Debuffs, Klick-Reinigen über die
  normale Klickbelegung
- Neu: Größe (Skalierung, im Kampf erst nach dem Kampf), kein Debuff-Scan mehr bei Leben/Mana-Events (F20)
- Architektur: Logic (rein) · SpellBook · Dispels · Profiles · HoTs · Settings · PaTiHeal.lua (500 Zeilen, F13)
- Tests: 34 Unit-Tests, Smoke-Tests mit Mocks
- Im Spiel bestätigt: Laden ohne Lua-Fehler, alte Belegung übernommen, Links- und Shift+Rechts-Klickzauber,
  Einstellungen, Sprachwahl nach `/reload`; 2026-09-30 Linksklick auf den eigenen Frame
- Offen im Spiel: Ränge, bannbare Debuffs, HoTs/Schilde, Klick-Reinigen, Kampfverhalten, Spell-IDs (`/ph auras`)

## PaTiAuras
- Funktion: eigene Buffs, Procs, Gruppenbuffs (auch solo, Click-to-Buff auf das nächste fehlende Mitglied),
  Heil-Auren pro Mitglied; jede Aura einzeln abschaltbar; Profile Schamane, Priester
- Schamanen-Waffenbuffs (Waffenhand/Schildhand) als eigene Datenquelle; V1 ohne Imbue-Art. Im Spiel (2026-09-30):
  Waffe an/ab/an wird erkannt; aktiver Felsbeißer zeigte „Fehlt“ (❌ PT-AURAS-053–055, 057). Ursache aus dem
  Owner-`/pa auras` 2026-10-02: das klassische Tupel meldet „kein Imbue“, `C_Item.GetWeaponEnchantInfo` hat ihn
  (`hasEnchant`, `timeLeft>0`, `enchantType=3`). Fix 2026-10-02: moderne API zuerst — **im Spiel noch nicht
  geprüft**
- Einstellungen: eine „Beobachten“-Auswahl statt Kategorie-Schaltern und doppelter Liste (Schema 2 mit Migration)
- PaTiAlerts: fehlende beobachtete Gruppenbuffs als eine Warnung pro Buff („Fehlt bei N“), neu, nicht im Spiel geprüft
- Tests: 86 Unit-Tests
- Im Spiel bestätigt: `C_UnitAuras` und `issecretvalue` vorhanden (`/pa debug`), Priester-IDs für Selbst- und
  Gruppenbuffs; 2026-09-30 Beobachten-Menü (ein Priester-Effekt an/ab), ein aktiver Priester-Gruppenbuff erkannt
- Offen im Spiel: alles Übrige, besonders Waffenbuffs, Click-to-Buff, Kampf, Schamanen-IDs, Priester-Heilauren

## PaTiTank
- Funktion: eigene Gesundheit, Ziel, Bedrohung; Aggro-Kontrolle („x / y unter Kontrolle“, Warnzeilen verlorener Gegner
  mit Rolle des Halters, „knapp“, „unklar“), Testmodus mit 6 Gegnern
- Neu: nummerierte Problem-Gegner — dieselbe Nummer (1–4) im Panel und über dem Namensschild, Farbe = Zustand;
  unterscheidet auch gleichnamige Gegner. Klick aufs Namensschild wählt ihn als Ziel. Anklickbare Panel-Zeilen: technisch blockiert (F17, WOW_API_COMPAT)
- Tests: 34 Unit-Tests (Aggro-Regeln, Nummern, Threat-Adapter, Namensschild-Marker, Alerts mit Mocks), Smoke-Tests
- Offen im Spiel: alles, besonders Aggro-Kontrolle und Marker im echten Kampf, Threat-APIs, Taint-Log

## PaTiGroup
- Funktion: acht Marker + Entfernen, Reset All, Ready Check, Pull, Ziel/Leitung/Rollen, Notiz; Tastenbelegung im
  WoW-Menü mit hervorgehobenem Hinweis in den Einstellungen; keine automatische Belegung, kein Makro
- Tests: 15 Unit-Tests
- Offen im Spiel: alles seit der Umstellung, der echte Menüpfad der Tastaturbelegung

## PaTiQuest, PaTiDungeon
- Funktion: ausgewählte Quest mit Zielen · Instanz, Gruppe, Kampfstatus
- Tests: 7 bzw. 8 Unit-Tests
- Offen im Spiel: alles seit der Umstellung

## PaTiAlerts (TOC 0.1.0, neu)
- Funktion: „Was braucht gerade meine Aufmerksamkeit?“ — offene Probleme aus PaTiTank (Aggro, gleiche Nummer wie
  Panel und Namensschild), PaTiAuras (fehlende/auslaufende eigene Buffs und Waffenbuffs, fehlende beobachtete
  Gruppenbuffs), PaTiHeal (bannbare Debuffs);
  rot/gelb/blau, kurzes einmaliges Hervorheben, automatisch ausblenden, Filter nach Quelle und Priorität
- Optionaler Empfänger: kein Addon braucht PaTiAlerts; Producer melden nur, wenn `PaTiAlertsAPI` existiert
- Tests: 18 Unit-Tests, Smoke-Tests mit PaTiTank und PaTiHeal (Mocks)
- Im Spiel bestätigt (2026-09-30): `/pal test`
- Offen im Spiel: echte Alerts der anderen Addons; Waffenbuff-Warnung bleibt bei aktivem Imbue (Ursache PaTiAuras)

## PaTiSuite (TOC 0.1.0, neu)
- Funktion: optionales Steuerfenster — installierte PaTi-Fenster einzeln oder mit einem Button alle
  einblenden/ausblenden (Beschriftung je nach Zustand); im Kampf
  gesperrte Fenster (Heal, Auras, Group) werden genannt und nicht angefasst. Keine Spiellogik
- Tests: 18 Unit-Tests, Smoke-Test mit PaTiHeal + PaTiTank (Mocks, Stand vor dem Umbau 2026-10-02)
- Im Spiel bestätigt (2026-09-30): einzelnes Ein-/Ausblenden, die früheren Buttons „Alle anzeigen“/„Alle ausblenden“,
  grüne/graue Statusfarben, Hover-Lesbarkeit
- Neu, noch nicht im Spiel geprüft: ein dynamischer Button statt zwei; kompakte Einträge (nur Punkt + Name),
  Layout vertikal/horizontal, Einklappen (Schema 2); offen: Icon in der AddOn-Liste

## PaTiShared 0.3.0 (Entwicklungsquelle, kein WoW-Addon, wird nicht veröffentlicht)
- Fenster, Menü, Modal (mit `AddNote`), Button, Dropdown, Checkbox, Popup, Tooltip, Badge, Aura-Icon; 7 Unit-Tests

## Nächster Schritt
- Retest Waffenbuff-Fix (PT-AURAS-052–057), PaTiSuite neu (PT-SUITE-033/034, 048, 100–128), Gruppenbuff-Alerts
  (PT-AURAS-112–116); offene Liste: `tools/ingame-status.sh --list open`, dann
  Fresh-Install-Tests nach [`docs/TESTING.md`](docs/TESTING.md#release-testing-per-release-candidate)
- Icons in der AddOn-Liste prüfen, Namensschild-Marker im echten Pull testen
