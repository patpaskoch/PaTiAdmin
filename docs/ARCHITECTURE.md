# Architecture

State of 2026-10-02 (code on `main`). Update this file when an addon's structure, SavedVariables, events or secure frames change.

## Suite shape

- Thirteen repos (see `AGENTS.md` §2): ten gameplay addons, PaTiSuite, PaTiShared, PaTiAdmin. No monorepo, no submodules, no runtime dependency between addons.
- **PaTiShared 0.3.0** (UI design system) is embedded per addon under `Shared/` via `sync-shared.sh`
  (`PaTiShared/README.md`) in all eleven runtime addons. The legacy `PaTiSharedPanel.lua` is gone.
- **PaTiAdmin** holds rules, docs, the check/package tools and CI/release templates. It ships nothing to players.
- **Releases:** one zip per addon with one folder `<Addon>/` (`tools/package.sh`, `docs/RELEASE.md`). PaTiShared and
  PaTiAdmin are never installed by players.

## Addon responsibilities

One job per addon (owner decision 2026-10-02). A feature goes into the addon whose job it is — never into two.
Addons complement each other but never depend on each other (AGENTS.md §3).

| Addon | Job | Not its job (→ where it lives) |
|---|---|---|
| **PaTiHeal** | Heal: player/party frames + heal-target frame, click healing, **the only source of your own HoTs/shields on healable frames**, dispellable debuffs, mana | buffs/procs/weapon imbues (→ Auras), roles overview (→ Group) |
| **PaTiAuras** | Buffs/auras: own buffs, procs, tracking, group buffs, weapon imbues, click-to-buff | HoTs/shields on members (→ Heal, removed here 2026-10-02) |
| **PaTiTank** | Tank awareness: target, threat, aggro lost/close, problem mobs, nameplate numbers, PaTiAlerts output | tank target for others (→ Group) |
| **PaTiRota** | Own skill priority: slots in your order, cooldowns, next ready skill highlighted, fixed cast buttons | any automatic casting, rotation rules (never) |
| **PaTiGroup** | Party awareness: who tanks, who heals, role counts, the tank's target and its raid marker (display only) | markers, ready check, pull, leader actions (→ Lead), threat (→ Tank), heal details (→ Heal) |
| **PaTiLead** | Lead/coordinate: raid markers, Clear/Reset All, ready check, pull timer, leader/assist, local note, marker key bindings (the former PaTiGroup) | party awareness (→ Group) |
| **PaTiQuest** | Quest companion: the selected quest and its objectives | |
| **PaTiDungeon** | Dungeon context: instance, group and combat status (later: dungeon quests, bosses, role notes, loot wishlist) | |
| **PaTiSocial** | Quick communication: emote and short message buttons | chat history, friends/guild/BNet, voice (never) |
| **PaTiAlerts** | One window for currently relevant problems (optional receiver) | producing alerts itself |
| **PaTiSuite** | Optional control panel: show/hide/overview of the windows | gameplay logic (never) |
| PaTiShared | Dev source of the shared UI, embedded into every addon (`Shared/`) | runtime dependency (never) |
| PaTiAdmin | Engineering centre: rules, docs, tools, CI templates — not a player addon | anything players install |

## Data flow (target for new and changed code)

```
WoW event ──► adapter: read WoW API, guard missing APIs, return plain values/tables
          ──► state/logic: pure Lua on plain tables (unit-testable, no WoW calls)
          ──► UI: write widgets; secure attributes only out of combat
```
Heal, Auras, Lead, Rota and Tank (aggro monitor) follow this split in several files; Group, Quest and Dungeon are small: `Logic.lua` (pure) plus
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
| Help note in settings | `modal:AddNote(title, highlight, text)` (PaTiShared): accent line, highlighted path, wrapped text — help, never a warning | Lead (key bindings), Heal (click dispel), Rota (skill slots + key bindings) |
| Combat guard | `if InCombatLockdown() then say("COMBAT_LOCKED") return end`; layout/attributes re-applied on `PLAYER_REGEN_ENABLED` | Heal, Auras, Lead, Rota |
| Secret values | `isSecret(v)` (issecretvalue) checked **before** any compare/test; widgets get raw values | all |
| Secure visibility in combat | `SecureHandlerStateTemplate` + `RegisterStateDriver(frame, state, "[macro conditions] show; hide")`; the restricted snippet shows/hides, anchors and sizes protected frames from attributes set out of combat; out of combat the same result is applied in Lua; without the driver: out-of-combat fallback | Heal (heal target, `TargetFrame.lua`) |
| Fixed secure buttons, moving highlight | one secure button per line/slot with a fixed action set out of combat; in combat only plain regions (texts, border, icon) change — the button never switches its action | Rota (slots), Auras (group/line buttons), Lead (markers) |
| Missing APIs | `if C_X and C_X.Fn then` + `pcall(...)` | all |
| Localization | `Locales/<code>.lua` → `ns.Locales[code].KEY`, lookup `UI.L.KEY` / `UI.BindText` | PaTiShared, all addons |
| Pure logic + migration | `Logic.lua`/`Config.lua` without WoW calls, `Migrate(db)` with `DB.schema`, tests in `tests/` | all |
| Robust migration | `Migrate` accepts nil/broken saves (`type(db) ~= "table"` → fresh), a broken schema runs the steps, a scale outside 0.5–2 falls back; only broken values are replaced, `Migrate(Migrate(db))` is stable — table-driven `tests/robustness_spec.lua` per addon | all |
| Caught-error diagnostics | `pcall` around APIs and PaTiAlerts `Sync`; the last error per source is kept as one short string (`<Module>.lastError` / a local) and shown only by `/<cmd> debug` — no chat, nothing saved | Heal, Auras, Tank, Rota, Lead |
| Window safety | `UI.WindowPosition` (broken saved anchor/offset → default), `SetClampedToScreen`; `window:SetCombatMovable(true)` for windows without secure children (`UI.CanMoveWindow`, never when protected) | PaTiShared; combat-movable: Tank, Group, Quest, Dungeon, Social, Alerts, Suite |

## Reset semantics (checked in code 2026-10-02)

Two separate actions in every addon: **Reset Position** (`/<cmd> reset`) clears only `point/relativePoint/x/y`;
**Restore Defaults** (settings footer) resets display/feature settings and **always keeps the position**. Personal
configuration that is hard to rebuild is kept on purpose; where a list is reset, that is its documented meaning.

| Addon | Restore Defaults resets | Kept on purpose |
|---|---|---|
| PaTiHeal | dispels, HoT choices/position/timers/charges, scale, opacity, lock, language | click bindings + ranks, collapsed, position |
| PaTiAuras | all settings incl. category layout; the Watch list (everything watched again) | seen auras, position |
| PaTiTank, PaTiQuest, PaTiDungeon, PaTiGroup | all settings | position |
| PaTiRota | all settings | the skill slots, position |
| PaTiLead | all settings incl. marker order | the local note, position |
| PaTiSocial | all settings and the button actions (six default buttons, PT-SOCIAL-053) | position |
| PaTiAlerts | all settings incl. source/priority filters | position |
| PaTiSuite | all settings and the remembered visibility | position |

## Addons

### PaTiHeal 0.6.0 (+ [Unreleased]) — party + heal-target frames, click casting, own HoTs & shields, dispels
- Files: `Shared/` → `Locales/` → `Logic.lua` (bindings → attributes, migration, health percent, secret-value helpers;
  pure, tested) → `SpellBook.lua` (spells, ranks) → `Dispels.lua` (dispellable debuffs, filter HARMFUL|RAID) →
  `Profiles/Shaman.lua`, `Profiles/Priest.lua` (data: healer auras + dispel spells) → `HoTs.lua` (own auras via
  HELPFUL|PLAYER + pure matching/texts, tested) → `Settings.lua` (settings modal) → `PaTiHeal.lua` (rows, HoT icons,
  menu, slash, events). `TargetFrame.lua` (heal-target secure driver) loads before `Settings.lua`.
- `PaTiHealDB` (per character), schema 2: point, relativePoint, x, y, locked, collapsed, language, showDispels,
  bindings{LEFT..ALT_RIGHT = spellID}, bindingRanks{key = rank}, hots{key = false}, hotPosition RIGHT|BELOW,
  showHotTimers, showHotCharges, scale (new keys get defaults, no schema step); `Logic.Migrate` converts 0.6.0.
  Scale: `SetScale` only out of combat, else pending until PLAYER_REGEN_ENABLED (secure rows).
- HoTs & shields: up to 3 plain icons per row (charges first, else timer; 0.5 s redraw only while a timer shows),
  right of the health bar or in the bottom line. Click dispel = the profile's dispel spells in the click-casting list;
  no combination preset. Independent of PaTiAuras by design (duplicated spell data accepted).
- Secure: `PaTiHealUnit1..5` (`SecureUnitButtonTemplate`, player + party1–4). `applyBindings()` writes every owned
  attribute out of combat; visibility via `RegisterUnitWatch`; collapse/hide/test mode blocked in combat.
- Heal target (2026-10-02): `PaTiHealTarget` (`SecureUnitButtonTemplate`, unit `target`, the same attributes from
  `applyBindings()`) above the player row; party rows are chained below `PaTiHealUnit1`. `TargetFrame.lua`:
  `PaTiHealTargetDriver` (`SecureHandlerStateTemplate`, `RegisterStateDriver` `[@target,help,nodead] show; hide`) —
  its restricted snippet shows/hides the row, moves the player row and sets the window height from attributes
  (`Logic.HealLayout`, `Logic.TargetMode`: collapsed hides, test mode shows) also in combat; without the driver only
  out of combat. Name, level (`Logic.LevelText`), health, mana, own HoTs, dispels; NPC = no class colour, no
  "offline". Never sends PaTiAlerts alerts. PLAYER_TARGET_CHANGED repaints it.
- Rows: name in class colour, health in percent (raw value when secret), tank = accent stripe, up to two dispel icons.
- Events: UNIT_HEALTH/UNIT_POWER_UPDATE/UNIT_CONNECTION/UNIT_FLAGS/UNIT_AURA repaint one row; GROUP_ROSTER_UPDATE,
  PLAYER_REGEN_ENABLED, SPELLS_CHANGED (rescan ranks), PLAYER_ENTERING_WORLD.
- Slash `/ph`, `/patiheal`: alone = show/hide, settings, test, show, hide, lock, unlock, reset, spells, auras, debug, version.

### PaTiAuras 0.1.0 — aura and buff watch, standalone and optional
- Files: `Shared/` → `Locales/` → `Config.lua` (DB defaults, pure) → `SpellBook.lua` (copy of PaTiHeal's) → `Auras.lua`
  (states, pure) → `AuraScan.lua` (C_UnitAuras/UnitAura adapter + test data) → `WeaponImbues.lua` (weapon enchant
  adapter: `C_Item.GetWeaponEnchantInfo` or `GetWeaponEnchantInfo`, pure `Evaluate`) → `Profiles/Shaman.lua`, `Profiles/Priest.lua`
  (data; `variants` join spells that give the same buff) → `Watch.lua` → `AuraWindow.lua` → `PaTiAuras.lua`.
- `PaTiAurasDB` (per character), schema 3 (`Config.DEFAULTS` incl. `collapsed`, `watch`, `seen`, `categoryLayout`, position,
  scale, `lastChangelog`). Categories: personal, procs, group, weapon, tracking — no healing since 2026-10-02 (PaTiHeal's
  job; old watch keys are ignored). Category layout (`categoryLayout`): vertical = one block in line order, horizontal
  = one column per category (`Auras.PlaceBlocks`, `Auras.ColumnWidth`, wraps on narrow screens); secure buttons follow
  their line; in combat the column origins are frozen and a change waits for PLAYER_REGEN_ENABLED.
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
- Group buffs also solo. No runtime API to PaTiHeal (owner decision 2026-09-28). Test mode uses the class profile.
- Slash `/pa`, `/patiauras`.

### PaTiLead 0.4.0 (+ [Unreleased]) — lead the group: markers, ready check, pull timer (former PaTiGroup)
- Renamed from PaTiGroup on 2026-10-02 (GitHub repo renamed, history kept). Fresh `PaTiLeadDB` — the old
  `PaTiGroupDB` is not taken over (pre-release). Old in-game IDs `PT-GROUP-001…102` are RETIRED there.
- Files: `Shared/` → `Locales/` → `Logic.lua` (settings, marker slots, reset text, secret-value helpers; pure, tested)
  → `Bar.lua` (window, secure buttons, layout, paint) → `PaTiLead.lua` (settings, commands, binding names, events) + `Bindings.xml`.
- `PaTiLeadDB` (per character), schema 1: position, locked, scale, language, collapsed, showPull, showGroupInfo, showNote, note, markers[8], lastChangelog.
  Collapsed = header only via `Bar.Layout` (secure marker buttons hidden), so collapsing is blocked in combat.
- Secure: `PaTiLeadMarker1..8` / `PaTiLeadClear` (`type=raidtarget`, `action=set`, `marker` 0-8), `PaTiLeadReset`
  (`type=macro`, `macrotext` /tm), invisible binding buttons on UIParent (`PaTiLeadBindMarker1..8`,
  `PaTiLeadBindClear`). Layout only out of combat (`Bar.Layout` → pending until PLAYER_REGEN_ENABLED).
- No macro creation, no automatic key binding, no SaveBindings. `DoReadyCheck`, `C_PartyInfo.DoCountdown` (leader/assist).
- Settings: own "Key bindings" section with a help note (`AddNote`) naming the WoW key binding menu path.
- Icon: crown with raid markers (owner-provided 2026-10-02). Slash `/plead`, `/patilead`.

### PaTiGroup 0.1.0 — party awareness (new 2026-10-02)
- Display only, no secure frames (updates in combat): Tank (you first if you tank; "+n"), Healer (dead/offline),
  Tank target (`player` → `target`, else `<unit>target`) with its raid marker or "no target", role counts. Party
  and raid (`raidN`), solo message. Roles only from `UnitGroupRolesAssigned`, never guessed.
- Files: `Shared/` → `Locales/` → `Logic.lua` (settings, migration, `Member`, `Summary`, `TargetOf`; pure, tested) →
  `PaTiGroup.lua` (adapter `readMembers`, window, settings, commands, events).
- `PaTiGroupDB`, schema 2 (schema 1 = the former PaTiGroup's table: never read, fresh start).
- Events: GROUP_ROSTER_UPDATE, PLAYER_ENTERING_WORLD, RAID_TARGET_UPDATE, PLAYER_TARGET_CHANGED and UNIT_TARGET (only
  the tank's line), UNIT_HEALTH/UNIT_CONNECTION/UNIT_FLAGS/UNIT_NAME_UPDATE (only the tank and healers), pcall-registered
  PLAYER_ROLES_ASSIGNED / ROLE_CHANGED_INFORM. In-game IDs from `PT-GROUP-200`. Slash `/pg`, `/ptg`, `/patigroup`.

### PaTiRota 0.1.0 — own skill priority (new 2026-10-02)
- Up to ten slots (`PaTiRotaDB.slots`, spell ID or 0) in priority order; typed name/ID or dragged from the spellbook.
  `Logic.CooldownState` (READY / GCD / COOLDOWN / UNUSABLE / NOT_KNOWN / UNKNOWN; secret → UNKNOWN), GCD via the
  reference spell 61304 or a 1.5 s fallback; `Logic.Recommend` = first READY-or-GCD slot, else the soonest cooldown.
- Files: `Shared/` → `Locales/` → `Logic.lua` (pure, tested) → `SpellBook.lua` (spell/cooldown/usable/cursor
  adapters; small copy of PaTiHeal's) → `Settings.lua` (slot editing) → `PaTiRota.lua` (window, buttons, painting,
  commands, events) + `Bindings.xml` (one CLICK binding per slot).
- Secure: `PaTiRotaSlot1..10` (SecureActionButtonTemplate, `type1=spell`, `spell1=<name>`), slot N = button N.
  `applySlots()` (out of combat) sets attributes, positions and visibility; in combat `slotsPending` waits for
  PLAYER_REGEN_ENABLED and painting follows each button's bound spell. Never casts by itself (AGENTS.md §8).
- Events: SPELL_UPDATE_COOLDOWN, SPELL_UPDATE_USABLE, SPELLS_CHANGED, PLAYER_REGEN_*; 0.1 s text ticker only while a
  shown skill cools down. `PaTiRotaDB` schema 1. Slash `/prota`, `/patirota`.

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

### PaTiSocial 0.1.0 — "Party Social", quick emote and message buttons
- Files: `Shared/` → `Locales/` → `Actions.lua` (action library + rules; pure, tested) → `Logic.lua` (settings,
  slots, layout; pure, tested) → `PaTiSocial.lua` (adapters, window, settings, commands).
- An action = data: emote (`DoEmote(token)`, offered only if the token is in the client's `EMOTEn_TOKEN` list) or
  predefined chat (`SendChatMessage(text, SAY|PARTY|RAID)`; PARTY only in a group, RAID only in a raid, no
  fallback to another channel). One click = one action, called from the click (a hardware event; SAY needs one).
- `PaTiSocialDB`, schema 1: position, locked, collapsed, scale, language, opacity, layout (horizontal|vertical),
  slotCount (4/6/8/10/12), slots = 12 action keys (`NONE` = empty). No secure frames, no test mode.
- Slash `/psocial`, `/patisocial`.

### PaTiSuite 0.1.0 — optional control panel
- Files: `Shared/` → `Locales/` → `Logic.lua` (settings, window list, show/hide rules; pure, tested) → `PaTiSuite.lua`.
- Reads `PaTiSuiteWindows` at PLAYER_LOGIN (all addons loaded, any load order) and follows state by post-hooks
  (OnShow/OnHide). Show/hide via `frame:SetSuiteShown` → the addon's own rules: Heal, Auras, Rota, Lead refuse in
  combat (secure children) and PaTiSuite names them in one message; Tank, Group, Quest, Dungeon, Social, Alerts are
  fine in combat. Order `Logic.ORDER`: Heal, Auras, Tank, Rota, Group, Lead, Quest, Dungeon, Social, Alerts.
  PaTiAlerts counts as shown unless hidden by the player (auto-hide aside). A protected frame without suite rules is
  never touched in combat.
- `PaTiSuiteDB`, schema 4: position, locked, scale, language, opacity, layout, collapsed, visibility (remembered
  show/hide per addon; schema 4 moved an old `visibility.PaTiGroup` to `PaTiLead`). No test mode.
- Rows: hover = BACKGROUND texture on OnEnter (text stays readable), status colour `Success` (shown) / `TextMuted`.
- Slash `/psuite`, `/patisuite`.

## Decisions

- **No Ace3/LibStub**: the addons are small; libraries add load order and update burden.
- **Embedded PaTiShared instead of a library addon**: players install one addon at a time.
- **Small adapters are duplicated, not shared** (e.g. `SpellBook.lua` in Heal, Auras and Rota): independence beats DRY.
- **PaTiGroup → PaTiLead (2026-10-02)**: the old PaTiGroup was a leader tool; it was renamed (history kept) and the
  name PaTiGroup reused for party awareness. Pre-release: no cross-addon SavedVariables migration; test IDs are never
  reused (old ones RETIRED in PaTiLead, the new PaTiGroup counts from 200).
- **Tools in plain Lua 5.1 + bash**: run on Windows (Git Bash + LuaJIT), macOS and CI without C modules.
