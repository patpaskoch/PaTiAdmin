# Release

## Versioning

- **Source of truth: `## Version` in `<Addon>.toc`** (already used by all addons). PaTiShared: its `VERSION` file.
- SemVer `MAJOR.MINOR.PATCH`: MAJOR = breaking change (e.g. settings reset, removed command), MINOR = feature,
  PATCH = bug fix. Pre-1.0 addons may treat MINOR as "any user-visible change".
- `tools/check.sh` rejects TOC versions that are not `X.Y.Z`.

## Changelog

Every repo has `CHANGELOG.md`:
```
## [Unreleased]
### Added / Changed / Fixed / Removed / Known Issues
## [0.7.0] - 2026-10-02
```
User-visible changes go under `[Unreleased]` in the same commit. On release rename it to the version + date.
Earlier history before the changelog existed: `git log`.

## Steps

1. `tools/check.sh <addon>` green; CI green; reviewer findings resolved.
2. Owner's WoW smoke test for the changed areas (docs/TESTING.md) done.
3. Bump `## Version` in the TOC, move `[Unreleased]` to `[x.y.z] - date`, commit "Release <Addon> x.y.z".
4. `git tag <Addon>-x.y.z` (tags are per repo; the prefix keeps them readable in PaTiAdmin notes).
5. `tools/package.sh ../PaTiAddons/<Addon>` → `PaTiAdmin/dist/<Addon>-x.y.z.zip` (git-ignored).
   Contains only `<Addon>/`: the TOC, files it references, XML includes, `Bindings.xml`, `Media/`.
6. Update `SUITE_STATUS.md` in PaTiAdmin.

No CurseForge/Wago upload automation until there is a concrete need.
