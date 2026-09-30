# Release

Everything about versions, packages, releases and the beta lives here. Tests: [`TESTING.md`](TESTING.md).
Current state per addon: [`../SUITE_STATUS.md`](../SUITE_STATUS.md).

## Versioning

- **Source of truth: `## Version` in `<Addon>.toc`.** PaTiShared: its `VERSION` file (embedded, never released alone).
- SemVer `MAJOR.MINOR.PATCH`: MAJOR = breaking change (e.g. settings reset, removed command), MINOR = feature,
  PATCH = bug fix. Pre-1.0 addons may treat MINOR as "any user-visible change". `tools/check.sh` rejects other formats.
- The version changes **only when a release is cut** — never for CI, docs or tooling changes, never "in advance".
- Tags are per repo: `v<version>` (e.g. `v0.7.0` in the PaTiHeal repo). Older notes used `<Addon>-x.y.z`; no such tag exists.
- Release zip: `<Addon>-<version>.zip`, containing exactly one folder `<Addon>/`.

## Changelog

Every repo has `CHANGELOG.md`: running changes under `## [Unreleased]` (Added / Changed / Fixed / Removed /
Known Issues), in the same commit as the code. On release the heading becomes `## [0.7.0] - 2026-10-02`;
that section is the release notes. History before the changelog existed: `git log`.

## Package

`tools/package.sh ../PaTiAddons/<Addon>` → `PaTiAdmin/dist/<Addon>-<version>.zip` (git-ignored).

- Contains only what the client loads: the TOC, every file it references, XML includes, `Bindings.xml`, `Media/`.
  Never: tests, `.github`, `.git`, `assets/`, `LICENSE`, `*.md`, scripts, `Shared/.manifest`, IDE or temp files — the package list fails if a
  TOC references such a file. README/CHANGELOG are shown on the GitHub release page, not shipped in the zip.
- Fails on a missing referenced file, a TOC error, a Lua file the TOC does not load or an `## IconTexture` that does not
  point to a texture inside the addon.
- Reproducible: sorted file order, file times = time of the last commit.
- `--dry-run` lists the files; `--verify` builds the zip in a temp folder and checks it (one folder `<Addon>/`, TOC
  present, content = package list). `tools/check.sh` runs `--verify` for every addon, locally and in CI.

## Release steps

```
code done → check.sh + CI green → manual WoW test → bump TOC version → cut CHANGELOG → commit → tag → draft release → publish
```

1. `tools/check.sh <addon>` green, CI green, reviewer findings resolved.
2. Owner's manual WoW tests for the changed areas plus the fresh install test ([`TESTING.md`](TESTING.md)), results
   entered in the addon's `INGAME_TESTING.md`; the gate below holds.
3. Bump `## Version` in the TOC; rename `[Unreleased]` to `[x.y.z] - YYYY-MM-DD` (start a new empty `[Unreleased]`).
4. Commit "Release <Addon> x.y.z", push, wait for CI.
5. `git tag vX.Y.Z && git push origin vX.Y.Z`.
6. The repo's **Release** workflow (`.github/workflows/release.yml`, copy of `templates/release.yml`) runs all checks,
   fails if the tag is not the TOC version, builds the zip and creates a **draft** GitHub release with the
   CHANGELOG section as notes. It uses only the built-in `GITHUB_TOKEN`.
7. Owner opens the draft on GitHub, checks zip and notes, presses **Publish release**.
8. Update `SUITE_STATUS.md` and regenerate [`INGAME_TEST_STATUS.md`](INGAME_TEST_STATUS.md).

No CurseForge/Wago upload automation until there is a concrete need and an explicit decision.

## Beta ready (per addon)

An addon may be called **beta** when all of this is true — CI alone is never enough:

- [ ] Current CI green (check.sh incl. zip check)
- [ ] Release zip built and the fresh install test passed ([`TESTING.md`](TESTING.md#fresh-install-test))
- [ ] Works alone (independence test) and together with all other PaTi addons (combined test)
- [ ] In-game verification gate below met (main paths VERIFIED in `INGAME_TESTING.md`), no known Lua errors
- [ ] No known taint/combat problems in the tested main paths
- [ ] No known critical/high bugs (`FOLLOW_UPS.md`); medium/low limitations are documented in README/CHANGELOG
- [ ] README, CHANGELOG and TOC match the code

## In-game verification

Source: the addon's `INGAME_TESTING.md` ([`TESTING.md`](TESTING.md#in-game-test-files)); overview
[`INGAME_TEST_STATUS.md`](INGAME_TEST_STATUS.md). Only the owner's confirmation in the real client counts — CI, unit
tests and review never do. An addon is not "in-game verified" while relevant tests are open.

Before a beta or release build:

- All critical / main-path tests are `✅ VERIFIED`: installation and loading (`…-001` to `…-005`), the main feature
  sections, Combat / Sicherheit, Combined.
- Every known `❌ FAIL` is assessed (`tools/ingame-status.sh --list failed`): fixed and retested, or consciously
  accepted with a note in the test and the CHANGELOG's Known Issues.
- No unresolved critical/high FAIL.
- Open low / edge-case tests may stay open when consciously accepted — not every box has to be ticked for a beta.
  Main paths decide.

## Beta freeze

From the day an addon is declared beta until its first stable release: **no new features.**
Allowed: bug fixes, WoW API compatibility fixes, taint/secure fixes, performance problems, localization fixes,
small UX fixes, documentation, packaging/release fixes. New ideas go to `FOLLOW_UPS.md` (backlog).
Goal: first release stable, then build on.

## Distribution checklist (GitHub, CurseForge, Wago)

Prepared, not done — no accounts, no uploads without an explicit task.

| Item | Where it comes from | State |
|---|---|---|
| Title | TOC `## Title` | ready |
| Short description | TOC `## Notes` (+ `Notes-deDE`) | ready |
| Long description | README (Features, Installation, Commands, Known limitations) | ready |
| Logo / icon | PaTiSuite icon set in all eight addons (PaTiAlerts: bell "Alarm", PaTiSuite: the gear emblem, both approved by the owner): `assets/icon-{1024,512,256,128,64,32}.png` per addon (not packaged); in game `Media/icon.tga` + `## IconTexture`. Cut from the approved sheet at ~244 px, so 512/1024 are upscaled (no new detail) — use the original artwork if a sharper large image is needed | ready |
| Screenshots | shot list below | not taken |
| Game version | WoW Forever 1.60.1 (build 70009), Interface 16001 — platforms may not list this client | to check per platform |
| Release zip | `tools/package.sh` / release workflow | ready |
| License | MIT, `LICENSE` in every repo (not in the release zip) | ready |
| Repository URL | `https://github.com/patpaskoch/<Addon>` | ready |
| Changelog | CHANGELOG section of the version | ready |
| Support / issues | GitHub Issues with the bug report template | ready |

## Screenshot list (to take in game; none exist yet)

| Addon | Shots |
|---|---|
| PaTiHeal | party frames in a group · settings (click casting + HoTs & shields) · HoT/shield icons with charges/timer · dispel icons · test mode |
| PaTiAuras | self section · group buffs with tooltip · healing auras · settings (aura switches) · first-start aura window |
| PaTiTank | HUD with target and threat · aggro 6 / 6 · lost enemy on the healer · settings |
| PaTiGroup | marker bar with target · settings with the highlighted key binding note · WoW key binding menu with PaTiGroup |
| PaTiQuest | selected quest with objectives |
| PaTiDungeon | window inside a dungeon in a group |
| PaTiAlerts | window with a red, a yellow and a blue alert during a pull · settings |
| PaTiSuite | control panel next to Heal/Auras/Tank windows, green and grey states |
