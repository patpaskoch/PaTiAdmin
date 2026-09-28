# AGENTS.md — PaTiSuite engineering rules

Binding for every coding agent (Claude Code, Codex, local LLMs) and for humans.
Short on purpose; details live in [`docs/`](docs/). If a rule here and a doc disagree, this file wins — then fix the doc.

## 1. What this is

PaTiSuite = small, independent World of Warcraft addons for one player/developer, running on the
**WoW Forever client, Interface 16001** (build 1.60.1.70009) — not Retail, not Classic Era.

Principles, in this order: **small · focused · reliable · readable before clever · maintainability before
abstraction · existing patterns before new patterns · no bloat.**

## 2. Repository layout (seven Git repos side by side)

```
C:\Users\patpa\code\                     (not a repo; macOS: same layout under ~/code)
├── PaTiAdmin/     THIS repo: rules, docs, tools, CI templates, suite status (public)
├── PaTiShared/    design system + UI components, embedded into addons (not a WoW addon)
└── PaTiAddons/
    ├── PaTiHeal/     healer party frames + manual click casting (secure)   /ph
    ├── PaTiTank/     own health, target, threat bar                        /pt
    ├── PaTiGroup/    raid markers (secure), ready check, pull timer        /pg /ptg /patigroup
    ├── PaTiQuest/    selected quest + objectives                           /phq
    ├── PaTiDungeon/  instance, group and combat status                     /pd
    └── PaTiAuras/    aura/buff watch (optional, standalone)                  /pa /patiauras
```
Each addon repo: `<Addon>.toc`, one main `<Addon>.lua` (+ `PaTiSharedPanel.lua` in Tank/Quest/Dungeon,
`Bindings.xml` in Group), `README.md`, `CHANGELOG.md`, `AGENTS.md` (addon specifics), `.github/workflows/ci.yml`.
Installed copies in `...\_classic_beta_\Interface\AddOns\` are **test targets only, never a source**.
Architecture and data flow: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## 3. Addon independence (hard rule)

- Every addon must load and work with no other PaTi addon installed. No `## Dependencies`, no
  `## OptionalDeps` on PaTi addons, no reading another addon's globals or SavedVariables.
- No runtime core/library addon. PaTiSuite (launcher) may come later and stays optional.
- Shared UI is **embedded**: PaTiShared is copied into `<Addon>/Shared/` by
  `PaTiShared/scripts/sync-shared.sh`. Never edit `<Addon>/Shared/` by hand (CI detects it).
- Small duplication between addons is acceptable when it keeps them independent.
  Shared pattern ≠ shared runtime dependency.

## 4. Before editing — every time

1. Read the files you will touch completely, plus the addon's `AGENTS.md` and `README.md`.
2. Understand the current implementation and why it is like that (`git log -p <file>`).
3. Search the other addons and PaTiShared for the same problem; reuse the pattern that exists.
4. Check existing tests (`tests/*_spec.lua`) and run `tools/check.sh` before and after.
5. Localization: will you add or change visible text? → [`docs/LOCALIZATION.md`](docs/LOCALIZATION.md).
6. Documentation that describes what you change (README, CHANGELOG, docs/).
7. SavedVariables: does the stored shape change? → migration (§9).
8. WoW API: secure/protected? combat? does the API exist in Interface 16001? → [`docs/WOW_API_COMPAT.md`](docs/WOW_API_COMPAT.md).

## 5. Coding style

- Lua 5.1. Clear names; small functions that do one thing; early returns over deep nesting.
- **Globals only** for: SavedVariables, `SLASH_*`, binding functions, and frame names WoW needs
  (e.g. for `UISpecialFrames`). Everything else `local` or in the addon namespace `local addonName, ns = ...`.
  `.luacheckrc` lists the allowed globals per addon — extending it needs a reason in the commit message.
- No hidden side effects (e.g. a getter that saves settings). Name side effects: `apply…`, `save…`, `set…`.
- No magic numbers without a name or a comment; UI numbers come from PaTiShared tokens (`UI.Sizes`, `UI.Spacing`).
- No metaprogramming beyond `setmetatable` for simple defaults/lookups. No classes/OOP frameworks.
- No new file above ~400 lines; split by responsibility, not per function. New lines ≤ 120 chars.
- Comments explain *why* (WoW quirks, combat rules), not what the next line does.
- No external libraries (Ace3, LibStub, …) without a written decision in `docs/ARCHITECTURE.md`.

## 6. Existing patterns first

Use what exists before inventing: event frame + `OnEvent` dispatch, `PLAYER_LOGIN` initialises the DB,
slash command table, `testMode` flag with fake data, `DB.locked` + drag to move, PaTiShared components
for any window/menu/modal/button/dropdown/checkbox/badge. **Never build a second mechanism for a problem
that already has one.** If the existing pattern is bad, write a follow-up (§12) instead of a parallel one.
Pattern catalogue: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md#existing-patterns).

## 7. Module boundaries

Target flow, applied to new and changed code (do not rewrite old code just for this):
`WoW event → read API (adapter) → normalized plain table → logic → UI update`.
Keep WoW calls at the edges so logic can be unit-tested with plain tables.
Split a file when it mixes responsibilities, not before. PaTiShared decides *how UI looks*; the addon decides *what it does*.

## 8. WoW API rules

- WoW Forever (Interface 16001) ≠ Retail. Never assume a Retail API exists — guard with
  `if C_X and C_X.Fn then` / `pcall`, and record verified facts in `docs/WOW_API_COMPAT.md`.
- **Combat lockdown:** never create, show/hide, move, resize, reparent secure frames or change their
  attributes while `InCombatLockdown()`; queue and apply on `PLAYER_REGEN_ENABLED`.
- Protected actions (casting, targeting, raid markers `SetRaidTarget`) only through
  `SecureActionButtonTemplate` / `SecureUnitButtonTemplate` attributes or secure macros — never from addon Lua.
- **Secret values** (restricted unit data): pass straight to widgets (`SetValue`, `SetText`); no arithmetic, comparisons or string ops.
- No gameplay automation: no automatic target, spell, marker or decision. The player clicks, the addon executes exactly that one click.
- Never work around Blizzard protection (taint tricks, hidden click forwarding, OnUpdate spamming protected calls).
- Keybindings and macros are the player's: do not overwrite an existing binding (PaTiGroup checks first — keep it that way).
- Addon messages (none exist yet): versioned prefix, validate every field, never trust remote data, no periodic full-state broadcasts. Document in `docs/PROTOCOL.md` before shipping.

## 9. SavedVariables

- Existing player data is sacred: never rename/delete keys silently. Read old keys, migrate, then write new ones.
- Schema changes: add `DB.schema = <n>` and a stepwise `migrate(DB)` run on `PLAYER_LOGIN`; cover it with a test.
- Defaults: `if DB.key == nil then DB.key = default end` — not `DB.key = DB.key or default`, which turns a saved `false` into the default.
- Runtime state (test mode, open panels, combat queues) is not persisted unless the player expects it.

## 10. Performance

Events over polling. `OnUpdate` only for real per-frame needs, throttled, and stopped when hidden.
Filter unit events by unit (`RegisterUnitEvent` where available) and update only the affected row instead
of full refreshes. Watch hot paths: `UNIT_HEALTH`, `UNIT_POWER_UPDATE`, `UNIT_AURA`, combat log.
No premature optimisation elsewhere.

## 11. Localization

English (enUS) is the source and fallback. Locales: **enUS, deDE, zhCN, zhTW, koKR** (enGB → enUS).
No visible text hard-coded in feature code — use `L.KEY` from `Locales/<code>.lua`.
Unsure translations: leave the key out (English fallback) rather than guess. Details: [`docs/LOCALIZATION.md`](docs/LOCALIZATION.md).
Existing addons still hard-code German text (follow-up); new or touched UI text must use keys.

## 12. Refactoring rule

Small local refactors needed for the task: allowed. **No "while I'm here" changes.**
Cross-module or architecture refactors: do **not** implement. Add an entry to
[`docs/FOLLOW_UPS.md`](docs/FOLLOW_UPS.md) with Problem · Affected code · Why it matters · Smallest solution ·
Alternative without refactor · Risk · Tests needed · Priority, and ask the owner.

## 13. Testing

- `tools/check.sh` = syntax, luacheck, unit tests, locales, TOC/file references, Shared/ integrity, package dry run.
  Same script in CI. Run it before every commit. See [`docs/TESTING.md`](docs/TESTING.md).
- Unit-test pure logic: config/defaults, SavedVariables migrations, version parsing, localization,
  protocol encode/decode, quest comparison, state transformations. Specs: `tests/*_spec.lua` (busted-style).
- Mock only the WoW functions the code under test calls (`PaTiAdmin/tests/mocks/wow_api.lua`). No client emulation.
- Bug fix: reproduce → failing test (if the logic is testable) → fix → green → full `check.sh`.
- **Manual in-game tests** are required for: secure click casting, combat lockdown, protected actions, taint,
  raid markers, visuals/layout, fonts (zhCN/zhTW/koKR), real group/dungeon situations, addon communication.
  **Never claim an in-game test you did not perform.** Write them down as "Manual WoW tests still required".

## 14. Documentation and changelog

Change code and docs in the same commit. User-visible change → `CHANGELOG.md` of that repo under
`## [Unreleased]` with **Added / Changed / Fixed / Removed / Known Issues**.
Versions: `## Version` in the TOC is the source of truth (SemVer). Release steps: [`docs/RELEASE.md`](docs/RELEASE.md).

## 15. Workflow: builder + independent reviewer

Issue → **Builder agent** → `tools/check.sh` → CI → **Reviewer agent (a different agent/model than the builder)**
→ findings → fix → CI again → **WoW smoke test by the owner** → release. Details: [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md).
Commits: one topic per commit; never commit untested in-game behaviour as "tested".

## 16. Definition of Done

- [ ] Implementation complete, scoped to the task, no unrelated changes
- [ ] Existing architecture and patterns respected (or follow-up written)
- [ ] Tests added where logic is testable; `tools/check.sh` green (syntax, lint, tests, locales, TOC, package)
- [ ] Localization keys added (enUS at least); no new hard-coded visible text
- [ ] Docs + CHANGELOG updated (if user-visible)
- [ ] SavedVariables compatibility checked (migration + test if the shape changed)
- [ ] WoW API assumptions checked against Interface 16001 / documented
- [ ] Performance considered for event hot paths
- [ ] Independent review performed
- [ ] CI green
- [ ] Required manual WoW tests listed

## 17. Validation output (end every task with this; never invent results)

```
VALIDATION
Changed:                     - files / behaviour
Architecture:                - patterns used, boundaries kept or follow-ups written
Tests executed:              - exact commands + results
Tests not executable here:   - …
Lint:                        - luacheck result (or "not run: reason")
Localization:                - keys added / untranslated
Documentation:               - files updated
SavedVariables:              - unchanged / migrated how
WoW API assumptions:         - …
CI:                          - run link/result, or "not run"
Manual WoW tests still required: - …
Known limitations:           - …
```
