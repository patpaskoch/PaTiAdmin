#!/usr/bin/env bash
# Puts the working copy of addons into the local WoW Forever client, so /reload in game shows what is in the clone
# right now (owner 2026-11-07). Copies exactly the files of the release zip (tools/package.sh --dry-run) into
# <AddOns>/<Addon>/ and replaces that folder, so deleted or renamed files do not linger. SavedVariables live in WTF/,
# not in AddOns/: settings stay.
#
#   tools/install-local.sh ../PaTiAddons/PaTiHeal [more addon folders]
#   tools/install-local.sh --all          every addon in PaTiAddons/
#
# Target: $PATI_WOW_ADDONS, else the first line of ~/.config/pati/wow-addons (machine-specific, never committed).
# It must end in Interface/AddOns. Installed copies are test targets only, never a source (AGENTS.md §2).
set -euo pipefail

ADMIN="$(cd "$(dirname "$0")/.." && pwd)"
CODE="$(cd "$ADMIN/.." && pwd)"
CONFIG="$HOME/.config/pati/wow-addons"

target="${PATI_WOW_ADDONS:-}"
if [ -z "$target" ] && [ -f "$CONFIG" ]; then target="$(head -1 "$CONFIG" | tr -d '\r')"; fi
[ -n "$target" ] || { echo "No AddOns folder: set PATI_WOW_ADDONS or write the path into $CONFIG." >&2; exit 2; }
target="${target%/}"
case "$target" in */Interface/AddOns) ;; *) echo "Not an Interface/AddOns folder: $target" >&2; exit 2 ;; esac
[ -d "$target" ] || { echo "Folder not found: $target" >&2; exit 2; }

if [ "${1:-}" = --all ]; then set -- "$CODE"/PaTiAddons/*/; fi
[ $# -ge 1 ] || { sed -n '2,11p' "$0"; exit 2; }

for arg in "$@"; do
    src="$(cd "$arg" && pwd)"; addon="$(basename "$src")"
    [ -f "$src/$addon.toc" ] || { echo "skip $addon (no $addon.toc)"; continue; }
    # Fails on TOC errors before anything in the game folder is touched.
    files="$(bash "$ADMIN/tools/package.sh" --dry-run "$src" | tail -n +2 | sed "s|^  $addon/||")"
    dest="$target/$addon"
    stage="$dest.installing"
    # Only ever a PaTi folder inside the checked AddOns folder (target and addon are never empty here).
    case "$addon" in PaTi*) ;; *) echo "skip $addon (not a PaTi addon)"; continue ;; esac
    rm -rf "${stage:?}"
    while IFS= read -r file; do
        mkdir -p "$stage/$(dirname "$file")"
        cp "$src/$file" "$stage/$file"
    done <<< "$files"
    rm -rf "${dest:?}"
    mv "$stage" "$dest"
    version="$(grep -i '^## Version:' "$src/$addon.toc" | head -1 | sed 's/^## Version:[[:space:]]*//' | tr -d '\r')"
    branch="$(git -C "$src" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
    echo "$addon $version ($branch, $(echo "$files" | wc -l | tr -d ' ') files) -> $dest"
done
