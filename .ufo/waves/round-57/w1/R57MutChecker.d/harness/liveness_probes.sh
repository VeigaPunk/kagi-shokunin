#!/usr/bin/env bash
# Liveness probes: show each surviving mutant is behaviourally live on a tree
# shape the frozen 11-control battery never builds. Writes one last-line capture
# per run; no lane writes.
set -u
S=/fast/scratch/hyaku/kagi-r57/R57MutChecker
F=$S/frozen/plans
B=$S/trees/base
T=$S/trees
out=$S/out
mkdir -p "$T"

run() { # run <label> <checker> <root>
  local label=$1 ck=$2 root=$3
  python3 -I -B "$ck" --root "$root" > "$out/probe-$label.txt" 2>&1
  echo "rc=$?" >> "$out/probe-$label.txt"
  tail -1 "$out/probe-$label.txt" | sed "s|^|$label: |" >> "$out/probe-summary.txt"
}

: > "$out/probe-summary.txt"

# P-M2: F5-shaped tree (sections removed), population 1, guard should be 0
run m2.pristine "$F/round-57-c1-check.py" "$T/f5"
run m2.mutant   "$S/mut/M2/plans/round-57-c1-check.py" "$T/f5"

# P-M5: manifest authority changed (one data row removed)
rm -rf "$T/p-m5"; cp -a "$B" "$T/p-m5"
python3 -I -B - "$T/p-m5/corpus/recheck-captures.tsv" <<'PY'
import sys
p=sys.argv[1]
lines=open(p,encoding="utf-8").read().splitlines(True)
data=[i for i,l in enumerate(lines) if l.strip() and not l.startswith("#") and not l.startswith("id\t")]
assert data, "no data rows"
del lines[data[-1]]
open(p,"w",encoding="utf-8").write("".join(lines))
PY
run m5.pristine "$F/round-57-c1-check.py" "$T/p-m5"
run m5.mutant   "$S/mut/M5/plans/round-57-c1-check.py" "$T/p-m5"

# P-M7: one surface file missing
rm -rf "$T/p-m7"; cp -a "$B" "$T/p-m7"; rm "$T/p-m7/LOG.md"
run m7.pristine "$F/round-57-c1-check.py" "$T/p-m7"
run m7.mutant   "$S/mut/M7/plans/round-57-c1-check.py" "$T/p-m7"

# P-M8: the N/N MATCH fraction perturbed
rm -rf "$T/p-m8"; cp -a "$B" "$T/p-m8"
python3 -I -B - "$T/p-m8/SCORECARD.md" <<'PY'
import sys
p=sys.argv[1]; s=open(p,encoding="utf-8").read()
t=s.replace("10/10 MATCH","9/10 MATCH",1)
assert t!=s, "inert pop edit"
open(p,"w",encoding="utf-8").write(t)
PY
run m8.pristine "$F/round-57-c1-check.py" "$T/p-m8"
run m8.mutant   "$S/mut/M8/plans/round-57-c1-check.py" "$T/p-m8"

# P-M9: the selftest case-count authority moved 20 -> 19 (stub instrument)
rm -rf "$T/p-m9"; cp -a "$B" "$T/p-m9"
cat > "$T/p-m9/corpus/recheck-replay.py" <<'EOS'
#!/usr/bin/env python3
import sys
print("RECHECK_REPLAY_SELFTEST: PASS (19 cases)")
sys.exit(0)
EOS
run m9.pristine "$F/round-57-c1-check.py" "$T/p-m9"
run m9.mutant   "$S/mut/M9/plans/round-57-c1-check.py" "$T/p-m9"

cat "$out/probe-summary.txt"
