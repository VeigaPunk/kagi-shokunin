#!/usr/bin/env bash
# scan.sh -- reproducible sibling scan for R55ConnectorSiblings
set -u

ROOT="/home/vgpnk/Projects/shokunin"
KAGI="$ROOT/kagi-shokunin"
BASE="ebe095857a734caf5efdd7bd776feb22b4e23972"
CAND="348aa3b8ea7298aeb2f4d69db321fe827a92ae4f"

echo "=== Sibling Scan Verification ==="
echo "Fleet root: $ROOT"
echo "Kagi BASE: $BASE"
echo "Kagi CANDIDATE: $CAND"

echo "--- Check (a): ISO 11770 / Key Management across all sibling lanes ---"
cnt_know=$(grep -rn "11770" "$ROOT"/*-shokunin/corpus/knowledge/ 2>/dev/null | grep -v "/kagi-shokunin/" | wc -l || true)
echo "11770 in sibling knowledge corpora: $cnt_know"

cnt_src=$(grep -rn "11770" "$ROOT"/*-shokunin/corpus/SOURCES.md 2>/dev/null | grep -v "/kagi-shokunin/" | wc -l || true)
echo "11770 in sibling SOURCES.md registries: $cnt_src"

echo "Sibling explicit acknowledgement of kagi's key management province:"
grep -rn "ConnSiblingOverlap.*kagi" "$ROOT"/*-shokunin/corpus/knowledge/ 2>/dev/null || true

echo "--- Check (b): Body citation scanning vs used-by gates ---"
echo "Mado c3-r56-used-by.py body token scanner & pairlines check:"
grep -n "def cite(" "$ROOT"/mado-shokunin/quality/counters/c3-r56-used-by.py || true
grep -n "outside_fence_lines" "$ROOT"/mado-shokunin/quality/counters/c3-r56-used-by.py | head -n 3 || true

echo "Chousa research-gate.sh metadata_registry_check_source (source: line only):"
grep -n "metadata_registry_check_source()" "$ROOT"/chousa-shokunin/tools/research-gate.sh || true

echo "--- Check (c): recheck: command parsing vs replay ---"
echo "Mori journal-reach-r49.md recheck syntax:"
grep -n "^recheck:.*grep -c" "$ROOT"/mori-shokunin/corpus/knowledge/journal-reach-r49.md || true

echo "Mori Mo49ScoutS351.md noting recheck command is unenforced:"
grep -n "counter does not check the entry" "$ROOT"/mori-shokunin/.ufo/waves/round-49/w1/Mo49ScoutS351.md || true

echo "Kagi plans/round-55-c2.sh recheck replay logic:"
grep -n "grep -c" "$KAGI"/plans/round-55-c2.sh | head -n 3 || true

echo "=== Verification complete ==="
