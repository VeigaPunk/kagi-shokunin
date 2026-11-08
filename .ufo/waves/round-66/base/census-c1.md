# Base census C1 — registry self-reference count (round 66)

Command: `awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ {n++} END{print n+0}' corpus/SOURCES.md`
Output at BASE `d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`: 155.
Self-reference sweep: `grep -cF 'S143.body' corpus/SOURCES.md` → 0. The S148
row does not cite its carrier path; the S148 binding exists only in
`corpus/source-fetches.tsv` (sha column 10, bytes column 11) and in the
volatile-shape gate's PIN literal. A do-nothing control (row edited to cite
a different carrier path) reads 155 still and no lane gate reads the delta —
the claim's baseline is the census digest measured with the row's carrier
path named, not a row count that cannot move.
