# CritSeparability — round 28 falsify, pinned candidate 62a33b1

Seat KagiR28.CritSeparability-8. Claim-only C1/C2 overlays of candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`
over BASE `3553d499577084a6c98d7078906017840bbf7b28`; committed trees only, nothing run in the lane.

## Verdict: FAIL (fixable defect; frozen counts unaffected)

The measured effects separate cleanly: each frozen command moves only for its own claim, and the
selftest counts add exactly. Strict separability fails at one point: the candidate's C2 branch is
gated by C1's predicate, so on a forged-anchor row with a non-canonical observation the candidate
is NOT the union of its overlays and the C2 finding is masked. Nothing passes silently (exit 1
throughout), and no frozen fixture reaches this path.

## Findings (candidate paths:lines)

1. **C2 gated by C1.** `corpus/release-clock.py:617-619` sets `non_canonical` from the anchor OR
   the observation, and the `DERIVATION` check requires `not non_canonical`. Counterexample P2:
   derived S029 (feed S037; anchor cell `8.23.0`, `corpus/SOURCES.md:43`) set to anchored `8.22.0`
   (canonical, forged lower), observed `8.22.00`, not-fired, receipt mirrored.
   C2-only: exit 1, `DERIVATION S029` + `INCONSISTENT S029`. C1-only: exit 1, `NON-CANONICAL S029`.
   Candidate: exit 1, `NON-CANONICAL S029` only, so the forgery stays hidden until the observation
   is canonicalised. Masking is defensible only when the ANCHOR is non-canonical (P1 `8.23.00`);
   C2 binds only the anchor. **Smallest safe correction:** `:618` `not non_canonical` →
   `not non_canonical_version(anchored)`. Mutant: selftest PASS (106 cases) exit 0, default CLEAN30
   exit 0, P2 reports `DERIVATION` + `NON-CANONICAL`, P1 unchanged
   (`sandboxes/CritSeparability-8/anchoronly-guard.diff`). No selftest pins P2 either way.
   Impacted axis: freshness (finding fidelity), not the frozen counts.

2. **Helper ownership is one-way, through that guard only.** C1 owns `NON_CANONICAL_PREFIX` `:391`,
   `non_canonical_version` `:395`, `version_order` `:409` and the rewritten `numeric_version`
   `:419-430`. C2 owns `STABLE_TOKEN_RE` `:345` and `derived_anchor_bound` `:349-363`, which use only
   BASE helpers C1 leaves unchanged (`norm_version`, `NUMERIC_VERSION_RE`, `version_is_named`).
   C2 calls a C1 helper only at `:617-618`; C1 calls nothing from C2. Neutral hunks: dead
   `VERSION_RE` removal (hunk 1) and the `run_case` try/except (hunk 12, `:1097-1101`).

3. **Selftest fixture coupling.** C2 changes the shared synthetic feed-row default for EVERY case:
   `:1066`/`:1079` change `"Latest release"` to `"Latest release 1.2.0; series 1.2.x"`. C1's case
   "derived leading-zero anchor refused" (`:1253`) expects only `NON-CANONICAL` under that default,
   and holds only through the `:618` guard. With the guard removed, selftest exits 1:
   `FAIL derived leading-zero anchor refused: errors {DERIVATION, NON-CANONICAL}`. The correction in
   finding 1 keeps it passing. No BASE case changed expectation (C2-only passes all 79 + its 9).

4. **Source fixtures: no coupling.** `corpus/SOURCES.md` only appends S044–S049 (`:51-56`).
   S033–S037 (`:39-43`) are unchanged, and their anchor cells already name every derived anchor
   (3.13.3 / 2.2.0 / 2.7.1 / 8.23.0), so C2 is CLEAN on BASE's registry. C1 cites S044/S045 in
   comments only; the C1-only overlay on BASE's registry (without those rows) behaves identically.

5. **The committed tool cannot split this candidate by hunk manifest.** Hunk 4 (`evaluate`
   `:617-641`) and hunk 17 (C1 case `:1939`, C2 case `:1982`) mix both claims. With 4 and 17 in
   `shared`, the C2-only tree raises `NameError: name 'non_canonical_version' is not defined`
   (default and selftest exit 1). Moving hunk 3 into `shared` puts C1's `NON-CANONICAL` branch
   inside "C2-only". A faithful split needs `--from-patches` with hand-split patches plus the
   decoupling edit. SCORECARD.md:1128 defers the overlays to after landing, so plan `:84`
   ("executed, not asserted") is not yet met in the candidate.

## Executed checks (scratch clone /fast/scratch/hyaku/kagi-r28/CritSeparability-8, now deleted)

Overlays are the BASE tree plus candidate `release-clock.py` hunks, built by
`sandboxes/CritSeparability-8/build_overlays.py`:
- C1-only: hunks 1,3,5–9,12,14–16 plus the C1 lines of hunks 4 and 17.
- C2-only: hunks 1,2,10–13 plus the C2 lines of hunks 4 and 17. Its only non-candidate byte is the
  `:618` guard without `not non_canonical`.
- All 17 hunks reproduce the candidate blob (sha256 `ebe17f16…`). Overlay SHA-256 values are in
  `overlays/SHA256SUMS`.

Frozen tools ran unchanged from the clone (same committed bytes; `LANE` = clone). Scratch commits:
c1only `bd506e6`, c2only `93a38ce`. Every measure command exited 0.

| tree | `c1-measure.py <rev> <label> <out>` | `c2-measure.py …` | `--selftest` | default |
|---|---|---|---|---|
| BASE | mishandled 3/4, typed 0/4 | accepted 4/4, exact 0/4 | PASS 79 | CLEAN30, exit 0 |
| C1-only | mishandled 0/4, typed 4/4 | accepted 4/4, exact 0/4 | PASS 97 | CLEAN30, exit 0 |
| C2-only | mishandled 3/4, typed 0/4 | accepted 0/4, exact 4/4 | PASS 88 | CLEAN30, exit 0 |
| candidate | mishandled 0/4, typed 4/4 | accepted 0/4, exact 4/4 | PASS 106 | CLEAN30, exit 0 |

- Selftests all exited 0, and counts are additive: 79 + 18 (C1) + 9 (C2) = 106.
- `probe_guard.py` (exit 0), using the committed `separability.build_table_fixture`:
  - P1 (anchor `8.23.00`): BASE CLEAN exit 0; C1-only NON-CANONICAL; C2-only DERIVATION;
    candidate NON-CANONICAL.
  - P2: see finding 1 (BASE: INCONSISTENT, exit 1).
  - P3 (anchor `8.22.0`, canonical): BASE and C1-only CLEAN exit 0; C2-only and candidate
    DERIVATION.
- Mutants: no-guard selftest exit 1; anchor-only guard selftest exit 0 (PASS 106); whole-hunk
  C2+shared tree NameError, exit 1. Raw logs: `sandboxes/CritSeparability-8/runs/`.

## Not checked

`corpus/self-counts.py`, ledger, stamps and census on the overlays (BASE pins kept);
`separability.py`'s full run (only its overlay construction); network `--observe`; C1/C2
correctness beyond separability. No tools were installed or updated.
