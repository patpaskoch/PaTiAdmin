# Follow-up recommendations

Found during the engineering-foundation review (2026-09-28). Not implemented on purpose (AGENTS.md §12).
Take one item per task; move finished items to the addon's CHANGELOG and delete them here. Items fixed in code but
still needing an in-game test stay here, marked "FIXED IN CODE … awaiting in-game test".

### F1 · PaTiHeal: stale secure click attributes — **high** · FIXED IN CODE (PaTiHeal [Unreleased]), awaiting in-game test
- Problem: `applyClickSpell()` clears only the unmodified `type<n>/spell<n>`. After switching e.g. Ctrl+Left → Shift+Left, `ctrl-type1/ctrl-spell1` stay set, plus `spell` from the first (overwritten) definition.
- Affected: `PaTiHeal.lua` `applyClickSpell` (second definition).
- Why: an old binding keeps casting although the UI shows another one.
- Approach: clear every known modifier/button attribute before setting the chosen ones; covered by the planned PaTiHeal settings migration.
- Risk: medium (secure attributes) · Tests: manual click test for every combination; unit test for an extracted "binding → attribute table" function.

### F2 · PaTiHeal: secure rows and parent frame shown/hidden in combat — **high** · FIXED IN CODE (PaTiHeal [Unreleased]), awaiting in-game test
- Problem: `refresh()` calls `row:Show()/Hide()` on `SecureUnitButtonTemplate` rows on `GROUP_ROSTER_UPDATE` etc. also in combat; the close X and `/ph hide` hide the parent.
- Why: `ADDON_ACTION_BLOCKED` and rows that stay wrong until combat ends.
- Approach: `RegisterUnitWatch(row)` for visibility; block hide/collapse in combat (menu entries disabled).
- Risk: medium · Tests: manual — join/leave party members during combat.

### F4 · Position saved with the wrong anchor — medium
- Status: fixed in code for all six addons (PaTiShared Window); awaiting in-game drag → reload test.
- Problem: Heal/Tank/Quest/Dungeon save `x, y` from `GetPoint()` after dragging but restore them as `CENTER` offsets; the window can jump after `/reload`.
- Approach: PaTiShared `Window:SavePosition` stores point + relativePoint; old saves keep working.
- Risk: low · Tests: manual drag → reload.

### F7 · Full refresh on every unit event — low · FIXED IN CODE for PaTiHeal and PaTiTank; awaiting an in-game busy-fight check
- Problem: PaTiHeal redraws all rows on each `UNIT_HEALTH`/`UNIT_POWER_UPDATE` for any unit (incl. nameplates/target); PaTiTank updates on every `UNIT_HEALTH`.
- Approach: `RegisterUnitEvent` for the watched units, update only the matching row.
- Risk: low · Tests: manual in a busy fight; no functional change.

### F8 · PaTiGroup side effects on login — low · FIXED IN CODE (PaTiGroup [Unreleased]): no macro, no automatic binding; awaiting in-game test
- Problem: creates/edits a character macro and may bind Ctrl+Left click and call `SaveBindings` on every login; not visible in settings; binding header strings `BINDING_HEADER_PATIGROUP` / `BINDING_NAME_PATIGROUP_TOGGLE` are not defined.
- Approach: document in README; define the binding strings; consider an opt-in setting.
- Risk: low · Tests: manual on a character with a full macro list / existing Ctrl+Left binding.

### F9 · PaTiHeal spell table contains 2061 twice — low · wrong entry removed; Greater Heal still needs its confirmed ID
- Problem: "Große Heilung" uses 2061 (Flash Heal's ID); the real Greater Heal is never offered.
- Approach: correct ID after verifying in this client (docs/WOW_API_COMPAT.md). Product data change → owner decision.

### F11 · Slash command sets — low (not release-critical)
- Status 2026-09-29: all six addons answer `show, hide, test, lock, unlock, reset, settings, debug, version`, and the
  command alone shows/hides the window. Extras on purpose: PaTiHeal `spells, auras`; PaTiAuras `auras, about, changelog`;
  PaTiGroup `toggle, about, changelog`. `/phq` (PaTiQuest) and `/ptg` (PaTiGroup) stay as compatibility aliases.
- Open: `toggle` exists only in PaTiGroup. Add it elsewhere only if players ask for it.

### F12 · Seven repositories — decision needed
- Problem: shared tooling, docs and CI templates live in PaTiAdmin and must be checked out next to each addon; cross-repo changes need several commits.
- Options: keep multi-repo (current, works) or move to one monorepo with per-addon packaging. Owner decision; do not start without it.

### F13 · PaTiHeal.lua above 400 lines — low
- Status: the settings modal moved to `Settings.lua` (2026-09-29); HoT row code and the scale setting brought
  `PaTiHeal.lua` back to 500 lines.
- Smallest solution: move the HoT row UI (`layoutHoTs`, `paintHoTs`, the timer ticker) next to `HoTs.lua` in its own
  file when PaTiHeal is next touched (not during the beta freeze unless a fix needs it).
- Risk: low · Tests: `smoke` test mode path (HoT icons with 5 / 8s), hots_spec.


### F16 · PaTiTank: mark lost enemies on their nameplates — low · FIXED IN CODE (PaTiTank [Unreleased]), awaiting in-game test
- `Plates.lua`: the row number (1–4, coloured by state) as our own child frame of the nameplate; forbidden plates
  skipped; setting on by default.
- Tests needed: panel number = plate number for the same enemy (also same-named enemies), number gone when held
  again / dead / plate gone, a reused `nameplateN` never shows an old number, `/console taintLog 1` has no PaTiTank entry.

### F17 · PaTiTank: click an aggro row to target that enemy — TECHNICALLY BLOCKED – documented
- Owner decision 2026-09-29: wanted, if WoW allows it safely. Investigation: `docs/WOW_API_COMPAT.md` ("Clickable
  targeting…"). In combat addon code cannot point, move or show a secure target button for an enemy it chose, and there
  is no secure condition for threat — so a row of the sorted list cannot be made to target its enemy reliably.
- Delivered instead: numbered nameplates (F16). The player clicks the marked nameplate; no automatic targeting or taunt.
- Reopen only if the Forever client offers a secure API for this (would be recorded in WOW_API_COMPAT first).

### F21 · PaTiAuras: name the weapon imbue (Flametongue, Windfury …) — low
- Status: V1 (2026-09-29) shows per slot only whether an imbue is on. How the Forever client identifies the imbue
  (enchant ID from the weapon enchant API, a tooltip line, a spell) is unknown.
- Next step: owner runs `/pa auras` with each imbue on and reports `enchantID`; then a small `enchantID → spell` table
  in the Shaman profile and an optional "wanted imbue per slot" setting. No guessing IDs before that.

### F22 · PaTiAuras → PaTiAlerts (weapon imbue missing) — decision needed
- PaTiAlerts does not exist. If it is ever built, PaTiAuras could report `WEAPON_IMBUE_MISSING` (WARNING) through an
  optional `if PaTiAlertsAPI then … end` — no dependency, no OptionalDeps, UNKNOWN never as missing.
