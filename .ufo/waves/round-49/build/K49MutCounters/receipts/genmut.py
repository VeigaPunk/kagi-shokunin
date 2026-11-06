import pathlib, sys, difflib
L = pathlib.Path("/fast/scratch/hyaku/kagi-r49/K49MutCounters/lane")
S = pathlib.Path("/fast/scratch/hyaku/kagi-r49/K49MutCounters/mut")
c1 = (L/"plans/round-49-c1.sh").read_text()
c2 = (L/"plans/round-49-c2.sh").read_text()

def rep(text, old, new, name):
    n = text.count(old)
    assert n == 1, f"{name}: expected 1 occurrence, got {n}"
    return text.replace(old, new)

M = {}
# ---- C1 mutants ----
M["c1-m1-drop-entry"] = rep(c1,
  'ok=0; [ "$rv" = HOLDS ] && [ "$sv" = BROKEN ] && [ "$ev" = 1 ] && ok=1',
  'ok=0; [ "$rv" = HOLDS ] && [ "$sv" = BROKEN ] && ok=1', "c1-m1")
M["c1-m2-dup-as-holds"] = rep(c1,
  'elif [ "$n" -gt 1 ]; then echo DUP',
  'elif [ "$n" -gt 1 ]; then echo HOLDS', "c1-m2")
M["c1-m3-drop-nosecret"] = rep(c1,
  '[ $setup_ok -eq 1 ] && [ $nosecret -eq 1 ] && [ $pins -eq 1 ] || final=0',
  '[ $setup_ok -eq 1 ] && [ $pins -eq 1 ] || final=0', "c1-m3")
M["c1-m4-swap-shim34"] = rep(c1,
  '  run "sh$i" "$W/sh$i.out"',
  '  sd="sh$i"; [ "$i" = 3 ] && sd=sh4; [ "$i" = 4 ] && sd=sh3\n  run "$sd" "$W/sh$i.out"', "c1-m4")
M["c1-m5-none-as-broken"] = rep(c1,
  'if [ "$n" -eq 0 ]; then echo NONE',
  'if [ "$n" -eq 0 ]; then echo BROKEN', "c1-m5")
M["c1-m6-drop-pin"] = rep(c1,
  '[ "$(sha256sum < "$BAO_BIN" | cut -d\' \' -f1)" = "$PIN_BAO" ] || setup bao-pin-mismatch',
  ': # pin check dropped (mutant)', "c1-m6")
M["c1-m7-drop-setup-ok"] = rep(c1,
  '[ $setup_ok -eq 1 ] && [ $nosecret -eq 1 ] && [ $pins -eq 1 ] || final=0',
  '[ $nosecret -eq 1 ] && [ $pins -eq 1 ] || final=0', "c1-m7")

# ---- C2 mutants ----
M["c2-m1-drop-G1"] = rep(c2,
'''# G1
for f in corpus/self-counts.py corpus/claim-ledger.sh; do
  [ -f "$C/$f" ] || setup "G1-missing-$f"
  [ "$(b "$f" | sha256sum)" = "$(sha256sum < "$C/$f")" ] || setup "G1-changed-$f"
done
''', ': # G1 dropped (mutant)\n', "c2-m1")
M["c2-m2-drop-G5"] = rep(c2,
'''# G5
pol=$(grep -E '^POLICY ' "$W/out" | awk '{print $2}' | sort | paste -sd, -)
[ "$pol" = "PV-FEEDTOKEN-SELFTEST,PV-FEEDTOKEN-SHAPES" ] || setup "G5-policy=$pol"
''', ': # G5 dropped (mutant)\n', "c2-m2")
M["c2-m3-setup-as-ok"] = rep(c2,
  '  [ "$v" = OK ] || value=$((value+1))',
  '  [ "$v" = OK ] || [ "$v" = SETUP ] || value=$((value+1))', "c2-m3")
M["c2-m4-drop-G4"] = rep(c2,
'''# G4
b corpus/stamps.tsv | grep -v '^#' | cut -f1 | sort -u > "$W/base-stamps"
grep -v '^#' "$C/corpus/stamps.tsv" | cut -f1 | sort -u > "$W/now-stamps"
missing=$(comm -23 "$W/base-stamps" "$W/now-stamps" | wc -l)
[ "$missing" -eq 0 ] || setup "G4-stamp-rows-removed=$missing"
''', ': # G4 dropped (mutant)\n', "c2-m4")
M["c2-m5-min-lines-0"] = rep(c2, 'MIN_LINES=63', 'MIN_LINES=0', "c2-m5")

for name, text in M.items():
    p = S/(name + ".sh")
    p.write_text(text)
    p.chmod(0o755)
    print(f"WROTE {p.name} sha256={__import__('hashlib').sha256(text.encode()).hexdigest()[:16]}")
