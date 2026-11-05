# Round 46 — frozen plan (kagi, attempt 1)

BASE (claim tip at declaration): `f5977284a8ce5bab09252be8196ee5dc18489926` (branch `master`; the
round-45 verifier spot-check landed at this tip and admitted round 45).
Counters: `plans/round-46-c1.sh`, `plans/round-46-c2.sh` (frozen; the predicate sentences below are
the same sentences as the counters' header comments). Pre-freeze controls: `plans/round-46-controls.py`
(11 controls, each with an independent expected value written before it ran). BASE and control
receipts: `.ufo/waves/round-46/controls/` (`c1-base.txt`, `c2-base.txt`, `controls-prefreeze.txt`,
`gates-base.txt`, `census-start.txt`, `instrument-sha256.txt`, `c2-positive-observe.json`).
Predeclaration commit: recorded in the report.

Axes: C1 → **operability**; C2 → **freshness**. All six axes sit at the saturation line 9 (tied
lowest). Stagnation: the last capability row's first-working round is 40; rounds 41–45 entered none,
so the window N=3 is exhausted and the nudge waives the lowest-axis duty. C2 works the lane's owned
freshness axis; C1 is an instrument move on a gate the lane already holds. No axis is retired or split.

Causal separability: C1 touches only `corpus/claims-declared.sh` (its `--run-selftest` block); C2
touches only the release-clock surface (`corpus/release-clock.py` default receipt binding and help
text, `corpus/release-clocks.tsv`, the round-46 receipt, and SKILL.md lines that describe the default
receipt). Neither counter reads the other claim's files: C1 can reach 3 with C2 absent, C2 can reach
29 with C1 absent (controls K1-P and K2-P are built from BASE with only their own change).

## C1 — operability: the declared-claim gate's own self-test kills the frozen mutants of its plan-to-manifest leg, 0 → 3

Problem (measured): round 45 added the plan-to-manifest direction to `corpus/claims-declared.sh`, but
its `--selftest` still asserts exactly 8 cases and has no fixture for `no-manifest-row` (round-45
closure, routed item 2; sentinel S-07 raised floor). At BASE the three frozen mutants of that leg
each pass the gate's own self-test (`controls/c1-base.txt`: rc m1=0 m2=0 m3=0).

Frozen predicate: `C1_SELFTEST_KILLS: value = KILLED when POSITIVE = 1 and EQUIV = 1 and REAL = 1,
else 0; target 3.`
- KILLED: mutants M1 (the no-manifest-row report and its counter increment replaced by `:`),
  M2 (floor 39 → 99), M3 (post-move condition inverted) whose `--selftest` exits non-zero.
- POSITIVE: the unmutated gate's `--selftest` exits 0 with `CLAIMS_DECLARED_SELFTEST: PASS`.
- EQUIV: equivalent mutants E1 (comment), E2 (`-lt 39` → `-le 38`), E3 (`$rname` → `${rname}` in the
  report line), E4 (`$rname` → `${rname}` in the post-move test) all still PASS — a self-test keyed
  on the bytes of the mutated lines kills them and scores 0 (control K1-F1).
- REAL: `bash corpus/claims-declared.sh` on the measured tree exits 0 with `CLAIMS_DECLARED: CLEAN`.
- A sed program that leaves the gate byte-identical is a SETUP refusal (exit 2), never a kill: the
  candidate must not edit the lines M1–M3 / E2–E4 rewrite (the bijection loop); only the
  `--run-selftest` block may change.

BASE measured: `value=0 killed=0 positive=1 equiv=1 real=1`. Controls (pre-freeze, all MATCH):
K1-0 do-nothing 0; K1-P reference cases 9–10 → 3; K1-F1 byte-keyed forgery → 0 (killed 3, equiv 0);
K1-F2 constant-PASS forgery → 0; K1-F3 positive self-test with a broken real manifest → 0.
Kill rules (frozen): C1 is killed if value < 3 at the candidate, if the counter exits 2 at the
candidate, or if the candidate's diff of `corpus/claims-declared.sh` touches any line outside the
`--run-selftest` block (header comment lines excepted).

Target: value 3 at the candidate.

## C2 — freshness: every BASE on-release clock re-observed live this round and the release-clock gate CLEAN again, 0 → 29

Problem (measured): the lane's release-clock gate reads FAILED on the real tree and has since the
round-39 landing `4776f71` (bisected over 6742fde, 4776f71, cb3f642, 209147c, 0d0192f, f597728 in
the L1 scratch): `ORPHAN S040`, `ORPHAN S041` (their recheck moved from on-release to an ISO date in
round 39 while their clock rows stayed), `RECEIPT-MISMATCH S040/S041`, and since round 41
`UNBOUND S098` (a REJECTED row carrying `on-release` with no clock). Every bound clock was last
observed 2026-11-04 (round-36 receipt). `controls/gates-base.txt` rc 1.

Frozen predicate: `C2_FRESH_CLOCKS: value = FRESH when DEFAULT = CLEAN and PINNED = CLEAN and KEPT = 1,
else 0; target 29.`
- ON29 (frozen): S005–S032 and S098, the 29 rows with recheck `on-release` at BASE.
- DEFAULT: `python3 -B corpus/release-clock.py --root <tree>` exits 0, `RELEASE_CLOCK: CLEAN`.
- PINNED: the same gate with `--receipt .ufo/waves/round-46/final/observe-r46.json --receipt-sha
  <sha256 of that file>` exits 0, CLEAN.
- KEPT: every registry id present at BASE is present at the candidate (no row deleted).
- FRESH: ON29 ids that still carry `on-release`, have exactly one clock row and exactly one receipt
  record with http_status 200, a 64-hex body sha256 and an observed_at date ≥ 2026-11-06 equal to
  the clock row's observed_at.

BASE measured: `value=0 fresh=0 default=0 pinned=0 kept=1`. Controls (pre-freeze, all MATCH): K2-0
do-nothing 0; K2-P live receipt observed 2026-11-06 replayed → 29; K2-F1 dates moved without a
receipt → 0; K2-F2 S098 deleted instead of bound → 0; K2-F3 fired S012 re-cadenced out of
on-release → 28 (below target); K2-F4 hand-written receipt with fake digests → 29 (**ceiling**, see
below). The positive control's receipt is evidence of feasibility only; the candidate observes again
after this freeze and its own receipt is the one measured.

Candidate work (named so the closure can match it): the S040/S041 clock rows are retired (their
registry rows are superseded by S095/S096 and no longer `on-release`); S098 is bound by a clock that
the gate accepts (preferred: a rendered-quote clock whose declared quote names the UTS #18 revision;
otherwise its declared title quote, with the ceiling named); one live `--observe` writes
`.ufo/waves/round-46/final/observe-r46.json`; the clock rows take the receipt's version, date and
verdict; the gate's default receipt path and pinned digest move to that receipt (the round-36
receipt stays as history, citable with `--receipt/--receipt-sha`); SKILL.md lines that name the
round-36 default are corrected. Fired clocks stay fired: the observation reports them, it does not
rearm them.

Kill rules (frozen): C2 is killed if value < 29 at the candidate, if any BASE registry row is deleted,
if any ON29 row's recheck leaves `on-release`, or if a non-author live re-observation (seat
`K46ReviewerLive` or the closure) disagrees with the candidate receipt's parsed version on any feed
clock that has not released in between.

Sourced claim (frontier step 4): C2 rests on the bound feed rows S033 (SOPS releases Atom), S034
(Vault releases Atom), S035 (OpenBao releases Atom), S036 (Python downloads RSS) and S037 (curl
release information), and on S098's own page, each opened this round by the observation; the
lesson's Gate records URL, access date and the observed newest stable version per feed.

Target: value 29 at the candidate.

## Mistakes mined (lesson §Mistakes; frontier step 3)

- M46-1 — class `instrument-drift` (a held gate silently red): `python3 corpus/release-clock.py`
  FAILED on every committed tip from `4776f71` (round 39) to BASE; no round re-ran its default mode.
  Captured-by: none — the round-36 migration of `corpus/claim-ledger.tsv` R25-04 replaced the only
  ledger row that ran the default replay with a byte pin of the round-26 receipt. Fix: a claim-ledger
  row that runs the default gate and expects `RELEASE_CLOCK: CLEAN`; shown able to fail by running
  that row's command at BASE (rc 1, FAILED) before it reads CLEAN at the candidate.
- M46-2 — class `control-validity` (caught pre-freeze): the first K1-F1 byte-keyed forgery grepped for
  strings its own inserted lines contained, so it matched itself in every mutant and killed nothing;
  the control read 0 for the wrong reason (equiv=1, killed=0). Fixed before freeze by split literals;
  the corrected control reads killed=3 equiv=0. Captured-by: reading the control's full receipt line,
  not its value.

## Routed items from round 45 (closure `corpus/lessons/round-45-verifier-spotcheck.md` §5)

1. `corpus/README.md` coverage map rows for `knowledge/iso-11770-3-edition-status.md` and
   `knowledge/feed-token-boundaries.md` — added this round (curation, not a claim).
2. `claims-declared.sh --selftest` no-manifest-row fixture — C1.
3. `.ufo/waves/round-45/final/measured-at-candidate.txt` hygiene — erratum E46-1 in the round-46
   lesson; the round-45 receipt is not rewritten.
4. Sentinel ceilings S-07 (C1 here, at the gate's self-test), S-09, S-10 (live re-fetch: C2's
   non-author live re-observation leg), S-11, S-14 — named in the lesson; only S-07 and S-10 are
   worked.
5. Carried, unchanged: D4 vocabulary, B1, round-40 report erratum (operator-side), SEAT-STATUS lines.

Considerthese: no new file since `considerthese/2026-10-26.md`; its unimplemented proposal 1 is operator
policy and is not taken. Assimilation: none (no staged `merge/kagi/` theme matches either claim).

## Wave contract (one v1 build wave, 12 seats; policy `scripts/hyaku/ufo-wave-policy.json`, band 8–16)

Roles: executor ×3, scribe ×1, scout ×1, connector ×1, reviewer ×2, critic ×1, mutation-tester ×1,
sentinel ×1, revenger ×1. Attack seats (reviewer ×2, critic, mutation-tester) = 4/12 = 33 %.
Connector 1 (≤ 2). The planner seat is the L1 (the validator rejects the role). No residual call
planned. Seats write only under `.ufo/waves/round-46/build/` and scratch `$HYAKU_SCRATCH/kagi-r46/<seat>/`;
they never commit, push or run a mutating git/jj command.

## Declared ceilings (named, accepted as stated)

- C1: a self-test that recognises the mutants by some other byte property than the lines E2–E4
  rewrite is not refused by the counter; the diff review is the remaining leg.
- C2: the counter cannot tell a fetched receipt from a hand-written one with plausible digests
  (K2-F4 scores 29). The non-author live re-observation is the leg that can; feed clocks only (page
  digests are volatile).
- C2 re-observes; it does not re-verify the teachings of the 13 fired clocks (that work is a later
  round's; the fired set is reported, not hidden).

## Frozen

Frozen at the predeclaration commit. No predicate, counter, target or kill rule changes after any seat
has scored; a change is an L0 question and a named amendment, not a silent edit.
