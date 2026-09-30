#!/usr/bin/env bash
# Reads the addons' INGAME_TESTING.md files (docs/TESTING.md#in-game-test-files) and counts or lists their tests.
#
#   tools/ingame-status.sh                     one line per addon: verified / failed / open
#   tools/ingame-status.sh --markdown          the same as a Markdown table (docs/INGAME_TEST_STATUS.md)
#   tools/ingame-status.sh --list failed       every test in that state: verified | failed (incl. retest) | retest |
#                                              open | retired
#   tools/ingame-status.sh --check <repo>...   format check only (used by check.sh); exit 1 on an error
#
# Without repo folders it reads every PaTiAddons/*/INGAME_TESTING.md next to PaTiAdmin.
# States: [x] = verified (latest result must be "✅ VERIFIED <date>"); [ ] with a "❌ FAIL" not followed by a
# VERIFIED = failed ("retest" when a "🔧 FIX IMPLEMENTED" came after the FAIL); any other [ ] = open.
set -uo pipefail

ADMIN="$(cd "$(dirname "$0")/.." && pwd)"
mode=summary; want=""
case "${1:-}" in
    --markdown) mode=markdown; shift ;;
    --list) mode=list; want="${2:-}"; shift 2 || { echo "--list needs a state" >&2; exit 2; } ;;
    --check) mode=check; shift ;;
esac

files=()
if [ $# -gt 0 ]; then for repo in "$@"; do files+=("$repo/INGAME_TESTING.md"); done
else for f in "$ADMIN"/../PaTiAddons/*/INGAME_TESTING.md; do [ -f "$f" ] && files+=("$f"); done; fi
[ ${#files[@]} -gt 0 ] || { echo "No INGAME_TESTING.md found." >&2; exit 2; }

# One record per test: addon <TAB> id <TAB> state <TAB> title. Format errors go to stderr and set the exit code.
records="$(awk '
    function fail(msg) { printf "  ERROR: %s: %s\n", FILENAME, msg > "/dev/stderr"; bad = 1 }
    function flush(   state) {
        if (id == "") return
        if (box == "x") {
            state = "verified"; if (last != "VERIFIED") fail(id " is [x] but its latest result is not VERIFIED")
        }
        else if (last == "VERIFIED") { fail(id " has VERIFIED as latest result but an open box") }
        else if (last == "FAIL") state = "failed"
        else if (last == "FIX") state = "retest"
        else state = "open"
        print addon "\t" id "\t" state "\t" title
        id = ""
    }
    function remember(tid) { if (tid in seen) fail("duplicate test ID " tid); seen[tid] = 1 }
    FNR == 1 { flush(); n = split(FILENAME, parts, "/"); addon = parts[n - 1]; if (NR > 1) delete seen }
    { sub(/\r$/, "") }
    /^## / { flush(); legend = ($0 ~ /^## Legende/); next }
    legend { next }
    /^- \[[ xX]\] / {
        flush()
        if (!match($0, /PT-[A-Z]+-[0-9][0-9][0-9]/) || RSTART != 7) {
            fail("test line without a PT-<ADDON>-NNN ID: " $0); next
        }
        box = tolower(substr($0, 4, 1)); id = substr($0, RSTART, RLENGTH); title = substr($0, RSTART + RLENGTH + 1)
        remember(id); last = ""; next
    }
    /^- ~~PT-/ {
        flush(); match($0, /PT-[A-Z]+-[0-9][0-9][0-9]/); rid = substr($0, RSTART, RLENGTH); remember(rid)
        title = substr($0, RSTART + RLENGTH + 1); gsub(/~~/, "", title); print addon "\t" rid "\tretired\t" title; next
    }
    /^  +- / && id != "" {
        if ($0 ~ /VERIFIED [0-9][0-9][0-9][0-9]-/) last = "VERIFIED"
        else if ($0 ~ / FAIL [0-9][0-9][0-9][0-9]-/) last = "FAIL"
        else if ($0 ~ /FIX IMPLEMENTED [0-9][0-9][0-9][0-9]-/ && last == "FAIL") last = "FIX"
        next
    }
    /^[^ ]/ { flush() }
    END { flush(); exit bad }
' "${files[@]}")"
status=$?

case $mode in
    check) exit $status ;;
    list) printf '%s\n' "$records" | awk -F '\t' -v want="$want" '
            $3 == want || (want == "failed" && $3 == "retest") { printf "%-12s %-16s %s\n", $1, $2, $4 }' ;;
    summary|markdown)
        printf '%s\n' "$records" | awk -F '\t' -v md=$([ $mode = markdown ] && echo 1 || echo 0) '
            !($1 in order) { order[$1] = ++n; name[n] = $1 }
            $3 == "verified" { v[$1]++ } $3 == "failed" || $3 == "retest" { f[$1]++ } $3 == "retest" { r[$1]++ }
            $3 == "open" { o[$1]++ }
            END {
                if (md) { print "| Addon | Verified | Failed | davon Fix da, Retest offen | Open | Tests |"
                          print "|---|---:|---:|---:|---:|---:|" }
                for (i = 1; i <= n; i++) {
                    a = name[i]; t = v[a] + f[a] + o[a]
                    if (md) printf "| [%s](https://github.com/patpaskoch/%s/blob/main/INGAME_TESTING.md) " \
                        "| %d | %d | %d | %d | %d |\n", a, a, v[a], f[a], r[a], o[a], t
                    else printf "%-12s verified %3d   failed %2d (retest %d)   open %3d   total %3d\n", \
                        a, v[a], f[a], r[a], o[a], t
                }
            }' ;;
esac
exit $status
