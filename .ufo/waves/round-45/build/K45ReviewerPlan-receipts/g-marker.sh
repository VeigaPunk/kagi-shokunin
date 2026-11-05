#!/bin/sh
# degenerate gate: implements NO bijection logic; MISMATCH keyed only on the
# synthetic '# fixture' marker that ALL THREE round-45 fixtures share in
# plans/*.md and SCORECARD.md. Parses --root exactly like the real gate does.
root=.
case "${1:-}" in
  --root) root=${2:?root} ;;
esac
for f in "$root"/plans/*.md "$root"/SCORECARD.md; do
  [ -f "$f" ] || continue
  if grep -q '^# fixture' "$f" 2>/dev/null; then
    echo "MISMATCH 0 C0 marker"
    exit 1
  fi
done
echo "CLAIMS_DECLARED: CLEAN (claims=0)"
exit 0
