#!/usr/bin/env bash
# All automated checks for the PaTi repositories — the same script runs locally and in CI.
#
#   tools/check.sh                      check PaTiAdmin, PaTiShared and every addon next to it
#   tools/check.sh ../PaTiAddons/PaTiHeal [more repo folders]
#
# Steps per repo: syntax, luacheck, unit tests, locales, CI/release workflow = template, TOC + referenced files,
# Shared/ integrity, package (a real zip built in a temp folder and checked, see tools/package.sh --verify). Needs Lua 5.1 or LuaJIT (LUA=... to override) and luacheck (LUACHECK=...).
# Missing luacheck is a SKIP locally and a FAIL in CI (CI=true).
set -uo pipefail

ADMIN="$(cd "$(dirname "$0")/.." && pwd)"
CODE="$(cd "$ADMIN/.." && pwd)"
RUN="$ADMIN/tools/lua/run.lua"
SUITE_INTERFACE="16001"   # Interface of the supported WoW Forever client (docs/WOW_API_COMPAT.md)

LUA="${LUA:-$(command -v lua5.1 || command -v luajit || command -v lua || true)}"
LUACHECK="${LUACHECK:-$(command -v luacheck || true)}"
if [ -z "$LUA" ]; then echo "No Lua interpreter found (install LuaJIT or Lua 5.1, or set LUA=...)." >&2; exit 2; fi

if [ $# -gt 0 ]; then
    targets=()
    for arg in "$@"; do
        abs="$(cd "$arg" 2>/dev/null && pwd)" || { echo "Not a folder: $arg" >&2; exit 2; }
        targets+=("$abs")
    done
else
    targets=("$ADMIN")
    [ -d "$CODE/PaTiShared" ] && targets+=("$CODE/PaTiShared")
    for dir in "$CODE"/PaTiAddons/*/; do [ -f "$dir/$(basename "$dir").toc" ] && targets+=("${dir%/}"); done
fi

results=(); failed=0
record() { results+=("$(printf '%-12s %-10s %s' "$1" "$2" "$3")"); [ "$1" = FAIL ] && failed=1; return 0; }

# Relative paths of all files in the current folder, without VCS/build output.
list_files() { find . -type f ! -path './.git/*' ! -path './dist/*' | sed 's|^\./||' | sort; }

hash_file() {
    if command -v sha256sum >/dev/null; then tr -d '\r' < "$1" | sha256sum | cut -c1-64
    else tr -d '\r' < "$1" | shasum -a 256 | cut -c1-64; fi
}

for target in "${targets[@]}"; do
    name="$(basename "$target")"
    echo "== $name"
    cd "$target" || exit 2
    files="$(list_files)"

    if echo "$files" | grep -q '\.lua$'; then
        if echo "$files" | "$LUA" "$RUN" syntax; then record PASS syntax "$name"; else record FAIL syntax "$name"; fi
    fi

    if [ -n "$LUACHECK" ]; then
        # Run from the code root so the per-addon globals in .luacheckrc match "PaTiAddons/<Addon>/...".
        # Relative paths: luacheck on Windows only recognises "C:\" as absolute, not "C:/".
        rel="${target#"$CODE"/}"; config="${ADMIN#"$CODE"/}/.luacheckrc"
        if (cd "$CODE" && $LUACHECK --no-cache --config "$config" --formatter plain -q "$rel"); then
            record PASS luacheck "$name"; else record FAIL luacheck "$name"; fi
    elif [ "${CI:-}" = true ]; then record FAIL luacheck "$name (luacheck not installed)"
    else record SKIP luacheck "$name (luacheck not installed)"; fi

    specs="$(echo "$files" | grep '^tests/.*_spec\.lua$' || true)"
    if [ -n "$specs" ]; then
        if echo "$specs" | "$LUA" "$RUN" test "$ADMIN/tests/mocks"; then record PASS tests "$name"; else record FAIL tests "$name"; fi
    else record NONE tests "$name (no *_spec.lua)"; fi

    if echo "$files" | grep -qE '^(Locales|Shared/Locales|src/Locales)/'; then
        if echo "$files" | "$LUA" "$RUN" locales; then record PASS locales "$name"; else record FAIL locales "$name"; fi
    else record NONE locales "$name (no Locales/ yet)"; fi

    # Each repo's workflow is a copy of PaTiAdmin/templates/ci.yml; copies must not drift.
    if [ "$target" != "$ADMIN" ]; then
        if [ ! -f .github/workflows/ci.yml ]; then record FAIL ci-file "$name (.github/workflows/ci.yml missing)"
        elif diff -q <(tr -d '\r' < .github/workflows/ci.yml) <(tr -d '\r' < "$ADMIN/templates/ci.yml") >/dev/null; then
            record PASS ci-file "$name"
        else echo "  ERROR: .github/workflows/ci.yml differs from PaTiAdmin/templates/ci.yml"; record FAIL ci-file "$name"; fi
    fi
    # Addons also carry the tag-triggered release workflow (draft releases only).
    if [ -f "$name.toc" ]; then
        if [ ! -f .github/workflows/release.yml ]; then record FAIL release "$name (.github/workflows/release.yml missing)"
        elif diff -q <(tr -d '\r' < .github/workflows/release.yml) <(tr -d '\r' < "$ADMIN/templates/release.yml") >/dev/null; then
            record PASS release "$name"
        else echo "  ERROR: .github/workflows/release.yml differs from PaTiAdmin/templates/release.yml"; record FAIL release "$name"; fi
    fi

    if [ -f "$name.toc" ]; then
        if echo "$files" | "$LUA" "$RUN" toc "$name" "$SUITE_INTERFACE"; then record PASS toc "$name"; else record FAIL toc "$name"; fi

        # Shared/ must match what PaTiShared's sync wrote (no hand edits in the embedded copy).
        if [ -f Shared/.manifest ]; then
            drift=""
            while read -r sum path; do
                [ -n "$path" ] || continue
                if [ ! -f "Shared/$path" ] || [ "$(hash_file "Shared/$path")" != "$sum" ]; then drift="$drift $path"; fi
            done < <(tail -n +2 Shared/.manifest | tr -d '\r')
            if [ -z "$drift" ]; then record PASS shared "$name ($(head -1 Shared/.manifest | tr -d '\r'))"
            else echo "  ERROR: Shared/ changed by hand:$drift"; record FAIL shared "$name"; fi
        fi

        if out="$(LUA="$LUA" bash "$ADMIN/tools/package.sh" --verify "$target" 2>&1)"; then record PASS package "$name (zip built and checked)"
        else echo "$out" | sed 's/^/  /'; record FAIL package "$name"; fi
    fi
done

echo
echo "RESULT       CHECK      TARGET"
printf '%s\n' "${results[@]}"
exit $failed
