# Architecture

State of 2026-09-28 (code on `main`). Update this file when an addon's structure, SavedVariables, events or secure frames change.

## Suite shape

- Eight repos (see `AGENTS.md` §2). No monorepo, no submodules, no runtime dependency between addons.
- **PaTiShared 0.3.0** (UI design system) is embedded per addon under `Shared/` via `sync-shared.sh`
  (`PaTiShared/README.md`): PaTiHeal, PaTiAuras, PaTiGroup. Tank/Quest/Dungeon still use the legacy `PaTiSharedPanel.lua`.
- **PaTiAdmin** holds rules, docs, the check/package tools and CI templates. It ships nothing to players.

## Data flow (target for new and changed code)

```
WoW event ──► adapter: read WoW API, guard missing APIs, return plain values/tables
          ──► state/logic: pure Lua on plain tables (unit-testable, no WoW calls)
          ──► UI: write widgets; secure attributes only out of combat
```
Heal, Auras and Group follow this split (adapters, `Logic.lua`/`Config.lua`/`Auras.lua`, UI files).
Tank/Quest/Dungeon are still single files that mix everything (accepted until their migration).

## Existing patterns

| Pattern | How it is done today | Where |
|---|---|---|
| Init | one `events` frame; `PLAYER_LOGIN` migrates the DB, sets the language, `window:Attach(DB, x, y)` | Heal, Auras, Group |
| Events | `for _, e in ipairs({...}) do events:RegisterEvent(e) end`; optional events via `pcall(events.RegisterEvent, …)` | all |
| Unit events | handler receives `unit`, ignores units without a frame, repaints only that unit | Heal, Auras |
| Slash commands | table `COMMANDS[name] = fn`; trim + lower; unknown → `L.HELP` | Heal, Auras, Group |
| Chat output | `say(key, ...)` → `print("|cff68caff<Addon>:|r " .. L[key]:format(...))` | Heal, Auras, Group |
| Test mode | `testMode` local (not saved), fake data in the adapter, TEST badge via `window:SetTestMode`, secure buttons disabled | all migrated |
| Window/move/lock | PaTiShared `UI.CreateWindow` + `window:Attach(DB)`: point + relativePoint + x/y, `DB.locked`, header drag | Heal, Auras, Group |
| Settings | lazily built `UI.CreateModal` (needs DB); sections, rows, `AddControls`, `Finish(restoreDefaults)` | Heal, Auras, Group |
| Combat guard | `if InCombatLockdown() then say("COMBAT_LOCKED") return end`; layout/attributes re-applied on `PLAYER_REGEN_ENABLED` | Heal, Group |
| Secret values | `isSecret(v)` (issecretvalue) checked **before** any compare/test; widgets get raw values | Heal, Auras, Group |
| Missing APIs | `if C_X and C_X.Fn then` + `pcall(...)` | all |
| Localization | `Locales/<code>.lua` → `ns.Locales[code].KEY`, lookup `UI.L.KEY` / `UI.BindText` | PaTiShared, Heal, Auras, Group |
| Pure logic + migration | `Logic.lua`/`Config.lua` without WoW calls, `Migrate(db)` with `DB.schema`, tests in `tests/` | Heal, Auras, Group |
| Legacy chrome | `PaTiSharedPanel.Attach` (global, copied file) → gear, chevron, close | Tank, Quest, Dungeon (to be replaced) |

## Addons

### PaTiHeal 0.6.0 (+ [Unreleased]) — party frames + click casting
- Files: `Shared/` → `Locales/` → `Logic.lua` (bindings → attributes, migration, health percent; pure, tested) →
  `SpellBook.lua` (spells, ranks) → `Dispels.lua` (dispellable debuffs) → `PaTiHeal.lua` (rows, settings, menu, slash, events).
- `PaTiHealDB` (per character), schema 2: point, relativePoint, x, y, locked, collapsed, language, showDispels,
  bindings{LEFT..ALT_RIGHT = spellID}, bindingRanks{key = rank}; `Logic.Migrate` converts 0.6.0.
- Secure: `PaTiHealUnit1..5` (`SecureUnitButtonTemplate`, player + party1–4). `applyBindings()` writes every owned
  attribute out of combat; visibility via `RegisterUnitWatch`; collapse/hide/test mode blocked in combat.
- Rows: name in class colour, health in percent (raw value when secret), tank = accent stripe, up to two dispel icons.
- Events: UNIT_HEALTH/UNIT_POWER_UPDATE/UNIT_CONNECTION/UNIT_FLAGS/UNIT_AURA repaint one row; GROUP_ROSTER_UPDATE,
  PLAYER_REGEN_ENABLED, SPELLS_CHANGED (rescan ranks), PLAYER_ENTERING_WORLD.
- Slash `/ph`, `/patiheal`: settings, test, show, hide, lock, unlock, spells, debug.

### PaTiAuras 0.1.0 — aura and buff watch, standalone and optional
- Files: `Shared/` → `Locales/` → `Config.lua` (DB defaults, pure) → `SpellBook.lua` (copy of PaTiHeal's) → `Auras.lua`
  (states, pure) → `AuraScan.lua` (C_UnitAuras/UnitAura adapter + test data) → `Profiles/Shaman.lua` → `Watch.lua` → `AuraWindow.lua` → `PaTiAuras.lua`.
- `PaTiAurasDB` (per character), schema 1 (`Config.DEFAULTS`, `watch`, position, scale, `lastChangelog`).
- Events: UNIT_AURA/UNIT_CONNECTION/UNIT_FLAGS (player, party1-4, one unit re-read), GROUP_ROSTER_UPDATE,
  PLAYER_ENTERING_WORLD, SPELLS_CHANGED + talent/spec events (pcall-registered). Timer redraw every 0.5 s only while a timer is visible.
- Unreadable aura data (secret values, API errors) → `AuraScan.UNREADABLE` → state UNKNOWN, never MISSING.
- No secure frames. Planned: Priest profile, click-to-buff, optional `PaTiAurasAPI` for PaTiHeal.
- Slash `/pa`, `/patiauras`.

### PaTiGroup 0.4.0 (+ [Unreleased]) — markers, ready check, pull timer
- Files: `Shared/` → `Locales/` → `Logic.lua` (settings, marker slots, reset text, secret-value helpers; pure, tested)
  → `Bar.lua` (window, secure buttons, layout, paint) → `PaTiGroup.lua` (settings, commands, binding names, events) + `Bindings.xml`.
- `PaTiGroupDB` (per character), schema 1: position, locked, scale, language, showPull, showGroupInfo, showNote, note, markers[8], lastChangelog.
- Secure: `PaTiGroupMarker1..8` / `PaTiGroupClear` (`type=raidtarget`, `action=set`, `marker` 0-8), `PaTiGroupReset`
  (`type=macro`, `macrotext` /tm), invisible binding buttons on UIParent (`PaTiGroupQuickSkull`, `PaTiGroupBindMarker1..7`,
  `PaTiGroupBindClear`). Layout only out of combat (`Bar.Layout` → pending until PLAYER_REGEN_ENABLED).
- No macro creation, no automatic key binding, no SaveBindings. `DoReadyCheck`, `C_PartyInfo.DoCountdown` (leader/assist).
- Slash `/pg`, `/ptg`, `/patigroup`.

### PaTiTank 0.1.0 — `PaTiTank.lua` + `PaTiSharedPanel.lua` (legacy)
- `PaTiTankDB`: `x, y, locked`. Events: PLAYER_LOGIN, PLAYER_ENTERING_WORLD, UNIT_HEALTH, PLAYER_TARGET_CHANGED,
  UNIT_THREAT_LIST_UPDATE, UNIT_THREAT_SITUATION_UPDATE. API: `UnitDetailedThreatSituation`. Slash `/pt`.

### PaTiQuest 0.1.0 — `PaTiQuest.lua` + `PaTiSharedPanel.lua` (legacy)
- `PaTiQuestDB`: `x, y, locked`. Events: PLAYER_LOGIN, PLAYER_ENTERING_WORLD, QUEST_LOG_UPDATE.
- API: `C_QuestLog.GetSelectedQuest / GetTitleForQuestID / GetQuestObjectives`, all `pcall`-guarded. Slash `/phq`.
- No addon communication (duo sync would need `docs/PROTOCOL.md` first).

### PaTiDungeon 0.1.0 — `PaTiDungeon.lua` + `PaTiSharedPanel.lua` (legacy)
- `PaTiDungeonDB`: `x, y, locked`. Events: PLAYER_LOGIN, PLAYER_ENTERING_WORLD, GROUP_ROSTER_UPDATE,
  ZONE_CHANGED_NEW_AREA, PLAYER_REGEN_DISABLED/ENABLED. API: `GetInstanceInfo`, `IsInInstance`. Slash `/pd`.

## Decisions

- **No Ace3/LibStub**: the addons are small; libraries add load order and update burden.
- **Embedded PaTiShared instead of a library addon**: players install one addon at a time.
- **Small adapters are duplicated, not shared** (e.g. `SpellBook.lua` in Heal and Auras): independence beats DRY.
- **Tools in plain Lua 5.1 + bash**: run on Windows (Git Bash + LuaJIT), macOS and CI without C modules.
