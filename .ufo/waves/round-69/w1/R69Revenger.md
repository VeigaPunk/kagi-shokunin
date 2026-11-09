# R69Revenger — independent re-measure of round 68 + 14th-defect hunt

Lane: kagi. Seat: R69Revenger (calibration adversary, leaf — no subagents dispatched, no production edits).
Claim BASE: `264917aa8fc9e71b6595d0d5166c4b615120fb8b` (round-68 verifier spot-check tip).
Method: `git archive 264917aa` extracted to scratch (`base2649`, 226 MB); every number below re-measurd
from that extraction with my own commands (receipt: `R69Revenger/revenger-measure.txt` next to this report).
No lane counter and no seat receipt was used as authority — receipts were re-read at BASE, never executed
as counters. Fleet report read via `git show cf4e3e1b:.ufo/reports/round-68/kagi.md` (fleet repo).

Conventions: `S` = `corpus/lessons/round-68-verifier-spotcheck.md` at BASE; `L1-13`
= legs of frozen plan `plans/round-69.md` §C1; `D1-13` = routed defects S §7.

## 1. The 13 routed defects, re-measured at BASE

Every defect reproduces exactly as routed. Column "plan leg" = which frozen-plan leg covers it.

| # | defect | my measurement at BASE 264917aa | plan leg |
|---|---|---|---|
| D1 | `SCORECARD.md:2425` prints fabricated `C2_RECORD: mismatches=0 population=3 guard=1 rc 0` | `SCORECARD.md:2425` carries `⇒ \`C2_RECORD: mismatches=0 population=3 guard=1\` rc 0` verbatim. `.ufo/waves/round-68/final/c2-candidate.txt` = **0 bytes**; `w1/R68ScribeLesson/c2-lane-run.txt:6` = `(no C2_RECORD line; the process was killed at the budget)`. The only aggregate line from a real run is `w1/R68ExecCounterC2/c2-run.txt:6` = `C2_RECORD: mismatches=3 population=3 guard=0` (RC 1/124, pre-fix bytes). | L1 |
| D2 | `SCORECARD.md:2426` says "QM97–QM99 enter the bar"; QUALITY unchanged | `SCORECARD.md:2426` carries `QM97–QM99 enter the bar`. `git diff d3b2a4e..264917aa -- corpus/QUALITY.md` = empty (exit 0). `grep -c QM97 corpus/QUALITY.md` = 0; tail criterion is QM96 (`corpus/QUALITY.md:329`). | L2 (+L11) |
| D3 | `corpus/lessons/round-68.md:18` states C2 target as achieved | Lines 17–18: `` `C2_RECORD` mismatches 3 → 0 `` present verbatim at `corpus/lessons/round-68.md:17-18`. | L3 |
| D4 | `LOG.md:2221` prints 59 cases; receipt says 56 | `LOG.md:2221` = `\`C1_VERIFIED_SELFTEST: PASS (59 cases)\``. `w1/R68ExecCounterC1/selftest.txt:13` = `C1_VERIFIED_SELFTEST: PASS (56 cases)`. `SCORECARD.md:2428` = 56. The 59 is a mutant-era count (see §3, spot-check self-conclusion). | L4 |
| D5 | `base-derivation.md:33` quotes `caught=0/6`; receipt reads `caught=6/6` | `base-derivation.md:32-33` = `` `C1_READTHROUGH: bound=36 located=36 caught=0/6 guard=0` ``. `base/c1-base-round67-counter.txt:21` = `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=0`. File agrees with itself at `:58` (6/6). Routed quoting is exact. | L5 |
| D6 | report cites `final/c1-base.txt`, absent from tree and every commit | `final/` holds only `c1-candidate.txt`, `c2-candidate.txt` (0 B), `l1-derivation-recut-only.txt`. Fleet report `cf4e3e1b:.ufo/reports/round-68/kagi.md:106` cites `.ufo/waves/round-68/final/c1-base.txt` (dead). Corrected pointer `w1/R68ExecCounterC1/base-run.txt:19` = `C1_VERIFIED: verified=36 col15=31 caught=0/6 guard=0` exists at BASE. | L6 |
| D7 | `claims.json` carries pre-A1 target `37/32` | ` .ufo/waves/round-68/claims.json` C1 target = `verified=37 col15=32 caught=6/6 GUARD=1 (BASE verified=36 col15=31 caught=0/6, …)`. Landed reading is 38/33 (`final/c1-candidate.txt:19`); my own count: pure=38 col15=33 (re-derived below). | L7 |
| D8 | `predicate_ok` ignores frozen floors; no sub-floor case | `plans/round-68-c1.sh:753-754` = `def predicate_ok(...): return (guard == 1 and caught == 6 and defects == 0)` — `verified`/`col15` never compared. `grep -c predicate-subfloor plans/round-68-c1.sh` = 0. Selftest cases at `:1098-1101` cover caught/guard/defects only. | L8 |
| D9 | `R68-02` pins a line the counter never produced; self-execution | `corpus/claim-ledger.tsv:119` R68-02: command `bash plans/round-68-c2.sh`, expect `^C2_RECORD: mismatches=0 population=3 guard=1$`, exit 0, timeout 3600. No `verify` receipt runs the row (only `candidate-verify.txt:37-38` RC=2 earlier). Counter treats own invocation as row execution (`plans/round-68-c2.sh:431-434,456-464` per S §2). `final/c2-candidate.txt` = 0 B proves the pinned line never produced on landed bytes. | L9 |
| D10 | `SCORECARD.md:2424` prints `0/6` alone; frozen-anchor battery reads 2/6 | `SCORECARD.md:2424` = `caught=0/6 guard=0` alone. `w1/R68Sentinel/receipts/base-legs.txt:1-6` header: BASE anchor = last binding row `line 199 id=S156`; M4/M6 CAUGHT, M1/M2/M3/M5 SURVIVED ⇒ 2/6 under frozen anchor. Counter anchor `S166` reads 0/6. Both readings real; record prints only one. | L10 |
| D11 | bar ends at QM96 while record claims new criteria | Same evidence as D2: `corpus/QUALITY.md` tail = QM96, zero bytes changed `d3b2a4e..264917aa`. Spot-check §7.11 routes "land the nine M68 criteria". | L11 |
| D12 | wave filed with no `w1-results.json`; achievement-shaped spec metadata | `ls .ufo/waves/round-68/w1-results.json` = no such file (fleet `.ufo/` also none). `w1-spec.json` milestone = `C1_VERIFIED verified 36->37 col15 31->32 caught 0/6->6/6; C2_RECORD mismatches 3->0; 15 seats, attack 4` (all three achievement-shaped). Registry `w1/swarm-registry.json` members carry the same milestone in all 15 seats. | L12 |
| D13 | expansion verdict `improved` for widening an existing entry | Fleet report `:183` = `expansion — improved` ("population widened 36 to 38"). `git diff --name-status d3b2a4e..264917aa -- corpus/knowledge/` = `M claim-ledger.md`, `M source-capture-binding.md` — **0 added files**. `corpus/README.md` diff = two index-count lines only (99→101 rows, stamp-note), no frontier/coverage row. Spot-check §6 disagrees (`unchanged`); I agree (see §2, candidate #3). | L13 |

### My own census re-derivation (C1 numbers, independent of every receipt)

Python split at BASE tree (no `awk` — shell quoting broke twice, see Dead ends):

```
BASE  source-fetches.tsv: total_lines=200 nf16=157 pure=36 mixed=1
LANDED source-fetches.tsv: total_lines=201 nf16=158 pure=38 mixed=0
```

`final/c1-candidate.txt:19` = `C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1`, derivation
`path_rows=38 bound=38 located=38 prose=120 mixed=none total=158` — matches my count exactly.
`verified=38` includes 7 `rejected` rows (my recount of col-2: 31 mined / 7 rejected — identical to S §2).
The 7-rejected-in-"mined" drift is real but safe-direction (superset); S routes it as
unresolved item 8, not a falsification. **I agree with the counter's expectation on all 13.**

### Readings where I disagree with the counter (nothing material)

1. **D5 line citation.** S §7.5 says "the receipt line 21 reads `caught=6/6` and line 58 of
   the same file says 6/6" — "the same file" is `base-derivation.md` itself (its line 58
   quotes the round-67 counter's `caught=6/6`), not one receipt. The counter's expectation
   (L5: parse `.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt`) is **wrong as a reading
   of S §7.5**: that file's line 19 reads `caught=0/6`, not 6/6. What L5 actually repairs is
   the `base-derivation.md:33` vs `base/c1-base-round67-counter.txt:21` pair. The leg's
   *intent* is right; its *citation* misnames the receipt. Candidate #5 below, not-a-defect
   for the leg, real citation drift for the plan.
2. **D10 framing.** The plan's L10 requires "both BASE readings (`0/6` and `2/6`)". My
   sentinel re-read shows M1/M2/M3/M5 = 4/6 blind under the frozen anchor, i.e. 2/6 *caught*.
   The plan speaks of `2/6` as a reading without naming which side (caught vs blind) — a
   reader counting SURVIVED legs will compute 4/6-blind. Not a disagreement with S (S §2 is
   explicit), but the plan's L10 paraphrase drops the caught/blind axis. Flagged, not fatal.

## 2. The 14th-defect hunt — candidates (at most five)

### Candidate 1 — `stamp_pointed` 247 vs 250: the same `cells` verdict quoted two ways

- **Evidence.** Report `:151` (L3 line) quotes `CELL_AUDIT: POLICY (cells=576 row_pointed=286
  stamp_pointed=250 policy=3)`; report `:223` (Ceilings) quotes the same verdict with
  `stamp_pointed=247`. Committed receipts split identically:
  `w1/R68ExecLedger/L3-cells-after.txt:246` = 247, `R68ExecLedger.md:231` = 247
  (922 s run) vs `w1/R68ScribeLesson/cells-live-timing.txt:7` = 250, `R68ScribeLesson.md:484,573`
  = 250 (1556 s live-tree run). Spot-check S §2 quotes **247** as canonical and parenthesises
  "(a second run reads `stamp_pointed=250`)" without naming which receipt it came from —
  unverifiable as written, and the report never reconciles the pair.
- **Why real.** Both receipts are genuine runs, 3 apart, with no reconciliation sentence as
  required by M68-3's own fix (every receipt names its tree digest; a 3-stamp drift between
  two "live" runs is exactly the shared-tree-mutation class the lane just mined). One of
  three stamps changed between runs (mid-wave stamp edits are documented: `L3-cells-after.txt`
  itself lists 3 STALE-POINTERs); the record should name the moving member.
- **Verdict: `real`** — report quotes both numbers without reconciling; spot-check names only
  one. Not routed (D1–D13 do not mention `stamp_pointed`); L9's ledger gate will read the
  247 line, so a reader matching the report's L3 quote gets a guaranteed miss.

### Candidate 2 — `CLAIMS_DECLARED: CLEAN (claims=63)`: a predicted candidate number, not a measured one

- **Evidence.** Report `:150` quotes `CLAIMS_DECLARED: CLEAN (claims=63)` as a landed reading.
  `w1/R68Critic.md:193` P-3 already flagged that 63 is true only **after** landing R68 rows;
  at freeze the live run reads `claims=61`. `w1/R68Connector/claim-headings-audit.txt:6` at
  BASE reads `CLAIMS_DECLARED: MISMATCH (claims=63 mismatch=2)` — i.e. 63 *before* the
  post-move section lands. Final clean: `w1/R68ExecLedger.md:103` = `CLAIMS_DECLARED: CLEAN
  (claims=63)` — but only after the L1 landed SCORECARD's Round-68 post-move section (§4
  leases exactly this shape).
- **Verdict: `not-a-defect`.** The plan predicted 63; the landed tree delivers 63 once the
  permitted section lands; the ledger seat measured it. The prediction matched. The shape is
  the same class as M68-1 (frozen number post-dating its own frontier), and S never routed
  it — but because (a) the plan names the command, (b) the reservation is lifted once the
  section lands, and (c) the claim is about the *post-move* tree, the number is a
  *measurement*, not an overclaim. Recorded so the counterexample stands on the record.

### Candidate 3 — the report's `discernment — improved` contradicts the round's own mistakes table

- **Evidence.** Report `:195` = `discernment — improved` ("Seven attack/review seats produced
  findings…"). The same report's Mistakes section (M68-1…M68-9 + freeze-sequence gap) records
  **nine classes where no criterion caught them**, and `git diff d3b2a4e..264917aa --
  corpus/QUALITY.md` = empty (S §6 calls this `harmed` on the same evidence). LEARNING §3
  requires a QUALITY criterion whenever no criterion caught a mistake; none landed. The
  report quotes the learning *input* (findings folded) as the *output* (improved) while the
  learning *mechanism* (bar) visibly did not run.
- **Verdict: `real`** — the report's discernment verdict does not follow from its own
  evidence; S §6 (harmed) is the correct reading. **Not routed** (D1–D13 route the
  record surfaces, not the trend verdict; L13 covers expansion only). This is the cleanest
  fourteenth defect: a conclusion the spot-check drew *the other way* from identical evidence
  and did not route.

### Candidate 4 — `88 → 98` journal pair: the old value was never the measured BASE value

- **Evidence.** `w1-spec.json` instructs: migrate R21-03 "from its current 88 to the measured
  count (round 67's journal pair 78->88 is historical…); .ufo/waves/round-68/journals/
  expectation-migrations.json with the full 88->N pair". Landed journal:
  `old_expect = ^SOURCES_CENSUS_SELFTEST: PASS \(88 cases\)$`, `new_expect = …98…`.
  But `git show d3b2a4e:corpus/claim-ledger.tsv | grep R21-03` prints **88** (stale — the pin
  covers only 40 at c41af82 per note), while the actual BASE gate run
  (`.ufo/waves/round-68/base/selftest.txt:90`) reads **89 cases**. The BASE measurement is
  therefore neither 88 (what the row pinned) nor 98 (what the journal claims to replace);
  it is 89, and no receipt quotes 89 as the base-selftest value under `--selftest` in S §2
  — S quotes `base/selftest.txt:90` = 89 while quoting the journal's 88→98 pair in the same
  section without flagging the off-by-one.
- **Verdict: `real`** — the journal's old caption (88) is three generations behind the
  measured BASE value (89); a ledger row whose expectation the pins had already outgrown was
  migrated from a number no run produced. The repair (pin 98, measured) lands, but the
  *journal's old value* is fiction — the same class as D9 (a row pinning a line the tree
  never printed), one level down. Not routed; L9's guard (d) does not cover R21-03's
  journal chain, only R68-02's new migration.

### Candidate 5 — plan L5 citation names the wrong receipt

- **Evidence.** Plan §C1 leg L5 (plans/round-69.md:73): "an appended correction names
  the value parsed from `.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt`".
  Mask: that file's line 19 reads `caught=0/6`, i.e. it supports the *fabricated* side of
  the contradiction, not the correction. The true source of `caught=6/6` is
  `base/c1-base-round67-counter.txt:21` (round-67 counter). If the C1 counter implements L5
  literally, the correction will be named with the wrong value, repaired on paper and
  re-falsified at the receipt.
- **Verdict: `real`** as a citation defect inside the frozen plan (a frozen target the counter
  will implement verbatim — L5's guard (a) does not bind the cited receipt's bytes). Not
  routed by definition (it *is* the repair). Flagged for the counter author, not a new
  record defect.

## 3. Claim BASE check

1. **Is 264917aa the spot-check tip?** Yes. `git log …264917aa` first parent = `cd9d66f1`
   (round-68 lane tip); `git show 264917aa --stat` = 1 file added,
   `corpus/lessons/round-68-verifier-spotcheck.md` (400 lines). `git ls-remote origin
   refs/heads/master` at round start printed it and the frozen predecessor commit `adb6972`
   carries it as parent — the file is the tip at claim time, byte-identical at HEAD
   (`sha256 7756fc0d…` both ends, `git diff --quiet 264917aa HEAD -- <file>` clean).
2. **Does the spot-check file change any surface the plan measures?** No. The plan's legs
   measure the round-68 surfaces (SCORECARD rows at :2424-2426, lesson :17-18, LOG :2221,
   `claims.json`, `plans/round-68-c1.sh`, `corpus/claim-ledger.tsv`, `corpus/QUALITY.md`,
   `base-derivation.md`). All nine files are byte-identical between 264917aa and HEAD
   (`git diff --quiet` clean on each — see receipt). The only post-BASE commits
   (`adb6972` plan+claims.json; `6a93ca6` round-69 base receipts + wave spec/dispatch/
   registry + inherited leftovers) add `round-69/` and `plans/round-69.md` only. Critically,
   the added file `plans/round-69.md` is itself protected surface for no leg (legs read
   `plans/round-68.md` and `plans/round-68-c1.sh`). **No BASE reading is invalidated.**
3. One caution: `.ufo/reports/round-68/kagi.md` does **not** exist in the lane tree at any of
   these commits — the report lives in the *fleet* repo (`cf4e3e1b`) and the lane path
   `git ls-files` is empty. S §1's check "report committed by the lane identity" therefore
   verifies a *fleet* file under a *lane* name. This is the site of D6 (the report's dead
   citation is a fleet-only file) and explains why L6's corrected pointer names a wave
   receipt, not the report. Not a new defect — the spot-check itself records the fleet
   commit `cf4e3e1b` as evidence — but any lane-rooted `test -e .ufo/reports/…` check will
   fail; QM96's "the tree the report names" is ambiguous between fleet and lane root here.

## 4. Dead ends measured (honest log)

- `awk 'NF==16 …'` census one-liner failed twice on shell escaping (`syntax error` in both
  BASE and candidate arms) — abandoned for a `python3` split; totals above are Python-derived.
- `git show d3b2a4e..264917aa` fails (`bad revision`) — the full tree hash is
  `d3b2a4e8eed710277951e430efd3d27b5983033c`; short 7-char needed rev-parse. Re-ran with the
  full hash; QUALITY diff = empty both ways.
- `git show cf4e3e1b:…` from the lane repo = `fatal: Not a valid object name` — the fleet
  commits (`cf4e3e1b`, `f2a3a920`, `227ec14f`) live in the fleet root repo only. Re-ran all
  fleet reads from `/home/vgpnk/Projects/shokunin`.
- `grep -rn` for the `register 97`/`p` population tokens returned only incidental hits
  (e.g. `build-results.json` round-40 payloads); `claims` count in report = 2 (C1/C2),
  not a third population. `p` as a standalone metric does not exist in this round's surface —
  the census population is `path_rows`/`verified`.
- `cells-live-timing.txt` vs `L3-cells-after.txt` provenance: I did **not** re-run
  `claim-ledger.sh cells` (both runs cost 922–1556 s; the host-guard rule on CPUs left the
  receipts as evidence. Verdict 1 rests on the receipts' own text).

## Findings summary for claim-falsification.tsv

```
F1	R69Revenger	real	report quotes CELL_AUDIT stamp_pointed=250 (:151) and =247 (:223) without reconciliation; receipts L3-cells-after.txt:246=247 vs cells-live-timing.txt:7=250; spot-check S§2 names 247 only, "(a second run reads 250)" unnamed
F2	R69Revenger	real	report discernment=improved (:195) from nine mistakes recording no-criterion-caught vs empty QUALITY diff; S§6 reads harmed from same evidence (not routed)
F3	R69Revenger	real	journal old_expect ^…PASS \(88 cases\)$ vs measured BASE gate 89 (base/selftest.txt:90), never reconciled; S§2 quotes both without flagging (D9-class one level down)
F4	R69Revenger	not-a-defect	claims=63 is plan-predicted (Critic P-3) and landed-measured (ExecLedger.md:103 CLEAN); prediction matched, no overclaim
F5	R69Revenger	(real plan citation)	plan L5 names w1/R68ExecCounterC1/base-run.txt:19 (caught=0/6) as the correction source; true 6/6 source is base/c1-base-round67-counter.txt:21 — counter author must not implement L5 literally
```

Verdict on the fourteenth: **three `real` candidate defects (F1–F3)**, all unrouted,
all surviving never-conflicting legs. F1 (247/250) is the strongest: it is a *fourteenth
contradiction between the report and its own receipts*, exactly the class D1–D13 claim to
repair exhaustively ("population=13"), so its absence from the frozen population is itself
the finding — L1–L13 cannot pass against a tree that carries it unless the round repairs it
outside the claim (the same inside/outside split the plan's Ceilings already concede for
L12/L13).
