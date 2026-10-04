# PaTiSuite Ingame Test Status

Stand: 2026-10-02. Übersicht über die Ingame-Testdateien der elf Runtime-Addons — die einzelnen Tests und ihre Historie
stehen nur in der jeweiligen `INGAME_TESTING.md` (Source of Truth). Regeln: [`TESTING.md`](TESTING.md#in-game-test-files).

Neu erzeugen: `tools/ingame-status.sh --markdown` (Tabelle unten ersetzen). Einzelne Listen:
`tools/ingame-status.sh --list failed` · `--list retest` · `--list open` · `--list verified`.

Verified = vom Owner im echten Client bestätigt (`[x]`). Failed = im Client fehlgeschlagen und noch nicht erneut bestätigt;
„davon Fix da, Retest offen“ = Codefix vorhanden, der Owner muss erneut testen. Open = noch nie im Client geprüft.


| Addon | Verified | Failed | davon Fix da, Retest offen | Open | Tests |
|---|---:|---:|---:|---:|---:|
| [PaTiAlerts](https://github.com/patpaskoch/PaTiAlerts/blob/main/INGAME_TESTING.md) | 2 | 0 | 0 | 40 | 42 |
| [PaTiAuras](https://github.com/patpaskoch/PaTiAuras/blob/main/INGAME_TESTING.md) | 19 | 0 | 0 | 109 | 128 |
| [PaTiDungeon](https://github.com/patpaskoch/PaTiDungeon/blob/main/INGAME_TESTING.md) | 1 | 0 | 0 | 39 | 40 |
| [PaTiGroup](https://github.com/patpaskoch/PaTiGroup/blob/main/INGAME_TESTING.md) | 0 | 0 | 0 | 34 | 34 |
| [PaTiHeal](https://github.com/patpaskoch/PaTiHeal/blob/main/INGAME_TESTING.md) | 13 | 1 | 1 | 79 | 93 |
| [PaTiLead](https://github.com/patpaskoch/PaTiLead/blob/main/INGAME_TESTING.md) | 0 | 1 | 1 | 52 | 53 |
| [PaTiQuest](https://github.com/patpaskoch/PaTiQuest/blob/main/INGAME_TESTING.md) | 1 | 0 | 0 | 36 | 37 |
| [PaTiRota](https://github.com/patpaskoch/PaTiRota/blob/main/INGAME_TESTING.md) | 15 | 2 | 1 | 29 | 46 |
| [PaTiSocial](https://github.com/patpaskoch/PaTiSocial/blob/main/INGAME_TESTING.md) | 6 | 0 | 0 | 31 | 37 |
| [PaTiSuite](https://github.com/patpaskoch/PaTiSuite/blob/main/INGAME_TESTING.md) | 7 | 0 | 0 | 85 | 92 |
| [PaTiTank](https://github.com/patpaskoch/PaTiTank/blob/main/INGAME_TESTING.md) | 1 | 0 | 0 | 58 | 59 |
