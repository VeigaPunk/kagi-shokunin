# Round 66 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 66, attempt 1. Claim BASE
`d549ee6eb8770a49938b78f49cf79e36d9c1c2e8` (round-65 verifier spot-check tip,
`corpus/lessons/round-65-verifier-spotcheck.md`, commit `d549ee6`). This file
is the predeclaration: committed alone before any candidate work. The
candidate moves; this file does not.

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3; capabilities entered
rounds 57–64, so no stagnation waiver is claimed. All claims name distinct
axes (calibration, freshness, operability); each is verifiable without the
others landed.

Motivating evidence: the round-65 verifier spot-check §6 routed defects 2,
3, 5 (capture-filename vs registry id; CITATION_GATE/CLAIM_LEDGER not re-run;
claims.json pre-amendment wording) plus the round-65 lesson M65-4 (a capture
named after a draft id the registry later renumbered — the S148 → S143.body
drift). At least one claim works the lowest non-retired axis — all six tie
at 9; C1 works freshness (the carrier binding the S148 row depends on), which
is also the SOURCED claim.

Claim BASE population census (measured, not assumed): at BASE,
`awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ {n++} END{print
n+0}' corpus/SOURCES.md` ⇒ 155 (tier A=138 B=2 C=15; mined=135 queued=3
rejected=17; malformed 0; dup 0); `sources-census.sh validate --root
/home/vgpnk/Projects/shokunin kagi` ⇒ `kagi ok` rc 0. The frontier census
(before) is in `.ufo/waves/round-66/base/census-start.txt`. The inherited
leftover `.ufo/waves/round-65/base/c1-base-counter.txt` modification was
reverted to its committed blob before this plan was frozen (routed defect 4).

## C1 — freshness: the S148 carrier binds by digest on the registry row's own terms

Target axis: freshness (re-verification of a drifted carrier: the S148 BioC
deposit). The S148 row pins sha256 `3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40`
(264946 B) and counts `<passage>` 182 / `<text>` 180. The bytes carrying
that pin today live at `.ufo/waves/round-64/capture/S143.body` (draft id),
while the file named for S148 holds an unrelated arXiv body
(`fabc74c534e42232d4bbcd46a638a926b4c6250cd13113fbe5cc51c940ba9f15`,
39750 B). The S148 registry row and its `source-fetches.tsv` row bind the
pin by digest but name no capture path: a reader who follows the id finds
the wrong body. That is M65-4 (QM88) carried unbound.

**Frozen predicate (this sentence is the plan's, the counter's code and the
receipt's label):**

```
C1_CARRIER: drift = 1 iff `bash plans/round-66-c1.sh --tree <candidate>`
prints `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=G` and exits 0,
where: paths = 3 mutated copies of the candidate tree, each holding ONE
round-64 capture body (S143/S156/S157) at a wrong id; hex = 3 (each
mutated body's sha256 differs from the candidate body's sha256);
match = 1 iff every mutated copy's header-ID digest still resolves to
the candidate body (the digest binding refuses every wrong-id file);
guard = 1 iff (a) on the unmutated candidate tree the counter resolves
the S148 body's capture path by digest from the registry row and reads
`C1_CARRIER: drift=1` on all three anchors; (b) the counter's
`--selftest` exits 0; (c) the round-65 volatile-shape gate still reads
`VOLATILE_SHAPE: match=1` on the same candidate; (d) `SOURCES_CENSUS:
CLEAN` reads at round end.
Target drift=1 (BASE 0: the three round-64 capture files accept any
id — a path-only repoint of S148's carrier leaves every census reading
unchanged, and no lane gate reads the delta).
```

**Carrier repair (the candidate work this predicate serves):** on the
candidate tree, the S148 registry anchor (`anchor` cell), the S148
`source-fetches.tsv` row (16th column), and `corpus/volatile-shape.py`
`DEFAULT_CAPTURE` all name the committed capture
`.ufo/waves/round-64/capture/S143.body` whose sha256 equals the S148 pin.
The written anchor is the capture path; its sha256 is the byte proof. No
committed capture is renamed (QM88: a rename is not a repair that rewrites
a committed capture); the binding changes, not the filename. The row's
anchor cell is append-only in its current shape — a corrected anchor is
written as a new registry row superseding S148, and `source-fetches.tsv`
carries the new id's row; the S148 row text is preserved verbatim with its
old→new change logged in the round-66 lesson.

`Source: S###` cited: S148 (the carrier this claim binds — opened live
2026-11-08, HTTP 200, 264946 B, sha256 `3b8d4e15…cba40` — byte-identical to
the committed capture). The counter reads match=1 on the live body as
well as on the committed bytes.

**Commands:**
```
bash plans/round-66-c1.sh [--tree DIR] [--selftest]
```
Output line: `C1_CARRIER: drift=A paths=3 hex=3 match=1 guard=G`. Exit 0
iff guard=1 and drift=1; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: a copy tree byte-identical to BASE reads `drift=0` (the
  capture-path resolution is absent there); a tree that reads drift=1 at
  BASE voids the claim.
- K2: a path-only edit (carrier-path string repointed, no bytes changed)
  reads `drift=0 match=0` (the digest binding refuses the wrong-id file —
  the do-nothing control cannot reach the target).
- K3: each of the three mutated copies (S156/S157/S143 wrong-id bodies)
  prints a named digest-mismatch line, never a pass.
- K4: the round-65 volatile-shape gate's `VOLATILE_SHAPE: match=1` line on
  the candidate tree still prints (the carrier repair does not break the
  prior gate).

**Population census at BASE (measured):** the candidate tree holds three
round-64 capture bodies whose fetch-row sha matches the file's own sha
(`S143`, `S156`, `S157` — 30 of 30 cited capture files exist; the S148 fetch
row's 16th column names an anchor, not a capture path, so the cited-set
check passes vacuously for it). Measured against
`.ufo/waves/round-66/base/census-c1.md`.

**Named ceilings:** the digest binding proves the row reads the bytes it
pins; it does not prove the live endpoint still serves them (the counter
performs one live re-open with the group's browser user agent and reports
`live_status` — a 429 is `rate_limited=1`, never a verdict change). The
anchor textual form is human-checked by the counter's plain-text rule;
`anchor` semantics for `S###` are bounded by the census's own 11-column
shape check.

## C2 — operability: the pre-file claims file matches the frozen plan + amendments

Target axis: operability (a runnable artifact whose verdict is reachable —
here, the pre-file gate's input: `.ufo/waves/round-66/claims.json` must name
the claims exactly as `plans/round-66.md` freezes them, including any
Amendments recorded before their readings).

**Frozen predicate:**

```
C2_CLAIMS: exact = 1 iff `bash plans/round-66-c2.sh --tree <candidate>`
prints `C2_CLAIMS: exact=1 claims=3 titles=3 targets=3 guard=G` and
exits 0, where exact = 1 iff every (title, target) pair in
`.ufo/waves/round-66/claims.json` equals the corresponding frozen
heading in `plans/round-66.md` (as amended), axis-equal, and no extra
key exists.
Target exact=1 (BASE 0: the round-65 `claims.json` carries pre-amendment
titles — C2 says "the six round-64 receipts" which Amendment A2
superseded with the round-63 five-receipt population, and C3's target uses
`volatile=1` which Amendment A1 superseded; `exact=0` at BASE measured
over the round-65 claims.json against `plans/round-65.md`).
GUARD = 1 iff (a) the counter's `--selftest` exits 0; (b) a mutation
that swaps one title with a plan's stale wording reads `exact=0`
(the counter can fail); (c) the pre-file gate
`prefile-falsification.py --lane kagi --round 66` reads `PREFILE-…:
PASS` on the candidate tree including this round's claims.json (exit 0);
(d) `corpus/claims-declared.sh` reads `CLAIMS_DECLARED: CLEAN` on the
candidate (round 66's rows present, `claims=59` expected: 56 + 3).
```

**Commands:**
```
bash plans/round-66-c2.sh [--tree DIR] [--selftest]
```
Output line: `C2_CLAIMS: exact=1 claims=3 titles=3 targets=3 guard=G`.
Exit 0 iff guard=1 and exact=1; 1 otherwise; 2 SETUP.

**Kill rules:**
- K1: at BASE the counter reads `exact=0` (titles diverge: round-65
  claims.json vs plans/round-65.md + Amendments A1–A3); a tree that
  reads exact=1 at BASE voids the claim.
- K2: a mutation replacing one title with the stale wording reads
  `exact=0` with the claim id named.
- K3: a claims.json carrying an extra fourth claim reads `exact=0`
  (the counter is sensitive to population, not only to matches).
- K4: the pre-file gate exits 0 only with this round's claims.json
  present — missing claims.json is SETUP exit 2, never a pass.

**Population census at BASE (measured):** the round-65 `claims.json` holds
3 claims (`claims=3`), all diverging from the frozen plan's final
state (liberally: 2 of 3 titles stale). Measured at
`.ufo/waves/round-66/base/census-c2.md`.

**Named ceilings:** exact-match is a text identity, not a judgment that the
frozen wording is good; a reviewer can falsify the wording, not the match.
Population is bound; semantics are unbounded.

## C3 — calibration: the registry's self-reference literals resolve

Target axis: calibration (mismatch between the registry's written population
— rows whose anchor cells cite committed capture artifacts — and observed
tree state: today the S148 row's anchor cell cites no capture path at all,
so a reader who follows the row's id finds the wrong body).

**Frozen predicate:**

```
C3_SELFREF: resolved = 1 iff `bash plans/round-66-c3.sh --tree
<candidate>` prints `C3_SELFREF: resolved=1 checks=3 failures=0
guard=G` and exits 0, where checks = 3: the carrier-path stands are
under `.ufo/waves/round-64/capture/`; each registry anchor cell's
cited carrier path (where the row cites one) exists on the candidate
tree and its sha256 equals the row's pin; failures = 0.
Target resolved=1 (BASE 0: the S148 row's anchor cell names no carrier
path — the round-66 repair lands it, and the counter's registry scan
finds it; a do-nothing tree reads failures=1 at BASE).
GUARD = 1 iff (a) the counter's `--selftest` exits 0; (b) a tree holding
a round-64 capture (the arXiv body) at the carrier path reads
`failures>=1` (the counter can fail on a real mismatch, not only on a
missing path); (c) the counter reads the BASE census from the committed
tree and prints `rows=155` (population is bound, not assumed); (d)
`SOURCES_CENSUS: CLEAN` on the candidate and the census validate
command exits 0 at round end.
```

**Commands:**
```
bash plans/round-66-c3.sh [--tree DIR] [--selftest]
```
Output line: `C3_SELFREF: resolved=1 checks=3 failures=0 guard=G`. Exit 0
iff guard=1 and resolved=1; 1 otherwise; 2 SETUP.

**Kill rules:**
- K1: at BASE the counter reads `failures>=1` (the S148 row's anchor
  cell cites no carrier path); a tree that reads failures=0 at BASE
  voids the claim.
- K2: a tree holding the arXiv body at the carrier path reads
  `failures>=1` naming the digest mismatch.
- K3: `rows=155` is asserted from the committed tree at each run (a
  registry whose rows shrink is SETUP, never a pass).
- K4: `SOURCES_CENSUS: CLEAN` reads at the candidate.

**Population census at BASE (measured):** `grep -cF 'S143.body'
corpus/SOURCES.md` ⇒ 0 (no row cites a capture path); `grep -cF
'capture/S143.body' corpus/source-fetches.tsv` ⇒ 1 row (S143);
`.ufo/waves/round-64/capture/S143.body` sha256 equals the S148 pin.

**Named ceilings:** the counter binds carrier paths to the row's pin
digest; it does not judge whether an anchor's prose is the best citation
of its section. Rows that cite no path are legible as "uncited" only for
rows whose anchor names one; the S148 row is cited by the repair and
therefore must resolve.

## Frontier step

Candidate sources to open this round (≥1 admitted, ≥1 rejected, each with a
≤25-word located quote + access date + URL in the lesson's `## Gate`):

1. The BioC deposit re-opened on the current date (the C1 source; the
   carrier the claim binds — `mined` row already S148; a `supersedes S148
   —` row if the shape changed since the 2026-11-08 capture).
2. The ConText article eutils carrier (S155's URL; `recheck` refresh if
   the digest still matches S135's pin).
3. One mutation-testing / equivalent-mutant state-of-the-art page as the
   weak lead (the reject: a vendor blog or an unopened citation chain).

## Assimilation

`Assimilation: none` this round (no package adoption; the `merge/kagi/`
package stays unadopted until its collision check passes — recorded in the
report's Sources & frontier section, no penalty).

## considerthese

At most ONE still-unimplemented proposal per round. The latest file is
`considerthese/2026-10-26.md`; if its proposals are all already mined
(round 63 QM83/QM84 for proposal 3), no new proposal is mined this round —
recorded in the report.

## Wave

`kagi-r66-w1`, 14 seats v1 (band 8–16, policy
`.ufo/waves/round-66/w1-dispatch.json`, reports
`.ufo/waves/round-66/w1/`): 2 scout, 4 executor, 2 scribe, 1 reviewer,
1 critic, 2 mutation-tester, 1 connector, 1 sentinel. Attack share 4/14 =
28.57 % literal (reviewer, critic, mutation-tester ×2; no labrat seat
exists), 5/14 = 35.71 % counting the sentinel. The L1 holds the canonical
planner seat and is the sole integration owner and committer. Roles span
the host route table (checker/counter seats to `executor` where they
write or run code; prose drafting to `scribe`; attacks to
reviewer/critic/mutation-tester/connector/sentinel/scout).

## Scratch discipline

Every seat's scratch root is `$HYAKU_SCRATCH/kagi-r66/<seat-name>/` with
`HYAKU_SCRATCH=/fast/scratch/hyaku` (explicit `mkdir -p`, explicit
`TMPDIR=… --work …`). Seats delete their scratch on exit
(`trap 'rm -rf -- "$S"' EXIT`); receipts are copied into
`.ufo/waves/round-66/w1/` first. `/tmp` is for files under 50 MB only.
Counters MUST honour `TMPDIR` and accept a scratch argument (QM74).

## Bounds

- The counters are the verdicts; the BASE census is the L1's own
  measurement (`.ufo/waves/round-66/base/`, committed) and is re-derived
  by the committed counters.
- The live re-open is reported, never decisive: a 429 is `rate_limited=1`,
  never a verdict change (round-65 Amendment A1 precedent).
- A counter whose fixture tree-copy cost exceeds its budget reads SETUP,
  never a pass.

## Amendments

None at freeze. Amendments to this plan are recorded below before the
reading they govern, appended (never rewritten), with the measurement
that forced them — same rule as round-65.

## Amendment A1 — 2026-11-08, before any candidate reading (C1 restated: the undefined term goes)

Measured by the round's own attack seats before any candidate reading was
taken — `R66Reviewer` F1/F2 and `R66Critic` F1 — and by the L1:

```
grep -rn "header-ID\|header_id" plans/ corpus/   ⇒ only plans/round-66.md:53
bash corpus/sources-census.sh                    ⇒ SOURCES_CENSUS: FAILED (findings=4 rows=155)
git cat-file -e d549ee6:.ufo/waves/round-66/claims.json  ⇒ fatal: ... not in 'd549ee6'
```

§C1's "header-ID digest" names no mechanism that exists in this lane (no file
derives an id from a digest; the two real mechanisms are a path-keyed read plus
a pin comparison, and a row-identity digest over registry columns). A predicate
whose central term has no implementation surface is M65-3 frozen in. §C1's kill
rule K2 is also self-contradictory: the candidate repair is a *string* change
(the three anchors name the carrier path), so a rule that defines "a path-only
edit" as the failing control defines the candidate's own action as failure.

**Restated §C1 predicate (replaces the §C1 block; the repair is unchanged):**

```
C1_CARRIER: drift = 1 iff `bash plans/round-66-c1.sh --tree <candidate>`
prints `C1_CARRIER: drift=1 paths=3 hex=3 match=1 guard=G` and exits 0,
where the three anchors below resolve to ONE path P whose sha256 equals
the pin the registry row carries (path equality + digest match — the only
mechanism this lane has):
  registry  the capture path cited in the anchor cell of the registry row
            that carries the S148 pin and supersedes S148;
  fetches   the same path in that row's corpus/source-fetches.tsv 16th
            column, with columns 10/11 equal to the pin and its byte count;
  volatile  corpus/volatile-shape.py DEFAULT_CAPTURE.
drift = 1 iff all three resolve to P and P's sha256 == the pin.
paths = 3 mutated copies of the candidate tree, each holding ONE
round-64 capture body (S143/S156/S157) at a wrong id; hex = 3 iff each
mutated body's sha256 differs from P's; match = 1 iff every mutated copy
prints a named digest-mismatch line and no pass.
GUARD = 1 iff (a) on a byte-identical BASE tree the counter reads
`drift=0` (measured on a `git archive d549ee6` extraction, receipt
committed — never SETUP); (b) `--selftest` exits 0; (c) the round-65
volatile-shape gate still reads `VOLATILE_SHAPE: match=1` on the
candidate; (d) a copy whose registry anchor cites the wrong-path file
(.ufo/waves/round-64/capture/S148.body, sha fabc74c5…) reads
`drift=0` with `digest-mismatch:` naming that path.
Target drift=1 (BASE 0, measured by the guard-(a) receipt).
```

Dropped from §C1's guard: the `SOURCES_CENSUS: CLEAN` leg. It is not
separable from C3 (that leg is red at BASE and its repair is C3's claim).

## Amendment A2 — 2026-11-08, before any candidate reading (C2 re-frozen: a target no work reaches)

Measured before any candidate reading: §C2's `C2_CLAIMS: exact=1` reads **1 on
the untouched working tree** — the round's `claims.json` already carries the
frozen headings and targets, so writing it *is* the only work and a do-nothing
control reaches the target. That is the M65-1 vacuity class, and it was written
into this plan by the L1. Its guard legs (c)/(d) are also unsatisfiable at the
moment of grading: the pre-file gate reads `SETUP findings=3` until the report
exists, and `claims-declared.sh` reads `CLEAN (claims=56)` until round-66's
rows land (measured: `c2-claims: guard-c prefile=0 rc=2`, `guard-d
claims-declared=0 rc=0 claims=56`).

**Restated §C2 predicate (replaces the §C2 block):**

```
C2_PREFILE: gate = 1 iff
`python3 /home/vgpnk/Projects/shokunin/scripts/hyaku/prefile-falsification.py
 --lane kagi --round 66` prints
`PREFILE-FALSIFICATION: PASS claims=3 rows=R attack_seats=K findings=0`
(exit 0, R >= 3, K >= 1) on the candidate tree,
AND `bash corpus/claims-declared.sh --root .` prints
`CLAIMS_DECLARED: CLEAN (claims=59)` (exit 0).
Target gate=1 (BASE 0: at BASE the round-66 wave dir has no
claim-falsification.tsv and no report — the pre-file gate reads
`PREFILE-FALSIFICATION: SETUP findings>=2`, measured).
GUARD = 1 iff (a) the pre-file gate's own `--selftest` prints
`PREFILE-FALSIFICATION-SELFTEST: PASS`; (b) a ledger with one claim's rows
removed reads `FINDING claim-uncovered` and exit 1; (c) a ledger that
omits one attack seat's artifact reads `FINDING attack-seat-unread` and
exit 1; (d) `claims-declared.sh` on a tree missing round-66's rows reads
`MISMATCH` (the gate can fail).
```

This is the round-65 spot-check's routed defects 3 and 5 closed as a measured
target: the ledger's attack-seat rows can only exist if the wave ran and the
L1 reconciled its receipts.

## Amendment A3 — 2026-11-08, before any candidate reading (C3 re-frozen on the lane's own gate)

§C3 as frozen asked a counter to bind *registry anchors* to capture paths and
hard-coded `checks=3` over a population the reviewer measured at 21+ citation
rows (`R66Reviewer` F7), and it contradicted itself about `rows=155` once C1
adds a row. Withdrawn in that form — a hard-coded sample presented as a census
is the calibration defect this lane exists to kill.

**Restated §C3 predicate (replaces the §C3 block):**

```
C3_CENSUS: findings = the count printed by the LANE's own gate
`bash corpus/sources-census.sh` (corpus/sources-census.sh, not the fleet
wrapper at scripts/sources-census.sh) in its
`SOURCES_CENSUS: FAILED (findings=N rows=M)` / `CLEAN (...)` verdict line.
Target findings=0 (BASE 4, measured: SC_FETCH S155/S156 missing-provenance;
SC_BODY_CITE claim-instrument-class-matrix.md S148/S156 unrecorded).
GUARD = 1 iff (a) the lane gate exits 0 with the verdict line present
(this lane's gate has historically exited 0 on FAILED — the line is the
verdict, not the exit code; the counter reads the line);
(b) on a copy with the `cites:` line removed the counter reads
findings>=1 (the repair is what turns it green, not a loosened gate);
(c) `rows=` is read from the gate's own line, never hard-coded;
(d) the fleet wrapper `scripts/sources-census.sh validate --root
/home/vgpnk/Projects/shokunin kagi` also prints `kagi ok` — the round
states which gate it means, closing the round-65 self-description defect
where "census ok" was the fleet wrapper while the lane gate was red.
```

The reparability of the four findings is a fact of the tree (two claims.json-
style provenance rows and two `cites:`/`used-by` declarations), not new scope.

## Amendment A4 — 2026-11-08, before any candidate reading (three corrections a wave seat measured)

Measured by `R66ScoutPreState` before the candidate reading:

1. **A2's token is wrong.** `scripts/hyaku/prefile-falsification.py:231` emits
   `PREFILE-FALSIFICATION: pass …` (lowercase) on a clean ledger and `FAIL`
   otherwise. A2 wrote `PASS`. Read A2's literal as `pass`; the counter matches
   case-insensitively and prints the tool's own line verbatim in its receipt.
2. **A2's `claims=59` needs both surfaces.** Measured on tree copies: the three
   `corpus/claims-declared.tsv` rows alone read `CLAIMS_DECLARED: MISMATCH
   (claims=59 mismatch=3)`, each `section-missing`; rows plus a
   `## Round 66 — post-move` SCORECARD section read `CLEAN (claims=59)`. Both
   land in the same commit.
3. **§C3's population-census paragraph is superseded.** Its command
   (`grep -cF 'capture/S143.body' corpus/source-fetches.tsv` ⇒ 1) hits the
   round-63 body (`8522a79e…`, the S143 pin), not the round-64 body that
   carries the S148 pin (`3b8d4e15…`), which no fetch row cited before this
   round. A basename grep is not a binding; A3's lane-gate `findings=` line is
   the C3 measurement and this paragraph is history.

Also recorded, not corrected: `corpus/source-fetches.tsv`'s round-64 family of
rows carries anchor prose in column 16 (the round-64 seat's ledger proposed
capture paths; the rows landed as prose). S164's column 16 names a capture path
deliberately and visibly — that is C1's second anchor, and the row's own
`anchor` cell names the same path. The departure is the claim, not an accident.
