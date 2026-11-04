source: S072 — https://app-updates.agilebits.com/product_history/CLI2
verified-at: 2026-11-03 — release entry opened; byte probe measured on installed op 2.41.1
recheck: 180d — reopen S072; replay the frozen counters in plans/round-32.md

# Round 32 — self-description sweep and op byte-evidence freshness

Frozen BASE `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`; plan `507dd9ffed82e79532eeb8588f8ba299c88c5edc`, committed alone before data. Late round-31 evidence R2 landed in `76241c0a8641868f41f4c5801e2aa6bb7aaeb03a`.

## Gate

| Candidate | Decision | Located evidence |
|---|---|---|
| S072, 1Password CLI release identity | ADMIT tier A for published release identity only; bytes are measured locally, not proved by release notes | https://app-updates.agilebits.com/product_history/CLI2 accessed 2026-11-03, article v2410101 heading: “2.41.1 (build #2410101 ) – released 2026-10-21” (7 whitespace-separated words); saved body and digest in `.ufo/waves/round-32/build/ScoutOp.md` |
| considerthese/2026-10-26.md proposal 4, BACKLOG file | REJECT: operator input is read-only; round-31 proposal 2 already supplied the SCORECARD lane-status line. Flip: a second status surface cannot be carried there | `considerthese/2026-10-26.md` §Self-improvement suggestions, opened 2026-11-03: “Create `considerthese/BACKLOG.md`” |
| NIST SP 800-57 family-status assimilation | Not selected under this round's two-claim cap; no adoption or source row | Read-only package `/home/vgpnk/Projects/shokuknow/merge/kagi/`; the plan shorthand refers to this external root, not a lane directory |

Non-author admit/reject spot-check: pending; dispatched seats are still this lane.

## Mistakes

| id | class | evidence | captured-by | fix shown able to fail |
|---|---|---|---|---|
| M32-1 | self-description outlived frontier-to-core move | round-31 verifier R1/R4/R6; BASE sweep SD1=2 SD2=2 SD4=1 | none for cross-document comparison; QM33 now captures the frontier part | `corpus/self-description-sweep.sh`; seven-case selftest clean plus one planted mismatch per SD id, `.ufo/waves/round-32/build/sweep/selftest.txt` exit 0; independent ReviewSD plants caught 3/3 |
| M32-2 | unmeasured BASE expectation frozen as fact | plan SD5 expected 3 and total 10; ReviewSD independently measured SD5=1 and total 8 | QM34 | record discrepancy, keep frozen predicate; do not repair history or change target after data |
| M32-3 | counter includes author-inaccessible correction | SD6 counts `corpus/lessons/round-30-verifier-spotcheck.md:41`, an integrator-owned file | none | do not edit the verifier file; retain residual and report C1 not admitted if it remains; no claimed fix |

## Frozen counter identity and actual BASE

`bash corpus/self-description-sweep.sh --root <BASE clone>` using the delivered counter reads:
`SELF_DESCRIPTION: MISMATCH n=8 (SD1=2 SD2=2 SD3=0 SD4=1 SD5=1 SD6=2)`, exit 1.
Receipt `.ufo/waves/round-32/build/sweep/base-run.txt`; independent derivation `.ufo/waves/round-32/build/review/ReviewSD.md` agrees. The erroneous plan estimates 10 and SD5=3 are superseded as estimates only; the target n=0 and kill rule do not change. SD1 counts per-theme frontier-line pairs (two hits on one line), not unique lines.

C2 BASE: installed `op --version` 2.41.1, §11 counter 0 (grep exit 1), six-class probe CLEAN exit 0; `.ufo/waves/round-32/build/probe/`. The two stub witnesses both produce DRIFT exit 1; the version-named stub actually witnesses failing run behaviour, not version enforcement. The probe does not read its version. Final receipt therefore records version/path/package/hash together with the unchanged probe execution.

## Routed corrections and limits

R1/R6: remove core-held OIDC and secret-scanning themes from active Frontier lists, preserving their Core records. R3/R4: appended Corrigenda 3 in round-31 lesson corrects Audience location precision and supplies the M31-6 table row. R5: round-32 calibration row names every operator red and justifies holding 9, without claiming the red passed. R2: late-seat files committed in 76241c0.

The round-31 lesson's slash-list citation has a historical marker added on its original line (logged in Corrigenda 3); the integrator-owned round-30 verifier citation is untouched. C1 cannot be self-admitted if its frozen n=0 target remains unmet. No predicate narrowing, gate-policy edit or verifier-file edit is authorized here.

CriticClaims recommends amendments after BASE data already existed. No post-data predicate amendment is made. Recorded ceilings: SD3 checks existence rather than evidence truth; SD4 checks row presence, not table placement; SD5 checks naming rather than score correctness; SD1 has a weak Core substring trigger; SD2 is literal-heading scoped. SOURCES Leads and historical SHONEN citation summaries are outside SD1–SD6. The version text counter measures naming, not proof of measurement. S072 supports publication identity only. No vault/account/ref resolution or handler contact occurred.

## Registry changes

New S072 only, tier A/mined, used-by this lesson (whose source declaration cites S072); one matching capture row. Existing status/recheck/used-by changes: none. Attempted migration of the legacy byte entry to a provenance trio triggered three SC_CREDENTIAL findings in its pre-existing historical examples. That unlanded migration was withdrawn rather than claiming legacy corpus safety; the existing legacy gap remains 21. The subsection cites S072 for release identity; the lesson is the census-bound evidence path. This differs from the plan's expected used-by path and is recorded as a conformance deviation, not a changed byte predicate.

Assimilation: none. No tools installed or upgraded. SHONEN remains four author `[~]` boxes; no promotion claim.

## Measurements

Final committed receipts are under `.ufo/waves/round-32/final/`; the fleet report names the measured lane revision and each exact exit. The frozen counter is retained even if C1 fails. All six scalar scores remain 9; no inferred independent discernment agreement is claimed.

## Snapshot migrations (reviewed metadata, not claim predicate changes)

Measured membership commands `bash corpus/row-identity.sh stamps`, `scorecard-rounds`, `revision-added`: 102→104 stamps (lesson + sweep), 38→40 headings (two round32 sections), 39→41 revision additions. Digests respectively `5c453cd1a99662b59ac98eb3e0ddc2d2619dee07ff3619a49b8f764cf259dc3a`, `e66c6362f0249f467407fbb73d216c559d76f6658c437e39ae77127fc8d36ab3`, `cb09c4e4df76447655e19c3994dd4fdeccc419fe39c7645951029f8b53a78866`. R12-03/R13-01/R22-03/R24-05/R24-06/R24-15 migrate those projections; R21-02/R31-02 migrate census rows71→72, A68→69, mined67→68, captures71→72; entries_sourced10/legacy21 remain. Existing registry mutable cells unchanged. Stamp regeneration uses every original path plus the two additions under LC_ALL=C; probe and gate source bytes are unchanged.

## Self-evaluation

Accuracy3 (BASE estimate wrong, corrected transparently); completeness3 (C1 inaccessible residual retained); clarity4 (claim verdicts separate from round admission); actionability4 (frozen rerunnable counters); conciseness3 (large wave records). Mean3.4; strongest improvement is executing controls before freezing rather than estimating them. The report must not call this round admitted.
