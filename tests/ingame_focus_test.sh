#!/usr/bin/env bash
# Tests tools/ingame-focus.py: the TSV mapping parses, shared evidence only counts with an owner-verified
# reference test and an identical Shared manifest, and the real mapping matches the addon checkouts.
set -u
ADMIN="$(cd "$(dirname "$0")/.." && pwd)"
PY="$(command -v python3 >/dev/null && python3 -c 1 2>/dev/null && echo python3 || echo python)"
export PYTHONIOENCODING=utf-8
tmp="$(mktemp -d)"; trap 'rm -rf "${tmp:?}"' EXIT
fails=0
check() { if echo "$out" | grep -qF -- "$2"; then echo "  ok: $1"; else echo "  FAIL: $1 (expected \"$2\")"; echo "$out" | sed 's/^/    /'; fails=$((fails+1)); fi; }

mkdir -p "$tmp/admin/tools" "$tmp/admin/docs" "$tmp/addons/PaTiHeal/Shared" "$tmp/addons/PaTiAuras/Shared"
cp "$ADMIN/tools/ingame-focus.py" "$tmp/admin/tools/"
printf '# comment\nPaTiAuras\tPT-AURAS-011\tshared\tPT-HEAL-011\nPaTiAuras\tPT-AURAS-004\tsmoke\t-\n' > "$tmp/admin/docs/INGAME_TEST_FOCUS.tsv"
printf -- '- [x] PT-HEAL-011 Drag\n  - ✅ VERIFIED 2026-11-07\n' > "$tmp/addons/PaTiHeal/INGAME_TESTING.md"
printf -- '- [ ] PT-AURAS-011 Drag\n- [ ] PT-AURAS-004 Login\n' > "$tmp/addons/PaTiAuras/INGAME_TESTING.md"
echo v1 > "$tmp/addons/PaTiHeal/Shared/.manifest"; echo v1 > "$tmp/addons/PaTiAuras/Shared/.manifest"
run() { PATI_ADDONS_DIR="$tmp/addons" "$PY" "$tmp/admin/tools/ingame-focus.py" --summary 2>&1; }

out="$(run)"
check "tab-separated mapping parses" "Mapped open tests: 1 shared candidates (1 matched), 1 individual smoke checks"
check "verified reference gives shared coverage, addon still unverified" "SHARED CODE COVERED (PaTiHeal PT-HEAL-011); ADDON UNVERIFIED"
check "smoke test listed" "ADDON SMOKE TEST REQUIRED"

echo v2 > "$tmp/addons/PaTiAuras/Shared/.manifest"; out="$(run)"
check "different Shared manifest gives no credit" "NOT MATCHED / RETEST"

printf 'v1
' > "$tmp/addons/PaTiAuras/Shared/.manifest"; out="$(run)"
check "CRLF checkout of the same manifest still matches" "(1 matched)"

echo v1 > "$tmp/addons/PaTiAuras/Shared/.manifest"; printf -- '- [ ] PT-HEAL-011 Drag\n' > "$tmp/addons/PaTiHeal/INGAME_TESTING.md"; out="$(run)"
check "unverified reference gives no credit" "NOT MATCHED / RETEST"

if [ -f "$ADMIN/../PaTiAddons/PaTiHeal/INGAME_TESTING.md" ]; then
    if out="$("$PY" "$ADMIN/tools/ingame-focus.py" --summary 2>&1)"; then echo "  ok: real mapping matches the addon checkouts"
    else echo "  FAIL: real mapping"; echo "$out" | tail -3 | sed 's/^/    /'; fails=$((fails+1)); fi
fi
[ "$fails" -eq 0 ]
