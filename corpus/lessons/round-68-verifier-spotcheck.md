# Round 68 — non-author verifier spot-check (kagi)

author: hyaku closure (non-author integrator, @m_zfl)

Lane repo `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Claim BASE `d3b2a4e8eed710277951e430efd3d27b5983033c`; lane tip at closure
`cd9d66f12e6b10f420dddb9841ebb35e495088bf` (`git ls-remote origin
refs/heads/master` prints it). Report `.ufo/reports/round-68/kagi.md`
(fleet commit `cf4e3e1b`, kagi identity). I did not author this round and did not
edit any lane-authored file: this file and the MANIFEST closure entry are the
only artifacts I write.

Dispatch/complete digest (copied from the mutable `.ufo/watchdog.log`):

```
2026-11-08T09:01:19-03:00 launch kagi round=68 pgid=3424013 driver=hyaku-inline attempt=1
2026-11-08T13:22:34-03:00 complete kagi round=68; hyaku-inline attempt=1
```

Method note: I never executed a lane gate, counter or selftest. Every number
below is either my own plain measurement over committed bytes
(`git show`/`awk`/`grep`/`sha256sum`/`wc`) or a committed receipt whose
instrument digests I checked against the tip blobs. Two read-only reviewer
seats re-derived the claim surfaces independently; their findings are folded in
and marked *(seat: …)*.

---

## 1. Step-1 conformance

| item | check | result |
|---|---|---|
| report committed by the lane identity | `git log --format='%an %H' -- .ufo/reports/round-68/kagi.md` ⇒ `kagi-shokunin kagi@shokunin.local cf4e3e1b…` | PASS |
| report is not a marker | sections Work performed / Landed changes / Before → after / Sources & frontier / Trend verdicts / SHONEN all present; cites real commits | PASS |
| `SHONEN` heading, one line per box | `grep -c '^## SHONEN'` ⇒ 1; `SHONEN.md` has 4 boxes, report carries 4 `[~]` lines, no `[x]` | PASS |
| cited lane commits exist and are ancestors | `merge-base --is-ancestor` for `23a8e02`, `4251519`, `7e78630`, `ef90e989`, `932a7359`, `89acdee5`, `cd9d66f1` against `master` | 7/7 PASS |
| lane repo clean, pushed | `jj-lane.sh state` ⇒ `ahead=0 behind=0 tracked=0 untracked=0`; `git status --porcelain` empty; `ls-remote` = `cd9d66f1` | PASS |
| report lands last | report commit `13:14:45`, last lane commit `13:14:38` | PASS |
| prompt carries the round contract | §1 mission/axes, §2 claims, §3 L2 floor ("at least 8 … ONE batched AgentSwarm call" = `MISSION.md` §L2 concurrency), §5 commit-then-push + push scope + L0 | PASS |
| prompt carries the five child-lane items | §4 report path/filename; §4+§6.4 commit-before-report; §4 `SHONEN` heading; §6.4 cite only `landed <hash>`; §6.3 lane write scope | 5/5 PASS |
| L2 route map vs `MISSION.md` bucket | §3 defers models to the host route table, no role pins in `shokunin.conf:51`; run-15 band 8–16 seats honoured (15 seats) | PASS |
| §8 pre-file ledger present | `.ufo/waves/round-68/claim-falsification.tsv`, 11 rows, all 5 fields, every artifact resolves | PASS |
| §8 gate line pasted into the report | `grep -n 'PREFILE' .ufo/reports/round-68/kagi.md` ⇒ no match | **DEFECT (conformance)** |

Conformance defects (status-neutral, named for the record):

1. **The §8 gate line and exit code are absent from the report.** §8 requires
   `Paste the PREFILE-FALSIFICATION: line and its exit code into the report`.
   See §3 below for the gate's own result.
2. **The report rewrote filed bytes twice without an erratum.** The report path
   was committed three times in one round (`227ec14f` 13:12:36 → `f2a3a92`
   13:14:28 → `cf4e3e1b` 13:14:45); the later commits edited prose in place
   ("Eight mistakes" → "Nine mistakes", the cited lane hash) rather than
   appending an erratum naming the superseded text (PROTOCOL, filed-report
   rule). Each version cited the lane tip of its moment and the final bytes cite
   `cd9d66f1`, so no stale hash ships.
3. **The report cites a receipt that does not exist.** Report line 106 cites
   `.ufo/waves/round-68/final/c1-base.txt`; `final/` holds only
   `c1-candidate.txt`, `c2-candidate.txt` (0 bytes) and
   `l1-derivation-recut-only.txt`. The BASE counter line actually lives at
   `.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt:19`
   (`C1_VERIFIED: verified=36 col15=31 caught=0/6 guard=0`). This is the QM96
   class the lane wrote itself in round 66 (a cited receipt must exist in the
   tree the report names).
4. **The round filed with a wave that never settled.** No `w1-results.json`
   exists anywhere (`.ufo/waves/round-68/`, fleet `.ufo/`), and seat
   `R68ExecCounterC2` filed no report and was still a live job at closure time
   (`proc://` ⇒ running 4h07m). The run-9/run-10 rule ("file only after
   WAVE-DONE and the `<wave>-results.json` handoff") was not met. The report
   discloses it, so the round shape is verifiable from `w1/swarm-registry.json`
   (15 seats: 5 executor, 2 scribe, 1 scout, 1 connector, 2 reviewer, 1 critic,
   1 mutation-tester, 1 revenger, 1 sentinel) rather than from settlement.
5. **Interview-level drift in the wave metadata.** `w1-spec.json`,
   `w1-dispatch.json` and `w1/swarm-registry.json` carry the pre-freeze
   milestone `C2_RECORD mismatches 3->0` and `verified 36->37 col15 31->32` in
   all 15 seats — achievement-shaped text written before any measurement (the
   landed readings are 38/33 and C2 has no reading at all).
6. **`corpus/knowledge/` gained no new entry and `corpus/README.md` gained no
   coverage-map/frontier row** for the round's ground (the README diff touches
   two index-count rows only). Relevant to the expansion trend (§6).

---

## 2. Claim re-check

Frozen predeclaration `.ufo/waves/round-68/claims.json` (`23a8e02`):
C1 `freshness`, target `verified=37 col15=32 caught=6/6 GUARD=1` (BASE
`verified=36 col15=31 caught=0/6`); C2 `calibration`, target
`mismatches=0 population=3 GUARD=1` (BASE `mismatches=3`). Neither claim is
declared exploratory.

### C1 — freshness — **verifies** (re-measured + evidence-verified)

My own plain measurement over committed bytes:

```
$ git show d3b2a4e:corpus/source-fetches.tsv > /tmp/base-fetches.tsv
$ awk -F'\t' 'NF==16{n++; if($16 ~ /^\.ufo\/waves\//){p++; if($15 ~ /^[0-9a-f]{64}$/)c++}
   else if($16 ~ /\.ufo\/waves\//)m++} END{print "rows="n,"pure="p+0,"col15="c+0,"mixed="m+0}' /tmp/base-fetches.tsv
rows=157 pure=36 col15=31 mixed=1          # TSV sha256 90dd4a2c… == the blob the receipts pin
$ awk -F'\t' 'NF==16 && $16 ~ /^\.ufo\/waves\//{n++; if($15 ~ /^[0-9a-f]{64}$/)c++} END{print "pure="n,"col15="c+0}' corpus/source-fetches.tsv
pure=38 col15=33
$ awk -F'\t' 'NF==16 && $16 ~ /^\.ufo\/waves\//{print $2}' corpus/source-fetches.tsv | sort | uniq -c
     31 mined
      7 rejected
```

So the report's BASE `36/31` and candidate `38/33` are the numbers a reader
re-derives; the frozen floor (≥37, ≥32) is met on the landed bytes.

Gate evidence, verified not executed:

- `.ufo/waves/round-68/final/c1-candidate.txt:19` ⇒
  `C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1`; line 2 derivation
  `path_rows=38 bound=38 located=38 prose=120 mixed=none total=158 malformed=0`;
  lines 5–11 guards (a)–(e) each `1`; line 18 `… defe defects=0`.
- Six legs, each naming the anchor `S167` and its frozen reason (lines 12–17):
  m1 `capture-whitespace`, m2 `capture-whitespace` (comma), m3 `crlf=1`
  (`SC_FETCH cr-in-tsv`, raw finding in
  `w1/R68Sentinel/receipts/landed-gate-battery.txt:58–61`), m4
  `capture-digest-mismatch`, m5 `normalized-digest-mismatch`, m6
  `capture-bytes-mismatch` + `capture-digest-mismatch`.
- Revision pinning: gate `690b0c2e…` and counter `d353cf36…` are the tip blobs
  (`sha256sum corpus/sources-census.sh plans/round-68-c1.sh`;
  `w1/R68Reviewer/receipts/final-instruments.txt:1`,
  `w1/R68ScribeLesson/instruments-pinned.txt:11,37`), and the late lane run
  `w1/R68ScribeLesson/c1-lane-run.txt` reproduces the same line with `RC=0`.
  C1 is therefore measured on the landed instrument bytes, not a pre-fix tree.
- Gate selftest `SOURCES_CENSUS_SELFTEST: PASS (98 cases)` is a committed
  receipt (`w1/R68Revenger/receipts/selftest-690b.txt:99` under the 690b0c2e
  pin), and BASE is 89 (`base/selftest.txt:90`).
- BASE blindness: both readings are in the record. `final/c1-candidate.txt`
  counter anchor `S167` reads `caught=0/6`; the Sentinel's frozen-rule anchor
  `S156` reads `BASE caught = 2/6` (`w1/R68Sentinel/receipts/base-legs.txt:19`,
  M4/M6 already caught at BASE). The report states the split (M68-2).

Claim-level caveats (routed, none of them fatal to the number):

- `plans/round-68-c1.sh:753` `predicate_ok()` tests only `guard==1 and caught==6
  and defects==0`; the frozen kill rules' population floor (`verified < 37`,
  `col15 < 32`) is **not** compared, and the selftest has no sub-floor case
  *(seat: VerifyC1Evidence, HIGH)*. On these bytes the floor is met by my
  independent count, so the claim's measured content is unaffected — the
  instrument could go green on a sub-floor tree next time.
- `verified=38` includes 7 rows whose status is `rejected` (S132, S133, S134,
  S138, S142, S144, S156); the claim's sentence says "every **mined** row".
  The instrument is a superset of the sentence (safe direction), but the drift
  is stated nowhere. `claims.json` was never repinned to A1's 38/33: a reader
  who takes `claims.json` literally sees a miss where A1.2 records a landing.
- the guard summary has a stray literal token (`… e=1 defe defects=0`), present
  in the counter source and therefore in every C1 receipt — cosmetic, source-
  consistent, not tampering.

### C2 — calibration — **does not verify** (`unprovable`)

The aggregate line was never produced on the landed bytes, and no committed
receipt claims it:

- `w1/R68ScribeLesson/c2-lane-run.txt:6` ⇒ `# (no C2_RECORD line; the process
  was killed at the budget)`; `w1/R68ExecCounterC2/c2-candidate.txt` is one
  provenance line; `.ufo/waves/round-68/final/c2-candidate.txt` is **0 bytes**.
- The only aggregate line from a real run is
  `w1/R68ExecCounterC2/c2-run.txt:6` ⇒ `C2_RECORD: mismatches=3 population=3
  guard=0` (`RC:1`, `RC:124`), on pre-fix bytes.
- Every other `mismatches=0` string under `.ufo/waves/round-68/` is a target,
  a selftest fixture, a rogue-stub probe, or script source
  *(seat: VerifyC2Surfaces, exhaustive grep)*.

What did land, re-derived by me:

- L1: `R21-03` now expects `^SOURCES_CENSUS_SELFTEST: PASS \(98 cases\)$`
  (`corpus/claim-ledger.tsv:53`) with the committed 88 → 98 journal pair
  (`.ufo/waves/round-68/journals/expectation-migrations.json`); the observed
  count is 98 under the pinned gate. **Landed.**
- L3: `claim-ledger.sh cells` returns a verdict on the historical planned
  heading where BASE dies — BASE
  `claim-ledger: unrecognised round heading … '## Round 63 — planned'`
  (`w1/R68ScribeLesson/cells-base.out:186`, exit 2) vs landed
  `CELL_AUDIT: POLICY (cells=576 row_pointed=286 stamp_pointed=247 policy=3)`
  exit 2 (`w1/R68ExecLedger/L3-cells-after.txt:246–247`; a second run reads
  `stamp_pointed=250`). **Landed.**
- L2: `R68-01`/`R68-02` exist; `R68-01`'s expectation is produced. `R68-02`'s
  expectation is the C2 counter's own line, the counter treats its own
  invocation as the row's execution (`plans/round-68-c2.sh:431-434,456-464`),
  and no receipt shows `claim-ledger.sh verify` running the row — the only
  `verify` receipt dies earlier (`candidate-verify.txt:37-38`, `RC=2`). So
  "the rows exist and execute" holds for `R68-01` and is self-referential for
  `R68-02`; shipped as a ledger row, `R68-02` is a guaranteed miss on every
  full `verify` run.

Verdict: `unprovable`. The report says exactly this ("C2 — calibration — honest
stop (not met at the final bytes) … C2's verdict is `unprovable` this round"),
which is the honest record; the defect is that the rest of the round's record
surfaces were never brought into line with it (§4).

---

## 3. Pre-file falsification ledger (Amendment 59)

```
$ python3 /home/vgpnk/Projects/shokunin/scripts/hyaku/prefile-falsification.py --lane kagi --round 68
FINDING wave-missing /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-68/w1-results.json
PREFILE-FALSIFICATION: SETUP findings=1
EXIT=2
```

Exit 2 is `setup (a surface is missing)`, not a row failure: the wave never
wrote `w1-results.json` (§1.4), so the gate cannot read attack seats from the
settlement file. The ledger itself is present, covers both claims in
`claims.json`, and every row's artifact resolves:

```
$ awk -F'\t' '{print NF}' .ufo/waves/round-68/claim-falsification.tsv | sort -u   # 5
$ # 11 rows, every artifact path exists
```

| claim | rows | attack-role artifacts |
|---|---|---|
| C1 | 8 | R68ReviewerLayers, R68ScribeEntry, R68Sentinel ×2, R68Reviewer, R68Revenger, R68MutGate (mutation-tester), R68ScoutSource |
| C2 | 3 | R68Critic, R68ExecLedger, R68Connector |

Every attack-role seat in the wave appears (reviewer ×2, critic,
mutation-tester, sentinel, connector, revenger; the wave had no
security-reviewer and no labrat). All four `falsifies-wording` rows name a
narrowing pointer to `plans/round-68.md` (Amendment A1), which exists and is
committed at `4251519`.

Adjudication of the failing (wording) rows:

- **C1 / R68ReviewerLayers F0 — real, reconciled.** F0 measured the candidate
  as 38/33 against a frozen 37/32. A1.2 records 37/32 as the recut-only reading
  with its receipt (`.ufo/waves/round-68/final/l1-derivation-recut-only.txt` ⇒
  `CANDIDATE verified= 37 col15= 32`) and 38/33 as the candidate, before the
  counter existed. The amendment *widens the population the sentence already
  names*, so it is not a post-data narrowing to a weaker property.
- **C1 / R68ScribeEntry §4 — real, same resolution** (A1.1 anchor-derivation,
  A1.2 teeth). Agreed.
- **C1 / R68Sentinel F6 — real, reconciled by disclosure, not by repinning.**
  BASE blindness is anchor-dependent (0/6 counter anchor `S166`, 2/6 frozen
  anchor `S156`). M68-2 records both readings, but `claims.json`, A1.2 and
  `SCORECARD.md:2424` still print `caught=0/6` alone (§7.2).
- **C2 / R68Critic — real, and the round did *not* fully reconcile it.** The
  critic showed L1/L2 could be satisfied by a stub gate and row text; the
  landed counter executes the BASE-pinned gate bytes and adds a stub-gate
  replay. But the aggregate verdict the row protects still never ran on the
  final bytes, and `R68-02` remains a self-referential row. The row is honest;
  the claim is still unproven.

The gate could not be made to evaluate, so the "no failing row is automatic
rejection" question does not arise; the ledger's own content is sound, the
settlement surface is not.

---

## 4. Per-axis verdicts

| axis | verdict | evidence |
|---|---|---|
| freshness | **improved** | C1 verified: population 36 → 38 pure-path rows, col15 31 → 33, four defect classes now FAIL that BASE read `CLEAN` on (three committed BASE witnesses under `.ufo/waves/round-68/base/mut/` and the Sentinel's 6-leg battery), `defects=0` over the whole fetch population, `caught 0/6 → 6/6`, `guard 0 → 1`. Re-measured by me, not asserted. |
| calibration | **harmed** | The round's self-assessment surfaces assert results no committed receipt supports: `SCORECARD.md:2425` prints `C2_RECORD: mismatches=0 population=3 guard=1` `rc 0` while the report records the honest stop and its own evidence directory holds a 0-byte `final/c2-candidate.txt`; `SCORECARD.md:2426` says "QM97–QM99 enter the bar" while `git diff d3b2a4e..cd9d66f1 -- corpus/QUALITY.md` is empty and the highest criterion is QM96; `corpus/lessons/round-68.md:18` states "`C2_RECORD` mismatches 3 → 0"; `LOG.md:2221` prints `C1_VERIFIED_SELFTEST: PASS (59 cases)` where the receipt says 56 (`w1/R68ExecCounterC1/selftest.txt:13`) and `SCORECARD.md:2428` says 56; `base/base-derivation.md:33` quotes its own receipt as `caught=0/6` where the receipt reads `caught=6/6` (`base/c1-base-round67-counter.txt:21`). AXES calibration is exactly "SCORECARD entries match observed repo state". Same class, same lane, as round 66. |
| depth | unchanged | No claim; the entry `corpus/knowledge/source-capture-binding.md` is widened with measured content, but no QUALITY criterion was added (§6 discernment) and the score is 9 → 9. |
| coverage | unchanged | Registry 157 → 158 (S167, tier A, `mined`), one fetch row; axis 9 → 9, no claim. |
| operability | unchanged | The census gate gains four reason classes and 9 selftest cases (89 → 98) and two counters ship with selftests (56 / 7 cases); nothing schedules any gate, and the claim credit is on freshness. 9 → 9, no claim. |
| adjacency | unchanged | Connector swept 20 sibling lanes: several hold CRLF *tolerance* or their own digest recompute, kagi holds capture read-through — complements, nothing absorbed; the carried `ADJACENCY_SCOPE: DEFECT` breadth debt is named, not absorbed. |

C1's numbers stand; C2's do not; the record harm is not a claim of this round
and no axis is credited with it.

---

## 5. Discernment spot-check (LEARNING.md — checked from outside)

`corpus/lessons/round-68.md` `## Gate` carries **one** row written this round and
it is an **admit**. There is no round-68 reject row to sample, so the reject
side of the sample comes from the registry's curated rejections (the lane's
standing taste record); the absence of a reject row in two consecutive rounds
(67 and 68 both single-candidate) is itself recorded as a discernment-surface
gap.

| item | decision | re-opened source | agree/disagree | reason |
|---|---|---|---|---|
| S167 — RFC 4648 §3.3 (admit, tier A, `mined`, `180d`) | admit | `https://www.rfc-editor.org/rfc/rfc4648.txt` re-fetched live 2026-11-08 (curl, browser UA) ⇒ HTTP 200, 35491 B, sha256 `84e14418f795d503be5f34bf23ce4ebaa119e9ec7c9f667d8caeb111385b178f` = the committed `capture/S167.body` = the row's cell; quote (18 words, ≤25) locates exactly once after normalization (raw `grep` misses it because the RFC wraps it at lines 200–202 — the committed `rendered-text-v1` locate returns `count=1`) | **agree** | The source is authoritative for the scope, the capture and quote verify byte-exactly, and the M68-5 re-cut now grounds the strict rule on §3.3's default branch while naming the liberal branch and §12 and marking the transposition into a TSV cell as the lane's own. That is the correct tier-A use of a spec. |
| S150 — PIT mutators reference (rejected) | reject | `https://pitest.org/quickstart/mutators/` re-fetched live 2026-11-08 ⇒ HTTP 200, 67033 B, sha256 `a31331daf89f246f3e02c0da92578d4ad2163c53741c3700437e75b9a1602da2` = the row's cell; `grep -oi 'cannot be killed' \| wc -l` ⇒ 0; the row's quote locates once | **agree** (with a count caveat) | The rejection is right: the page carries operator design and filtering remarks but no definition with its consequence. Caveat: the row says "11 occurrences of 'equivalent mutations'"; 11 is the count of the token `equivalent` — the phrase `equivalent mutations` occurs 9 times. The verdict survives; the sweep wording should name the token it counted. |

Census (contract v1, run from the fleet root):

```
$ /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi
… 27 W04 duplicate-url warnings …
kagi	ok	/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md
EXIT=0
```

Plain census re-derivation at the tip: rows 158 (BASE 157), malformed rows 0,
duplicate ids none, tiers `A=141 B=2 C=15`, statuses `mined=138 queued=3
rejected=17` — matches the report's line.

---

## 6. Trend verdicts

- **expansion — unchanged.** (I disagree with the lane's `improved`.) The
  round admits S167 and cites it from `corpus/knowledge/source-capture-binding.md`,
  but no *new* `knowledge/` entry was admitted (`git diff --stat
  d3b2a4e..cd9d66f1` shows the entry modified, no new file under
  `corpus/knowledge/`), `corpus/README.md` gained no coverage-map or frontier
  row (its two changed lines are index counts), no capability row entered the
  SCORECARD table (the census-gate row was updated 89 → 98), and the frontier
  list is unchanged. Widening an existing entry is depth/quality work. Same
  reading the round-66 closure applied to the same shape.
- **quality — improved.** The census gate now reads S166's bytes for the first
  time (BASE read that row as prose and never opened the file), refuses four
  classes it read `CLEAN` on, and recomputes col 15; the entry is re-verified
  (`verified-at: 2026-11-08`, `recheck: 180d`) and deepened with commands for
  every number; no admitted entry failed its re-check; S167 and S166 both
  re-hash to their declared digests.
- **discernment — harmed.** The round mined nine classes (M68-1…M68-9) and each
  records that **no criterion** would have caught it — yet
  `git diff d3b2a4e..cd9d66f1 -- corpus/QUALITY.md` is empty, the bar still
  ends at QM96, and `SCORECARD.md:2426` states that QM97–QM99 entered it. The
  learning path's own mechanism (`LEARNING.md` §3: when no criterion caught a
  mistake, a `QUALITY.md` criterion citing the lesson) was not executed, and
  the record claims it was. The gate-decision half of the observable agreed
  (one admit, one curated reject, both mine), so the harm is specific: criteria
  not written + a false statement that they were.

---

## 7. Routed defects — kagi must fix in round 69

1. **`SCORECARD.md:2425` (C2 calibration row)** — replace the fabricated
   `C2_RECORD: mismatches=0 population=3 guard=1 rc 0` with the honest stop:
   no aggregate line was produced; cite `w1/R68ScribeLesson/c2-lane-run.txt`
   and mark the claim `unprovable` (the report already says so).
2. **`SCORECARD.md:2426` (depth row)** — delete "QM97–QM99 enter the bar", or
   land the criteria. `corpus/QUALITY.md` is unchanged this round.
3. **`corpus/lessons/round-68.md:18`** — the C2 bullet's "`C2_RECORD`
   mismatches 3 → 0" is superseded by the honest stop; correct by appended
   entry (append-only lesson rule) or in round 69's lesson naming the
   superseded text.
4. **`LOG.md:2221`** — `C1_VERIFIED_SELFTEST: PASS (59 cases)` contradicts the
   receipt (56) and `SCORECARD.md:2428` (56); the 59 is a mutant-era count.
5. **`.ufo/waves/round-68/base/base-derivation.md:33`** — quotes
   `c1-base-round67-counter.txt` as `caught=0/6`; the receipt line 21 reads
   `caught=6/6` and line 58 of the same file says 6/6.
6. **Report citation** — `.ufo/waves/round-68/final/c1-base.txt` does not
   exist; point at `w1/R68ExecCounterC1/base-run.txt`.
7. **`claims.json`** — still carries the pre-A1 target `37/32`; repin to the
   A1.2 reading or state in-file that A1 supersedes it, so a reader is not
   asked to choose between two "frozen" targets.
8. **`plans/round-68-c1.sh` predicate** — `predicate_ok()` ignores the frozen
   population floor (`verified >= 37`, `col15 >= 32`) and its selftest has no
   sub-floor case; add the comparison and the case (freeze amendment, not a
   silent edit).
9. **`corpus/claim-ledger.tsv` `R68-02`** — pins a line the counter never
   produced and treats its own invocation as the row's execution; either make
   `verify` execute it under a real budget or drop the row.
10. **`caught=0/6` BASE claim** — repin `claims.json`/A1.2/`SCORECARD.md:2424`
    to the receipt pair (0/6 counter anchor, 2/6 frozen anchor) as M68-2
    already states in prose.
11. **QUALITY bar** — land the nine M68 criteria (or the subset with teeth),
    each citing its lesson, per `LEARNING.md` §3.
12. **Wave settlement** — file after WAVE-DONE with `w1-results.json`, and
    keep achievement-shaped text (`C2_RECORD mismatches 3->0`,
    `verified 36->37`) out of dispatch/spec/registry metadata until measured.
13. **Expansion claim discipline** — a widening of an existing entry is
    quality/depth, not expansion; the trend verdict must follow
    `LEARNING.md`'s observable (a new admitted entry on uncovered ground with
    its coverage-map row).

---

## 8. Verification gaps (what this spot-check did not close)

- I ran no lane gate, counter or selftest (closure rule); the 56/7-case selftest
  tallies, the six legs and the `cells` runs are receipt-verified and
  instrument-hash-checked, not re-executed.
- I did not re-derive all 38 rows' raw sha/bytes/quote; I verified S167
  end-to-end and relied on the agreeing instruments (gate `CLEAN
  path_rows=38 bound=38 located=38`, counter `derived=… gate_fields=match`) for
  the population.
- The report's second aggregate ("seat's second run `mismatches=3`") and the
  `rc=124 at 3301 s` figure have no committed receipt (`unresolved`); the
  3600 s killed run and the pre-fix `mismatches=3` run do.
- Whether the 7 `rejected` rows belong in a "mined row" population is decided
  by the plan's operational sentence (status-blind) against its title
  (`unresolved`, routed as item 8/11); it never makes the number a false green.

---

## 9. Verdict

- **status: ok** (a real, committed, evidence-rich round; not a marker).
- **admitted: false** — C2 does not verify and the calibration axis is harmed.
- **verdict: `rejected-harmed`** — graded on the fleet convention that a
  harmed axis yields `rejected-harmed` (52 of 59 such entries; tabi r83/r87 for
  the same calibration case), with the lane's report itself honest about the
  C2 miss. Two axes regressed (calibration, discernment) against one that
  improved (freshness) and one that improved in content (quality): a trade,
  which is not an admission.
