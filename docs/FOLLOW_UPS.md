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
- Status: fixed in code for PaTiHeal, PaTiAuras, PaTiGroup (PaTiShared Window; awaiting in-game drag → reload test); Tank/Quest/Dungeon open.
- Problem: Heal/Tank/Quest/Dungeon save `x, y` from `GetPoint()` after dragging but restore them as `CENTER` offsets; the window can jump after `/reload`.
- Approach: PaTiShared `Window:SavePosition` stores point + relativePoint; old saves keep working.
- Risk: low · Tests: manual drag → reload.

### F5 · Hard-coded German UI text in all addons — medium
- Status: done for PaTiHeal, PaTiAuras, PaTiGroup (enUS + deDE); Tank, Quest, Dungeon open.
- Problem: every label, tooltip and chat line is German in code.
- Approach: per addon, when its UI is touched: `Locales/enUS.lua` (source) + `deDE.lua` with the current German text; other locales fall back to English.
- Risk: low · Tests: locale validation (automatic) + visual check.

### F6 · Legacy global `PaTiSharedPanel` redefined by three addons — medium
- Problem: Tank/Quest/Dungeon each define the same global; the last loaded wins. The title is created twice (hidden own title + panel title).
- Approach: replace with embedded PaTiShared Window when each addon is migrated; then remove it from `.luacheckrc`.
- Risk: low · Tests: load each addon alone and all together.

### F7 · Full refresh on every unit event — low · FIXED IN CODE for PaTiHeal (per-unit repaint); PaTiTank open
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

### F10 · No separable logic, therefore no addon unit tests — low · done for PaTiHeal, PaTiAuras, PaTiGroup; Tank/Quest/Dungeon open
- Problem: one file per addon mixes events, API and UI; nothing can be loaded without frames.
- Approach: when touching logic, extract pure functions (e.g. `unitData` normalisation, click-binding table, quest objective formatting) into a small file without frame creation, then test it.
- Risk: low if done per touched function.

### F11 · Inconsistent slash command sets — low
- Problem: `/phq` for PaTiQuest (looks like "PaTiHeal quest"), PaTiGroup keeps German `an/aus` aliases, Tank/Quest/Dungeon allow
  `test`/`lock` in combat without guard and have no `debug`/`settings`. Heal, Auras, Group already share settings/test/lock/unlock/debug.
- Approach: agree one set (`show, hide, toggle, lock, unlock, test, debug, version`) and align when each addon is touched; keep old aliases.

### F12 · Seven repositories — decision needed
- Problem: shared tooling, docs and CI templates live in PaTiAdmin and must be checked out next to each addon; cross-repo changes need several commits.
- Options: keep multi-repo (current, works) or move to one monorepo with per-addon packaging. Owner decision; do not start without it.

### F13 · PaTiHeal.lua above 400 lines — low
- Problem: 441 lines after ranks, dispels and the frame UX pass (rows, settings, menu, events in one file).
- Approach: move the settings modal (`spellItems`, `rankItems`, `bindingControls`, `buildSettings`) into `Settings.lua` next time it is touched.
- Risk: low · Tests: existing smoke paths (settings open, rank change).
