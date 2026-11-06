#!/usr/bin/env bash
# m50-3-pin-sites.sh — list every place the lane cites the OpenBao binary pin or its provenance,
# and say whether the gpg/sigstore ceiling appears within a 4-line window of the citation.
# Read-only. Excludes .ufo/ (evidence tree), .jj/ (VCS working-copy shadow) and .git/.
set -u
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
cd "$L" || exit 2

echo "== A. full pin sha256 =="
echo "\$ grep -rn --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git '9c5f3628' ."
grep -rn --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git '9c5f3628' . | cut -c1-160
echo "\$ ... | wc -l"
grep -rn --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git '9c5f3628' . | wc -l

echo
echo "== B. short-form pin citations (file:line only) =="
echo "\$ grep -rln --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git -E '9c5f3[0-9a-f]{0,3}' ."
grep -rln --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git -E '9c5f3[0-9a-f]{0,3}' . | sort

echo
echo "== C. ceiling within a 4-line window? (gpgsig|sigstore) =="
grep -rn --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git -E '9c5f3[0-9a-f]{0,3}' . \
 | cut -d: -f1,2 | sort -u | while IFS=: read -r f ln; do
    n=$(sed -n "$((ln>2?ln-2:1)),$((ln+3))p" "$f" | grep -ciE 'gpgsig|sigstore')
    echo "$f:$ln ceiling_lines=$n"
  done

echo
echo "== D. provenance phrases =="
echo "\$ grep -rn --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git 'sha256-pinned' . | cut -c1-120"
grep -rn --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git 'sha256-pinned' . | cut -c1-120
echo "\$ grep -rn --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git 'tool-install' . | cut -d: -f1,2"
grep -rn --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git 'tool-install' . | cut -d: -f1,2
echo "\$ grep -rn --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git 'tool-install' . | wc -l"
grep -rn --exclude-dir=.ufo --exclude-dir=.jj --exclude-dir=.git 'tool-install' . | wc -l

echo
echo "== E. install receipt (round-49), gate-relevant lines =="
echo "\$ grep -nE 'gpgsig|sigstore|checksums|asset' .ufo/waves/round-49/controls/tool-install.txt | cut -c1-160"
grep -nE 'gpgsig|sigstore|checksums|asset' .ufo/waves/round-49/controls/tool-install.txt | cut -c1-160
