# Testing

## Automated: `tools/check.sh`

| Step | What it checks | Tool |
|---|---|---|
| syntax | every `.lua` compiles (Lua 5.1 grammar) | `tools/lua/run.lua syntax` |
| luacheck | undefined/unused variables, forbidden globals (per-addon allow list) | `luacheck` + `.luacheckrc` |
| tests | `tests/*_spec.lua` of the repo | `tools/lua/test.lua` (busted-compatible subset) |
| locales | enUS present, no unknown/duplicate keys, files load, values are strings; untranslated = warning | `tools/lua/locales.lua` |
| toc | Interface/Title/Version (SemVer), SavedVariables names, every referenced file exists (incl. XML includes), no stray characters, unloaded `.lua` files (warning) | `tools/lua/toc.lua` |
| shared | `Shared/` matches its `.manifest` (no hand edits) | bash |
| package | release file list can be built | `tools/package.sh --dry-run` |

```
PaTiAdmin/tools/check.sh                       # everything next to PaTiAdmin
PaTiAdmin/tools/check.sh ../PaTiAddons/PaTiHeal
LUA=/path/to/luajit LUACHECK=/path/to/luacheck PaTiAdmin/tools/check.sh
```
Results: PASS / FAIL / SKIP (tool missing locally) / NONE (nothing to check yet). Exit code ≠ 0 on any FAIL.

## Unit tests

- Location: `<repo>/tests/<topic>_spec.lua`. Runner: `describe`, `it`, `before_each`,
  `assert.equal/same/is_true/is_false/is_nil/truthy/falsy/matches/has_error` — the busted API, so the
  specs can move to busted unchanged if it ever becomes installable everywhere.
- Load addon files like WoW does: `require("wow_api").loadAddonFile(path, ns)` passes `(addonName, ns)`.
- Mocks: `PaTiAdmin/tests/mocks/wow_api.lua`. Add a mock only for a function the code under test calls.
  Do not mock frames, secure templates or combat — those are manual tests.
- What to test: defaults/config, SavedVariables migrations (old table in → new table out, no data lost),
  version parsing, locale lookup/fallback, protocol encode/decode/validation, quest comparison,
  state transformations, pure helpers.
- Current coverage: PaTiAdmin tools (TOC parser incl. the `` `r`n `` regression, locale validator), PaTiShared locale
  handling, PaTiHeal (bindings → attributes, migration, ranks, health percent), PaTiAuras (states, config, spellbook,
  unreadable auras → UNKNOWN), PaTiGroup (settings, marker slots, secret-value helpers, 1/true flags), PaTiTank (migration, threat value),
  PaTiQuest (migration, quest lines), PaTiDungeon (migration, status incl. 1/nil flags).

## Regression rule

Bug → reproduce → failing test if the logic is testable → fix → test green → full `check.sh`.
If not testable outside WoW, add the reproduction steps to the manual list below in the PR/commit notes.

## Manual WoW tests (CI cannot do these)

Owner runs them in the client after `/reload`; agents list which are needed, never mark them done.

| Area | Minimum check |
|---|---|
| Secure click casting (PaTiHeal) | every configured button/modifier casts the chosen spell on the clicked unit; nothing casts in test mode |
| Combat lockdown | enter combat, use every menu/slash command; no `ADDON_ACTION_BLOCKED`/`ADDON_ACTION_FORBIDDEN` |
| Taint | `/console taintLog 1`, play, check `Logs/taint.log` for PaTi entries |
| Raid markers (PaTiGroup) | each marker + Clear on the current target; Reset All clears all; key bindings from the WoW menu; no binding/macro created |
| Visuals | layout at UI scale 0.64–1.0, locked/unlocked, test mode badge, long German/zh/ko strings fit |
| Fonts | zhCN, zhTW, koKR texts render (not boxes) on the deDE client |
| Group/dungeon | real party: roster changes, offline/dead members, ready check, pull timer, instance change |
| SavedVariables | settings survive `/reload` and relog; old saved files load after an update |
