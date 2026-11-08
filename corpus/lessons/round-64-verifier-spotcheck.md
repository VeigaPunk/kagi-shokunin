# Round 64 — verifier spot-check (non-author)

author: hyaku closure (non-author integrator, @m_zfl)

Lane: kagi (secrets & vault ops). Claim BASE
`09cbee831d57be7c4edfbe77bf238f46bf729047`; lane HEAD under review
`525c69de649424011276dc05cba24c891ebf7ad0`.
Dispatch/complete digest (from `.ufo/watchdog.log`, copied verbatim; the log is
mutable, this digest is the pointer):

```
2026-11-07T23:37:07-03:00 launch kagi round=64 pgid=1124956 driver=hyaku-inline attempt=1
2026-11-08T00:08:45-03:00 lane-dead-no-report kagi round=64; retry same round (hyaku-inline attempt=1: L1 ended without a landed report: FAIL report_of (missing, unchanged, no SHONEN heading, or < 400B): .ufo/reports/round-64/kagi.md)
2026-11-08T00:08:51-03:00 launch kagi round=64 pgid=340676 driver=hyaku-inline attempt=2
2026-11-08T04:53:39-03:00 complete kagi round=64; hyaku-inline attempt=2
```

## 1. Step-1 conformance

- Report `.ufo/reports/round-64/kagi.md` committed in the fleet repo by the lane
  identity: `git log --format='%an %H' -- <report>` =
  `kagi-shokunin 21fb0a01c6e133687603de74603158a3b7b6fc9e` (also two earlier
  attempts' commits `956efae7`, `c9c945b3`, all lane-identity). Byte size
  21347 B (≥400). `## SHONEN` heading at line 237, four `[~]` lines (one per
  box) with evidence pointers — author-asserted, no `[x]` claimed.
- Required sections present, in order: `## Work performed` (13),
  `## Landed changes` (82), `## Before → after measurements` (109),
  `## Sources & frontier` (168), `## Trend verdicts` (205), `## SHONEN` (237).
- Ancestry: `git -C kagi-shokunin merge-base --is-ancestor <h> master` holds for
  both `09cbee8` and `525c69d`; `git rev-parse master` =
  `525c69de649424011276dc05cba24c891ebf7ad0`. Lane round commits
  `dff0929` (plan), `823855d`, `eb647d2`, `6593f72`, `e5668ff`, `4aab7fa`,
  `6178d47`, `525c69d` all sit on `master` between BASE and HEAD.
- Lane state: `/home/vgpnk/Projects/shokunin/scripts/hyaku/jj-lane.sh state
  kagi-shokunin` ⇒ `state branch=master local=525c69d… remote=525c69d…
  ahead=0 behind=0 head=detached tracked=0 untracked=0`;
  `git status --porcelain` empty. Report cites lane tip `525c69de…`;
  `git ls-remote origin refs/heads/master` prints the same hash. No
  uncommitted round work. No jj command was run in the lane beyond the helper
  `state` call.
- Dispatched prompt `.ufo/prompts/kagi-round-64.md` carries the template
  contract: mission/axes binding (§1), 1–3 claims (§2), frontier step (§2b),
  L2 floor (§3), report contract incl. sources-marker / SHONEN rules (§4),
  commit/push/L0 (§5), hyaku addendum with band 8–16, attack share and routing
  (§6). §1 names 16 seats, attack share 25% literal / 31.25% counting the
  sentinel.
- Marker check: real committed work with matching hashes and evidence pointers
  throughout; not a marker. Status: `ok`.
- Conformance defect (status-neutral, recorded not barring admission): attempt 1
  died without a landed report (`lane-dead-no-report`) and the round was
  retried as attempt 2 in the same round number. The report names the retry
  honestly and documents the inherited items; fine.

## 2. Claim re-checks

Method: the two counters take 508–670 s (C1) and 285 s (C2); per PROTOCOL
§Gate standard (Closure consequence) this closure re-measures composition and
seal/scoreline receipts and verifies the committed frozen-run evidence rather
than re-executing the sibling's gate. Self-tests and the seal were re-run
independently; counter verdict lines are **evidence-verified** against
`.ufo/waves/round-64/final/` receipts, not re-measured on this session.

### C1 — calibration (`C1_HELDOUT` heldout 8 → 0, population 8)

Commands and observed output:

- `sha256sum plans/round-64-heldout.tsv` ⇒
  `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2`
  — matches the frozen seal; receipt `c1-heldout.txt` agrees. The TSV has 21
  lines (header + 20 rows: F1–F10, P1–P7, B3–B5).
- `bash plans/round-64-c1.sh --selftest` ⇒ `C1_HELDOUT_SELFTEST: PASS (cases=23)`
  (re-run here). Checker `C1_CHECK_SELFTEST: PASS (cases=111)` (re-run here).
- Committed receipts: `c1-base-counter.txt` ⇒
  `C1_HELDOUT: heldout=8 population=8 guard=0 (real=1 selftest=0 resid=1
  stub=1 vehicle=1)` rc 1, 508 s;
  `c1-heldout.txt` ⇒ `C1_HELDOUT: heldout=0 population=8 guard=1 (real=1
  selftest=1 resid=1 stub=1 vehicle=1)` rc 0, 670 s, with per-fixture
  `F2=value1 F6=value1 F8=value1 F10=value1 B4=value1 P6=value0 B5=value0
  P7=value0`; resid `accepted=0 rejected=0 population=10/6 guard=1`; stub
  refused (`e1_rc=2 e2_rc=2`); vehicle `heldout=5`.
- Guard legs: (a) unmodified `value=0` bits=i1..i7=1, (b) selftest 111 cases
  ≥ 109 floor, (c) resid reproduces, (d) stub refused, (e) A4 vehicle refused
  on the sealed set. Self-test tally, frozen-run verdict, revision-measured
  (`09cbee8` slim archive for BASE) all present in the receipt.
- SOURCES rows 143 → 153 counted independently:
  `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'` = 143 at `09cbee8`,
  153 at HEAD. ✓ matches report.
- Census re-run (`sources-census.sh validate --root … kagi`) ⇒ `kagi ok …
  EXIT=0` (W04 duplicate-url warnings across scopes are pre-existing; S148/S149
  join that warning class, no failure).

**C1 verifies.** Axis `calibration`: **improved**.

### C2 — operability (`C2_REFUSAL` terminates 0 → 1, killed=5 population=5)

- `bash plans/round-64-c2.sh --selftest` ⇒ `C2R64_SELFTEST: PASS (cases=21)`
  (re-run); `plans/round-63-c2.sh --selftest` ⇒ `C2R63_SELFTEST: PASS
  (cases=13)`; `plans/round-64-controls.sh --selftest` ⇒
  `CONTROLS_SELFTEST: PASS (cases=36)`.
- Committed receipts: `c2-refusal.txt` (314 B) ⇒ `C2_REFUSAL: killed=5
  population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1
  terminates=1 bound=1)` rc 0, `elapsed=285s`, inside `timeout 1200`.
  BASE: `c2-bound-off.txt` rc 124 (no verdict line); round-63
  `.ufo/waves/round-63/final/c2-refusal.txt` 7 B rc 124; `base/c2-e2e-head.txt`
  rc 124 at 240 s. Refutation leg `C2_RECURSION_BOUND=0` inside 240 s ⇒ no
  line; battery `C2-BOUND` reads `match` (`controls.txt`).
- Reported `guard=1` components `l1..l6=1 selftest=1 real=1` all present.
  Pre-freeze battery `match=3 mismatch=6` as reported (2 stub refusals,
  C2-BOUND + 2 positive `match`, NOWORK `mismatch` on pre-freeze BASE
  semantics — shape matches round 63).

**C2 verifies.** Axis `operability`: **improved**.

### 2b. Pre-file falsification ledger

`python3 scripts/hyaku/prefile-falsification.py --lane kagi --round 64` ⇒
`PREFILE-FALSIFICATION: pass claims=2 rows=14 attack_seats=7 findings=0`
exit 0. The ledger covers every claim in `claims.json` (C1, C2); seven
attack-role seat artifacts are read (R64Critic, R64Reviewer, R64MutC1,
R64MutC2, R64Connector, R64Sentinel, R64Revenger).

Standing `falsifies-wording` rows (4), each with a named narrowing — adjudicated
here, claim by claim:

- C1-1 (Critic, high): the pre-amendment census file carried the held-out
  distinguishing strings verbatim and the C1 seat prompt pointed at it — a
  real process breach of "held out from the instrument". Narrowing accepted:
  the claim verifies the instrument's behaviour on the sealed population, not
  builder blindness; the census is redacted at integration; the class-only
  prototype reproduces the readings from mechanism descriptions alone. The
  report narrows the wording (§Amendment A1, C1-1 note). The breach is a
  defect; it does not leave the claim unreconciled. Routed: open reviewer
  findings C1-3…C1-10 already carry the residual risk into round 65.
- C2-1 (high): the landed guard (d) is not the frozen (d) — the frozen one is
  unsatisfiable in fixture-only mode (SKIPS: 4). Narrowing accepted: the
  landed guard is the round-63 battery's PASS plus the round-63 guard (d),
  and the report states the substitution. The claim as landed is
  measurable; the frozen-guardsite defect is recorded, not silent.
- C2-2/C2-3 (high/medium): the bound lives in the measured tree, the counter
  carries no timeout, and `killed` is self-reported (leg-sum cross-check
  unimplemented). Narrowing accepted: the counter's own l3/l4 run under the
  parent's 1200 s budget, the refutation leg fires, and the report names
  the ceiling. Self-reported `killed=5` is a named ceiling (the five legs are
  round-63's), not hidden arithmetic.
- C2 MutC2: `C2-BOUND` reads `match` on the landed bytes, but the expectation
  is a fixed timeout — a slower host would read the same verdict for a
  different reason. Narrowing accepted: `terminates=1` is a termination claim
  on this host's load (285 s of 1200 s), not a liveness proof; the report
  says so.

No `falsifies-wording` row is left unreconciled: every failing row names its
narrowing in `claim-falsification.tsv` and the report carries the narrowed
wording plus the ceilings. The four findings' residual risks are routed to
round 65 (C1-3…C1-10, C2-3…C2-6 in `SCORECARD.md` §planned), not absorbed.

## 3. Discernment spot-check (LEARNING.md)

Re-opened from committed capture bodies with
`python3 corpus/rendered-text-v1.py locate <capture> "<quote>"`.

| item | decision | re-opened source | agree/disagree | reason |
|---|---|---|---|---|
| S147 (registry) / capture S151 — Stryker `equivalent-mutants` page, `There is no definitive way …` 11 words | admit, tier A | `.ufo/waves/round-64/capture/S151.body` | agree | quote resolves `count=1`; page carries the equivalent-mutant statement + no-separation consequence; ≤25-word quote. |
| S146 — survey chapter, `Computing the mutation score requires…` 10 words | admit, tier A | `.ufo/waves/round-64/capture/S153.p40.txt` | agree | quote resolves `count=1`; Crossref record (S163) independently confirms venue/pages/DOI, so the row does not rest on the publisher's site; peer-reviewed survey from a group independent of the registry's existing carriers. |
| S145 — PIT mutators reference, `Pitest will filter out equivalent mutations…` 17 words | reject | `.ufo/waves/round-64/capture/S145.body` | agree | quote resolves `count=1` but the page states operator design only; killer-phrase count (`cannot be killed`, `can never be killed`, `never be killed`, `cannot kill`) = 0/4; the rule's definition + consequence are absent. |
| S152 — arXiv 1909.02196, `the quantum approximate optimization algorithm` 7 words | reject | `.ufo/waves/round-64/capture/S152.body` | agree | quote resolves `count=1`; body carries 0 occurrences of `mutat` — the identifier belongs to an unrelated quantum-noise paper; rejected with the mis-derivation recorded. |
| S149 — Wikipedia `Mutation_testing`, consequence sentence 18 words | reject | `.ufo/waves/round-64/capture/S149.body` | agree | quote resolves `count=1`; reject is on source class (community-edited, no editorial gate) against already-held peer-reviewed carriers, with the measured presence of the primary-work citations disclosed — the honest reason is named. |

New registry-row quote check: the registry S147 row quotes 11 words
(≤25) with anchor + revision; census validates the full registry
(rows=153, malformed rows 0, no enum violations). `DOC_AUDIT: CLEAN
(entries=45 row_linked=42)` receipt present. Gate trend: spot-check agrees
with the gate on 3 admits and 2 rejects (5 of 5 sampled, including 2 admits
and 2 rejects cited above plus the class-based S149 reject).

## 4. Axis verdicts (agrees with the MANIFEST entry)

| axis | verdict |
|---|---|
| calibration | improved |
| operability | improved |
| depth | unchanged |
| coverage | unchanged |
| freshness | unchanged |
| adjacency | unchanged |

Score deltas: all six lanes scores stood 9 → 9 (scorecard, L1 reading);
closure grades the two claim axes `improved` on verified before→after
measurements, the rest `unchanged`. No axis harmed — gate receipts named in
the report remain consistent with the candidate: `SOURCES_CENSUS: CLEAN`
(rows=153 …), `DOC_AUDIT: CLEAN (entries=45 …)`, `RELEASE_CLOCK: CLEAN`,
`CLAIMS_DECLARED: CLEAN (claims=53)`, `ADJACENCY_SCOPE: DEFECT` unchanged
(carried breadth debt, named not absorbed), `CITATION_GATE: BROKEN (22
unresolved)` with all 22 pre-existing (round-34/35/43/44/51/53/54/58/59/60/62-era
documents and two absent `round-59/final/` paths — spot-confirmed none in a
round-64 document), `CLAIM_LEDGER: POLICY` with the 20 FAIL rows pinning
historical counts, all pre-existing; round-64's own R64-01…R64-03 pass and
every changed artifact was re-stamped (161 rows).

## 5. Trend verdicts (with evidence)

- **expansion: improved** — rows 143 → 153 (independently counted), entry
  `corpus/knowledge/claim-instrument-heldout.md` (45 `DOC_AUDIT` entries),
  four admissible carriers including a second independent peer-reviewed
  attestation (S145/S154 group/venue distinct from the registry's
  S137/S139/S140) and a Crossref-verified survey chapter (S146/S153).
  The 6 additional OpenBao pages are deliberately one absence claim (S154,
  6363 paths, 0 `mutat`) and not 6–7 near-identical rows.
- **quality: improved** — C1 is the first claim in the lane whose test set is
  not the instrument's own tables (sealed held-out set, seal verified by
  sha256 here); C2 closes the round-63 routed defect with a live refutation
  leg; `heldout` 8 → 0 and `terminates` 0 → 1. The lane also falsified and
  re-cut its own frozen census (M64-1) before landing anything.
- **discernment: improved** — the gate priced 24 pages (20 rows; 4 admits
  tier A, 6 rejects with reasons and flips, 2 byte-identical re-opens minting
  no rows, 1 identity record) and this closure's outside spot-check agrees
  (5 of 5, §3 above); every falsifying attack finding is narrowed in the
  ledger and its residual risk routed to round 65 rather than absorbed.

Ceilings: reviewer/critic open findings C1-3…C1-10, C2-3…C2-6 remain open;
the C1-1 builder-blindness breach is mitigated by narrowing but not erased
by re-sealing; D-63-3 (missing round-63 `controls.txt` receipt) stays open
and is routed to round 65 in `SCORECARD.md` §planned.

## 6. Routed defects (next round)

1. **D-63-3 (record defect, round-63 spot-check):** `ROUTED: d3=0` — the
   round-63 verifier spot-check named six receipts under
   `.ufo/waves/round-63/final/`; the tree holds five (no `controls.txt`).
   Owner: kagi. Either commit a reconstructed receipt with its own
   provenance or correct the routed leg's population to the five receipts
   the tree holds (QM57). Confirmed here that `round-63/final/` lists
   exactly five files. **Routed, not closed this round.**
2. **C1 golden-set ceiling:** the C1-1/C1-3…C1-10 findings — one held-out
   instance per class (class matrix) and a structural vehicle needle instead
   of the 15-string lookup — are routed to next round (`SCORECARD.md`
   §planned, item 1). The `vehicle` guard leg currently functions as a
   structural property check, but its needle string set is finite and total.
3. **`ADJACENCY_SCOPE: DEFECT` (breadth_drift=5 breadth_unverified=1):**
   unchanged since the carried debt; remains named-not-absorbed. No new
   scope has been introduced by this round's mutation-testing ground (all
   peer-reviewed rows are external; the lane's own OpenBao domain was swept
   silent, S154).
4. **Attempt-1 dead launch:** transparently reported and documented
   (inherited items re-verified); no action.

## 7. Closure recommendation

- `status: ok`, `admitted: true`, verdict category `admitted`.
- Verification type: gate-evidence-verified (frozen-run receipts, self-test
  tallies re-run independently on this session) + re-measured composition
  (seal sha, row counts, census exit 0, quote locates). The two 300–700 s
  counters were not re-executed by this closure.
- `capabilities_added`: none this round (no new capability demonstrated).
