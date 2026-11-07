# Shared UI test coverage and focused in-game checks

Updated: 2026-11-07. This **reduces repeated manual work**; it does not certify untested addons.

## Evidence and boundaries

- All 12 runtime addons have the identical `Shared/.manifest` at the time of this review (PaTiShared 0.4.0). `PaTiHeal` is the code-evidence reference.
- The owner explicitly confirmed 17 PaTiHeal in-game checks on 2026-11-07. Relevant verified window controls (drag, lock, collapse, opacity, reset) can support code-level confidence in other addons with identical embedded Shared code.
- The mapping in [INGAME_TEST_FOCUS.tsv](INGAME_TEST_FOCUS.tsv) is curated **per test ID**; no broad filename / keyword classification.
- `shared` means **same underlying UI code and reference verified**. It does **not** mean tested in the consuming addon. Addon-specific wiring, event handling, SavedVariables, slash commands, secure/combat behavior, other UI elements, and localization may differ.
- `smoke` is the first individual check to run in that addon. Release asset installation and addon independence must still be verified individually. Every failure/retest remains visible in the canonical test files.
- A mixed test (e.g. collapse + persistence, scale during combat, reset preserving feature-specific options) may require a brief addon-specific follow-up even when Shared code is covered.
- Changing any Shared manifest breaks the evidence match for that addon. The CLI shows **NOT MATCHED / RETEST**, rather than transferring credit.
- **Never auto-tick** `[x]` in an addon's `INGAME_TESTING.md`. Only the owner can confirm it in WoW, per [TESTING.md](TESTING.md).

## How to use

With PaTiAdmin and all runtime-addon repos checked out side by side in the standard layout:

```sh
python3 PaTiAdmin/tools/ingame-focus.py --summary --list all
python3 PaTiAdmin/tools/ingame-focus.py --list shared
python3 PaTiAdmin/tools/ingame-focus.py --list smoke
PaTiAdmin/tools/ingame-status.sh --list retest
```

The new tool **only reads** the manifest and test files. Existing `tools/ingame-status.sh`, CI, release rules, and the source-of-truth `INGAME_TESTING.md` files are unchanged.

## Quick test flow

1. Run `--list shared` to see code-level coverage from owner-verified PaTiHeal tests; do not repeat full UI tests without a reason.
2. Run `--list smoke`: test loading, slash command, `/reload`, and the basic addon window where listed; log the owner's results in the corresponding repository.
3. Then prioritize `tools/ingame-status.sh --list retest` and feature-specific, combat/secure, group, dungeon and release-candidate tests.
4. If the shared implementation changes or a regression appears, rerun the affected reference and addon integration tests before relying on shared coverage.

This is a **curated initial focus view**, not a replacement for the complete in-game suite or the external interactive HTML test page. The classification can grow through explicit ID mapping after reviewing real test descriptions.
