# R63ScribeRecords — seat report (round 63, wave `kagi-r63-w1`)

Seat: scribe (records). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, claim BASE
`0c07aab8df64b673a54a5113aebd7f34b622adbc`. Receipts:
`.ufo/waves/round-63/build/R63ScribeRecords/` (`records.md`, `sources-block.md`). Scratch
`/fast/scratch/hyaku/kagi-r63/R63ScribeRecords/` (deleted before yield).

## Behavior

1. `corpus/lessons/round-63.md` — written. Sections in order: `## Claims` (C1/C2 frozen
   predicates verbatim, BASE readings from the committed census, candidate instrument
   state, the admitted ground for each claim, named ceilings), `## Gate` (10 rows
   S135–S144 — 6 admit, 4 reject — each with URL, access date, a ≤25-word located quote,
   reason and flip; every quote re-resolved by this seat from the scout's ledger),
   `## Mistakes` (9 rows M63-1 … M63-9), `## Corrections` (the D-A single-line
   correction), `## Routed dispositions` (D-A/D-B/D-C), `## considerthese`, `## Wave`
   (dispatch-derived; settled counts are the L1's append), `## Case enumeration` (the
   checker's 102 selftest case names), `## Bounds`.
2. `corpus/SOURCES.md` row block — drafted in
   `.ufo/waves/round-63/build/R63ScribeRecords/sources-block.md`: 10 rows in the
   11-column contract (S135 ConText efetch admit, S136 IEEE 5661753 reject, S137 arXiv
   2408.01760v1 admit, S138 Codecov reject, S139 Jia & Harman PDF admit, S140 arXiv
   1903.05432v1 admit, S141 NegEx PubMed admit, S142 IEEE sibling reject, S143 ConText
   BioC admit, S144 IEEE 5487526 reject) plus 9 complete `source-fetches.tsv` rows
   (S136 has none: a 0-byte body fails the census's `bytes` check). The L1 appends; this
   seat did not edit `SOURCES.md`.
3. `corpus/README.md` — one coverage-map row for `knowledge/negation-scope-grammar.md`,
   one for `lessons/round-63.md`, and one `## Frontier` bullet for the negation-scope
   ground.
4. `records.md` — every command and its output, including the 14 ledger quote
   re-resolutions (all `count=1`), the S139 PDF `SETUP (not strict UTF-8)` reading, the
   C1 counter selftest (`PASS (10/10 checks)` rc 0), the case-list extraction (102), the
   routed-leg readings and the capture-digest census.

## Gates (run by this seat)

| gate | command | observed |
|---|---|---|
| locate, all ledger quotes | `python3 corpus/rendered-text-v1.py locate <capture> "<quote>"` | `count=1` for all 14 strings (S139's in `S139.txt`); the PDF bytes give `SETUP (not strict UTF-8)` |
| C1 counter selftest | `bash plans/round-63-c1.sh --selftest` | `C1_RESIDUAL_SELFTEST: PASS (10/10 checks)` rc 0 |
| checker selftest | `python3 -I -B plans/round-61-c1-check.py --selftest` | `C1_CHECK_SELFTEST: PASS (cases=102)` rc 0 |
| case enumeration | scratch extractor on the checker | `CASES: 102`, matching the PASS line |
| routed legs | `bash plans/round-63-routed.sh` | `da=1 db=0 dc=1` — `db=0` because the six receipts are the L1's at integration; `da`/`dc` read 1 on this lesson |

## Touched surfaces

- `corpus/lessons/round-63.md` (new, 309 lines)
- `corpus/README.md` (two coverage rows, one Frontier bullet)
- `.ufo/waves/round-63/build/R63ScribeRecords/records.md` (new)
- `.ufo/waves/round-63/build/R63ScribeRecords/sources-block.md` (new)
- `.ufo/waves/round-63/w1/R63ScribeRecords.md` (this report)

No other lane file was written; no git/jj mutation was run.

## Out of scope (not done by this seat)

- `corpus/SOURCES.md` and `corpus/source-fetches.tsv` appends (L1).
- The six gate receipts under `.ufo/waves/round-63/final/` (L1/executors).
- The candidate verdict lines (`C1_RESIDUAL`, `C2_REFUSAL`) — the frozen counters' to
  print and the L1's to land; this seat did not run the 16-fixture verdict.
- The knowledge entry `corpus/knowledge/negation-scope-grammar.md`, `QUALITY.md` and
  `SKILL.md` (R63ScribeEntry).
- The Wave section's settled counts and seat verdicts (L1).

## Findings (reported, not amended)

1. **Dispatch vs frozen plan (M63-1).** `.ufo/waves/round-63/w1-spec.json` (committed
   `4fe6c0d`) carries `C2_REFUSAL killed 0 -> 6` and a C2 seat prompt requiring
   `population=6 … K=6`; plan Amendment A2 (committed `81bd56c`, 35 s later) sets
   population 5 / target 5 because L5 already fires at BASE. The lesson states the frozen
   population is 5 and names the stale dispatch text.
2. **The C1 guard is satisfiable without a grammar (M63-6).** The critic's §A4 lookup-table
   checker passes every frozen guard leg and reaches `accepted=0 rejected=0`; the round-62
   counter refused it only through a `chal` leg the round-63 guard does not carry. This is
   the round's largest named ceiling.
3. **The `dc` routed leg's stated rule is not its code (M63-4).** The receipt says prose
   `cases=` mentions do not set the floor; the code scans every line. Measured: a fixture
   lesson with a four-digit prose figure reads `dc:max_cases=<figure> enum_items=2` ⇒
   `dc=0`. This lesson's own M63-4 row first tripped it (the literal was removed).
4. **The plan's `ceiling=` landing is unrealized (M63-5).** §considerthese says the verdict
   lines carry a `ceiling=` field; the frozen §C1/§C2 line specs have no such field and
   `plans/round-63-c1.sh` carries 0 occurrences. The QUALITY criterion lands; the field
   does not.
5. **The plan's frontier candidate 1 URL is already a registry row (scout defect 1).**
   S135's efetch body is byte-identical to S130's (same URL, 189603 B, sha `cdbb4173…`).
   The row is kept as `mined` with a §3.1.2 `teaches` that S130 did not quote, and S143 is
   the distinct-URL carrier of the same lesson; the L1 decides which to keep.
6. **The candidate list's IEEE id for Jia & Harman is wrong (scout defect 2).** 5661753 is
   "Address Translation Aware Memory Consistency"; the survey is 5487526 (S144, Crossref
   DOI 10.1109/TSE.2010.62). S136/S142 carry the measured proof; S139 is the citable
   carrier.
7. **Round 62's S132 PMID was wrong (scout defect 3).** NegEx is PMID 12123149 (S141);
   11554662 is "Endoscopic transnasal pituitary surgery".
8. **A PDF body cannot carry a `rendered-text-v1` quote.** S139's quote is located in
   `S139.txt`, the committed text layer of the same PDF (both digests recorded); the
   registry row uses the `raw-literal-v1` / `-` shape S078/S079 already use, and S136 has
   no fetch row because its body is 0 bytes.

## Artifact paths

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-63.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/README.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-63/build/R63ScribeRecords/records.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-63/build/R63ScribeRecords/sources-block.md`

Tool installs: none.

SEAT-STATUS: complete
