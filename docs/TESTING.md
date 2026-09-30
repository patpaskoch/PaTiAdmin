# Testing

## Automated: `tools/check.sh`

| Step | What it checks | Tool |
|---|---|---|
| syntax | every `.lua` compiles (Lua 5.1 grammar) | `tools/lua/run.lua syntax` |
| luacheck | undefined/unused variables, forbidden globals (per-addon allow list) | `luacheck` + `.luacheckrc` |
| tests | `tests/*_spec.lua` of the repo | `tools/lua/test.lua` (busted-compatible subset) |
| locales | enUS present, no unknown/duplicate keys, files load, values are strings; untranslated = warning | `tools/lua/locales.lua` |
| toc | Interface/Title/Version (SemVer), SavedVariables names, every referenced file exists (incl. XML includes), no stray characters, no `Dependencies`/`OptionalDeps` on PaTi addons, every `.lua` outside `tests/` is loaded (error); missing Notes/Author (warning) | `tools/lua/toc.lua` |
| shared | `Shared/` matches its `.manifest` (no hand edits) | bash |
| ci-file / release | `.github/workflows/ci.yml` and (addons) `release.yml` equal the templates | bash |
| package | a real zip is built in a temp folder: one folder `<Addon>/`, TOC inside, content = package list, no development files | `tools/package.sh --verify` |

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
- Current coverage: PaTiAdmin tools (TOC parser incl. the `` `r`n `` regression, release rules, changelog sections,
  locale validator), PaTiShared locale handling, PaTiHeal (bindings → attributes, migration incl. HoT settings, ranks,
  health percent, secret-value helpers, profiles, HoT matching/texts), PaTiAuras (states, config, spellbook, profiles,
  unreadable auras → UNKNOWN, secret names/flags, Priest healing auras), PaTiGroup (settings, marker slots, secret-value
  helpers, 1/true flags), PaTiTank (migration, collapse, threat value, aggro states, threat adapter with mocks),
  PaTiQuest (migration, collapse, quest lines), PaTiDungeon (migration, collapse, status incl. 1/nil flags).

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
| Aggro monitor (PaTiTank) | `/pt test` shows 5 / 6, Ghoul → Healer, Zombie barely held; real pull with 3+ enemies: counts match, a mob on the healer shows "→ Healer" within ~1 s, dead enemies disappear, no Lua errors in combat; `/pt debug` aggro line |
| Numbered nameplates (PaTiTank) | pull 3+ enemies, one on the healer, one on a DPS: panel `1 A → Healer`, `2 B → DD`; exactly A carries a red "1", B a "2"; with two same-named enemies the numbers still match; clicking the "1" plate targets A (no taunt, no target change by itself); number gone when aggro is back / the enemy dies / its plate disappears; a new enemy on a reused `nameplateN` never shows an old number; `/pt test` shows `1 Ghoul`, `2 Zombie` without plate overlays; no Lua errors, taint log has no PaTiTank entry |
| Icons (all seven) | icon shows in the AddOns list (no white/missing texture, no path error), readable at small size |
| Collapse (all seven) | ••• → Collapse/Expand; state survives `/reload`; Heal/Group/Auras: entry disabled in combat |
| SavedVariables | settings survive `/reload` and relog; old saved files load after an update |
| HoTs & shields (PaTiHeal) | Shaman/Priest: `/ph auras` lists IDs; own HoT/shield icon on the frame with charges/timer; another healer's does not show; right/below setting; click dispel on a chosen combination |
| Key binding note (PaTiGroup) | the path shown in the settings is the real one in this client (report the real path) |

## Fresh install test

"Does the downloaded zip work like for a stranger?" Per addon, once per release candidate:

1. Build the zip: `PaTiAdmin/tools/package.sh ../PaTiAddons/<Addon>` (or take it from the draft release).
2. Unpack it: exactly one folder `<Addon>/` must appear, with `<Addon>.toc` directly inside.
3. Move every PaTi folder out of `Interface/AddOns/` (keep `WTF/` — or also test once with its SavedVariables removed).
4. Copy only `<Addon>/` into `Interface/AddOns/`, start WoW, enable only this addon.
5. Login: the addon is listed with its description and loads; no Lua error.
6. `/reload`; open the main window and the settings (`/<cmd> settings`); `/<cmd> test`; no Lua error.

**Independence test:** the fresh install test once for each addon alone (PaTiHeal, PaTiAuras, PaTiTank, PaTiGroup,
PaTiQuest, PaTiDungeon, PaTiAlerts). **Combined test:** all seven together: every window opens, every slash command answers the right
addon (`/ph /pa /pt /pg /ptg /phq /pd /pal /psuite`), each settings window saves its own values, no Lua or taint error.

## Short in-game list (per release candidate)

Priority: 1 loads · 2 UI · 3 main feature · 4 combat · 5 `/reload` · 6 SavedVariables · 7 all addons together · 8 Lua/taint.

| Addon | Checks |
|---|---|
| all | fresh install alone loads, icon in the AddOns list, no Lua error · ••• menu entries · settings open/save · Collapse survives `/reload` · test mode |
| PaTiHeal | each bound click casts on the clicked frame · own HoT/shield icons · dispel icon + click dispel · member joins/leaves in combat · Collapse/Hide greyed out in combat · Scale changed in combat applies after combat |
| PaTiAuras | own class profile shows; toggling an aura hides it · group buff click buffs the named member, one cast per click · in combat target stays · UNKNOWN never shows as Missing |
| PaTiAuras weapon imbues, owner sequence | A no weapon → no line · B weapon, no Rockbiter → "Missing" (not Unknown) · C Rockbiter → "Active" (+ timer) · D Rockbiter gone → "Missing" · E again → "Active" · F weapon off → line gone · G weapon on → read fresh · H `/pa debug` + `/pa auras` output (API, slot, enchantID, timeLeft, readable) · PaTiAlerts: warning while missing, gone while active, never for Unknown |
| PaTiAuras settings | General clear; Watch button opens the list of your class's effects (self, procs, healing, weapon, group), ticks toggle one each, list stays open; no second aura list; choices survive `/reload`; an old "healing off" stays off after the update |
| PaTiAuras weapon imbues (Shaman) | `/pa debug`: which enchant API exists · no imbue: Main Hand "Missing" · imbue main hand: Active + timer · off hand separately · expiring < 30 s · renew: updates within ~2 s · swap weapon / take off off hand / equip shield: no old state, no Lua error · in combat an imbue expires or is renewed · `/pa auras` with Flametongue and Windfury on (report the enchant IDs) |
| PaTiTank | pull 3+ mobs: `x / y` matches, a mob on the healer shows "Healer" within ~1 s and its row number in red on its nameplate, clicking that nameplate targets it, dead mobs vanish · `/pt debug` aggro line |
| PaTiGroup | each marker + Clear on a target, Reset All · key bindings at the path shown in the settings · no key/macro created · bar not changeable in combat |
| PaTiQuest | selecting another quest updates the window |
| PaTiDungeon | entering a dungeon / joining a group / combat updates the window |
| PaTiAlerts alone | loads, `/pal test` shows red/yellow/blue lines, move/lock/scale/collapse, settings saved after `/reload`, auto-hide when empty and locked |
| PaTiAlerts + PaTiTank | pull 3+ mobs: `1 A → Healer` appears in PaTiTank and PaTiAlerts, "1" on A's nameplate; same-named enemies; aggro back / enemy dies → line gone |
| PaTiAlerts + PaTiAuras | missing watched buff / weapon imbue → line; active → gone; unclear never as missing |
| PaTiAlerts + PaTiHeal | member with a dispellable debuff → blue line; dispelled → gone |
| Panel opacity (all seven) | change it in the settings → body lighter/darker, header, texts, icons, bars unchanged; `/reload` keeps it |
| Window moving | no snapping setting any more; windows move freely, positions survive `/reload`; dragging a Heal/Auras/Group window is impossible in combat |
| PaTiSuite hover/colours | mouse over a line: background darker, text light and readable; shown = green dot + "Shown", hidden = grey |
| PaTiSuite | with one, two and all seven PaTi addons: only installed ones listed; click a line → window hides/shows; Show all / Hide all (panel stays); in combat Hide all → "Heal: not possible in combat", Tank still hides; `/reload`; without PaTiSuite everything as before |
| Without PaTiAlerts | PaTiTank, PaTiAuras, PaTiHeal each without PaTiAlerts: unchanged, no Lua error |
