#!/usr/bin/env bash
# Builds the release zip of one addon: only what the WoW client loads (TOC, files it references,
# XML-included files, Bindings.xml, Media/). No tests, docs, git or IDE files.
#
#   tools/package.sh ../PaTiAddons/PaTiHeal            -> dist/PaTiHeal-0.6.0.zip
#   tools/package.sh --dry-run ../PaTiAddons/PaTiHeal  -> list the files, write nothing
#   tools/package.sh --verify ../PaTiAddons/PaTiHeal   -> build into a temp folder, check the zip, delete it
#
# Output folder: PaTiAdmin/dist (override with PATI_DIST). The zip contains exactly one folder <Addon>/.
# Reproducible: files are added in sorted order with the time of the last commit (zip -X, no extra attributes),
# so the same commit gives the same zip content.
set -euo pipefail

ADMIN="$(cd "$(dirname "$0")/.." && pwd)"
LUA="${LUA:-$(command -v lua5.1 || command -v luajit || command -v lua || true)}"
[ -n "$LUA" ] || { echo "No Lua interpreter found (set LUA=...)." >&2; exit 2; }

mode=build
case "${1:-}" in --dry-run) mode=dry; shift ;; --verify) mode=verify; shift ;; esac
[ $# -eq 1 ] || { sed -n '2,11p' "$0"; exit 2; }

src="$(cd "$1" && pwd)"; addon="$(basename "$src")"
cd "$src"
# package-list fails on TOC errors, missing referenced files and development files a TOC would ship.
list="$(find . -type f ! -path './.git/*' | sed 's|^\./||' | "$LUA" "$ADMIN/tools/lua/run.lua" package-list "$addon" | tr -d '\r')" \
    || { echo "$list"; exit 1; }
version="$(grep -i '^## Version:' "$addon.toc" | head -1 | sed 's/^## Version:[[:space:]]*//' | tr -d '\r')"

if [ $mode = dry ]; then
    echo "$addon $version would contain:"
    echo "$list" | sed "s|^|  $addon/|"
    exit 0
fi

stage="$(mktemp -d)"; trap 'rm -rf "$stage"' EXIT
if [ $mode = verify ]; then dist="$stage/dist"; else dist="${PATI_DIST:-$ADMIN/dist}"; fi
mkdir -p "$dist"; dist="$(cd "$dist" && pwd)"
zip="$dist/$addon-$version.zip"

# Time of the last commit (fallback: now) for every packaged file -> same commit, same zip.
stamp="$(git log -1 --format=%ct 2>/dev/null || date +%s)"
while IFS= read -r path; do
    mkdir -p "$stage/$addon/$(dirname "$path")"
    cp "$path" "$stage/$addon/$path"
    touch -d "@$stamp" "$stage/$addon/$path" 2>/dev/null || true
done <<< "$list"
rm -f "$zip"
if command -v zip >/dev/null; then
    (cd "$stage" && echo "$list" | sed "s|^|$addon/|" | zip -X -q "$zip" -@)
elif [ -x /c/Windows/System32/tar.exe ]; then (cd "$stage" && /c/Windows/System32/tar.exe -a -cf "$(cygpath -w "$zip")" "$addon")
elif tar --version 2>/dev/null | grep -q bsdtar; then (cd "$stage" && tar -a -cf "$zip" "$addon")
else echo "Neither zip nor bsdtar available." >&2; exit 1; fi

# Entries of the zip, files only, one per line.
zip_entries() {
    if command -v unzip >/dev/null; then unzip -Z1 "$1"
    elif [ -x /c/Windows/System32/tar.exe ]; then /c/Windows/System32/tar.exe -tf "$(cygpath -w "$1")"
    else tar -tf "$1"; fi
}

if [ $mode = verify ]; then
    entries="$(zip_entries "$zip" | tr -d '\r' | grep -v '/$' | sort)"
    expected="$(echo "$list" | sed "s|^|$addon/|" | sort)"
    problems=""
    outside="$(echo "$entries" | grep -v "^$addon/" || true)"
    [ -z "$outside" ] || problems="$problems\n  files outside $addon/: $outside"
    echo "$entries" | grep -qx "$addon/$addon.toc" || problems="$problems\n  $addon/$addon.toc missing"
    [ "$entries" = "$expected" ] || problems="$problems\n  zip content differs from the package list"
    if [ -n "$problems" ]; then printf "ZIP CHECK FAILED for %s:%b\n" "$addon-$version.zip" "$problems" >&2; exit 1; fi
    echo "$addon-$version.zip ok: one folder $addon/, $(echo "$entries" | wc -l | tr -d ' ') files, TOC present"
    exit 0
fi
echo "$zip ($(echo "$list" | wc -l | tr -d ' ') files)"
