#!/usr/bin/env bash
# Test for tools/install-local.sh against a temporary AddOns folder (run by tools/check.sh for PaTiAdmin).
# Needs one addon next to PaTiAdmin (PaTiAddons/PaTiHeal, as in CI).
set -uo pipefail

ADMIN="$(cd "$(dirname "$0")/.." && pwd)"
ADDON="$ADMIN/../PaTiAddons/PaTiHeal"
[ -d "$ADDON" ] || { echo "  skip: PaTiAddons/PaTiHeal not found"; exit 0; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
addons="$tmp/Interface/AddOns"
mkdir -p "$addons/PaTiHeal"
echo stale > "$addons/PaTiHeal/Old.lua"
fail=0
check() { if eval "$2"; then :; else echo "  FAIL: $1"; fail=1; fi; }

PATI_WOW_ADDONS="$addons" bash "$ADMIN/tools/install-local.sh" "$ADDON" >/dev/null
check "copies the TOC" '[ -f "$addons/PaTiHeal/PaTiHeal.toc" ]'
check "copies embedded Shared/" '[ -f "$addons/PaTiHeal/Shared/Theme.lua" ]'
check "removes files no longer shipped" '[ ! -e "$addons/PaTiHeal/Old.lua" ]'
check "ships no tests" '[ ! -e "$addons/PaTiHeal/tests" ]'
check "leaves no staging folder" '[ ! -e "$addons/PaTiHeal.installing" ]'

mkdir -p "$tmp/Elsewhere"
check "refuses a folder that is not Interface/AddOns" \
    '! PATI_WOW_ADDONS="$tmp/Elsewhere" bash "$ADMIN/tools/install-local.sh" "$ADDON" >/dev/null 2>&1'
check "touches nothing there" '[ -z "$(ls -A "$tmp/Elsewhere")" ]'

exit $fail
