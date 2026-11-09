#!/usr/bin/env bash
# R70Sentinel probe F — does the frozen counter's NOSECRET leg see a secret that the trial
# writes to DISK under --work instead of printing it?
# The counter scans only  $W/*.out  and  $W/*.out.err  (plans/round-70-c1.sh line 149), while
# the trial's scratch lives under $W/tmp/ (line 101: --work "$W/tmp").
# This builds a fixture whose trial is the P1 trial PLUS one line that writes a PEM private
# key to a file in its scratch, and reads the counter's own nosecret field.
set -u
S=/fast/scratch/hyaku/kagi-r70/R70Sentinel
WD=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/w1/R70Sentinel
R=$WD/receipts
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
FIX=$S/fixture-ns
C=$LANE/.ufo/waves/round-70/controls

rm -rf "$FIX"; mkdir -p "$FIX/corpus/knowledge"
cp "$C/p1/corpus/openbao-pki-trial.sh" "$FIX/corpus/openbao-pki-trial.sh"
cp "$C/p1/corpus/knowledge/openbao-pki-certificate-lifecycle.md" "$FIX/corpus/knowledge/"
cp "$C/p1/corpus/SOURCES.md" "$FIX/corpus/SOURCES.md"

# inject ONE line: write a PEM private key to a file in the trial's scratch (not stdout)
python3 - "$FIX/corpus/openbao-pki-trial.sh" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
anchor = 'export HOME="$S/home" TMPDIR="$S/tmp"; mkdir -p "$HOME" "$TMPDIR"\n'
assert anchor in s
inject = anchor + ('printf -- "-----BEGIN RSA PRIVATE KEY-----\\n'
                   'MIIEowIBAAKCAQEAxFAKEKEYMATERIALFORTHETESTONLY0000000000000000\\n'
                   '-----END RSA PRIVATE KEY-----\\n" > "$S/spilled.pem"\n')
s = s.replace(anchor, inject, 1)
open(p, "w").write(s)
print("  injected one line: writes a PEM private key to $S/spilled.pem (no stdout/stderr change)")
PY

echo
echo "=== the fixture trial vs the P1 trial (one added line) ==="
diff "$C/p1/corpus/openbao-pki-trial.sh" "$FIX/corpus/openbao-pki-trial.sh" | sed 's/^/  /'
echo
echo "=== the FROZEN counter's verdict on that fixture ==="
HYAKU_SCRATCH="$S" bash "$LANE/plans/round-70-c1.sh" --tree "$FIX" 2>&1 | tee "$R/probe-F-nosecret-blindspot.log"
echo "counter rc=${PIPESTATUS[0]}"
echo
echo "=== what the counter's nosecret scan actually reads vs what exists on disk ==="
echo "  counter scan expression:"
grep -n 'cat "\$W"/\*\.out' "$LANE/plans/round-70-c1.sh" | sed 's/^/    /'
echo "  the trial's --work:"; grep -n '\-\-work "\$W' "$LANE/plans/round-70-c1.sh" | sed 's/^/    /'
echo "  => \$W/tmp/kagi-pki-trial.XXXXXX/spilled.pem is BELOW \$W and is NOT matched by \$W/*.out"
echo
echo "=== dev servers left ==="; pgrep -af 'bao server -dev' | sed 's/^/  /' || echo "  none"
