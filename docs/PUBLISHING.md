# Veröffentlichen — Handbuch für Plattformen, Releases und Updates

Stand: 2026-10-31. Dieses Handbuch beschreibt, wie jede Plattform eingerichtet und jedes Release veröffentlicht wird.

- **Abhaken:** in den [GitHub-Issues mit Label `launch`](https://github.com/patpaskoch/PaTiAdmin/issues?q=label%3Alaunch).
- **Jedes neue Release:** ein Issue aus der Vorlage „Release-Checkliste“ anlegen.
- **Technische Release-Schritte:** [`RELEASE.md`](RELEASE.md). Wellen und Kanäle: [`LAUNCH.md`](LAUNCH.md).

## Grundregeln

- **Nichts Privates in dieses Repo.** Es ist öffentlich: keine Tokens, Passwörter, Kontodaten oder Einnahmen, auch nicht
  in Issues.
- **GitHub zuerst.** Jede Datei entsteht dort. Auf alle Plattformen kommt dasselbe Zip aus dem GitHub-Release.
- **Nur Forever auswählen.** Interface 16001 / Spielversion 1.60.1. Fehlt Forever in der Auswahl: abbrechen, nicht auf
  einen anderen Client ausweichen.
- **Nur getestet veröffentlichen.** Das Beta-Gate aus `RELEASE.md` gilt vor jedem Upload.
- **Im Addon keine Werbung und kein Spendenaufruf.** Spendenlinks stehen nur auf Webseiten und in Repos.
- **Uploads macht der Owner** in seinen Konten. Agenten liefern Zip-Prüfung, Texte und Release-Notes.

## Wo was gemacht wird

| Bereich | Ort | Einrichtung | Uploads |
|---|---|---|---|
| GitHub | Repo jedes Addons | Owner und Agent | Workflow erzeugt Entwurf, Owner veröffentlicht |
| CurseForge | [Author Console](https://authors.curseforge.com/) | Owner | manuell |
| Wago Addons | [Developer-Bereich](https://addons.wago.io/developers) | Owner | manuell |
| WoWInterface | [wowinterface.com](https://www.wowinterface.com/) | Owner | manuell |
| Ko-fi | [ko-fi.com](https://ko-fi.com/) | Owner | keine |

## Plattformen einrichten

Die folgenden Abläufe stammen aus den verlinkten Quellen. Felder, die dort fehlen, sind als „prüfen“ markiert. Was du
beim Einrichten siehst, wird hier nachgetragen.

### GitHub

- Beschreibung, Website-Link und Topics jedes Repos setzen (`world-of-warcraft`, `wow-addon`, `wow-forever`).
- README beginnt mit Logo oder Screenshot, Funktionen, Installation, Befehlen und bekannten Grenzen.
- `.github/FUNDING.yml` mit dem Ko-fi-Namen in jedem öffentlichen Addon-Repo.
- Release-Entwurf prüfen, bei Beta „pre-release“ wählen, dann veröffentlichen.

### CurseForge

- In der Author Console „Create a Project“ wählen, Spiel World of Warcraft, Klasse Addons.
- Projektdaten ausfüllen und das Projekt-Logo hochladen (Maße prüfen; `assets/icon-512.png` ist vorhanden).
- Datei im Reiter „Files“ hochladen. Laut einer Drittquelle startet erst damit die Moderation. Die Dauer ist nicht
  belegt, also Zeit einplanen.
- Dabei Forever 1.60.1 und den Release-Typ wählen (Beta oder Release).
- Rewards-Programm im Author-Bereich aktivieren, falls gewünscht.

### Wago Addons

- Mit genau einem Konto arbeiten.
- Projekt im Developer-Bereich anlegen. Die Projekt-ID hat 8 Zeichen und steht unter dem Addon-Namen.
- Version hochladen: Label, Stabilität (`stable`, `beta`, `alpha`), Changelog, unterstützter Patch.
- Prüfen: Forever als Patch wählbar? Die öffentliche Doku nennt bisher nur Retail, WotLK, BC und Classic.

### WoWInterface

- Konto anlegen und die Upload-Bedingungen lesen.
- Datei hochladen. Das Zip darf nur den Addon-Ordner enthalten; das erfüllt `package.sh`.
- Prüfen: Forever in der Kompatibilitätsliste? Wenn nicht, gilt die Grundregel oben und die Plattform wird zurückgestellt.
- Aktuelle Anleitungen waren nicht auffindbar. Die Felder beim ersten Upload hier nachtragen.

### Ko-fi

- Konto anlegen und Stripe oder PayPal verbinden.
- Einmalige Spenden kosten laut Drittquellen keine Plattformgebühr; die Zahlungsanbieter berechnen aber Gebühren.
- Seite kurz halten: PaTiSuite, Logo, Link zu GitHub. Kostenlos bleibt kostenlos; keine Gegenleistung für Spenden.
- Den Nutzernamen an den Agenten geben (`FUNDING.yml`, README, Plattformtexte).

## Richtig präsentieren

Jede Addon-Seite sieht auf jeder Plattform gleich aus.

| Baustein | Inhalt | Quelle |
|---|---|---|
| Name | exakt der TOC-Titel, z. B. `PaTiHeal` | `## Title` |
| Logo | PaTiSuite-Icon des Addons | `assets/icon-512.png` |
| Kurztext | ein Satz: was es tut | `## Notes` |
| Beschreibung | Was es tut · Funktionen · Installation · Befehle · Bekannte Grenzen · PaTiSuite-Familie · Support | README |
| Screenshots | mindestens 3, einer im WoForever-Theme, keine Namen fremder Spieler | Liste in `RELEASE.md` |
| Spielversion | WoW Forever 1.60.1 | TOC |
| Sprachen | Englisch, Deutsch; Deutsch als eigener Abschnitt | README |
| Lizenz | MIT | `LICENSE` |
| Links | GitHub, Issues, Ko-fi | Repo |

Am Ende jeder Beschreibung steht derselbe Block mit Links zu den anderen PaTi-Addons, damit die Seiten zusammengehören.
Dabei nur bereits veröffentlichte Addons verlinken. Der Status „Beta“ steht sichtbar am Anfang der Beschreibung.

Ankündigungen: eine pro Welle und Kanal, in Forever-Discord und Foren zuerst, danach r/wowaddons. Regeln des jeweiligen
Kanals vorher lesen.

## Ablauf eines Releases

1. Issue aus der Vorlage „Release-Checkliste“ anlegen.
2. Release wie in `RELEASE.md` bauen: Tests, Version, CHANGELOG, Tag, Entwurf.
3. Zip aus dem Entwurf auf dem Rechner testen (Fresh-Install-Test).
4. GitHub-Release veröffentlichen.
5. Dasselbe Zip nacheinander auf CurseForge, Wago und WoWInterface hochladen, mit denselben Release-Notes.
6. Auf jeder Plattform kontrollieren: sichtbar, richtige Spielversion, richtiger Typ, Download klappt.
7. Seiten aktualisieren, wenn sich Funktionen, Screenshots oder Grenzen geändert haben.
8. Bei größeren Releases ankündigen.

## Updates

| Fall | Version | Vorgehen |
|---|---|---|
| Fehlerbehebung | `-beta.N+1` oder PATCH | normaler Ablauf; Tests nur für den betroffenen Bereich plus Laden |
| Neue Funktion | MINOR | normaler Ablauf, Seite und Screenshots prüfen; im Beta-Freeze nicht erlaubt |
| Forever-Patch ohne neue Interface-Nummer | keine Änderung | Smoke-Test; bei Fehlern Fehlerbehebung |
| Neue Interface-Nummer | PATCH für alle Addons | alle TOCs und `SUITE_INTERFACE` in `tools/check.sh` ändern, `WOW_API_COMPAT.md` nachziehen, Smoke-Test, alle veröffentlichten Addons neu hochladen |
| Beta wird stabil | Version ohne `-beta.N` | Beta-Gate und stabile Phase bestätigt, Status auf den Seiten ändern, ankündigen |
| Kritischer Fehler | PATCH sofort | fehlerhafte Datei auf den Plattformen zurückziehen oder ausblenden, Fehler nennen, Korrektur hochladen |

**Nach jedem Update:** offene Issues des Release schließen, `SUITE_STATUS.md` aktualisieren und `INGAME_TEST_STATUS.md`
neu erzeugen.

**Pflege:** alle 4 Wochen Issues und Plattform-Kommentare durchgehen, Downloads notieren und Forever-Patches prüfen.

## Automatisierung

Bewusst noch nicht eingerichtet. Der [BigWigs Packager](https://github.com/BigWigsMods/packager) kann auf alle drei
Plattformen hochladen (`CF_API_TOKEN`, `WAGO_API_TOKEN`, `WOWI_API_TOKEN`, IDs als `X-Curse-Project-ID`, `X-Wago-ID`,
`X-WoWI-ID` in der TOC). Forever wird in seiner Doku aber nicht als Flavor genannt, und auch der Wago-Upload nennt
Forever nicht. Entscheidung deshalb nach Welle 1, wenn die manuellen Abläufe bekannt sind.

## Quellen

- [CurseForge: Autor werden](https://blog.curseforge.com/how-to-become-a-curseforge-author/)
- [CurseForge-Ablauf laut Drittquelle](https://hytalemodding.dev/en/docs/publishing/curseforge)
- [Wago-Dokumentation](https://docs.wago.io/)
- [WoWInterface: Paketregeln im Forum (2015)](https://www.wowinterface.com/forums/archive/index.php/t-52700.html)
- [Ko-fi-Gebühren laut Drittquelle](https://www.ruzuku.com/learn/articles/ko-fi-pricing)
