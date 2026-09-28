# PaTi Addons – Arbeitsregeln

- Jedes Addon ist ein eigenes Git-Repository.
- Entwickle nur in `C:\Users\patpa\code`.
- Der WoW-AddOns-Ordner ist ausschliesslich ein Installations- und Testziel.
- Vor jeder Installation Dateien lokal pruefen und danach im Spiel mit `/reload` testen.
- Keine automatischen Spielentscheidungen implementieren.
- Secure Buttons und Attribute niemals waehrend Combat Lockdown aendern.
- Secret Values nur direkt an erlaubte WoW-Widgets weitergeben; keine Lua-Arithmetik darauf anwenden.
- Gemeinsame UI (Design, Komponenten, Sprachen) wird nur in `C:\Users\patpa\code\PaTiShared` entwickelt und per `scripts/sync-shared.sh` in `<Addon>/Shared/` kopiert. `<Addon>/Shared/` nie von Hand aendern.
- Alle Addons unterstuetzen Englisch, Deutsch, Chinesisch (zhCN) und Koreanisch (koKR); die Sprache ist in den Einstellungen waehlbar.
