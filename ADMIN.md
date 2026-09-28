# PaTi Addons – Entwicklung

Dieser Ordner ist die einzige Entwicklungsquelle fuer die PaTi-Addons.

## Ordner

- Entwicklungsprojekt: `C:\Users\patpa\code\PaTiAddons`
- Installierte WoW-Addons: `D:\Users\patpa\Apps\wow\World of Warcraft\_classic_beta_\Interface\AddOns`
- Aktueller WoW-Client: Build `1.60.1.70009`, Interface `16001`

## Arbeitsablauf

1. Code nur im Entwicklungsprojekt aendern.
2. Geaenderte Dateien lokal pruefen.
3. Nur die betroffenen Dateien in den gleichnamigen Ordner unter `Interface\AddOns` kopieren.
4. Im Spiel `/reload` ausfuehren und testen.
5. Den getesteten Stand mit Git sichern.

Der WoW-Ordner ist nur das Installations- und Testziel. Er ist keine Entwicklungsquelle.

## Addons

- `PaTiHeal` – Heiler-UI
- `PaTiGroup` – Gruppen- und Raid-Werkzeuge
- `PaTiTank` – geplantes Tank-HUD
- `PaTiQuest` – geplanter Duo-Quest-Begleiter
- `PaTiDungeon` – geplanter Dungeon-Begleiter

## Sicherheitsregeln

- Secure Buttons und Attribute nie waehrend Combat Lockdown aendern.
- Secret Values direkt an passende WoW-Widgets weiterreichen; keine Lua-Rechnung darauf ausfuehren.
- Keine automatische Zielwahl, Zauberwahl oder Spielentscheidung implementieren.
