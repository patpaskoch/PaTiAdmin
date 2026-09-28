#!/usr/bin/env bash
# Builds the release zip of one addon: only what the WoW client loads (TOC, files it references,
# XML-included files, Bindings.xml, Media/). No tests, docs, git or IDE files.
#
#   tools/package.sh ../PaTiAddons/PaTiHeal            -> dist/PaTiHeal-0.6.0.zip
#   tools/package.sh --dry-run ../PaTiAddons/PaTiHeal  -> list the files, write nothing
#
# Output folder: PaTiAdmin/dist (override with PATI_DIST). The zip contains one folder <Addon>/.
set -euo pipefail

ADMIN="$(cd "$(dirname "$0")/.." && pwd)"
LUA="${LUA:-$(command -v lua5.1 || command -v luajit || command -v lua || true)}"
[ -n "$LUA" ] || { echo "No Lua interpreter found (set LUA=...)." >&2; exit 2; }

dry=0
if [ "${1:-}" = "--dry-run" ]; then dry=1; shift; fi
[ $# -eq 1 ] || { sed -n '2,9p' "$0"; exit 2; }

src="$(cd "$1" && pwd)"; addon="$(basename "$src")"
cd "$src"
list="$(find . -type f ! -path './.git/*' | sed 's|^\./||' | "$LUA" "$ADMIN/tools/lua/run.lua" package-list "$addon" | tr -d '\r')" \
    || { echo "$list"; exit 1; }
version="$(grep -i '^## Version:' "$addon.toc" | head -1 | sed 's/^## Version:[[:space:]]*//' | tr -d '\r')"

if [ $dry -eq 1 ]; then
    echo "$addon $version would contain:"
    echo "$list" | sed "s|^|  $addon/|"
    exit 0
fi

dist="${PATI_DIST:-$ADMIN/dist}"; mkdir -p "$dist"
zip="$dist/$addon-$version.zip"
stage="$(mktemp -d)"; trap 'rm -rf "$stage"' EXIT
while IFS= read -r path; do
    mkdir -p "$stage/$addon/$(dirname "$path")"
    cp "$path" "$stage/$addon/$path"
done <<< "$list"
rm -f "$zip"
if command -v zip >/dev/null; then (cd "$stage" && zip -qr "$zip" "$addon")
elif [ -x /c/Windows/System32/tar.exe ]; then (cd "$stage" && /c/Windows/System32/tar.exe -a -cf "$(cygpath -w "$zip")" "$addon")
elif tar --version 2>/dev/null | grep -q bsdtar; then (cd "$stage" && tar -a -cf "$zip" "$addon")
else echo "Neither zip nor bsdtar available." >&2; exit 1; fi
echo "$zip ($(echo "$list" | wc -l | tr -d ' ') files)"
