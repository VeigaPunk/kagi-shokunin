#!/usr/bin/env bash
# ReviewC1 scratch battery: run C1/C2 counters over every fixture tree and
# collect single-instrument quotes. All paths under the seat scratch root.
S=/fast/scratch/hyaku/kagi-r36/ReviewC1
mkdir -p "$S/out"
export TMPDIR="$S/tmp"

run_one() {
  v=$1
  d="$S/$v"
  (
    cd "$d" || exit 99
    bash plans/round-36-c1.sh >"$S/out/$v.c1.out" 2>"$S/out/$v.c1.err"
    echo "rc=$?" >"$S/out/$v.c1.rc"
  ) &
  (
    cd "$d" || exit 99
    bash plans/round-36-c2.sh >"$S/out/$v.c2.out" 2>"$S/out/$v.c2.err"
    echo "rc=$?" >"$S/out/$v.c2.rc"
  ) &
}

for v in base cb8 candidate f12 f34 shortcutA shortcutB shortcutC shortcutAB forge71 forgeEarly; do
  run_one "$v"
done
wait
echo "=== COUNTER SUMMARY (integer | rc) ==="
for v in base cb8 candidate f12 f34 shortcutA shortcutB shortcutC shortcutAB forge71 forgeEarly; do
  for c in c1 c2; do
    printf '%-10s %s: %s | %s\n' "$v" "$c" "$(cat "$S/out/$v.$c.out" 2>/dev/null | tr -d '\n')" "$(cat "$S/out/$v.$c.rc" 2>/dev/null | tr -d '\n')"
  done
done

echo; echo "=== sweep last lines ==="
for v in base candidate shortcutA shortcutAB shortcutC forgeEarly; do
  printf '%-10s ' "$v"
  ( cd "$S/$v" && bash corpus/self-description-sweep.sh 2>/dev/null | tail -1 )
done

echo; echo "=== self-counts: SA-CAP line + verdict (base) ==="
( cd "$S/base" && python3 corpus/self-counts.py 2>/dev/null | grep -E 'SA-CAP|^SELF_COUNTS' )
echo "=== self-counts: SA-CAP line + verdict (candidate) ==="
( cd "$S/candidate" && python3 corpus/self-counts.py 2>/dev/null | grep -E 'SA-CAP|^SELF_COUNTS' )
echo "=== self-counts: SA-CAP line + verdict (shortcutC) ==="
( cd "$S/shortcutC" && python3 corpus/self-counts.py 2>/dev/null | grep -E 'SA-CAP|UNLOCATED|^SELF_COUNTS' )

echo; echo "=== R21-03 command re-run (base): bash corpus/sources-census.sh --selftest ==="
( cd "$S/base" && bash corpus/sources-census.sh --selftest 2>/dev/null | tail -1; echo "rc=$?" )

echo; echo "=== release-clock selftest (base) ==="
( cd "$S/base" && python3 corpus/release-clock.py --selftest 2>/dev/null | tail -1; echo "rc=$?" )
echo "=== release-clock selftest (candidate, after F4) ==="
( cd "$S/candidate" && python3 corpus/release-clock.py --selftest 2>/dev/null | tail -1; echo "rc=$?" )

echo; echo "=== release-clock verify (candidate, default receipt repointed) ==="
( cd "$S/candidate" && python3 corpus/release-clock.py 2>/dev/null | tail -1; echo "rc=$?" )
echo "=== release-clock verify (base, old round-26 default receipt) ==="
( cd "$S/base" && python3 corpus/release-clock.py 2>/dev/null | tail -1; echo "rc=$?" )

echo; echo "=== BASE receipt sha in every fixture that needs it ==="
sha256sum "$S/base/.ufo/waves/round-36/controls/observe-live.json" "$S/candidate/.ufo/waves/round-36/controls/observe-live.json"
echo "BATTERY DONE"
