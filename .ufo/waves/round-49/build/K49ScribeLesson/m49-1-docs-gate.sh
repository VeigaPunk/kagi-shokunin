#!/usr/bin/env bash
# M49-1 fix check, after CORPUS.md "A fix is shown able to fail before it counts".
# The gate that should have caught the round-45 ISO entry is the docs declaration
# audit (ledger row R14-01, `bash corpus/claim-ledger.sh docs`). This check reads
# that gate plus the two artifacts the entry was missing.
#
# usage: m49-1-docs-gate.sh <absolute-tree>
#   FLAG  — the round-45 defect state: no `Reverify:` line, no stamps row, docs rc 1
#   CLEAN — the repaired state: one `Reverify:` line, a stamps row, docs rc 0
set -u
tree=${1:?usage: m49-1-docs-gate.sh <absolute-tree>}
entry=corpus/knowledge/iso-11770-3-edition-status.md
reverify=$(grep -cE '^Reverify: ' "$tree/$entry" 2>/dev/null || true)
stamp=$(grep -cF "$entry" "$tree/corpus/stamps.tsv" 2>/dev/null || true)
out=$( cd "$tree" && bash corpus/claim-ledger.sh docs 2>&1 ); rc=$?
last=$(printf '%s\n' "$out" | grep -E '^DOC_AUDIT: ' | tail -1)
printf 'TREE %s\nREVERIFY_LINES %s\nSTAMP_ROWS %s\nDOCS_RC %s\nDOCS_LAST %s\n' \
  "$tree" "$reverify" "$stamp" "$rc" "$last"
if [[ $rc -eq 0 && $last == 'DOC_AUDIT: CLEAN'* && $reverify -eq 1 && $stamp -ge 1 ]]; then
  printf 'VERDICT: CLEAN (entry declared, pinned, docs CLEAN)\n'
  exit 0
fi
printf 'VERDICT: FLAG (docs rc=%s reverify=%s stamp=%s)\n' "$rc" "$reverify" "$stamp"
exit 1
