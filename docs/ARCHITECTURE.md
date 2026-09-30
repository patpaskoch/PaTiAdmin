# Architecture

State of 2026-09-29 (code on `main`). Update this file when an addon's structure, SavedVariables, events or secure frames change.

## Suite shape

- Eight repos (see `AGENTS.md` §2). No monorepo, no submodules, no runtime dependency between addons.
- **PaTiShared 0.3.0** (UI design system) is embedded per addon under `Shared/` via `sync-shared.sh`
  (`PaTiShared/README.md`) in all seven addons. The legacy `PaTiSharedPanel.lua` is gone.
- **PaTiAdmin** holds rules, docs, the check/package tools and CI/release templates. It ships nothing to players.
- **Releases:** one zip per addon with one folder `<Addon>/` (`tools/package.sh`, `docs/RELEASE.md`). PaTiShared and
  PaTiAdmin are never installed by players.

## Data flow (target for new and changed code)

```
WoW event ──► adapter: read WoW API, guard missing APIs, return plain values/tables
          ──► state/logic: pure Lua on plain tables (unit-testable, no WoW calls)
          ──► UI: write widgets; secure attributes only out of combat
```
Heal, Auras, Group and Tank (aggro monitor) follow this split in several files; Quest and Dungeon are small: `Logic.lua` (pure) plus
one `<Addon>.lua` with a clearly separated adapter function, window, settings, commands and events.

## Existing patterns

| Pattern | How it is done today | Where |
|---|---|---|
| Init | one `events` frame; `PLAYER_LOGIN` migrates the DB, sets the language, `window:Attach(DB, x, y)` | all |
| Events | `for _, e in ipairs({...}) do events:RegisterEvent(e) end`; optional events via `pcall(events.RegisterEvent, …)` | all |
| Unit events | handler receives `unit`, ignores units without a frame, repaints only that unit | Heal, Auras |
| Slash commands | table `COMMANDS[name] = fn`; trim + lower; unknown → `L.HELP` | all |
| Chat output | `say(key, ...)` → `print("|cff68caff<Addon>:|r " .. L[key]:format(...))` | all |
| Test mode | `testMode` local (not saved), fake data in the adapter, TEST badge via `window:SetTestMode`, secure buttons disabled | all |
| Window/move/lock | PaTiShared `UI.CreateWindow` + `window:Attach(DB)`: point + relativePoint + x/y, `DB.locked`, header drag | all |
| Opacity | `DB.opacity` (default 0.75, clamped 0.3–1; body only, header opaque) in each addon's defaults; applied by `Attach`; settings via `UI.AddWindowSettings`. (Snapping was removed 2026-09-30; an old `snapWindows` is ignored.) | all |
| Window registry | `_G.PaTiSuiteWindows[addonName] = window` (every `UI.CreateWindow`); `window.suiteSetShown(shown, → false if blocked)` = the addon's own `setShown(shown, quiet)` | all, read by PaTiSuite |
| Settings | lazily built `UI.CreateModal` (needs DB); sections, rows, `AddControls`, `Finish(restoreDefaults)` | all |
| Collapse/Expand | `DB.collapsed` (default false, migration keeps a saved value), ••• menu entry, header-only window; restore defaults expands (PaTiHeal keeps it). With secure children the entry is disabled/blocked in combat | all |
| Help note in settings | `modal:AddNote(title, highlight, text)` (PaTiShared): accent line, highlighted path, wrapped text — help, never a warning | Group (key bindings), Heal (click dispel) |
| Combat guard | `if InCombatLockdown() then say("COMBAT_LOCKED") return end`; layout/attributes re-applied on `PLAYER_REGEN_ENABLED` | Heal, Group |
| Secret values | `isSecret(v)` (issecretvalue) checked **before** any compare/test; widgets get raw values | all |
| Missing APIs | `if C_X and C_X.Fn then` + `pcall(...)` | all |
| Localization | `Locales/<code>.lua` → `ns.Locales[code].KEY`, lookup `UI.L.KEY` / `UI.BindText` | PaTiShared, all addons |
| Pure logic + migration | `Logic.lua`/`Config.lua` without WoW calls, `Migrate(db)` with `DB.schema`, tests in `tests/` | all |

## Addons

### PaTiHeal 0.6.0 (+ [Unreleased]) — party frames, click casting, HoTs & shields, dispels
- Files: `Shared/` → `Locales/` → `Logic.lua` (bindings → attributes, migration, health percent, secret-value helpers;
  pure, tested) → `SpellBook.lua` (spells, ranks) → `Dispels.lua` (dispellable debuffs, filter HARMFUL|RAID) →
  `Profiles/Shaman.lua`, `Profiles/Priest.lua` (data: healer auras + dispel spells) → `HoTs.lua` (own auras via
  HELPFUL|PLAYER + pure matching/texts, tested) → `Settings.lua` (settings modal) → `PaTiHeal.lua` (rows, HoT icons,
  menu, slash, events).
- `PaTiHealDB` (per character), schema 2: point, relativePoint, x, y, locked, collapsed, language, showDispels,
  bindings{LEFT..ALT_RIGHT = spellID}, bindingRanks{key = rank}, hots{key = false}, hotPosition RIGHT|BELOW,
  showHotTimers, showHotCharges, scale (new keys get defaults, no schema step); `Logic.Migrate` converts 0.6.0.
  Scale: `SetScale` only out of combat, else pending until PLAYER_REGEN_ENABLED (secure rows).
- HoTs & shields: up to 3 plain icons per row (charges first, else timer; 0.5 s redraw only while a timer shows),
  right of the health bar or in the bottom line. Click dispel = the profile's dispel spells in the click-casting list;
  no combination preset. Independent of PaTiAuras by design (duplicated spell data accepted).
- Secure: `PaTiHealUnit1..5` (`SecureUnitButtonTemplate`, player + party1–4). `applyBindings()` writes every owned
  attribute out of combat; visibility via `RegisterUnitWatch`; collapse/hide/test mode blocked in combat.
- Rows: name in class colour, health in percent (raw value when secret), tank = accent stripe, up to two dispel icons.
- Events: UNIT_HEALTH/UNIT_POWER_UPDATE/UNIT_CONNECTION/UNIT_FLAGS/UNIT_AURA repaint one row; GROUP_ROSTER_UPDATE,
  PLAYER_REGEN_ENABLED, SPELLS_CHANGED (rescan ranks), PLAYER_ENTERING_WORLD.
- Slash `/ph`, `/patiheal`: alone = show/hide, settings, test, show, hide, lock, unlock, reset, spells, auras, debug, version.

### PaTiAuras 0.1.0 — aura and buff watch, standalone and optional
- Files: `Shared/` → `Locales/` → `Config.lua` (DB defaults, pure) → `SpellBook.lua` (copy of PaTiHeal's) → `Auras.lua`
  (states, pure) → `AuraScan.lua` (C_UnitAuras/UnitAura adapter + test data) → `WeaponImbues.lua` (weapon enchant
  adapter: `C_Item.GetWeaponEnchantInfo` or `GetWeaponEnchantInfo`, pure `Evaluate`) → `Profiles/Shaman.lua`, `Profiles/Priest.lua`
  (data; `variants` join spells that give the same buff) → `Watch.lua` → `AuraWindow.lua` → `PaTiAuras.lua`.
- `PaTiAurasDB` (per character), schema 1 (`Config.DEFAULTS` incl. `collapsed`, `watch`, `seen`, position, scale, `lastChangelog`).
  Collapsed = header only; the buff buttons are hidden out of combat, so collapsing is blocked in combat.
  "New auras" dialog: entries you can use (`Watch.IsOffered`) that are not in `seen` are offered once, out of combat.
- Events: UNIT_AURA/UNIT_CONNECTION/UNIT_FLAGS (player, party1-4, one unit re-read), GROUP_ROSTER_UPDATE,
  PLAYER_ENTERING_WORLD, SPELLS_CHANGED + talent/spec events (pcall-registered). Timer redraw every 0.5 s only while a timer is visible.
- Unreadable aura data (secret values, API errors) → `AuraScan.UNREADABLE` → state UNKNOWN, never MISSING.
- Secure: `PaTiAurasBuff1..4` (SecureActionButtonTemplate, `type1=spell`, `unit`, `spell1` = single-target buff) over the
  group lines; target = `Auras.NextTarget` (missing, alive, online, visible), set out of combat only. In combat the
  target stays; window size/visibility/scale wait for PLAYER_REGEN_ENABLED. Group section first (fixed rows).
- Weapon imbues (Shaman profile `weapon`, one entry per slot, no spell ID): not UNIT_AURA. API chain with separate
  parsers: `GetWeaponEnchantInfo()` (classic tuple) → `C_Item.GetWeaponEnchantInfo(Enum.WeaponSlot.*)` (fallback; the
  temporary entry, never a permanent enchant). Re-read on UNIT_INVENTORY_CHANGED / PLAYER_EQUIPMENT_CHANGED /
  WEAPON_ENCHANT_CHANGED / WEAPON_SLOT_CHANGED and by a 1 s check (only while slots are watched, repaint only when
  `WeaponImbues.Signature` changes). Unreadable → UNKNOWN, never MISSING. Nothing cached between reads.
- What to watch: only `DB.watch[key]` (settings "Watch", a multi-select popup of `Watch.Choices`); schema 2 removed
  the category switches (a switched-off category became watch = false per entry).
- Group buffs also solo. Priest healing auras: Renew, Power Word: Shield, Prayer of Mending. No runtime API to PaTiHeal
  (owner decision 2026-09-28). Test mode uses the class profile.
- Slash `/pa`, `/patiauras`.

### PaTiGroup 0.4.0 (+ [Unreleased]) — markers, ready check, pull timer
- Files: `Shared/` → `Locales/` → `Logic.lua` (settings, marker slots, reset text, secret-value helpers; pure, tested)
  → `Bar.lua` (window, secure buttons, layout, paint) → `PaTiGroup.lua` (settings, commands, binding names, events) + `Bindings.xml`.
- `PaTiGroupDB` (per character), schema 1: position, locked, scale, language, collapsed, showPull, showGroupInfo, showNote, note, markers[8], lastChangelog.
  Collapsed = header only via `Bar.Layout` (secure marker buttons hidden), so collapsing is blocked in combat.
- Secure: `PaTiGroupMarker1..8` / `PaTiGroupClear` (`type=raidtarget`, `action=set`, `marker` 0-8), `PaTiGroupReset`
  (`type=macro`, `macrotext` /tm), invisible binding buttons on UIParent (`PaTiGroupQuickSkull`, `PaTiGroupBindMarker1..7`,
  `PaTiGroupBindClear`). Layout only out of combat (`Bar.Layout` → pending until PLAYER_REGEN_ENABLED).
- No macro creation, no automatic key binding, no SaveBindings. `DoReadyCheck`, `C_PartyInfo.DoCountdown` (leader/assist).
- Settings: own "Key bindings" section with a help note (`AddNote`) naming the WoW key binding menu path.
- Slash `/pg`, `/ptg`, `/patigroup`.

### PaTiTank 0.1.0 (+ [Unreleased]) — own health, target, threat, aggro control
- Files: `Shared/` → `Locales/` → `Logic.lua` (settings, `ThreatValue`; pure, tested) → `Aggro.lua` (states CONTROLLED /
  DANGER / LOST / UNKNOWN, summary, holder label; pure, tested) → `Threat.lua` (adapter: the only threat/nameplate API
  calls; tested with mocks) → `Plates.lua` (nameplate markers; tested with mocks) → `PaTiTank.lua` (window, aggro
  block, scan scheduler, settings, commands, events).
- `PaTiTankDB`, schema 1: x, y (+ point/relativePoint), locked, collapsed, scale, language (0.1.0 values kept).
- Events: UNIT_HEALTH/UNIT_MAXHEALTH (only `player` repaints), PLAYER_TARGET_CHANGED, UNIT_THREAT_LIST_UPDATE,
  UNIT_THREAT_SITUATION_UPDATE, PLAYER_ENTERING_WORLD; pcall-registered NAME_PLATE_UNIT_ADDED/REMOVED, UNIT_TARGET
  (party1-4 only), GROUP_ROSTER_UPDATE, PLAYER_REGEN_DISABLED/ENABLED. APIs `UnitDetailedThreatSituation`,
  `UnitThreatSituation`, `UnitCanAttack`, `UnitIsDead`, `UnitGUID`. No secure frames.
- Aggro: enemies = target + tracked nameplate tokens + party1-4 targets, de-duplicated by GUID. Per enemy
  `UnitThreatSituation("player", enemy)`: 3 CONTROLLED, 2 DANGER; otherwise the group (party1-4, pet) is searched for
  the holder → LOST. Secret/erroring values → `Aggro.UNREADABLE` → UNKNOWN (never CONTROLLED). Scans are coalesced
  (0.1 s after the last event), skipped while collapsed/test mode, plus a 1 s fallback rescan while in combat.
  Display only: no targeting, no taunt. Numbering (`Aggro.Number`, pure): the visible problem rows (≤ MAX_ROWS) with
  their own `nameplateN` token get 1–4; a readable GUID keeps its number while visible; a token used by two rows gets
  none. The panel and `Plates.lua` (our own child frame of the plate, coloured by state) are painted from the same
  list in the same call. NAME_PLATE_UNIT_ADDED/REMOVED clears that plate's number and the panel row's number
  synchronously (`forgetPlate`); forbidden plates are skipped.
  Clickable panel rows are TECHNICALLY BLOCKED (F17, WOW_API_COMPAT): the player clicks the marked nameplate.
- Settings add `markPlates` (default on). Slash `/pt`, `/patitank`.

### PaTiQuest 0.1.0 (+ [Unreleased]) — selected quest + objectives
- Files: `Shared/` → `Locales/` → `Logic.lua` (settings, `QuestLines`; pure, tested) → `PaTiQuest.lua`
  (`readSelectedQuest()` adapter: every `C_QuestLog.*` call existence-checked and `pcall`-guarded).
- `PaTiQuestDB`, schema 1 (as Tank). Events: PLAYER_LOGIN, PLAYER_ENTERING_WORLD, QUEST_LOG_UPDATE. No secure frames.
- No addon communication (duo sync would need `docs/PROTOCOL.md` first). Slash `/phq` (kept), `/patiquest`.

### PaTiDungeon 0.1.0 (+ [Unreleased]) — instance, group, combat status
- Files: `Shared/` → `Locales/` → `Logic.lua` (settings, `Status` normalisation incl. 1/nil flags; pure, tested) → `PaTiDungeon.lua`.
- `PaTiDungeonDB`, schema 1 (as Tank). Events: PLAYER_LOGIN, PLAYER_ENTERING_WORLD, GROUP_ROSTER_UPDATE,
  ZONE_CHANGED_NEW_AREA, PLAYER_REGEN_DISABLED/ENABLED (rare → full repaint). API `GetInstanceInfo`, `IsInInstance`.
- Slash `/pd`, `/patidungeon`.

### PaTiAlerts 0.1.0 — open problems reported by the other addons (optional receiver)
- Files: `Shared/` → `Locales/` → `Logic.lua` (settings, auto-hide rule; pure, tested) → `State.lua` (alert store;
  pure, tested) → `PaTiAlerts.lua` (window, `PaTiAlertsAPI`, settings, commands).
- `PaTiAlertsDB`, schema 1: position, locked, collapsed, scale, language, autoHide, pulseNew, sourceFilters,
  priorityFilters. Alerts are never saved. No secure frames; rows are not clickable.
- API v1 (`_G.PaTiAlertsAPI`, the one cross-addon global, AGENTS.md §3): `Sync(source, list)` (preferred: the
  producer's complete current list), `Upsert(alert)`, `Remove(source, id)`, `ClearSource(source)`; all pcall-guarded.
  Key = source + id. Alert = { id, priority CRITICAL|WARNING|INFO (unknown → INFO), kind, text | name, detail?, number? };
  plain strings checked for secrecy first, `name` may be secret (SetText only). Order: priority, then first seen.
- Producers (V1): PaTiTank (`Aggro.Alerts`: LOST → CRITICAL AGGRO_LOST, DANGER → WARNING AGGRO_DANGER, same number as
  panel + nameplate), PaTiAuras (`Auras.Alerts`: personal buffs + weapon imbues MISSING/EXPIRING → WARNING; UNKNOWN
  never), PaTiHeal (`Logic.DispelAlerts`: dispellable debuff → INFO DISPELLABLE). Each sends after its normal refresh,
  so load order does not matter; while PaTiAlerts exists, a collapsed Tank/Heal keeps scanning.
- Slash `/pal`, `/palerts`.

### PaTiSuite 0.1.0 — optional control panel
- Files: `Shared/` → `Locales/` → `Logic.lua` (settings, window list, show/hide rules; pure, tested) → `PaTiSuite.lua`.
- Reads `PaTiSuiteWindows` at PLAYER_LOGIN (all addons loaded, any load order) and follows state by post-hooks
  (OnShow/OnHide). Show/hide via `frame:SetSuiteShown` → the addon's own rules: Heal, Auras, Group refuse in combat
  (secure children) and PaTiSuite names them in one message; Tank, Quest, Dungeon, Alerts are fine in combat.
  PaTiAlerts counts as shown unless hidden by the player (auto-hide aside). A protected frame without suite rules is
  never touched in combat.
- `PaTiSuiteDB`, schema 1: position, locked, scale, language, opacity. No test mode, no collapse.
- Rows: hover = BACKGROUND texture on OnEnter (text stays readable), status colour `Success` (shown) / `TextMuted`.
- Slash `/psuite`, `/patisuite`.

## Decisions

- **No Ace3/LibStub**: the addons are small; libraries add load order and update burden.
- **Embedded PaTiShared instead of a library addon**: players install one addon at a time.
- **Small adapters are duplicated, not shared** (e.g. `SpellBook.lua` in Heal and Auras): independence beats DRY.
- **Tools in plain Lua 5.1 + bash**: run on Windows (Git Bash + LuaJIT), macOS and CI without C modules.
