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
  PaTiGroup `about, changelog`. `/phq` (PaTiQuest) and `/ptg` (PaTiGroup) stay as compatibility aliases.
- Open: no addon has an explicit `toggle` word (the bare command toggles). Add `toggle` only if players ask for it.

### F12 · Seven repositories — decision needed
- Problem: shared tooling, docs and CI templates live in PaTiAdmin and must be checked out next to each addon; cross-repo changes need several commits.
- Options: keep multi-repo (current, works) or move to one monorepo with per-addon packaging. Owner decision; do not start without it.

### F13 · PaTiHeal.lua above 400 lines — low
- Status: the settings modal moved to `Settings.lua` (2026-09-29); the HoT row code brought `PaTiHeal.lua` back to ~490 lines.
- Smallest solution: move the HoT row UI (`layoutHoTs`, `paintHoTs`, the timer ticker) next to `HoTs.lua` in its own
  file when PaTiHeal is next touched (not during the beta freeze unless a fix needs it).
- Risk: low · Tests: `smoke` test mode path (HoT icons with 5 / 8s), hots_spec.

### F14 · PaTiHeal lacks a Scale setting — low
- Status: `/ph` alone, `/ph reset` and `/ph version` exist since 2026-09-29. Only the Scale setting is missing.
- Smallest solution: like PaTiTank (Logic.SCALES + dropdown); SetScale on the secure PaTiHeal window only out of combat.
- Risk: low · Tests: settings smoke path, `/reload` in combat.


### F16 · PaTiTank: highlight lost enemies on their nameplates — low
- Problem: the aggro monitor lists lost enemies, but their nameplates are not marked.
- Why not done: nameplate frames belong to Blizzard (possibly forbidden frames in this client); drawing on them risks
  taint or errors. Needs `C_NamePlate.GetNamePlateForUnit` behaviour verified in this client first.
- Smallest solution: own overlay frame anchored to the plate, only if the plate is not forbidden (`IsForbidden`), pcall-guarded.
- Risk: medium (taint) · Tests: taint log in combat with 5+ enemies.

### F17 · PaTiTank: click an aggro row to target that enemy — decision needed
- Problem: the rows cannot be clicked to target the enemy.
- Limitation: targeting needs a secure button with `unit` = the enemy's token; nameplate tokens change as plates
  appear and vanish, and secure attributes cannot change in combat, so rows would target the wrong enemy mid-fight.
- Possible: only rows backed by a stable token (e.g. `party1target`) — a partial feature; owner decides whether that is worth it.
- Never: automatic targeting or taunting.

### F18 · No LICENSE in any repo — high for distribution · decision needed
- Problem: the public repos have no license, so nobody may legally reuse or redistribute the code; CurseForge and Wago
  ask for a license when a project is created.
- Owner decision: which license (common for WoW addons: MIT, GPL-3.0, or "All Rights Reserved"). Then add the same
  `LICENSE` to every repo (not into the release zip) and name it in the READMEs.
- Risk: none technically · Blocks: public distribution (RELEASE.md distribution checklist).

### F19 · Addon icons / logos — low
- Problem: only PaTiAuras has `Media/icon.tga` (`## IconTexture`); platforms want a logo per project.
- Smallest solution: one icon per addon in `Media/` + `## IconTexture`; the package already ships `Media/`.

### F20 · PaTiHeal reads dispellable debuffs on every UNIT_HEALTH — low
- Problem: the unit-event handler repaints the dispel icons (an aura scan) also on UNIT_HEALTH/UNIT_POWER_UPDATE of
  party units, though debuffs only change with UNIT_AURA/UNIT_CONNECTION/UNIT_FLAGS. HoT icons already skip those events.
- Smallest solution: the same event filter for `paintDispels`. · Risk: low · Tests: busy fight, dispel icons still appear.
