# Development

## Setup (once per machine)

1. Clone all repos into one folder: `PaTiAdmin`, `PaTiShared`, `PaTiAddons/<Addon>` (layout in `AGENTS.md` §2).
2. Lua 5.1-compatible interpreter:
   - Windows: `winget install DEVCOM.LuaJIT` (→ `%LOCALAPPDATA%\Programs\LuaJIT\bin\luajit.exe`, new terminal for PATH)
   - macOS: `brew install luajit`
3. Luacheck (static analysis):
   - macOS/Linux: `luarocks --lua-version 5.1 install luacheck`
   - Windows: the LuaJIT package's luarocks cannot build luacheck's C dependency. CI always runs luacheck;
     locally `check.sh` reports it as SKIP. If you have a working luacheck, point `LUACHECK=` at it.
4. Agent entry points outside Git (recreate on a new machine):
   - `code/CLAUDE.md` containing `@PaTiAdmin/AGENTS.md` (Claude Code reads CLAUDE.md in parent folders)
   - `code/AGENTS.md` pointing to `PaTiAdmin/AGENTS.md` (Codex started in `code/`)
   - every repo's own `AGENTS.md` starts with a link to the suite rules.

## Daily loop

```
edit in C:\Users\patpa\code\...           (never in the WoW AddOns folder)
PaTiAdmin/tools/check.sh <repo folder>    (or no argument = everything)
copy the changed addon files to  D:\Users\patpa\Apps\wow\World of Warcraft\_classic_beta_\Interface\AddOns\<Addon>\
/reload in game, test, note what you tested
commit (one topic), CHANGELOG under [Unreleased] if user-visible
```
Changing shared UI: edit `PaTiShared/src`, then `PaTiShared/scripts/sync-shared.sh --all`, then check + test each synced addon.
Client: WoW Forever build 1.60.1.70009, Interface 16001, client locale deDE.

## Four-eyes process with agents

```
Issue → Builder agent → tools/check.sh → CI → Reviewer agent → findings → fix → CI → WoW smoke test → release
```
- Builder and reviewer should be **different agents/models** (e.g. Claude Code builds, Codex reviews, or the reverse).
- Builder ends with the VALIDATION block (`AGENTS.md` §17). The reviewer gets the diff + that block.
- Reviewer prompt (copy):
  > Review this diff in the PaTiSuite repos against PaTiAdmin/AGENTS.md. Report only concrete findings:
  > correctness bugs, combat-lockdown/secure/taint risks, SavedVariables compatibility, hard-coded UI text,
  > unrelated changes, missing tests, violated patterns. For each: file:line, problem, failure scenario, fix.
  > Do not restyle code. Say explicitly which claims in the VALIDATION block you could not verify.
- The owner does the WoW smoke test; agents never mark in-game behaviour as tested.

## Git

- Default branch `main`. One topic per commit; message says what and why.
- Commit only what you checked. In-game-untested fixes may be committed, but the commit message or
  CHANGELOG must not claim an in-game test.
- `PaTiAdmin` is private; addon repos are public on github.com/patpaskoch.
