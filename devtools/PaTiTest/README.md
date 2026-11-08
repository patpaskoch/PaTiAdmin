# PaTiTest (developer tool, never released)

Self-check of the installed PaTi addons in the real client, started by hand with `/patitest`.
It saves time on routine checks; it does **not** tick in-game tests — the owner still confirms every
`INGAME_TESTING.md` entry (AGENTS.md §13).

## Use

1. Copy this folder to `…\_forever_\Interface\AddOns\PaTiTest\` (only on the developer's machine).
2. In game, out of combat: `/patitest`. Chat shows one line per addon and a total.
3. `/reload`, then `/patitest` again: the "after /reload" check compares window position and visibility.
4. `/patitest fehler` (or `errors`) lists the Lua errors caught since login.

Results are in `WTF\Account\<account>\SavedVariables\PaTiTest.lua` (`PaTiTestDB.last`), written on `/reload` or logout.

## What it checks per addon

| Check | How | Fails when |
|---|---|---|
| loaded | `C_AddOns.IsAddOnLoaded`, version from the TOC | installed but not loaded (not installed = skipped) |
| Lua errors | its own error handler, wrapped around the previous one | an error mentions `AddOns/<Addon>/` |
| command | `SlashCmdList[<KEY>]` and every `SLASH_*` global | no handler, no command, or a command used by another addon |
| window | `_G.PaTiSuiteWindows[<Addon>]` | no window registered |
| show/hide | the addon's own `SetSuiteShown`, then switched back | Lua error or window not switched back (no effect = note) |
| after /reload | first-run snapshot of the previous session vs. now | position (±1 px) or visibility differs |

## Limits

- Loads after the PaTi addons (alphabetical), so an error while *their files load* is not caught; errors from
  `PLAYER_LOGIN` on are.
- Nothing in combat, no clicks, no casts, no settings changes; looks (layout, colours) stay manual tests.
- Reads only what AGENTS.md §3 allows plus the addon list and `SLASH_*` globals; never another addon's SavedVariables.

Logic: `Logic.lua` (unit-tested in `tests/patitest_spec.lua`, which also runs the whole addon with a stand-in client).
