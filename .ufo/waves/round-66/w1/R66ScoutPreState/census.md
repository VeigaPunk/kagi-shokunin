# R66ScoutPreState — pre-state census receipt (round 66, kagi)

Seat: R66ScoutPreState (scout; axes operability, calibration).
Claim BASE `d549ee6eb8770a49938b78f49cf79e36d9c1c2e8` (round-65 verifier
spot-check tip). Frozen plan `plans/round-66.md` (landed `ddcd46bb`).
Read-only on lane source; scratch `/fast/scratch/hyaku/kagi-r66/R66ScoutPreState`
(deleted on exit). Every command below is reproducible from the BASE tree
(`git archive d549ee6` extracted to scratch) or from the lane tree, whose
`corpus/` is byte-identical to BASE (verified, §A0).

## A0 — lane corpus is byte-identical to BASE
worktree  d443890a0c15ce785acae23ff43c52312baf7c205fdf5e3be9d7b8bc9e0ef48a  corpus/SOURCES.md
worktree  5cb3a15a0f8faf7a55b86d1b8d1ef9a0266d72add9d136ce32229d39f5c023b6  corpus/source-fetches.tsv
worktree  48fd3e2753bbab58f84f48021910f0577790bb30a1a25890a4b5fd70fcaf3b4a  corpus/volatile-shape.py
BASE      d443890a0c15ce785acae23ff43c52312baf7c205fdf5e3be9d7b8bc9e0ef48a  corpus/SOURCES.md
BASE      5cb3a15a0f8faf7a55b86d1b8d1ef9a0266d72add9d136ce32229d39f5c023b6  corpus/source-fetches.tsv
BASE      48fd3e2753bbab58f84f48021910f0577790bb30a1a25890a4b5fd70fcaf3b4a  corpus/volatile-shape.py

### A. registry census at BASE (git archive d549ee6), awk per plan
rows=155
    138 | A |
      2 | B |
     15 | C |
    135 | mined |
      3 | queued |
     17 | rejected |
malformed(NF!=13): 0
dup_ids: 0

### B. fleet sources-census validate --root <fleet> kagi
rc=0
kagi	ok	/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md
W04_warnings=24

### C. lane corpus/sources-census.sh (emits SOURCES_CENSUS:)

### D. inherited leftover verdict — .ufo/waves/round-65/base/c1-base-counter.txt
git status --porcelain (path): []  (empty = no working-tree modification)
worktree sha256: 450e5462d6bea6ea04c6269cec6e5cfd596f7da6f35428effee3ac59dab6b1e9
BASE    sha256: 450e5462d6bea6ea04c6269cec6e5cfd596f7da6f35428effee3ac59dab6b1e9
blob id at 3248c15 == d549ee6: 3112a45ab404f7b68619ccbba27991161523056d == 3112a45ab404f7b68619ccbba27991161523056d
bytes worktree=484  committed=484
lines=9
last line: C1_MATRIX: matrix=5 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)
VERDICT: reverted-to-committed-blob = TRUE

### E. S148 carrier defect — round-64 capture bodies vs fetch pins
round-64/capture/S148.body  sha=fabc74c534e42232d4bbcd46a638a926b4c6250cd13113fbe5cc51c940ba9f15  bytes=39750
round-64/capture/S143.body  sha=3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40  bytes=264946
S148 fetch row col10 pin    = 3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40
S148 registry anchor pin    = 3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40
volatile-shape.py PIN_SHA   = 3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40
DEFAULT_CAPTURE             = .ufo/waves/round-64/capture/S143.body
--- which registry row owns the round-64 S148.body bytes? ---
  owner row: S152  (registry: rejected...)
  S148.body body head: <!DOCTYPE html><html lang="en"><head><script>document.documentElement.classList.add('js');</script>  <title>[1909.02196]
  => the file NAMED S148 holds the arXiv QAOA body (row S152), NOT the BioC deposit.
  => the S148 pin 3b8d4e15 lives at .ufo/waves/round-64/capture/S143.body (264946 B).

---

## F. ROOT CAUSE of the S148 carrier defect — the round-64 capture names are DRAFT HANDLES, not registry ids

The plan reads the defect as a single-row anomaly (S148's file is misnamed).
Measurement shows it is a **systematic offset across the whole round-64 capture
set**: the round-64 seat numbered its captures by its own handle, and the L1
renumbered the registry ids before commit. `.ufo/waves/round-64/capture/notes.md`
says so explicitly ("**Capture handle ≠ registry id** ... the L1 owns the ids
and may renumber"), and its proposal table maps handle -> proposed id.

Measured by digest (each capture file's own sha256 vs the fetch row whose
col10 pin equals it):

| round-64 capture handle | own sha256 (10) | owning registry row | notes.md proposed id | agree? |
|---|---|---|---|---|
| S143 | 3b8d4e159a | S148 | S148 | yes |
| S145 | a31331daf8 | S150 | S150 | yes |
| S146 | 185130082d | S129 | (re-open of S129, no new row) | n/a |
| S147 | b0c7e0505c | S128 | (re-open of S128, no new row) | n/a |
| S148 | fabc74c534 | S152 | S152 | yes |
| S149 | 4b5a837439 | S149 | S149 | yes (only self-consistent handle) |
| S150 | f996c36df1 | S154 | S154 | yes |
| S151 | 0008280532 | S147 | S147 | yes |
| S152 | 6e6bffb065 | none | S155 | orphan |
| S153 | 63b7bfca87 | S146 | S146 | yes |
| S154 | 066f44388d | S145 | S145 | yes |
| S155 | 2381b66ba0 | none | — | orphan |
| S156 | ccf6ac493d | S151 | S151 | yes |
| S157 | 49dd5ac486 | S153 | S153 | yes |
| S158-S163 | (6 distinct) | none | S156-S160 | orphan |

- 10 of the 16 handles that carry a landed row agree exactly with notes.md's
  proposal table; 6 handles are orphans (their proposed ids S155-S160 were
  renumbered past by the L1 and never landed as rows).
- **Only `S149.body` carries its own id's bytes.** Every other round-64 capture
  file is off by the seat's handle offset.
- Consequence for C1: the plan's "three round-64 capture bodies whose fetch-row
  sha matches the file's own sha (S143, S156, S157)" is true as stated only for
  the *digest* match, and the plan's own census file
  `.ufo/waves/round-66/base/census-c1.md` says the same. But **none of the three
  is bound by its own id**: S143.body's bytes are S148's, S156.body's are S151's,
  S157.body's are S153's. A counter that resolves the carrier "by the row's id"
  rather than "by the digest the row pins" therefore reads the wrong body for
  all three. The digest binding is the *only* correct resolution path, and the
  plan's carrier repair (name `.ufo/waves/round-64/capture/S143.body`) is
  consistent with it.

## G. Where the S148 pin is (and is not) cited at BASE

| surface | value at BASE | cites a round-64 path? |
|---|---|---|
| `corpus/SOURCES.md` S148 anchor cell (col 6) | `§3.1.2 …` + sha256 `3b8d4e15…cba40` (264946 B) — pin only, **no path** | no |
| `corpus/source-fetches.tsv` S148 row col 16 | `§3.1.2 Trigger Terms, … (BioC XML body)` — anchor prose, **no path** | no |
| `corpus/volatile-shape.py` `DEFAULT_CAPTURE` | `.ufo/waves/round-64/capture/S143.body` | yes |
| `corpus/source-fetches.tsv` col16 paths that ARE round-64 | **0 rows** | — |
| `corpus/SOURCES.md` anchor cells citing a round-64 capture | **0 rows** | — |

The plan's §C1 population census says "`grep -cF 'capture/S143.body'
corpus/source-fetches.tsv` ⇒ 1 row (S143)". Measured: the single hit is
`S143 … .ufo/waves/round-63/capture/S143.body` — the **round-63** file
(sha `8522a79e…`, 264946 B), whose sha is the *S143* pin, not the S148 pin.
The round-64 file that actually carries the S148 pin is cited by **no** row of
`source-fetches.tsv` and by **no** registry row. The grep hit is a same-basename
coincidence across rounds; a counter that greps by basename can bind the
round-63 body and miss the pin.

## H. The L1 rewrote ALL TEN round-64 fetch rows' col 16 from a path to anchor prose

`.ufo/waves/round-64/build/R64ScribeRecords/sources-block.md` (the seat's
proposed fetch rows) gives col 16 = a capture path for every round-64 row, e.g.
S148 -> `.ufo/waves/round-64/capture/S143.body`. The landed
`corpus/source-fetches.tsv` gives col 16 = anchor prose for all ten
(S148 -> `§3.1.2 Trigger Terms, …`). So the anchor-vs-path shape is the L1's
landing choice, applied uniformly to the round-64 family — not a defect unique
to S148. Any C3 counter that expects col 16 to be a path for S148 must also
expect it to be prose for S145-S154.

## I. Population census the C1/C3 predicates rest on — measured

- `corpus/SOURCES.md` rows citing **any** capture path in the anchor cell:
  21 distinct rows, 22 (row,path) citations.
  By family: round-56:1, 57:3, 58:4, 59:2, 60:2, 61:3, 62:7 — and
  **round-64: 0**.
- `corpus/source-fetches.tsv` col 16 citing a capture path: 30 `.body` rows
  (30 unique paths) + 3 non-body (`S100/S101/S102` `.raw`) + 1 non-capture
  (`S099` -> a prompt file). 34 rows carry a `.ufo/` col-16 cell.
  By family: round-45:3, 55:2, 57:3, 58:3, 59:2, 60:2, 61:3, 62:7, 63:9 —
  and **round-64: 0**.
- All 30 cited `.body` paths exist; every one's sha256 equals its row's col10
  pin and its byte count equals col 11. The 30-of-30 cited-set check the plan
  cites is TRUE at BASE, and it is true *without* the round-64 family
  participating at all.

## J. Two anchor-cell citations already FAIL a strict "cited path sha == row pin" rule at BASE

Applying "every capture path named in an anchor cell must digest to that row's
pin" to all 22 registry anchor citations:

| row | cited path | measured sha | row pin | anchor cell carries that sha? |
|---|---|---|---|---|
| S113 | `.ufo/waves/round-56/capture/rejections/S113-default-ua.body` | `ce3cb7f2eb0e…` | `d8dfe35408b1…` | yes (it is the 403-rejection receipt, dual-attested) |
| S121 | `.ufo/waves/round-58/capture/S121.body` | `37e706c2b204…` | `d8879a2a4d78…` | **no** (the anchor cell names the round-59 file as the source and the round-58 file as "the rejected token-CLI page and not this source") |

So a C3 counter whose "each registry anchor cell's cited carrier path exists
and its sha256 equals the row's pin" is read over the whole registry reads
**failures >= 2 at BASE regardless of the S148 repair** — the target
`failures=0` is unreachable unless the counter scopes to the round-64 family
(as R66ExecC3SelfRef's counter does) or distinguishes the cited-source path
from a co-cited rejection receipt. `R66Reviewer` F7 names the S121 half.

## K. Lane census gate reads FAILED at BASE — both C1 guard (d) and C3 guard (d) key on `SOURCES_CENSUS: CLEAN`

`bash corpus/sources-census.sh` (the lane script that emits the
`SOURCES_CENSUS:` token the plan's guards require) at BASE:

```
FINDING SC_FETCH id=S156 missing-provenance
FINDING SC_FETCH id=S155 missing-provenance
FINDING SC_BODY_CITE entry=corpus/knowledge/claim-instrument-class-matrix.md id=S148 unrecorded
FINDING SC_BODY_CITE entry=corpus/knowledge/claim-instrument-class-matrix.md id=S156 unrecorded
SOURCES_CENSUS: FAILED (findings=4 rows=155)   exit 1
```

Root cause, measured: round 65 landed S155/S156 registry rows but **no
`source-fetches.tsv` rows for them** (the round-65 commit `8abab0f` touches
`corpus/SOURCES.md` but not `corpus/source-fetches.tsv`; the lesson's claim
"`corpus/source-fetches.tsv` gains the two captures" is **not** true of the
committed tree — `grep -c '^S15[56]' corpus/source-fetches.tsv` = 0). The two
SC_BODY_CITE findings are the mirror image: the knowledge entry
`corpus/knowledge/claim-instrument-class-matrix.md` names S148 and S156 in its
**body** but records neither on its `source:`/`cites:` line (it names only
S155), so the round-55 SC_BODY_CITE rule fires.

Both C1 guard (d) and C3 guard (d) are written against the `SOURCES_CENSUS:
CLEAN` token, so the guard cannot read 1 on the current tree. This is
round-65 debt carried in (the round-65 spot-check §2 item (c) already recorded
"CITATION_GATE/CLAIM_LEDGER not re-run" as named debt), not a round-66 defect —
but it is a **hard precondition** on both claims' guard=1 and it is not in the
plan's population census.

## L. Live re-open of the carrier (reported, never decisive)

`curl -A <browser UA> --compressed https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode`
on 2026-11-08 => **HTTP 200**, 264946 B decoded, sha256
`3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40` — byte-identical
to the committed round-64 capture and to the S148 pin; `<passage>` 182,
`<text>` 180. `live_status=200`, `rate_limited=0` at this moment.
(This does not reverse round 65's S156 rejection, which priced *grounding* on
the live carrier, not content.)

## M. C2 pre-state — claims.json vs the frozen plan

- `.ufo/waves/round-66/claims.json` (untracked, present in the working tree)
  already carries the round-66 titles/targets:
  C1 "C1_CARRIER: the S148 carrier binds by digest on the registry row's own terms";
  C2 "C2_CLAIMS: the pre-file claims file matches the frozen plan + amendments";
  C3 "C3_SELFREF: the registry's self-reference literals resolve".
  The **frozen plan's** headings are `## C1 — freshness: …`,
  `## C2 — operability: …`, `## C3 — calibration: …`, and the plan's frozen
  predicate lines are `C1_CARRIER: …`, `C2_CLAIMS: …`, `C3_SELFREF: …`.
  The claims.json titles use the **predicate** labels, not the heading axes, so
  any counter that compares claims.json titles against the heading text
  verbatim reads a mismatch; one that compares against the predicate labels
  reads a match. The plan does not say which surface is authoritative — the
  C2 executor's counter chose the predicate-label derivation and documents it.
- `corpus/claims-declared.tsv` at BASE has 56 data rows and **no round-66
  rows**; `SCORECARD.md` has **no `## Round 66 — post-move` section**.
  `bash corpus/claims-declared.sh` at BASE reads `CLAIMS_DECLARED: CLEAN
  (claims=56)` — clean *because* round 66 is absent. Simulated on a tree copy:
  adding the 3 round-66 manifest rows alone reads
  `MISMATCH 66 C1 section-missing` (×3) and `CLAIMS_DECLARED: MISMATCH
  (claims=59 mismatch=3)`; adding the manifest rows **and** a
  `## Round 66 — post-move` SCORECARD section reads
  `CLAIMS_DECLARED: CLEAN (claims=59)` exit 0. So the plan's expected
  `claims=59` is reachable, but **only with both surfaces**, and the manifest
  rows alone are a MISMATCH, not a CLEAN. (`R66Reviewer` F6 reaches the same
  56->59 arithmetic from the other side.)
- `python3 scripts/hyaku/prefile-falsification.py --lane kagi --round 66` reads
  `PREFILE-FALSIFICATION: SETUP findings=3` (exit 2) at present: wave-missing
  (`kagi-r66-w1-results.json`), ledger-missing
  (`.ufo/waves/round-66/claim-falsification.tsv`), report-missing
  (`/home/vgpnk/Projects/shokunin/.ufo/reports/round-66/kagi.md`). The script
  returns **2** for SETUP and only prints `PREFILE-FALSIFICATION: pass` when
  all four inputs exist and no rule fails — the plan's C2 guard (c) requires
  that `pass` token, so it is currently unreachable by construction
  (`R66Reviewer` F5 names the same).

---

## N. RECONCILIATION — the L1 amended the plan (A1–A3) concurrently with this seat's census

Observed at 06:3x: `plans/round-66.md` is modified in the working tree
(`git status` ⇒ ` M plans/round-66.md`, 119 added lines) with three appended
amendments, all dated 2026-11-08 and stated as "before any candidate reading".
This seat read the **committed** freeze (`ddcd46bb`) and measured BASE
`d549ee6`; the amendments are appended, not rewriting (round-65 precedent).
My measurements were taken against the frozen text and are unchanged by them;
this section records where they corroborate or sharpen the amendments.

**Corroborated by my measurements (independently re-derived):**

- **A1** cites `bash corpus/sources-census.sh` ⇒ `SOURCES_CENSUS: FAILED
  (findings=4 rows=155)`. My §C/§K measured exactly that at the BASE tree and
  at the live tree, with the same four finding ids (SC_FETCH S155/S156
  missing-provenance; SC_BODY_CITE claim-instrument-class-matrix.md S148/S156
  unrecorded). A3 re-freezes C3 on this gate with "BASE 4, measured" — my
  census independently reproduces the 4.
- **A1** cites `git cat-file -e d549ee6:.ufo/waves/round-66/claims.json` ⇒
  absent. Confirmed: the round-66 wave dir does not exist at BASE (my §BASE
  tree listing shows waves round-22…round-65 only).
- **A2** cites `claims-declared.sh` ⇒ `CLEAN (claims=56)` until round-66's
  rows land, and `guard-c prefile=0 rc=2`. Confirmed exactly (§M): the gate
  reads `CLAIMS_DECLARED: CLEAN (claims=56)` at BASE (clean *because* round 66
  is absent), and `prefile-falsification.py` returns **2** on SETUP.
  My §M additionally measures the **ordering hazard** A2 does not name: the
  3 round-66 manifest rows **alone** read `MISMATCH 66 C1 section-missing`
  (×3) ⇒ `CLAIMS_DECLARED: MISMATCH (claims=59 mismatch=3)`, exit 1. Only
  manifest rows **plus** a `## Round 66 — post-move` SCORECARD section read
  `CLEAN (claims=59)` exit 0. The L1's landing order must add both surfaces
  together, or the A2 target's second conjunct is a MISMATCH, not a CLEAN.
- **A2** says the round-66 `claims.json` "already carries the frozen headings
  and targets", so writing it *is* the only work. My §M measured the same
  artifact and reached a **sharper** statement: the claims.json titles use the
  frozen **predicate labels** (`C1_CARRIER:` / `C2_CLAIMS:` / `C3_SELFREF:`),
  while the plan's **headings** are `## C1 — freshness: …` / `## C2 —
  operability: …` / `## C3 — calibration: …`. The two surfaces are not
  byte-equal, so "already carries the frozen headings" is true only under the
  predicate-label reading; a counter comparing against heading text verbatim
  reads a mismatch. A2 re-freezes C2 as a pre-file gate (no claims.json
  comparison), which dissolves the ambiguity — worth recording, since the
  claims.json file stays on disk with the label-shaped titles.

**New finding the amendments do not yet price (C2, A2 guard leg):**

- **Token case.** A2's frozen predicate requires the gate to print
  `PREFILE-FALSIFICATION: PASS claims=3 rows=R attack_seats=K findings=0`
  (uppercase `PASS`). The gate emits **lowercase**:
  `scripts/hyaku/prefile-falsification.py:231` is
  `status = "pass" if not findings else "FAIL"`, printed as
  `PREFILE-FALSIFICATION: %s claims=%d rows=%d attack_seats=%d findings=%d`.
  Measured: no uppercase `PASS` is emitted anywhere in that script; the
  success token is `PREFILE-FALSIFICATION: pass`. A literal reader of the
  frozen A2 sentence therefore cannot see the target it names, while the
  in-flight counter's regex `re.search(r"PREFILE-FALSIFICATION:\s*pass\b", out,
  re.I)` is **case-insensitive** and would accept it. A case-sensitive checker
  built to the A2 sentence would read SETUP/miss on a fully passing tree.
  This is the same class as the round-65 lesson's routed defect 3
  ("CITATION_GATE/CLAIM_LEDGER not re-run", i.e. a gate read against a token
  that was never re-measured) and of the round-65 self-description defect A3
  guard (d) names ("census ok" was the fleet wrapper while the lane gate was
  red). Cheap fix for the L1: amend the A2 literal to the lowercase `pass`
  the gate actually prints, or amend the gate to print `PASS` — do not leave
  the frozen predicate naming a token the tool never emits.
- **Ledger shape is a hard precondition, and A2 names it.** The gate's rules
  (`scripts/hyaku/prefile-falsification.py:214-220`) require one ledger row
  per claim id (`claim-uncovered`) and one referenced artifact per wave
  attack seat (`attack-seat-unread`), where the seat set comes from
  `attack_seats(results)` over `kagi-r66-w1-results.json` filtered by
  `ATTACK_ROLES`. The wave spec declares 5 attack seats (reviewer, critic,
  mutation-tester ×2, sentinel), so K >= 1 is satisfied but the ledger must
  reference **each** seat's artifact by name or the gate reads
  `attack-seat-unread`. A2's `rows=R` with R >= 3 is the floor; the real
  requirement is one row per claim **plus** one per attack seat.

## O. Verification summary — every assigned check re-run

| assigned check | command | observed | expected (plan/assignment) | result |
|---|---|---|---|---|
| BASE registry rows | awk per plan on `git archive d549ee6` | 155 | 155 | PASS |
| BASE tier histogram | grep on SOURCES.md | A=138 B=2 C=15 | A=138 B=2 C=15 | PASS |
| BASE status histogram | grep on SOURCES.md | mined=135 queued=3 rejected=17 | same | PASS |
| BASE malformed / dup | awk NF!=13; uniq -d | 0 / 0 | 0 / 0 | PASS |
| fleet sources-census | `scripts/sources-census.sh validate --root <fleet> kagi` | `kagi ok` rc=0, 24 W04 | `kagi ok` rc 0 | PASS |
| lane census gate | `corpus/sources-census.sh` | `SOURCES_CENSUS: FAILED (findings=4 rows=155)` rc 1 | (not in plan's census) | **NEW: guard (d) precondition red** |
| leftover reverted | sha256 worktree vs `git show d549ee6:…` | identical, 484 B, 9 lines, clean `git status` | reverted to committed blob | PASS |
| S148.body is unrelated | sha256 + owner-row lookup | `fabc74c5…` = row **S152**'s bytes (arXiv QAOA, 39750 B) | unrelated arXiv body | PASS |
| S148 pin lives in S143.body | sha256 | `3b8d4e15…cba40` 264946 B == row pin == anchor pin == PIN_SHA | yes | PASS |
| handle-offset root cause | digest map of 20 round-64 bodies vs fetch col10 | 10 agree with notes.md, 6 orphans, only S149 self-consistent | (not priced in plan) | **NEW** |
| col16 rewritten lane-wide | ledger vs landed `source-fetches.tsv` | 10/10 round-64 rows path -> anchor prose | (not priced in plan) | **NEW** |
| S113/S121 pre-existing anchor mismatches | sha of cited path vs row pin | 2 rows fail a strict rule at BASE | (not priced in plan) | **NEW** |
| live carrier | curl browser UA | HTTP 200, 264946 B, sha == pin, 182/180 | reported, not decisive | PASS |
| C2 claims=59 reachability | `claims-declared.sh` on tree copies | rows alone ⇒ MISMATCH; rows+SCORECARD ⇒ CLEAN(59) | reachable | PASS (ordering hazard) |
| prefile gate | `prefile-falsification.py --lane kagi --round 66` | `SETUP findings=3` exit 2 | SETUP pre-candidate | PASS |

--- POST-STATE (observed after this seat's census; the L1 landed the repair concurrently) ---
lane census NOW: SOURCES_CENSUS: CLEAN (rows=156 A=139 B=2 C=15 queued=3 mined=136 rejected=17 entries_sourced=25 legacy=21 captures=156 inrow=16 inrow_only=0 inrow_nonreproducing=12)
registry rows NOW: 156  (BASE was 155)
manifest round-66 rows NOW: 0
SCORECARD '## Round 66 — post-move' NOW: 0
source-fetches rows citing a round-64 capture NOW: 1
=> the §K guard-(d) precondition has been repaired by the L1 (findings 4 -> 0).
=> the §5 ordering hazard (b) is STILL LIVE: manifest round-66 rows = 0 and the
   SCORECARD round-66 section is absent, so 'claims=59' is not yet reached.

## P. CLOSURE — L1 priced these findings into Amendment A4 (verified in the plan)

`plans/round-66.md:415` now carries **Amendment A4 — 2026-11-08, before any
candidate reading (three corrections a wave seat measured)**, which names
`R66ScoutPreState` as the measuring seat and adopts:

1. **A2 token corrected to lowercase `pass`** — A4 reads
   `scripts/hyaku/prefile-falsification.py:231` and states the tool emits
   `PREFILE-FALSIFICATION: pass …` (lowercase) on a clean ledger and `FAIL`
   otherwise, "Read A2's literal as `pass`". Verified: A4 line 420 carries the
   lowercase form. (The superseded A2 literal at line 364 still reads `PASS` in
   the file, but A4 is appended and supersedes it.)
2. **`claims=59` needs both surfaces** — A4 states the three manifest rows alone
   read `CLAIMS_DECLARED: MISMATCH (claims=59 mismatch=3)` with each
   `section-missing`, that rows plus the `## Round 66 — post-move` SCORECARD
   section read `CLEAN (claims=59)`, and that **both land in the same commit**.
   Verified at plan line 426. My §5 ordering hazard is now a named constraint on
   the landing order.
3. **§C3's basename-census paragraph superseded** — A4 records that the
   `grep -cF 'capture/S143.body'` command hits the round-63 body
   (`8522a79e…`, the S143 pin), not the round-64 body carrying the S148 pin
   (`3b8d4e15…`) which no fetch row cited before this round, and states "a
   basename grep is not a binding; A3's lane-gate `findings=` line is the C3
   measurement and this paragraph is history". Verified: A4 names the exact
   digests I measured. My N5 finding is closed by supersession.
4. **The round-64 col-16 prose convention recorded as a visible departure** —
   A4 states the round-64 family's column 16 carries anchor prose (the seat's
   ledger proposed capture paths; the rows landed as prose), and that S164's
   column 16 names a capture path **deliberately and visibly**, with the row's
   own `anchor` cell naming the same path — "the departure is the claim, not an
   accident". Verified. My N4 finding is adopted as the record of that choice.

The L1 further confirmed the §K finding is now C3's measured target: lane
`bash corpus/sources-census.sh` BASE = `FAILED (findings=4 rows=155)`, and after
the S155/S156 provenance rows and the class-matrix entry's `cites:`/used-by
declarations it reads `CLEAN (findings=0 rows=156)` — my four reproduced
finding ids are exactly the four the repair closes. The 12 borrowed-identity
round-64 handles are routed to round 67 as a checked class rather than adopted
silently.

**No further action required; nothing was re-run after this A4 verification
(read-only inspection of the plan text only).**
