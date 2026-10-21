# FIdentityR1111 — C3 / R11-11

Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`.
Original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
Experiment: isolated clone(s) under `/fast/scratch/kagi-r24-recovery/FIdentityR1111-9`, checked out at the frozen revision; `HOME` was the empty sandbox directory and commands ran with `env -i PATH=/usr/bin:/bin`.

## Assigned mutant result

**KILLED (not invalid).** `claim-ledger.tsv:25` defines R11-11 as `grep -cv '^#' corpus/surface-census.tsv`, expected `^35$`. I invoked only R11-11's function from `identity-swap.py` (`m_blank_last_row`, lines 81–92): it deletes the first non-comment, nonblank declaration (`$HOME/.config/the-janitor`) and inserts a blank line; its `restamp()` updates the changed file's pin. No 15-row harness was run.

- Pristine control: `grep -cv '^#' corpus/surface-census.tsv` → `35`, exit 0. `row-identity.sh surface-census` → `ROW_IDENTITY: surface-census count=35 blank=0 sha256=9d34b393b708c3e0537c040c82ae0483932ce7267004d1a5b2dbfc52ef0c8d27`, exit 0. Selected ledger claims: `claims=2 failed=0`, `stale=0`.
- Mutant: same R11-11 command → `35`, exit 0 (the row's old count is preserved, with 34 data declarations plus 1 blank). Selector → `ROW_IDENTITY: surface-census count=34 blank=1 sha256=6bc479d49cac693ea78be35ebf766e03c7e915c8ddff22df333fac8ad9274d78`, exit 0. The only selected row failure was `FAIL R24-04 reason=verdict-not-final exit=0`; summary `claims=2 failed=1 stamped=83 stale=0`. The membership change is therefore caught by R24-04, not stale-stamp drift.
- Control qualification: the `verify --claims ...` process itself exited 1 in both trees because its final diagnostic had `unresolved_ids=498` (`control: failed=0`; mutant: failed=1, R24-04). Thus the assigned rows have a clean pristine control, but the full command is not a zero-exit clean run; do not claim otherwise.

Commands were the direct R11-11 count, `bash corpus/row-identity.sh surface-census`, and `bash corpus/claim-ledger.sh verify --claims <sandbox>/claims-R1111.tsv --stamps corpus/stamps.tsv`, with the two-row claims subset (R11-11, R24-04). The control/mutant selector and ledger results above are from revision `c5ef9e9`.

## Finding — MEDIUM, C3 membership coverage

`claim-ledger.tsv:25` describes 35 rows split `20 asset / 15 runtime`, while R24-04 (`claim-ledger.tsv:67`) says it pins the 35 surface keys. `row-identity.sh:64–65` actually projects only the first TAB field (path) and separately counts literal blank lines; it omits the `asset`/`runtime` field. A path-preserving class change would leave both R11-11's count and R24-04's path digest unchanged while changing the note's stated partition. This is a static counterexample to full-note coverage, **not** an additional executed mutant. The assigned deletion+blank mutant is killed, but that result establishes path-key membership only.

## Residual evidence and gaps

`identity-before-v2.txt` records BASE with 15/15 survivors; `identity-after.txt` records `rev=6c23a56dea0f`, not the frozen revision. I did not treat those aggregate snapshots as c5 evidence. `build/IdentR1111.md` describes an earlier, different probe; this report uses the one-row mutation above. No tools were installed or updated.