# Architecture

State of 2026-09-28. Update this file when an addon's structure, SavedVariables, events or secure frames change.

## Suite shape

- Seven Git repos (see `AGENTS.md` §2). No monorepo, no submodules, no runtime dependency between addons.
- **PaTiShared** (UI design system) is embedded per addon under `Shared/` via `sync-shared.sh`
  (`PaTiShared/README.md`). No addon embeds it yet — PaTiHeal is the planned first.
- **PaTiAdmin** holds rules, docs, the check/package tools and CI templates. It ships nothing to players.

## Data flow (target for new and changed code)

```
WoW event ──► adapter: read WoW API, guard missing APIs, return plain values/tables
          ──► state/logic: pure Lua on plain tables (unit-testable, no WoW calls)
          ──► UI: write widgets; secure attributes only out of combat
```
Today every addon is one file where event handler, API calls and UI updates are mixed. That is
accepted legacy: apply the flow when you touch a part, do not rewrite files for it (see FOLLOW_UPS.md).

## Existing patterns

| Pattern | How it is done today | Where |
|---|---|---|
| Init | one `events` frame; `PLAYER_LOGIN` creates/loads the DB, applies defaults, restores position | all |
| Events | `for _, e in ipairs({...}) do events:RegisterEvent(e) end` + one `OnEvent` | all |
| Refresh | most events call one `update()`/`refresh()` that redraws everything | all |
| Slash commands | `SLASH_X1..n` + `SlashCmdList.X = function(msg)`; trim + lower; unknown → help line | all |
| Chat output | `print("|cff68caff<Addon>:|r " .. text)` | all |
| Test mode | `testMode` local (not saved), fake data inside the data function, `/x test` toggles | Heal, Tank, Quest, Dungeon |
| Move/lock | frame drag via `OnDragStart`, `DB.locked` blocks it, `DB.x/DB.y` saved as CENTER offsets | Heal, Tank, Quest, Dungeon |
| Window chrome | `PaTiSharedPanel.Attach` (global, copied file) → gear, chevron, close | Tank, Quest, Dungeon |
| Combat guard | `if InCombatLockdown() then print(...) return end` before secure changes; re-apply on `PLAYER_REGEN_ENABLED` | Heal, Group |
| Missing APIs | `if C_X and C_X.Fn then` + `pcall(...)` | Heal, Quest, Group |
| Shared UI | `PaTiShared` components in `ns.UI` (Window, Modal, Dropdown, …) | none yet (PaTiHeal next) |
| Localization | `Locales/<code>.lua` → `ns.Locales[code].KEY`, lookup `UI.L.KEY` | PaTiShared only |

New code uses the PaTiShared rows instead of `PaTiSharedPanel` and hard-coded text.

## Addons

### PaTiHeal 0.6.0 — `PaTiHeal.lua` (338 lines)
- SavedVariablesPerCharacter `PaTiHealDB`: `x, y, locked, collapsed, clickSpellID, clickButton, clickModifier`.
- Secure: `PaTiHealUnit1..5` (`SecureUnitButtonTemplate`, units player, party1–4); attributes
  `[modifier-]type<n>` / `[modifier-]spell<n>` set in `applyClickSpell()` only out of combat.
- Events: PLAYER_LOGIN, PLAYER_ENTERING_WORLD, GROUP_ROSTER_UPDATE, UNIT_HEALTH, UNIT_POWER_UPDATE,
  UNIT_CONNECTION, UNIT_FLAGS, PLAYER_REGEN_ENABLED, SPELLS_CHANGED → every event runs a full `refresh()`.
- Slash `/ph`, `/patiheal`: test, show, hide, lock, unlock, spells, debug.
- Known structure debt: settings panel and handlers defined twice (second definition wins). See FOLLOW_UPS.md.

### PaTiTank 0.1.0 — `PaTiTank.lua` + `PaTiSharedPanel.lua`
- `PaTiTankDB`: `x, y, locked`. Events: PLAYER_LOGIN, PLAYER_ENTERING_WORLD, UNIT_HEALTH, PLAYER_TARGET_CHANGED,
  UNIT_THREAT_LIST_UPDATE, UNIT_THREAT_SITUATION_UPDATE. API: `UnitDetailedThreatSituation`. Slash `/pt`.

### PaTiQuest 0.1.0 — `PaTiQuest.lua` + `PaTiSharedPanel.lua`
- `PaTiQuestDB`: `x, y, locked`. Events: PLAYER_LOGIN, PLAYER_ENTERING_WORLD, QUEST_LOG_UPDATE.
- API: `C_QuestLog.GetSelectedQuest / GetTitleForQuestID / GetQuestObjectives`, all `pcall`-guarded. Slash `/phq`.
- No addon communication yet (duo sync is planned → needs `docs/PROTOCOL.md` first).

### PaTiDungeon 0.1.0 — `PaTiDungeon.lua` + `PaTiSharedPanel.lua`
- `PaTiDungeonDB`: `x, y, locked`. Events: PLAYER_LOGIN, PLAYER_ENTERING_WORLD, GROUP_ROSTER_UPDATE,
  ZONE_CHANGED_NEW_AREA, PLAYER_REGEN_DISABLED/ENABLED. API: `GetInstanceInfo`, `IsInInstance`. Slash `/pd`.

### PaTiGroup 0.4.0 — `PaTiGroup.lua` + `Bindings.xml`
- No SavedVariables (position not saved, by design of the first test version).
- Secure: four `SecureActionButtonTemplate` marker buttons (`type=raidtarget`), `PaTiGroupQuickSkull`
  (bound to Ctrl+Left click only if that binding is free), reset button running a character macro `PaTiG_Reset`
  that the addon creates/updates on login (`/tm` lines — `SetRaidTarget` is protected in this client).
- `DoReadyCheck`, `C_PartyInfo.DoCountdown` (leader/assistant, out of combat). Binding `PATIGROUP_TOGGLE`.
- Slash `/pg`, `/ptg`, `/patigroup`: show|an, hide|aus, toggle.

## Decisions

- **No Ace3/LibStub**: the addons are small; libraries add load order and update burden.
- **Embedded PaTiShared instead of a library addon**: players install one addon at a time.
- **Tools in plain Lua 5.1 + bash**: run on Windows (Git Bash + LuaJIT), macOS and CI without C modules.
