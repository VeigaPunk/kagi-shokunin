#!/usr/bin/env bash
# plans/round-52-c2.sh — FROZEN round-52 C2 counter (axis calibration): the lane's own committed
# statements about what OpenBao's rewrap does agree with what the pinned binary does
# (round-51 closure D1, corpus/lessons/round-51-verifier-spotcheck.md:104).
#
# Predicate (same sentence as plans/round-52.md §C2):
#   C2_REWRAP_STATEMENTS: value = U, the number of lane-authored assertion lines that pair `rewrap`
#   with a judgement of the documentation or the binary and carry no truth-bound correction, when
#   GUARD = 1 and PROBE = 1, else SETUP; target 0 (BASE 2).
# - Lane-authored scope: tracked `*.md` files of the measured tree outside `.ufo/`, `plans/` and
#   `considerthese/`, excluding names matching `*-verifier-spotcheck.md` or `*aggregator*`.
# - Assertion line: a line matching (case-insensitive) ERE `rewrap` AND ERE
#   `does not do|misleading|is wrong|contradict`, that is not itself a correction line.
# - Correction line: a line, outside any HTML comment (a `<!--` inside an inline code span opens
#   none: pre-freeze run 1, round-51.md:15), whose text after an optional `- ` starts with
#   `Correction (round 52, D1)`.
# - Truth-bound: assertion line n of file F is corrected iff F holds a correction line that names
#   `<basename F>:<n>` and contains both literals
#     helper-origin rewrap reads `<OBS_HELPER>`   and   KV-origin rewrap reads `<OBS_KV>`
#   where OBS_HELPER is the creation path the PROBE reads for a `sys/wrapping/wrap` token after
#   `sys/wrapping/rewrap`, and OBS_KV the creation path it reads for a wrapped `kv get` of
#   `secret/<p>` after rewrap, with `<p>` written as `<path>`.
# - GUARD: every scoped file that held an assertion line at BASE (BASE_REV below) is, at the
#   measured revision, its BASE bytes followed only by appended bytes (no BASE line deleted or
#   rewritten); else SETUP.
#
# Named ceilings: the assertion pattern is lexical (a judgement phrased with other words is not
# seen); the probe measures one OpenBao version (2.7.2); a correction is checked for the two
# literals and the line pointer, not for its prose.
#
# Usage: bash plans/round-52-c2.sh <rev> | --tree DIR
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r52/c2-counter.XXXXXX, removed on exit.
set -u
BASE_REV=1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b
PIN_BAO=9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
BAO_BIN="${R52_BAO:-$HOME/.local/bin/bao}"

setup() { echo "C2_REWRAP_STATEMENTS: SETUP reason=$1"; exit 2; }
[ $# -ge 1 ] || setup usage
LANE=$(cd "$(dirname "$0")/.." && pwd)
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r52"
mkdir -p "$SCR" || setup scratch
W=$(mktemp -d "$SCR/c2-counter.XXXXXX") || setup mktemp
SRV=""
cleanup() { [ -n "$SRV" ] && { kill "$SRV" 2>/dev/null; sleep 0.3; kill -9 "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; }; rm -rf -- "$W"; }
trap cleanup EXIT

git -C "$LANE" rev-parse --verify -q "$BASE_REV^{commit}" >/dev/null || setup base-rev-missing
mkdir -p "$W/base" && git -C "$LANE" archive "$BASE_REV" | tar -x -C "$W/base" || setup base-archive
if [ "$1" = "--tree" ]; then
  [ -d "${2:-}" ] || setup tree-missing
  T=$(cd "$2" && pwd)
else
  git -C "$LANE" rev-parse --verify -q "$1^{commit}" >/dev/null || setup bad-rev
  mkdir -p "$W/tree" && git -C "$LANE" archive "$1" | tar -x -C "$W/tree" || setup archive
  T="$W/tree"
fi

# ---- PROBE (pinned binary, throwaway dev server, no secret on argv) ----
[ -x "$BAO_BIN" ] || setup bao-missing
[ "$(sha256sum < "$BAO_BIN" | cut -d' ' -f1)" = "$PIN_BAO" ] || setup bao-pin-mismatch
mkdir -p "$W/home"
probe() {
  local port root i
  port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
  root="r52p-$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')"
  env -i HOME="$W/home" PATH=/usr/bin:/bin BAO_DEV_ROOT_TOKEN_ID="$root" \
    setpriv --pdeathsig KILL "$BAO_BIN" server -dev -dev-listen-address="127.0.0.1:$port" -dev-no-store-token >/dev/null 2>&1 &
  SRV=$!
  export HOME="$W/home" BAO_ADDR="http://127.0.0.1:$port" BAO_TOKEN="$root"
  for i in $(seq 1 100); do "$BAO_BIN" status >/dev/null 2>&1 && break; sleep 0.1; done
  jtok() { python3 -c 'import json,sys
try: print(json.load(sys.stdin)["wrap_info"]["token"])
except Exception: sys.exit(1)'; }
  cpath() { printf '%s' "$1" | env -u BAO_TOKEN "$BAO_BIN" write -format=json sys/wrapping/lookup token=- 2>/dev/null | python3 -c 'import json,sys
try: print(json.load(sys.stdin)["data"]["creation_path"])
except Exception: sys.exit(1)'; }
  rewrap() { printf '%s' "$1" | "$BAO_BIN" write -format=json sys/wrapping/rewrap token=- 2>/dev/null | jtok; }
  local t1 t2 k1 k2
  t1=$(printf 'r52probe' | "$BAO_BIN" write -format=json sys/wrapping/wrap v=- 2>/dev/null | jtok) || return 1
  t2=$(rewrap "$t1") || return 1
  OBS_HELPER=$(cpath "$t2") || return 1
  printf 'r52probe' | "$BAO_BIN" kv put secret/r52probe v=- >/dev/null 2>&1 || return 1
  k1=$("$BAO_BIN" kv get -wrap-ttl=120s -format=json secret/r52probe 2>/dev/null | jtok) || return 1
  k2=$(rewrap "$k1") || return 1
  OBS_KV=$(cpath "$k2") || return 1
  OBS_KV=$(printf '%s' "$OBS_KV" | sed 's#^secret/data/r52probe$#secret/data/<path>#')
}
OBS_HELPER=""; OBS_KV=""
probe; unset BAO_ADDR BAO_TOKEN
[ -n "$OBS_HELPER" ] && [ -n "$OBS_KV" ] || setup "probe-failed(helper=$OBS_HELPER kv=$OBS_KV)"

# ---- scope, assertions, corrections ----
scoped() { # dir -> NUL-separated relative md paths
  (cd "$1" && find . -type f -name '*.md' -not -path './.ufo/*' -not -path './plans/*' \
     -not -path './considerthese/*' -not -name '*-verifier-spotcheck.md' -not -name '*aggregator*' -print0 | sort -z)
}
assertions() { # file -> line numbers of assertion lines
  awk 'BEGIN{IGNORECASE=1}
    { l=$0; sub(/^- /,"",l) }
    l ~ /^Correction \(round 52, D1\)/ { next }
    tolower($0) ~ /rewrap/ && tolower($0) ~ /does not do|misleading|is wrong|contradict/ { print NR }' "$1"
}

# GUARD: BASE files that held an assertion are byte-prefixes of their measured versions.
guard=1; gdetail=""
while IFS= read -r -d '' f; do
  [ -n "$(assertions "$W/base/$f")" ] || continue
  if [ ! -f "$T/$f" ]; then guard=0; gdetail="$gdetail missing:$f"; continue; fi
  bs=$(stat -c %s "$W/base/$f")
  cmp -s -n "$bs" "$W/base/$f" "$T/$f" || { guard=0; gdetail="$gdetail rewritten:$f"; }
done < <(scoped "$W/base")
[ $guard -eq 1 ] || setup "guard${gdetail}"

U=0; total=0; list=""
NEED1="helper-origin rewrap reads \`$OBS_HELPER\`"
NEED2="KV-origin rewrap reads \`$OBS_KV\`"
while IFS= read -r -d '' f; do
  for n in $(assertions "$T/$f"); do
    total=$((total+1))
    b=$(basename "$f")
    ok=$(awk -v ptr="$b:$n" -v n1="$NEED1" -v n2="$NEED2" '
      # mask(s): the line with every inline code span (`...`) blanked to "x", same length, so a
      # `<!--` written inside backticks does not open an HTML comment.
      function mask(s,   i, c, o, inc) { o=""; inc=0
        for (i=1; i<=length(s); i++) { c=substr(s,i,1)
          if (c=="`") { inc=!inc; o=o "x" } else o=o (inc ? "x" : c) }
        return o }
      { line=$0; m=mask(line); vis="" }
      { while (1) {
          if (incom) { p=index(m,"-->"); if (!p) { line=""; m=""; break }
                       line=substr(line,p+3); m=substr(m,p+3); incom=0 }
          p=index(m,"<!--"); if (!p) break
          vis=vis substr(line,1,p-1); line=substr(line,p+4); m=substr(m,p+4); incom=1
        }
        vis=vis line
        t=vis; sub(/^- /,"",t)
        if (index(t,"Correction (round 52, D1)")==1 && index(t,ptr)>0 && index(t,n1)>0 && index(t,n2)>0) {
          rest=substr(t, index(t,ptr)+length(ptr), 1)
          if (rest !~ /[0-9]/) found=1
        }
      }
      END { print found?1:0 }' "$T/$f")
    if [ "$ok" != 1 ]; then U=$((U+1)); list="$list ${f#./}:$n"; fi
  done
done < <(scoped "$T")

echo "C2_REWRAP_STATEMENTS: value=$U assertions=$total guard=$guard probe=1 obs_helper=$OBS_HELPER obs_kv=$OBS_KV uncorrected=[${list# }]"
exit 0
