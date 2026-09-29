# Entwicklungsstand

Stand: 2026-09-29. „Im Spiel bestätigt“ heißt: vom Besitzer im Client getestet. Alles andere ist nur per Code,
Unit-Tests, Smoke-Tests mit Mocks und CI geprüft — grüne CI heißt nicht, dass es im Spiel funktioniert.
Release-Regeln, Beta-Kriterien und Freeze: [`docs/RELEASE.md`](docs/RELEASE.md). Tests: [`docs/TESTING.md`](docs/TESTING.md).

## Release-Reife

| Addon | Version (TOC) | Code | CI | Paket (ZIP geprüft) | Doku | Fresh Install | WoW-Test | Beta |
|---|---|---|---|---|---|---|---|---|
| PaTiHeal | 0.6.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ teilweise (Klickzauber, Migration, Sprache) | Nein |
| PaTiAuras | 0.1.0 | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ nur `/pa debug`, Priester-IDs | Nein |
| PaTiTank | 0.1.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiGroup | 0.4.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiQuest | 0.1.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |
| PaTiDungeon | 0.1.0 + [Unreleased] | ✅ | ✅ | ✅ | ✅ | ⏳ | ⏳ | Nein |

✅ = erledigt und geprüft · ⏳ = offen. Lizenz: MIT in allen acht Repos. Icons: PaTiSuite-Set in allen sechs Addons
(`Media/icon.tga` im Spiel, `assets/` für Plattformen) — im Spiel noch nicht gesehen.

## Alle sechs Addons
- Eigenständig: keine Abhängigkeit untereinander (TOC-Prüfung erzwingt das), eigene SavedVariables, eigene Slash-Befehle
- PaTiShared-Oberfläche 0.3.0 eingebettet; `•••`-Menü mit Einstellungen, Sperren, Ein-/Ausklappen (gespeichert),
  Testmodus, Ausblenden; Position gespeichert; Sprachen enUS/deDE (zhCN/zhTW/koKR → Englisch außer Menütexten)
- Befehle: allein = ein-/ausblenden, `show hide test lock unlock reset settings debug version`
- Release: ZIP mit genau einem Ordner (inkl. Icon, ohne `assets/`/LICENSE), Entwurfs-Release per Tag `vX.Y.Z`,
  Bug-Report-Vorlage; Release-Workflow noch nie gelaufen (erst mit dem ersten Tag)

## PaTiHeal
- Funktion: Gruppenrahmen (Leben, Mana, Tank-Streifen), Klickzauber für neun Kombinationen mit Rangwahl, eigene HoTs und
  Schilde (Schamane, Priester) mit Aufladungen/Timer rechts oder unten, bannbare Debuffs, Klick-Reinigen über die
  normale Klickbelegung
- Neu: Größe (Skalierung, im Kampf erst nach dem Kampf), kein Debuff-Scan mehr bei Leben/Mana-Events (F20)
- Architektur: Logic (rein) · SpellBook · Dispels · Profiles · HoTs · Settings · PaTiHeal.lua (500 Zeilen, F13)
- Tests: 31 Unit-Tests, Smoke-Tests mit Mocks
- Im Spiel bestätigt: Laden ohne Lua-Fehler, alte Belegung übernommen, Links- und Shift+Rechts-Klickzauber,
  Einstellungen, Sprachwahl nach `/reload`
- Offen im Spiel: Ränge, bannbare Debuffs, HoTs/Schilde, Klick-Reinigen, Kampfverhalten, Spell-IDs (`/ph auras`)

## PaTiAuras
- Funktion: eigene Buffs, Procs, Gruppenbuffs (auch solo, Click-to-Buff auf das nächste fehlende Mitglied),
  Heil-Auren pro Mitglied; jede Aura einzeln abschaltbar; Profile Schamane, Priester
- Tests: 45 Unit-Tests
- Im Spiel bestätigt: `C_UnitAuras` und `issecretvalue` vorhanden (`/pa debug`), Priester-IDs für Selbst- und Gruppenbuffs
- Offen im Spiel: alles Übrige, besonders Click-to-Buff, Kampf, Schamanen-IDs, Priester-Heilauren

## PaTiTank
- Funktion: eigene Gesundheit, Ziel, Bedrohung; Aggro-Kontrolle („x / y unter Kontrolle“, Warnzeilen verlorener Gegner
  mit Rolle des Halters, „knapp“, „unklar“), Testmodus mit 6 Gegnern
- Neu: nummerierte Problem-Gegner — dieselbe Nummer (1–4) im Panel und über dem Namensschild, Farbe = Zustand;
  unterscheidet auch gleichnamige Gegner. Klick aufs Namensschild wählt ihn als Ziel. Anklickbare Panel-Zeilen: technisch blockiert (F17, WOW_API_COMPAT)
- Tests: 22 Unit-Tests (Aggro-Regeln, Threat-Adapter, Namensschild-Marker mit Mocks), Smoke-Tests
- Offen im Spiel: alles, besonders Aggro-Kontrolle und Marker im echten Kampf, Threat-APIs, Taint-Log

## PaTiGroup
- Funktion: acht Marker + Entfernen, Reset All, Ready Check, Pull, Ziel/Leitung/Rollen, Notiz; Tastenbelegung im
  WoW-Menü mit hervorgehobenem Hinweis in den Einstellungen; keine automatische Belegung, kein Makro
- Tests: 14 Unit-Tests
- Offen im Spiel: alles seit der Umstellung, der echte Menüpfad der Tastaturbelegung

## PaTiQuest, PaTiDungeon
- Funktion: ausgewählte Quest mit Zielen · Instanz, Gruppe, Kampfstatus
- Tests: 7 bzw. 8 Unit-Tests
- Offen im Spiel: alles seit der Umstellung

## PaTiShared 0.3.0 (Entwicklungsquelle, kein WoW-Addon, wird nicht veröffentlicht)
- Fenster, Menü, Modal (mit `AddNote`), Button, Dropdown, Checkbox, Popup, Tooltip, Badge, Aura-Icon; 7 Unit-Tests

## Nächster Schritt
- Fresh-Install- und Kurztests im Spiel nach [`docs/TESTING.md`](docs/TESTING.md#short-in-game-list-per-release-candidate)
- Icons in der AddOn-Liste prüfen, Namensschild-Marker im echten Pull testen
