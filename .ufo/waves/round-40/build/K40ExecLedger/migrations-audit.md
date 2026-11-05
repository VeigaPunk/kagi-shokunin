# Expectation-migrations audit — seat K40ExecLedger, 2026-11-05

Audited: `.ufo/waves/round-40/expectation-migrations.json` (6 rows) against
BASE `6cc8850dfc5757927699e5a53a876f47c8df21aa:corpus/claim-ledger.tsv` (47462 B, sha256
`6da91663a6448ec042d0a421aaf9713e6ff06617427373e9348dbda4f18cd596`) and candidate
`cb3f642479a09644a03874909bb7e44b52697a8d:corpus/claim-ledger.tsv` (48330 B, sha256
`434b8233ee23fde89ab288c1bd16371402aa79862682214e0a0c912e9fae9bd4`), both extracted with
`git show <rev>:corpus/claim-ledger.tsv` from the lane checkout at HEAD = candidate.
Ledger row shape: `id <TAB> command <TAB> expect <TAB> exit <TAB> timeout <TAB> note`.

## 1. Field-for-field: json vs ledger bytes

Every cell compared as exact byte equality against the extracted revision bytes.

| id | json command == BASE cmd cell | json command == CAND cmd cell | old_expect == BASE expect cell | new_expect == CAND expect cell |
|---|---|---|---|---|
| R13-01 | yes | yes | yes | yes |
| R21-02 | yes | yes | yes | yes |
| R24-06 | yes | yes | yes | yes |
| R31-02 | yes | yes | yes | yes |
| R33-02 | yes | yes | yes | yes |
| R34-03 | yes | yes | yes | yes |

Result: **6/6 rows field-for-field identical on both sides.**

## 2. new_expect vs the command's real output on the candidate tree

Commands re-run directly in the lane working tree (HEAD = candidate), outputs verbatim:

```
$ grep -c '^## Round ' SCORECARD.md
exit=0
54

$ bash corpus/row-identity.sh scorecard-rounds
exit=0
ROW_IDENTITY: scorecard-rounds count=54 sha256=52e7ba8d9b4de4a3aa7543b7f0370361dd17c2ae18b98c0c318618917dfe50c7

$ bash corpus/sources-census.sh
exit=0
SOURCES_CENSUS: CLEAN (rows=96 A=92 B=2 C=2 queued=1 mined=92 rejected=3 entries_sourced=14 legacy=21 captures=96 inrow=16 inrow_only=0 inrow_nonreproducing=12)
```

Regex tests (json strings used as-is):

| id | new_expect matches recomputed output | old_expect still matches new output |
|---|---|---|
| R13-01 (`^54$`) | yes | no |
| R21-02 (census rows=96 …) | yes | no |
| R24-06 (ROW_IDENTITY count=54 sha256=52e7ba8d…) | yes | no |
| R31-02 (census rows=96 …) | yes | no |
| R33-02 (census rows=96 …) | yes | no |
| R34-03 (census rows=96 …) | yes | no |

Result: **every new_expect re-derives on the candidate tree; every old_expect is dead there**
(the migration is real, not a stale copy).

## 3. Red set of `bash corpus/claim-ledger.sh verify` at the candidate

Full output in `verify-full.txt` (exit 2, 288 s). Machine-checked with
`grep -c '^(FAIL|STALE|MISSING).*(R13-01|R21-02|R24-06|R31-02|R33-02|R34-03)'` → **0 matches**:
no red line names any frozen-set id.

- FAIL lines (exactly 5, all expected): R11-08, R22-03, R24-15, R25-02, R36-03 — all
  `exit-mismatch`, all outside the frozen set, all byte-unchanged rows (see untouched-rows.txt).
- STALE lines (exactly 8, stamp class): claim-ledger.tsv, laneguard.sh, QUALITY.md,
  source-fetches.tsv, SOURCES.md, LOG.md, SCORECARD.md, SKILL.md — file stamps with
  old→new sha/lines/bytes, no claim ids.
- MISSING-ID lines: historical errata classes only — R32-1..5, R33-1..7, R34-2, R34-3, R34-4,
  R35-1, R36-1..5 (single-digit errata form; distinct from ledger row ids such as R33-02).
- POLICY rows (3, outside population, per plan): R29-01, R29-02 (first-token:python), R38-03
  (python-script). HOST-SKIP and LABELED-ID lines unchanged in shape.
- Summary identical to BASE: `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)`.

### BASE vs candidate verify diff (committed receipt `.ufo/waves/round-40/controls/base-verify-at-tip.txt`)

The unified diff contains exactly:
1. the six frozen-set FAIL lines removed at the candidate (`FAIL R13-01|R21-02|R24-06|R31-02|
   R33-02|R34-03 reason=verdict-not-final exit=0`);
2. stamp sha/byte updates on QUALITY.md, source-fetches.tsv, SOURCES.md, SCORECARD.md and two
   newly stamped files (claim-ledger.tsv, SKILL.md) — same STALE stamp class;
3. SCORECARD.md erratum line drift +1 (1338→1339, 1438→1439), same erratum ids;
4. no other delta. The BASE receipt additionally carries a trailing `rc=2` capture line absent
   from my format (receipt-shape difference only).

## 4. Verdict

The migration journal is fully consistent with both ledger revisions and with the live tree:
old_expect matches BASE bytes, new_expect matches candidate bytes and the re-derived command
output, the six set rows are green at the candidate (C1 prints 0), and the surviving red set is
exactly the five named FAILs plus the historical MISSING-ID errata classes plus the STALE stamp
rows. No defect found in the audit population.
