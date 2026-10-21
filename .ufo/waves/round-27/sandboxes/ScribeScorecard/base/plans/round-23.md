# Round 23 — frozen claims

Base: `d218603b74099ddca0bd8f869516fc41db0979bf` (round-22 non-author spot-check).
L1 holds the frozen planner seat. The round's build wave is the parent-held
66-seat read-only audit (43 claim-ledger command rows + 23 source rows,
`.ufo/waves/round-23/parent-build/`); this round does not dispatch a second build
wave. A fresh 64-seat falsification wave follows integration.

1. **C1 calibration (capability acquisition).** Consume the non-author closure's
   decisions instead of self-certifying agreement: `corpus/closure-dispositions.py`
   parses the round-22 verifier spot-check (nine routed defects, five discernment
   decisions, the adjudication ruling), requires exactly one typed disposition per
   obligation, resolves every `fixed` pointer in the commit tree, and fails on a
   missing/duplicate/unknown obligation, an unresolved pointer, or source drift.
   Before: `test -e corpus/closure-dispositions.py` fails (1) and nine
   `^- D[0-9]` obligations have no machine disposition. After: `verify` exits 0
   with `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 ...)`; selftest kills the
   missing/duplicate/bogus-pointer mutants and admits a valid control. No
   calibration statistic and no outside-agreement claim: the scores stay 9.
2. **C2 freshness (D7).** Make source provenance machine-checked for the seven
   mined rows that lack it and for one new frontier row: `corpus/source-fetches.tsv`
   records, for the ten registry rows without an in-row pin (S017–S026 after the
   three correction rows), the reopened URL, final URL, status, request profile,
   fetch date, representation, SHA-256 and decoded byte count plus a located
   ≤25-word quote and its normalization; legacy in-row pins (S001–S016) are
   classified historical and never compared to fresh captures;
   `corpus/sources-census.sh` gains a fail-closed `SC_FETCH` check (in-row
   `Fetch sha256:` or a complete provenance row, URL equality, digest shape,
   quote bound, location present) with selftest cases. Before: `grep -c
   'Fetch sha256:' corpus/SOURCES.md` = 16 of 23 rows and the census has no
   `source-fetches` reference. After: 10 active declared-provenance rows over 26
   registry rows, 0 rows without either an active row or a historical in-row pin,
   census selftest green with the new cases, and S024–S026 opened this round. Digests are point attestations of the fetched representation,
   never content-drift pins.
3. **C3 operability (D9).** Give `claim-ledger.sh cells` a hermetic, host-free
   execution path through committed fixtures: `corpus/fixtures/cells-hermetic/`
   plus ledger row `R23-01`, whose command runs `cells` at the fixture root and
   must print the exact `CELL_AUDIT: CLEAN` line; a fixture mutation case must
   fail. Before: zero ledger rows execute `cells` host-free (`R13-03` is skipped
   for host rows) and `grep -c 'corpus/fixtures/cells' corpus/claim-ledger.tsv`
   = 0. After: `R23-01` passes in the safe-row run, mutation case fails as
   expected, and R13-03's skip reason stays explicit.

Axes are distinct: calibration, freshness, operability. All six axes sit at 9;
no stagnation waiver is needed or claimed. No depth move, no legacy-header
migration, no host/private gate, no vault/account action, no secret value.
Every corpus/log/quality change is an append; only the two executable TSV
snapshots (claim ledger, stamps) are updated with old/new migration records
per QM14. One integration owner: this L1.
