# Round 68 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 68, attempt 1. Claim BASE
`d3b2a4e8eed710277951e430efd3d27b5983033c` (round-67 verifier spot-check tip,
`corpus/lessons/round-67-verifier-spotcheck.md`). This file is the
predeclaration: committed alone before any candidate work. The candidate
moves; this file does not.

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3. A capability entered
in round 67 (capture read-through in the source census), so the stagnation
nudge does not fire and the lowest-axis obligation binds. All six axes stand
at 9, so the tie is broken by measurement: round 67's own non-author closure
(`round-67-verifier-spotcheck.md` §Routed defects 1–3) lists three surviving
classes of the gate round 67 landed, and the wave's revenger measured them:
(1) the prose escape hatch (a stray space/CR in a location cell disengages
the binding while the gate prints `SOURCES_CENSUS: CLEAN`; whole-file CRLF
reads `path_rows=0`), (2) column 15's normalized digest is format-checked but
never recomputed (borrowed normalized digests read CLEAN), (3) the round's own
new capture row S166 is prose and unread by the gate (its bytes, digest and
quote are verified by hand only). The round moves the census's binding from
"capture-path-shaped rows" to "every mined row that names a lane-tree
capture," and closes the other two classes. No retirement, no split. The
shokuknow package `merge/kagi/` is a standing residual — q1: read its
`MERGE-REPORT.md` § header and diff signature for C1 evidence; an assimilation
claim is a later round's call, and `considerthese/` proposals remain the
operating input's source.

Motivating evidence, measured at BASE this round:

- The round-67 closure §Routed defects 1–3 (`round-67-verifier-spotcheck.md`)
  and the wave report `.ufo/waves/round-67/w1/R67Revenger.md` §3 (classes
  C0–C3 with exact bytes and proposed checks): `S113.col16` + one trailing
  space, leading/interior spaces, eight spaces, a trailing CR, a comma-joined
  two-path cell, `//etc/passwd` and `~/S113.body` all read `CLEAN` with
  `path_rows=35`; a `col15` borrowed from S164 reads `CLEAN`; S166's six
  tamper probes all read `CLEAN`.
- Lane gate selftest is 89 cases, but `corpus/claim-ledger.tsv` row `R21-03`
  expects 88 — the round-67 ledger migration journaled 78→88 and this
  round's measured count is stale on contact again (qm90 class).
- `claim-ledger.sh cells` reads `SETUP` on the historical heading
  `## Round 63 — planned` (present at BASE), so the cells gate that every
  pre-move section must pass cannot be green on the landed tree.

## C1 — freshness: the census re-verifies every mined row that names a lane-tree capture

Target axis: freshness (`AXES.md`: "skill claims re-verified against live
surfaces"). Capability already entered (read-through, round 67); this round
widens its population and its reason set.

**Frozen predicate (this sentence is the plan's, the counter's code and the
receipt's label):**

```
C1_VERIFIED: verified=37 col15=32 caught=6/6 guard=1
```

where `bash plans/round-68-c1.sh --tree <candidate> --base-tree <BASE
extraction>` computes, all populations derived row by row, never listed:

- `verified` — `corpus/source-fetches.tsv` rows whose col 16 is a repo-relative
  capture path **or** whose col 16 contains a whitespace-delimited token that
  is a repo-relative `.ufo/waves/` capture path, and whose first such token
  names a file inside the measured tree whose raw sha256 equals col 10, whose
  byte count equals col 11, and whose declared quote (col 13) locates
  `count >= 1` under the declared normalization. S166's row, re-cut to the
  pure path `.ufo/waves/round-67/capture/S166.body`, is the +1.
- `col15` — of the verified rows with normalization `rendered-text-v1`,
  those whose normalized digest (recomputed with `rendered-text-v1.py digest`
  on the bound file) equals col 15. The moved number is 31 → 32 through
  S166's row (its col 15 already equals the recomputed digest).
- `caught` — of six mutated copies of the candidate tree (one defect each),
  the number on which the candidate gate prints `SOURCES_CENSUS: FAILED`
  and a `FINDING SC_CAPTURE` line for the mutated id with the expected
  reason (the expected reason is named per leg below).
- `guard = 1` iff (a) the unmodified candidate tree prints
  `SOURCES_CENSUS: CLEAN` and `SOURCES_CAPTURES: CLEAN` with the gate's
  four counts equal to this counter's derivation; (b)
  `bash corpus/sources-census.sh --selftest` exits 0 printing
  `SOURCES_CENSUS_SELFTEST: PASS (N cases)` with `N >= 89`; (c) the BASE
  gate on the escaped-CRLF copy prints `SOURCES_CENSUS: CLEAN` (the
  blindness witness: the target is not reachable by doing nothing); (d) the
  fleet wrapper reads `kagi ok` on the candidate; (e) the non-capture
  prose rows (a `col16` with no `.ufo/waves/` token) produce no
  `SC_CAPTURE` finding on the unmodified tree.

Reason set (this round's additions to the frozen vocabulary):
`capture-whitespace` (a cell that trims to a `.ufo/waves/` path but carries
stray whitespace, a comma-joined second value, or a CR),
`capture-token` (a non-pure cell naming a `.ufo/waves/` file: a mixed-prose
cell, a `~/` or `//` form, or a token that does not resolve in-lane),
`normalized-digest-mismatch` (col 15 differs from the recomputed
`rendered-text-v1` digest of the bound file), and `SC_FETCH cr-in-tsv`
(a CR byte anywhere in `corpus/source-fetches.tsv`).

Classification rule (monotone, one sentence): a `col16` cell is **legal**
iff it either names no `.ufo/waves/` whitespace-delimited token at all
(frozen `prose`, never read) or is exactly one such path with no other
content (frozen `path`, read and bound); every other shape that mentions a
`.ufo/waves/` path is a defect. `.ufo/prompts/…` and other fleet-root paths
carry no `.ufo/waves/` token, so S099 stays `prose` and no gate may claim it.

Six legs. The **anchor** is derived, never named: the LAST
capture-path-shaped row in file order that binds its declared bytes on the
unmodified candidate tree (`S166` at the candidate, `S164` at BASE); its id
is the mutated id for all six legs, and no anchor is a SETUP.

| leg | mutation on a copy of the candidate tree | expected reason |
|---|---|---|
| M1 | append one space (`0x20`) to the anchor's col 16 | `capture-whitespace` |
| M2 | append `,` + the anchor's own path again (comma-joined duplicate) | `capture-whitespace` |
| M3 | rewrite the whole `corpus/source-fetches.tsv` with CR at every line end | `SC_FETCH cr-in-tsv` |
| M4 | replace one hex digit of the anchor's col 10 (still 64 lowercase hex) | `capture-digest-mismatch` |
| M5 | replace the anchor's col 15 with another 64-hex digest of the same normalization | `normalized-digest-mismatch` |
| M6 | append one byte to the anchor's capture body | `capture-bytes-mismatch` |

Each leg counts only when the candidate gate's own stdout exits 1 with
`SOURCES_CENSUS: FAILED` and prints a `FINDING … id=<anchor> <expected
reason>` line. A leg whose mutation produces a byte-identical file (nothing
to mutate) is SETUP, never a pass.

Kill rules: the target is missed if `verified < 37`, `col15 < 32`,
`caught < 6` or `guard = 0`. A `SETUP` line is never a pass. A count
produced by a constant printer (a gate that prints the CLEAN line without
reading a byte) is refused by guard (c) and by the mutation legs. The
counter may not hard-code any of the three numbers.

Landing surface: `corpus/SOURCES.md` S166's col16 re-cut to the pure path;
`corpus/source-fetches.tsv` S166 col16 re-cut to the pure path; the position
of S099 is fleet-root (`/home/vgpnk/Projects/shokunin/.ufo/prompts/
kagi-round-44.md` — the fleet tree, outside the lane) carrying the measured
digest this round by hand (receipt, never re-opened as evidence of anything
but its current bytes) and is named as a residual with its flip condition
(a fleet-root class in a later round); the round-67 lesson's S166 Gate row is
extended by the same re-cut; the entry `corpus/knowledge/
source-capture-binding.md` gains the widened population and the col-15 rule.

Bounds (named ceilings, not saturations): S099's file lives in the fleet
tree and cannot be bound by a lane-rooted gate; hardlink durability (C2 of
the revenger) and one-token quotes (C5) stay ceilings — re-verification is a
point-in-time attestation, and evidentiary strength of a quote is not
measured; a gate cannot vouch for itself (C4's normalizer-tamper class stays
counter-guarded, never gate-guarded).

## C2 — calibration: the round's record surfaces match the state they describe

Target axis: calibration (`AXES.md`: "SHONEN.md/SCORECARD entries match
observed repo state"). `bash plans/round-68-c2.sh --tree <candidate>` runs
three legs, each a mismatch measured at BASE this round:

| leg | defect at BASE (measured) | repair |
|---|---|---|
| L1 | `corpus/claim-ledger.tsv` row `R21-03` expects the census selftest at 88 cases while the gate prints 89 (`SOURCES_CENSUS_SELFTEST: PASS (89 cases)`) and the expectation-migration journal `corpus/expectation-migrations.json` journals 78→88 | migrate `R21-03` to the measured count with a journal entry (measured before any C1 case lands; the same migration protocol every gate-count move needs) |
| L2 | the round's two declared claims (C1_VERIFIED/C2_RECORD) have no rows in `corpus/claim-ledger.tsv` | two rows (`R68-01`, `R68-02`) minted from this plan, each bound to its counter's frozen predicate |
| L3 | `claim-ledger.sh cells` reads `SETUP` on the historical heading `## Round 63 — planned` (`SCORECARD.md` at BASE) | the cells parser accepts the non-scored `## Round N — planned` heading as a section the audit may skip rather than a setup error; the gate still rejects a scored section missing an axis |

**Frozen predicate:**

```
C2_RECORD: mismatches=0 population=3 guard=1
```

Kill rules: the target is missed if `mismatches > 0`, or `guard = 0`.
`guard = 1` iff (a) the unmodified candidate tree prints
`SOURCES_CENSUS: CLEAN` (the registry this round re-cuts is not broken);
(b) `bash corpus/claim-ledger.sh verify` on the candidate tree prints
`CLAIM_LEDGER: CLEAN` (no MISSING or POLICY findings beyond the
pre-existing round-37/38/46 lessons); (c) each repaired leg's own tooling
still rejects its negative control (the ledger `verify` still flags an
unminted id; the cells gate still flags a scored section whose heading
lacks an axis).

Landing surface: `corpus/claim-ledger.tsv` (`R21-03` + `R68-01`/`R68-02`),
the expectation-migration journal, the cells parser in
`corpus/claim-ledger.sh`, the ledger rows' measured targets, this plan's
`claims.json` mint (`CLAIMS_DECLARED: CLEAN (claims=63)` at candidate).

Ceilings: pointer relevance remains unverifiable (the ledger binds pointers,
not meaning); the `cells` parser tolerance covers exactly the non-scored
`## Round N — planned` heading, never a scored one.

## Frontier step (contract v1)

One source opened this round, to be named before the wave (the seat opens
it): **S167**, an rfc-editor text RFC whose § states the rule the census
gate now enforces for location cells ("when a field carries structured data,
a receiving parser either accepts the exact form or refuses the record —
never reads past the malformed byte") — opened to ground C1's `capture-
whitespace` rule and the S166 col16 re-cut. One row admitted, tier A if the
§ is primary, `mined`, `checked-out-side capture`. The S166 re-cut is the
round's in-place registry change (col16 old→new); any other `status` /
`recheck` / `used-by` change is logged old→new in the round lesson per
contract v1 rule 2. No shokuknow package adoption this round (an
assimilation claim is a later round's call); `considerthese/` proposals
remain the operating input of the frontier step.

## Mistakes to mine

Round 67's own spot-check routed five mistakes (M67-1–M67-5) into next
round's lesson: the round-68 lesson carries M68-1 (this plan's `capture-
token` rule must distinguish "names a `.ufo/waves/` file in-lane" from the
fleet-root S099 by construction, and state which class the fleet tree
occupies rather than letting it become prose by accident), plus any new
misfires the wave measures. The L1's own counter-side misreads (M67-4's
pattern) stay mine.

## Wave

One v1 wave, `kagi-r68-w1`, 12–16 seats under `ufo-wave-policy.json`
(run-15 band 8–16, ≥25% attack share, ≤2 connector seats). Seats: executor×4
(counter C1 build incl. anchors/probes; gate widened population; gate col15
recompute; base/baseextraction scripts), executor×2 (C2 legs L1–L3 of
round-68-c2 counters), executor×2 (round-68 counter proofs: do-nothing
control derivation; fleet wrapper + digest pins), scribe×1 (S167 registry +
fetch row drafting), scribe×1 (round-68 lesson + LOG scaffolding),
connector×1 (S099 fleet-root residual class sweep; pointer/claim grammar
check), scout×1 (S167 source opening + registry citation),
reviewer×1, critic×1, mutation-tester×1, sentinel×1 (attack: token grammar
bypasses, prose-regression, blind/guard abuse, receipt forgery). Planner seat
is the L1's. No `considerthese/` proposal is edited. Roadblocks: none. The
`capture-whitespace` reason is `SC_CAPTURE`; a location cell that trims to
a shaped path but carries stray whitespace is a defect, never a pass —
`prose` keeps its frozen meaning (no `.ufo/waves/` token). A mixed-prose
col16 is legal iff it names exactly one `.ufo/waves/` token (e.g. S166's
`§1.2 … capture .ufo/waves/round-67/capture/S166.body` before the re-cut;
after the re-cut a mixed-prose `.ufo/waves/` cell is a defect by
construction).
