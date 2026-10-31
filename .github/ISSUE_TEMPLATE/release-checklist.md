---
name: Release-Checkliste
about: Ein Addon-Release von der Prüfung bis zur Plattform abarbeiten
title: "Release: <Addon> <Version>"
labels: release
---

Ablauf: [PUBLISHING.md](https://github.com/patpaskoch/PaTiAdmin/blob/main/docs/PUBLISHING.md) und
[RELEASE.md](https://github.com/patpaskoch/PaTiAdmin/blob/main/docs/RELEASE.md).
Keine Tokens oder Kontodaten in dieses Issue schreiben.

**Addon:**
**Version:**
**Art:** Beta / Stabil / Fehlerbehebung / Interface-Update

## Vorbereitung
- [ ] `tools/check.sh` und CI grün
- [ ] Ingame-Tests der geänderten Bereiche eingetragen, Beta-Gate erfüllt
- [ ] Bekannte Fehlschläge bewertet (`tools/ingame-status.sh --list failed`)
- [ ] README, CHANGELOG und TOC passen zum Code

## GitHub
- [ ] Version in der TOC erhöht, CHANGELOG-Abschnitt erstellt
- [ ] Commit gepusht, CI grün
- [ ] Tag gepusht, Release-Entwurf erzeugt
- [ ] Zip aus dem Entwurf frisch installiert und getestet
- [ ] Bei Beta „pre-release“ gewählt
- [ ] Release veröffentlicht

## Plattformen (dasselbe Zip)
- [ ] CurseForge: hochgeladen, Forever 1.60.1, richtiger Typ
- [ ] Wago: hochgeladen, Forever-Patch, richtige Stabilität
- [ ] WoWInterface: hochgeladen, Forever gewählt
- [ ] Release-Notes überall gleich
- [ ] Seiten geprüft: sichtbar, Download funktioniert, Moderation durch

## Abschluss
- [ ] Beschreibung, Screenshots und Status auf den Seiten aktuell
- [ ] Ankündigung gepostet (nur bei größeren Releases)
- [ ] `SUITE_STATUS.md` aktualisiert, `INGAME_TEST_STATUS.md` neu erzeugt
- [ ] Zugehörige Fehler-Issues geschlossen
