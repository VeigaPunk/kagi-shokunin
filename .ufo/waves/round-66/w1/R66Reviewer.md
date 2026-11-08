# R66Reviewer — attack on the frozen round-66 instruments (read-only)

Reviewer seat: calibration + freshness. Sources attackable at review time:
`plans/round-66.md` (frozen), `corpus/SOURCES.md`, `corpus/source-fetches.tsv`,
`corpus/volatile-shape.py`, `.ufo/waves/round-66/claims.json`,
`.ufo/waves/round-66/base/census-{c1,c2}.md`, and the two gates named in the
freeze (`corpus/sources-census.sh`, `corpus/claims-declared.sh`,
`prefile-falsification.py`). No `plans/round-66-c1.sh`, `round-66-c2.sh` or
`round-66-c3.sh` exists yet, so every finding below attacks the *frozen
predicate text, the guard as written, and the population the counters must
measure* — i.e. the things the executor seats will build to.
Report path: `.ufo/waves/round-66/w1/R66Reviewer.md` (this file plus the
required `Report:` trailer are the seat's only writes).

Axes attacked: calibration (registry ↔ tree mismatch, counter can-fail),
freshness (carrier binding by digest), operability (runnable verdict).

## Findings

### F1 (CRITICAL, C1) — "header-ID digest" is undefined; no such mechanism exists in any inventoried file

- Evidence: `grep -rn "header-ID|header_id" plans/ corpus/` matches only
  `plans/round-66.md:53`: "every mutated copy's header-ID digest still resolves
  to the candidate body (the digest binding refuses every wrong-id file)".
  No file in the lane defines a header-ID digest, an ID-deriving digest, or any
  resolution from a wrong id to the candidate body. The two real mechanisms that
  exist are: (a) `corpus/volatile-shape.py` — a path-keyed read of
  `.ufo/waves/round-64/capture/S143.body` plus a full-body pin comparison; it
  resolves *paths*, never ids, and (b) `corpus/sources-census.sh` SC_FETCH at
  `corpus/sources-census.sh:257-306` — it checks id/status/url/identity-digest
  consistency of `source-fetches.tsv` rows, never file content at a path.
  Neither walks "wrong-id file → candidate body".
- Attack: an executor who implements "match=1" as the only honest reading of the
  plan (sha of file at path = pin) produces a counter where K3's "named
  digest-mismatch line, never a pass" is the only thing that can fire, and the
  BASE/mutation geometry is undefined. Conversely an executor who invents a
  header-ID recovery feature (e.g. scanning `S*.body` filenames and reading the
  pin from the file whose *name* is wrong) builds a new, unreviewed
  carrier-resolution mechanism to satisfy an undefined predicate — the exact
  QM88 class (borrowed identity) the round exists to kill.
- Guard implication: C1 guard leg (a) — "resolves the S148 body's capture path
  by digest from the registry row and reads drift=1 on all three anchors" —
  cannot be executed as written; there is no defined way to read "drift=1" off
  a registry row except the counter's own output. This is M65-3 (impossible
  predicate direction written and frozen) FROZEN IN: the plan mandates a
  predicate whose central term has no implementation surface.
- Counter demand: before any `plans/round-66-c1.sh` is scored, the L1
  (sole committer) must record an Amendment defining "header-ID digest" as a
  measurable rule, or the C1 executor MUST NOT inherit the phrase — the
  immutable minimum the predicate can honestly measure is "file at the registry
  anchor path has sha256 equal to the row pin" (path equality + digest match),
  and "match=1" must be re-expressed in those terms. Absent an amendment,
  K3 cannot be independently verified against the freeze.

### F2 (CRITICAL, C1) — the "path-only repoint" do-nothing control (K2) is reachable with zero work

- Why: the plan says K2 "a path-only edit (carrier-path string repointed, no
  bytes changed) reads `drift=0 match=0` (the digest binding refuses the
  wrong-id file — the do-nothing control cannot reach the target)". But the
  wrong-id files at `S148.body` (arXiv, sha `fabc74c534…`) and `S143/S156/S157`
  are already in every candidate tree; any counter that reads
  "path + digest == pin" already makes K2 `match=0` true *before the repair
  lands*. Measured at the current tree: the registry anchor cell (SOURCES.md
  cell 6) contains no `capture/` path at all, `source-fetches.tsv` col 16 for
  S148 is the prose `§3.1.2 Trigger Terms…` (not a path), and
  `volatile-shape.py:DEFAULT_CAPTURE` already equals
  `.ufo/waves/round-64/capture/S143.body` (sha `3b8d4e15…cba40` == pin,
  verified `sha256sum` both files above, identical). So on *today's*
  candidate tree the K2 geometry already reads as the predicate's "post-repair"
  outcome for two of three anchors — the do-nothing control is not separated
  from the repair by the numbers the freeze prints (`drift=1, paths=3, hex=3,
  match=1`: the only BASE→candidate delta available is a literal string
  rewrite).
- K1 is additionally a non-killer in the conservative direction: BASE (`d549ee6`)
  DOES NOT CONTAIN `.ufo/waves/round-66/claims.json` at all (`git cat-file -e`
  ⇒ `fatal: path … exists on disk, but not in 'd549ee6'`), and the same
  absence almost certainly holds for any `plans/round-66-c1.sh` reading of BASE.
  A counter run against BASE exits SETUP (missing claims/counter file), never
  the `drift=0` reading K1 requires. The freeze's K1 sentence ("a copy tree
  byte-identical to BASE reads drift=0") is therefore unmeasurable as specified
  for C2 and unproven for C1/C3 until the executor circulates a BASE-tree
  receipt.
- Counter demands: (1) ship a BASE-extract receipt (`git archive d549ee6` +
  the counters) proving `drift=0` / `exact=0` / `failures>=1` is *read*, not
  SETUP; (2) K2's control must repoint the carrier string to a path whose file
  bytes differ from the pin AND show `match=0` naming that path — "no bytes
  changed" cannot be the control if the repair makes no byte change either.

### F3 (CRITICAL, C1+C3) — guard leg (d) / C3 guard (d) are already FAILED at the current tree

- Evidence, measured this seat (rerunnable):
  - `bash corpus/sources-census.sh` ⇒ exit `1`,
    `SOURCES_CENSUS: FAILED (findings=4 rows=155)` with
    `SC_FETCH id=S156 missing-provenance`, `SC_FETCH id=S155 missing-provenance`,
    `SC_BODY_CITE … claim-instrument-class-matrix.md id=S148 unrecorded`,
    `… id=S156 unrecorded`.
  - `bash corpus/claims-declared.sh` ⇒ `CLAIMS_DECLARED: CLEAN (claims=56)` exit
    0 — the fleet census at `scripts/sources-census.sh` instead reads only
    `W04` warnings and exits 0 (the `kagi ok` at
    `.ufo/waves/round-66/base/census-start.txt` was taken with the *fleet*
    script, not the lane's). Two different "SOURCES_CENSUS: CLEAN" readings
    exist; the lane one FAILS.
- Why it is critical: the frozen C1 guard REQUIRES
  "(d) `SOURCES_CENSUS: CLEAN` reads at round end" and the C3 guard REQUIRES
  "SOURCES_CENSUS: CLEAN on the candidate and the census validate command exits
  0 at round end". Both guards can only fire after the candidate lands four
  provenance/citation repairs that are **not among the frozen carrier repairs**
  (the plan's carrier repair names exactly three anchors: SOURCES.md anchor,
  source-fetches.tsv col 16, DEFAULT_CAPTURE). `corpus/sources-census.sh:257-306`
  (SC_FETCH) needs a provenance row for S155/S156; `SC_BODY_CITE`
  (`corpus/sources-census.sh:359-370`) needs `cites:` in
  `corpus/knowledge/claim-instrument-class-matrix.md` recording S148/S156 and
  S148/S156 used-by cells listing that entry. Neither is mentioned anywhere in
  the plan. If the executors build exactly the frozen three-anchor repair,
  `SOURCES_CENSUS: CLEAN` reads `FAILED` and **guard=0 for C1 and C3 on a
  "perfect" repair**.
- Further poison: S155/S156 each have zero `source-fetches.tsv` rows
  (`grep -c "^S155\|^S156"` ⇒ 0/0) though the captures exist
  (`.ufo/waves/round-66/capture/S148.body`, `S155.body` verified same pin).
  So the C1/C3 "SOURCES_CENSUS: CLEAN" gate implicitly demands provenance-row
  authoring for two rejected/admitted rows round 65 did not write — a scope
  expansion the freeze never prices.
- Counter demands: either (a) an L1 Amendment naming the four extra repairs
  as *part of the guard* (with their own receipts), or (b) the guards must be
  pinned to the *fleet* `sources-census.sh validate` reading (which is CLEAN
  modulo W04), not the lane script's. As frozen, the same English phrase
  "SOURCES_CENSUS: CLEAN" denotes two different gates with opposite current
  readings; any of the three counters that accepts the lane-script reading
  can fail every candidate, and any that accepts the fleet reading can pass
  a tree the lane gate fails. The reviewer cannot tell which the executor
  means — that is a frozen-predicate ambiguity, i.e. a killable claim.

### F4 (MAJOR, C1) — the census-c1 note inverts QM88: the "cited-set check passes vacuously" sentence is false for the repaired row

- Evidence: `plans/round-66.md` line 106-107: "the S148 fetch row's 16th column
  names an anchor, not a capture path, so the cited-set check passes vacuously
  for it." True TODAY (col 16 = `§3.1.2 …`). But the freeze's own carrier
  repair (lines 66-77) rewrites col 16 to a capture path on the **new
  superseding id**. After that repair the vacuity disappears and the row
  participates in the 30-of-30 cited-set check — the plan's §Population
  census sentence ("the candidate tree holds three round-64 capture bodies
  whose fetch-row sha matches the file's own sha", measured against
  `.ufo/waves/round-66/base/census-c1.md`) is a *pre-repair* measurement that
  the repair necessarily violates. `.ufo/waves/round-66/base/census-c1.md`
  itself concedes the weakness: "a do-nothing control (row edited to cite a
  different carrier path) reads 155 still and no lane gate reads the delta —
  the claim's baseline is the census digest measured with the row's carrier
  path named, not a row count that cannot move." And at BASE,
  `grep -cF 'capture/' corpus/SOURCES.md` = 21 rows, `grep -cF 'S143.body'
  corpus/SOURCES.md` = 0, while `source-fetches.tsv` has 30 rows citing a
  `.body` path — the two "cited sets" are already different populations at
  BASE.
- Counter demands: the executor's receipt must state which cited set (registry
  anchors vs fetch rows) "30 of 30" is measured over *after* the repair, and
  the do-nothing control in census-c1 must be re-run against the repaired
  tree (a path-only repoint that keeps sha equal on all 30/31 rows). As frozen,
  `paths=3` counts mutated copies of the S143/S156/S157 bodies, but the
  registry population that carries a capture path is 21 rows (S113-S134) —
  "paths=3" does not bind the 21-row population the freeze's census rests on.

### F5 (CRITICAL, C2) — the pre-file guard is untestable at the moment it is graded, by construction

- Evidence: `prefile-falsification.py` setup-refuses (exit 2) unless ALL of:
  `.ufo/waves/round-<N>/claims.json`, `.../<wave>-results.json`,
  `.../claim-falsification.tsv`, and `.ufo/reports/round-<N>/<lane>.md` exist.
  Measured this seat: `PREFILE-FALSIFICATION: SETUP findings=3`
  (`wave-missing w1-results.json`, `ledger-missing claim-falsification.tsv`,
  `report-missing round-66/kagi.md`). The wave results file is written only
  when the wave completes, and the report file — by the program's own design —
  does not exist until the round's end. Therefore *no* candidate tree that
  anyone runs mid-round can read `PREFILE-…: PASS` for the guard leg
  "(c) the pre-file gate reads PASS on the candidate tree including this
  round's claims.json (exit 0)". The C2 guard can reach `guard=1` at exactly
  one moment — after the report exists — which is the same moment the verdict
  is filed.
- This is an M65-3 unsatisfiable guard, frozen. Counter demand: guard leg (c)
  must be re-scoped to its runnable subset ("ledger VALID shape + attack seats
  read, ignoring the report-existence leg") or the Amendment must state that
  the pre-file leg is evaluated by the closure, not the counter, and remove it
  from the `guard=G` exit arithmetic. As frozen, the C2 executor must either
  fabricate a report to make the counter exit 0 (a fake artifact — worse than
  a non-passing guard) or ship `guard=0` and fail C2 on a technically correct
  claims.json.

### F6 (MAJOR, C2) — `claims=59` expected contradicts the frozen registry (56 → 59)

- Evidence: C2 guard leg (d) says `corpus/claims-declared.sh` reads
  `CLAIMS_DECLARED: CLEAN` "with `claims=59` expected: 56 + 3". Measured:
  `corpus/claims-declared.tsv` has 57 lines ⇒ `claims=56` today, and
  `bash corpus/claims-declared.sh` prints `CLEAN (claims=56)`. Adding three
  round-66 rows yields 59 **only if** (i) the executor commits three ledger
  rows, and (ii) `SCORECARD.md` gains a `## Round 66 — post-move` section with
  exactly one `[C1]/[C2]/[C3]`-tagged row each (the D3/D5 rules at
  `corpus/claims-declared.sh` header). Neither ledger rows nor scorecard
  section exist today (`grep -n "Round 66" SCORECARD.md` ⇒ no match; tail of
  claims-declared.tsv ends at 65 C3). The C2 counter therefore grades a piece
  of scorecard authoring it does not own, and K1 ("at BASE reads exact=0")
  cannot distinguish "BASE lacks claims.json entirely" (SETUP) from "BASE
  titles diverge" (exact=0) — `git cat-file -e d549ee6:.ufo/waves/round-66/claims.json`
  fails, so the round-65-evidence note ("measured over the round-65
  claims.json against plans/round-65.md") is the only actual BASE reading.
  Counter demands: run `claims-declared.sh --selftest` (it churns
  `corpus/claims-declared.tsv` triples — do it on a scratch copy, not the
  lane tree) and publish the BASE-side `exact=0` receipt against the
  round-65 claims.json/round-65 plan pair, explicitly naming that the round-66
  pair has no BASE side.

### F7 (MAJOR, C3) — "checks=3" under-binds a 21-row population and S121 already falsifies its digest rule twice

- Evidence: C3 predicate says "checks = 3: the carrier-path stands are under
  `.ufo/waves/round-64/capture/`". But today 21 registry anchors cite a
  capture path (S113, S115-S134), and at least one row (S121) cites TWO paths
  in the same anchor cell: `.ufo/waves/round-59/capture/S121.body` (sha
  `d8879a2a…` == row pin AND == fetch-row sha, bytes 48604) and
  `.ufo/waves/round-58/capture/S121.body` (sha `37e706c2…`, NOT the pin) with an
  explicit "(the round-58 staging file of the same id … is the rejected
  token-CLI page and not this source)". Any counter that implements "each cited
  path's sha == row pin" as a boolean over *all* cited paths reads
  `failures>=1` for S121 on **every** tree — a pre-existing falsifier the
  "checks=3" framing hides. If instead the counter checks only the round-64
  stands, the other 18 round-55..62 anchors are unprotected and the claim's
  "registry self-reference literals resolve" wording is false over the registry
  the census counts (155 rows, all but 21 uncited — exactly the
  QM88 "row-shape outside the registry section" class at
  `sources-census.sh:336-353` SC_BODY_CITE).
- Counter demands: S121 must be handled by an explicit rule (e.g. "first cited
  path must match; subsequent parenthetical rejections are named and skipped",
  with the rejected path's digest asserted *unequal*), or checks=N must be
  stated as "checks = 21 + new" and BASE failures re-measured honestly
  (`failures>=1` at BASE is today explainable by two independent causes —
  S148 uncited AND S121 second-cite digest mismatch — the freeze conflates
  them). K2's arXiv-at-carrier-path control is already in the tree
  (`.ufo/waves/round-64/capture/S148.body` IS the arXiv body, sha `fabc74c5…`);
  it must show `failures>=1` *naming S148* on the candidate, not just any
  failure count.

### F8 (MODERATE, C1 carried into C3) — `.ufo/waves/round-66/capture/S148.body` is a second, competing binding the freeze never prices

- Evidence: `.ufo/waves/round-66/capture/S148.body` (264946 B) is byte-identical
  to `.ufo/waves/round-64/capture/S143.body` (same sha `3b8d4e15…cba40`,
  verified by `sha256sum`), and `S155.body` exists beside it. A reader who
  follows "the file named for S148" finds the right bytes here — the M65-4
  drift the plan exists to repair is already repaired by a same-bytes copy in
  the very directory the candidate writes to, without touching any registry
  row. If C1/C3 counters resolve paths by *existence under the registry id's
  own round directory*, a tree where the executor only copies `S143.body` →
  `capture/S148.body` reads the same digests as a tree where the three anchors
  are rewritten. The freeze's "No committed capture is renamed (QM88)" line
  guards committed round-64 captures only, not new same-bytes copies.
- Counter demands: the counters must *require* the digest to be reached via the
  registry anchor path string as written (exact `.ufo/waves/round-64/capture/
  S143.body` on all three anchors), never via a filename lookup, and the
  receipt must show the S148-named round-66 copy is not what made it pass
  (e.g. with the round-66 capture dir removed from the fixture tree).

### F9 (MODERATE, all) — K3's "prints a named digest-mismatch line, never a pass" has no named comparator

- The S143 fetch row (col 10 `sha256` = `8522a79e…`, the round-63
  `S143.body` digest, NOT the S148 pin `3b8d4e15…`) and the S148 fetch row
  (col 10 = `3b8d4e15…`) disagree about what "the digest" is for the same
  bytes; measured in `corpus/source-fetches.tsv` lines `S143 … 8522a79e…`
  vs `S148 … 3b8d4e15…` (the round-64 S143.body IS the S148 pin; the round-63
  one is the prior date stamp). The new supersedes row will carry yet a third
  row-identity digest. "Named digest-mismatch" therefore has three candidate
  expected digests and the freeze names none per anchor. A counter that
  compares against the *fetch row's* col 10 on the repaired row passes
  trivially (self-fulfilling); a counter that compares against the
  *registry prose* pin (`S148` cell 6, `3b8d4e15…`) is the honest one. The
  receipt must name, per anchor, which digest literal was compared.

## What is NOT found (non-findings, so the executors can stop looking)

- The lane's own `volatile-shape.py` reads `VOLATILE_SHAPE: match=1 … exit 0`
  today, and its `--selftest` exists; guard legs C1(b) and C1(c) are runnable
  as frozen (only leg (a)'s "header-ID digest" and leg (d) are defective).
- `claims-declared.sh --selftest` covers D1-D5/duplicates/padded cells
  (in-file cases 1-13); it is not a vacuous gate — but its
  "tagged row's first cell == axis byte-exact" rule (D5) means the scorecard
  rows the L1 writes must carry exactly `freshness / operability / calibration`
  in column 1, no padding (a one-space pad reads `axis-cell` MISMATCH).
- Census hex count: `S115`/`S116` fetch sha == file sha (verified); the
  21-anchor digest population is healthy except for the S121 second-cite.
- `grep -c 'capture/S143.body' corpus/source-fetches.tsv` ⇒ 1 row (S143) and
  `grep -cF 'S143.body' corpus/SOURCES.md` ⇒ 0 — the plan's C3 census numbers
  reproduce exactly.
- Axis names in `claims.json` (freshness, operability, calibration) are
  distinct and match `corpus/claims-declared.tsv` round-65 axes; no axis typo.

## Falsification ledger (for `claim-falsification.tsv`)

- C1 | plans/round-66.md (header-ID digest undefined) | falsifies-wording | amendment required before the executor builds | the "digest binding refuses every wrong-id file" wording overstates a mechanism no file defines
- C1 | corpus/sources-census.sh FAILED (4 findings) at current tree | falsifies-number | guard leg (d) must name the fleet reading or the extra repairs must be priced | `SOURCES_CENSUS: CLEAN` as the lane script reads it is 0 today
- C2 | plans/round-66.md guard (c) + prefile-falsification.py setup refusals | falsifies-wording | guard must be re-scoped or removed from exit arithmetic | the pre-file leg reads SETUP at every moment the counter exists
- C2 | corpus/claims-declared.tsv + SCORECARD.md (no round-66 rows) | falsifies-number | counter must publish the round-65-pair BASE receipt, not a round-66 BASE receipt | `exact=0 at BASE` was measured against a different plan/claims pair
- C3 | S121 second cited path (round-58, digest `37e706c2…` ≠ pin) | falsifies-wording | S121 needs an explicit first-match/rejected-skip rule | "each cited carrier path's sha equals the row's pin" is already false for S121
- C1 | .ufo/waves/round-66/capture/S148.body (same-bytes copy) | neutral | counter must forbid filename-lookup resolution | a same-bytes copy where the registry fix would be trivially satisfies content checks

## Residual risk & verification gaps

- No `round-66-c1.sh/c2.sh/c3.sh` exists yet: findings F1-F9 attack the
  frozen *text*. Once the executors land, this seat's claims must be
  re-tested against the actual scripts (my F1 "undefined" may dissolve if the
  executor's amendment genuinely defines header-ID digest; my F5 survives any
  reasonable re-scoping short of removing the leg).
- The fleet `scripts/sources-census.sh validate` (W04-only) vs the lane
  `corpus/sources-census.sh` (4 findings) give opposite "CLEAN" readings;
  L1 must name ONE as `SOURCES_CENSUS: CLEAN` before integration.
- Edit rights: this seat performed NO edit outside its report dir; all
  numeric claims are `sha256sum`/grep reproductions run from the lane tree.

Report: .ufo/waves/round-66/w1/R66Reviewer.md
