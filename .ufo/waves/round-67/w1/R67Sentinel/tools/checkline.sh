#!/usr/bin/env bash
# Verify the landed census gate keeps the existing SOURCES_CENSUS: line byte-identical
# to BASE, and print the CLEAN-form SOURCES_CAPTURES line from a clean fixture.
SCRATCH=/fast/scratch/hyaku/kagi-r67/R67Sentinel
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
cd "$LANE" || exit 9

echo "--- BASE SOURCES_CENSUS line ---"
git show 076701a11a58e3eb58d996b4c76c5e18071fb179:corpus/sources-census.sh \
  | grep -n 'SOURCES_CENSUS: CLEAN' | head -3
echo "--- LANDED SOURCES_CENSUS line ---"
grep -n 'SOURCES_CENSUS: CLEAN' corpus/sources-census.sh | head -3
echo "--- byte-identity of the two format strings ---"
python3 - <<'PY'
import subprocess
base=subprocess.run(["git","show","076701a11a58e3eb58d996b4c76c5e18071fb179:corpus/sources-census.sh"],capture_output=True,text=True).stdout
land=open("corpus/sources-census.sh").read()
def line(t,pat):
    for l in t.splitlines():
        if pat in l: return l
    return None
b=line(base,"SOURCES_CENSUS: CLEAN")
l=line(land,"SOURCES_CENSUS: CLEAN")
print("BASE :",repr(b))
print("LAND :",repr(l))
print("IDENTICAL:", b==l)
# the SOURCES_CAPTURES format string, new
c=line(land,"SOURCES_CAPTURES: CLEAN")
d=line(land,"SOURCES_CAPTURES: FAILED")
print("CLEAN fmt :",repr(c))
print("FAILED fmt:",repr(d))
PY
exit 0
