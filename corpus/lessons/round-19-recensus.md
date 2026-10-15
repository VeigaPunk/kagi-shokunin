# round-19 re-census — OMP-era freshness, measured unchanged

2026-10-14. Steered round 19. Advisory inventories: fleet-root
`.ufo/waves/shokunin12h-20261014-p1-repair/members/Kagi*.md`.

## Verdict lines (measured, full lines retained in the wave receipts)

- `bash corpus/claim-ledger.sh citations` → exit 0,
  `CITATION_GATE: CLEAN (cites=912 docs=53 unresolved=0 ephemeral=0 labeled=13)`
- `bash corpus/claim-ledger.sh docs` → exit 0,
  `DOC_AUDIT: CLEAN (entries=21 row_linked=18 by_hand=3 undeclared=0 missing_ids=0 …)`
- Selftests exit 0: `SELFTEST: PASS (97 cases)`, `DRIFT_SELFTEST: PASS (13 cases)`,
  `SELFTEST: PASS (16 cases)`, `SCOPE_SELFTEST: PASS (61 cases)`,
  `OP_REF_SELFTEST: PASS (29 cases)`, `CHECKLIST_SELFTEST: PASS (34 cases)`,
  transcript-scan `SELFTEST OK (seeded hit + wal-resident hit)`.

## No gate-default repair was warranted

The seven registered gates carry no `$UFO_SRC` / `--src` / `origin-work` /
`ufo-fsd` derivation (`rg` over `corpus/*.sh` → no matches). Inventing one would
add a resolver no caller consumes: this lane censes the-janitor host surfaces,
not the OMP tree. Round 18 already closed that class as vacuous.

## Excluded from live verification (secret/session boundary)

`transcript-scan.sh`, `checklist-run.sh`, `surface-census.sh` and
`drift-pins.sh` are run in `--selftest`/scratch mode only: their live modes copy
or read `opencode.db` session text or `op.env`. Recorded by the wave sentinel.

## Named debt (describe, don't pin — no re-pin to an empty host)

- Substrate absence (11 deferred ledger rows; six fail-closed live verdicts).
  Unblock: reinstall the-janitor tree, then un-defer in one run.
- `SKILL.md:46` "54 stamps + 32 claims" and `:241` "--selftest 94 cases" are
  superseded counts; live data files hold 56 / 35 and pin `R11-09` = 97.
- Host source-basis lines still assert hash prefixes of absent files; the
  withheld private prefix `af8873ca…` must not be expanded.
- `~/projects/shokunin` (lowercase) strings are deleted-path spellings; the
  resolver is script-derived (`scope-gate.sh:91`).
- `corpus/lessons/round-13.md:9` `<FILL ON STAMP>` was never filled; the
  round-13 blob is described, never re-pinned as HEAD.
