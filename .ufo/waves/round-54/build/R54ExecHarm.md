# R54ExecHarm — harm check: ledger expectation migrations + targeted rows (BASE vs candidate)

Scope: kagi-shokunin round 54. BASE `1a0f43a9220bb0e995462c2aef745ac0124c3317`, candidate `ede4373afa07a33e24cbd35e9fd33fc2fddf2f14`. Both ledger extracts have 86 non-comment rows (no row added or deleted).
Method: read-only `git show` for the two ledgers; `git clone -q --shared` of the lane into scratch `/fast/scratch/hyaku/kagi-r54/R54ExecHarm`, `git checkout --detach` at each revision after asserting `git rev-parse --show-toplevel` equals the clone; every row command run alone from its clone root with the ledger's own timeout, expect ERE matched via `grep -qE` against the last non-empty line of combined output plus exit-code equality. Per-run env: `HYAKU_SCRATCH`/`TMPDIR` pointed inside the seat scratch; HOME untouched. Scratch removed at exit; no lane or fleet file touched except this report dir. No tools installed. Receipts: `R54ExecHarm.d/receipts/` (81 files), machine-readable `R54ExecHarm.d/row-results.json`.

## (1) expect-journal gate

Command: `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/expect-journal.sh --base-ledger <git show BASE:corpus/claim-ledger.tsv> --ledger <git show CAND:corpus/claim-ledger.tsv> --journals <scratch dir holding only a copy of .ufo/waves/round-54/expectation-migrations.json>`

Full output (`R54ExecHarm.d/receipts/expect-journal.txt`), exit 0:

```
EXPECT_JOURNAL: CLEAN (changed=10 journaled=10)
rc=0
```

Verdict: **CLEAN**. Exactly 10 rows changed BASE→candidate (R13-01 R21-02 R24-06 R25-03 R31-02 R33-02 R34-03 R36-02 R36-03 R38-01 = the migration journal's population), every entry's `old_expect`/`command`/`new_expect` matched literally, all new expects fully literal anchored; no REFUSE, no ORPHAN warnings, no MISSING_ROW/DELETED.

## (2) Targeted row execution — 16 ids × both revisions (32 runs, all PASS)

Verdict rule met: all 10 migrated rows PASS in the candidate clone against the new expectations; all 6 non-migrated rows give the identical PASS (same exit, same last line) in both clones. No row FAILs anywhere.

| id | migrated | BASE last line (verdict) | candidate last line (verdict) |
|----|----------|--------------------------|-------------------------------|
| R12-02 | no | `OP_REF_SELFTEST: PASS (36 cases)` — PASS | identical — PASS |
| R13-01 | yes | `71` — PASS (^71$) | `72` — PASS (^72$) |
| R21-01 | no | `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)` — PASS | identical — PASS |
| R21-02 | yes | `SOURCES_CENSUS: CLEAN (rows=111 A=107 B=2 C=2 … captures=111 …)` — PASS | `(rows=112 A=108 … captures=112 …)` — PASS |
| R21-03 | no | `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` — PASS | identical — PASS |
| R24-05 | no | `ROW_IDENTITY: stamps count=125 sha256=369e92e5…` — PASS | identical — PASS |
| R24-06 | yes | `ROW_IDENTITY: scorecard-rounds count=71 sha256=385e89bc…` — PASS | `count=72 sha256=358ac082…` — PASS |
| R24-14 | no | `ROW_IDENTITY: ledger-ids count=86 sha256=3728b4c4…` — PASS | identical — PASS |
| R25-03 | yes | `RELEASE_CLOCK_SELFTEST: PASS (116 cases)` — PASS | `PASS (121 cases)` — PASS |
| R25-04 | no | `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169  .ufo/waves/round-26/observe-2.json` — PASS | identical — PASS |
| R31-02 | yes | census `rows=111 … captures=111` — PASS | `rows=112 … captures=112` — PASS |
| R33-02 | yes | census `rows=111 … captures=111` — PASS | `rows=112 … captures=112` — PASS |
| R34-03 | yes | census `rows=111 … captures=111` — PASS | `rows=112 … captures=112` — PASS |
| R36-02 | yes | `2` — PASS (^2$) | `3` — PASS (^3$) |
| R36-03 | yes | `RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17)` — PASS | `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)` — PASS |
| R38-01 | yes | `9` — PASS (^9$) | `10` — PASS (^10$) |

Every measured line matches the corresponding `old_expect` (BASE) / `new_expect` (candidate) recorded in the migration journal. The census line growth (111→112 rows, A 107→108, mined 106→107, captures 111→112, all other cells unchanged) and the clock line growth (on_release/bound/observed 31→32, fired 13→14, derived 17 unchanged) are exactly what the journal declares for S112 and S072→on-release. R21-01 was exercised live through the lane probe `corpus/op-ref-probe.sh --dotenv-bytes` (the refusal-boundary-authorized probe; its output contains only the CLEAN summary line). Receipt files `base-NN-*.txt` / `cand-NN-*.txt` + `*-lastline.txt` in `R54ExecHarm.d/receipts/`.

## (3) L1 verify receipt comparison (final/verify-base.txt vs final/verify-candidate-tree.txt)

- Both receipts 105 lines; unified diff (n=0) differs **only on the header comment line** (which tree was verified; 11m09s vs 11m10s). Body byte-identical.
- FAIL sets: base {R11-08, R25-02, R36-01} = candidate {R11-08, R25-02, R36-01} — no id on only one side.
- POLICY sets: base {R29-01, R29-02, R38-03} = candidate {R29-01, R29-02, R38-03}.
- HOST-SKIP: 13 ids, identical sets. LABELED-ID: 21 refs, identical.
- MISSING-ID lines: **57 in base, 57 in candidate, line-for-line identical**.
- Final line both receipts: `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)`, `rc=2`.

Explanation of each difference: **there are no differences to explain.** Structurally, the candidate cannot move these sets: it adds/deletes no ledger row (86/86, stamps still 125 per R24-05/R24-14 above), and the 10 re-bound expectations each hold on their own tree (§2), so no row flips to FAIL/POLICY on either side. The candidate's new prose (LOG `## Round 54 …` at line 1906 of 1912; SCORECARD `## Round 54 — post-move` at line 1815 of 1826) is appended after every previously referenced line number (highest LOG ref 1693, highest SCORECARD ref 1455), so all LABELED-ID/MISSING-ID file:line references stay put, and the new text names only ids that exist in the ledger, so it creates no new MISSING-ID. The persistent FAIL/POLICY ids are revision-independent, pre-existing states, not candidate harm: R11-08 (citations gate) timed out at tmo=300 on the load-200 host in both runs; R25-02 (exit-mismatch exit=2 want=0) and R36-01 (verdict-not-final exit=0) reproduce identically; R29-01/R29-02 (`first-token:python`) and R38-03 (`python-script`) are command-safety POLICY refusals present at both revisions.

## (4) claims-declared + sources-census in the candidate clone

- `bash corpus/claims-declared.sh` → exit 0, last line: `CLAIMS_DECLARED: CLEAN (claims=34)` (receipt `claims-declared.txt`)
- `bash corpus/sources-census.sh` → exit 0, last line: `SOURCES_CENSUS: CLEAN (rows=112 A=108 B=2 C=2 queued=1 mined=107 rejected=4 entries_sourced=16 legacy=21 captures=112 inrow=16 inrow_only=0 inrow_nonreproducing=12)` (receipt `census-cand.txt`) — identical to the R21-02/R31-02/R33-02/R34-03 candidate verdict in §2.

## Harm verdict

**No harm detected.** The migration journal is exactly sufficient and exactly bounded (changed=10 journaled=10, all literal), all 16 targeted rows PASS on their respective trees with the journal-declared values, the full-verify FAIL/POLICY/MISSING-ID surfaces are byte-identical across BASE and candidate, and the candidate census/claims scripts end CLEAN.

## Integrity notes

- Receipts swept for `op://`, private-key blocks, `AQAAA`, "root token": none present (`grep -rEn` rc=1, no hits). No token, key, or vault value entered any artifact; the only live `op` execution was the authorized lane probe path.
- Scratch `/fast/scratch/hyaku/kagi-r54/R54ExecHarm` deleted at exit (verified absent). No lane/fleet file written other than `build/R54ExecHarm.md` and `build/R54ExecHarm.d/`.
