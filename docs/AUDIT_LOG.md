# Audit-Log (Deutsch)

## 2026-11-08 (Nachhol-Lauf, im Lauf vom 2026-11-15 ausgeführt, Prompt war am Ende abgeschnitten)
Umgesetzt (Branch `ccr-5f8e7a2b-enxpxt`, nicht gemergt, kein PR):
- PaTiAlerts: Filter-Checkbox konnte nie wieder angehakt werden (`shown and nil or false` ergibt immer false) → `Logic.SetFilter` + Test. Spieltest PT-ALERTS-045 offen.
- PaTiAggro: `HolderLabel` liefert `OTHER_PLAYER` statt `OTHER`. Retest PT-TANK-065 offen.
- PaTiAuras: Restore Defaults im Kampf gesperrt. Test PT-AURAS-124 offen.
- PaTiHeal: `followState(targetRow, data)` bei `PLAYER_TARGET_CHANGED` (Auferstehungs-Klick bei totem Ziel). Prompt-Text hier abgeschnitten – Deutung "PLAYER_TARGET_CHANGED" ist eine Annahme.
Tests: `check.sh` je Addon grün (tests/luacheck). Ingame nichts getestet.
