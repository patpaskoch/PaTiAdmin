# Entwicklungsstand

Stand: 2026-09-28. „Im Spiel bestätigt“ heißt: vom Besitzer im Client getestet. Alles andere ist nur per Code,
Unit-Tests und CI geprüft.

## PaTiShared 0.3.0 (Entwicklungsquelle, kein WoW-Addon)
- Fenster mit `•••`-Menü, Modal, Button (auch für Secure-Buttons), Dropdown, Checkbox, Popup, Tooltip, Badge, Aura-Icon
- Sprachen enUS/deDE (zhCN/koKR ungeprüft, zhTW → Englisch)
- Eingebettet in PaTiHeal, PaTiAuras, PaTiGroup

## PaTiHeal (TOC 0.6.0, Änderungen unter [Unreleased])
- PaTiShared-Oberfläche, Einstellungsfenster, Sprachen, SavedVariables Schema 2 mit Migration
- Neun Klickzauber-Kombinationen mit Rangwahl, bannbare Debuffs, Name in Klassenfarbe, Leben in Prozent, Tank-Streifen
- Im Spiel bestätigt: Laden ohne Lua-Fehler, Übernahme der alten Belegung, Links- und Shift+Rechts-Klickzauber,
  Einstellungen, Sprachwahl bleibt nach `/reload`
- Offen im Spiel: Ränge, bannbare Debuffs, Kampf-Verhalten, neue Rahmen-Optik, alle übrigen Klick-Kombinationen

## PaTiAuras (TOC 0.1.0, neu)
- Eigenes Addon: eigene Buffs, Procs, Gruppenbuff-Übersicht, Heil-Auren; Zustände aktiv/fehlt/läuft aus/unbekannt
- Schamanen-Profil; Spell-IDs noch nicht im Client bestätigt (`/pa auras`)
- Offen: alles im Spiel; Priester-Profil, Click-to-Buff und PaTiHeal-Anbindung noch nicht gebaut

## PaTiGroup (TOC 0.4.0, Änderungen unter [Unreleased])
- PaTiShared-Oberfläche, alle acht Marker + Entfernen, Reihenfolge einstellbar, Ziel/Leitung/Rollen, Notiz,
  Ready Check, Pull, Tastenbelegung im WoW-Menü; keine automatische Belegung, kein Makro mehr
- Offen im Spiel: alles seit der Umstellung

## PaTiTank, PaTiQuest, PaTiDungeon (TOC 0.1.0)
- TOC-Fehler behoben (Addons laden laut Code wieder); noch alte Oberfläche mit `PaTiSharedPanel`
- Nächster Schritt: Umstellung auf PaTiShared (Auftrag vom 2026-09-28)

## Nächster Schritt
- Manuelle Tests im Spiel nach `PaTiAdmin/docs/TESTING.md`, besonders `/pa auras`, Kampf-Tests und Secure-Aktionen.
