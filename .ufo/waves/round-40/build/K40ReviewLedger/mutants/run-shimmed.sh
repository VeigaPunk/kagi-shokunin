#!/usr/bin/env bash
# attack3/5 shared runner: run plans/round-40-c1.sh in a variant with an intercepted
# corpus/claim-ledger.sh (PATH shim). Never mutates the variant; SHIM specifies filtering.
set -u
d=$1            # variant root
mode=$2         # drop-summary | drop-verdict
shimdir=/fast/scratch/hyaku/kagi-r40/K40ReviewLedger/shims/$mode
mkdir -p "$shimdir"
cat > "$shimdir/claim-ledger.sh" <<EOF
#!/usr/bin/env bash
target=$d/corpus/claim-ledger.sh.bak
[ -x "\$target" ] || target=$d/corpus/claim-ledger.sh
EOF
if [ "$mode" = drop-summary ]; then
cat >> "$shimdir/claim-ledger.sh" <<'EOF'
out=$(bash "$target" "$@" 2>&1); rc=$?
rc0=$rc
printf '%s\n' "$out" | grep -vE '^CLAIM_LEDGER:' 
exit $rc0
EOF
else
cat >> "$shimdir/claim-ledger.sh" <<'EOF'
out=$(bash "$target" "$@" 2>&1); rc=$?
rc0=$rc
printf '%s\n' "$out" | grep -vE '^(FAIL|STALE|MISSING|MISSING-ID) '
exit $rc0
EOF
fi
chmod +x "$shimdir/claim-ledger.sh"
cd "$d"
PATH="$shimdir:$PATH" bash plans/round-40-c1.sh > /tmp/out.$$ 2> /tmp/err.$$; rc=$?
echo "== rc=$rc stdout: $(cat /tmp/out.$$)"; echo "== stderr: $(cat /tmp/err.$$)"
rm -f /tmp/out.$$ /tmp/err.$$
