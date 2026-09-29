# PaTi Addons – Entwicklung

Die Arbeitsregeln stehen in [`AGENTS.md`](AGENTS.md), der Entwicklungsablauf in [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md).

Kurzfassung:

- Entwicklungsprojekt: ein Code-Ordner mit PaTiAdmin, PaTiShared, PaTiAddons/<Addon>
- Installierte WoW-Addons (nur Testziel): `<WoW>/_classic_beta_/Interface/AddOns`
- Client: Build `1.60.1.70009`, Interface `16001`
- Vor jedem Commit: `PaTiAdmin/tools/check.sh`
- Nach dem Kopieren ins Spiel: `/reload` und testen, dann committen
