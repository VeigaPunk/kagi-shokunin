# KagiR28.CheckDefault — default-clock identity falsification (round 28)

**Verdict: PASS (narrow).** Default release-clock output at BASE `3553d499…` and pinned candidate `62a33b1b…` is byte-identical (`RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0), and `corpus/release-clocks.tsv` is unchanged between the two revisions. No concrete mismatch found; my one control shows the candidate's new C2 gate is live on the default data path, so the identical default line is not a vacuous no-op.

Target `…/kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (lane HEAD is that commit; `git diff --quiet 62a33b1b… -- corpus/` clean → lane worktree corpus IS the candidate blob set). My only writes: this report and `.ufo/waves/round-28/sandboxes/KagiR28.CheckDefault/`. No production file touched, no lane gate run in the lane checkout, no host-private ledger row executed.

## 1. Default output identity (primary claim)

```
mkdir -p …/sandboxes/KagiR28.CheckDefault/{base,cand}
git -C …/kagi-shokunin archive 3553d499… corpus .ufo/waves/round-26/observe-2.json | tar -x -C …/base
git -C …/kagi-shokunin archive 62a33b1b… corpus .ufo/waves/round-26/observe-2.json | tar -x -C …/cand
cd …/base && python3 -I -B corpus/release-clock.py    # exit 0
cd …/cand && python3 -I -B corpus/release-clock.py    # exit 0
```

- Both stdout identical, stderr empty, exit 0: `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`.
- `cmp base.out cand.out` → exit 0 (byte-identical); sha256 of both stdout files `1a5cff1c6df55f536b165949e8c64bbac07d98079e85d2b416adf717f0e21232`.
- Emitting path (candidate): `corpus/release-clock.py:713` (`print_result`), format string `corpus/release-clock.py:717`; counters accumulated in `evaluate()` (`corpus/release-clock.py:554`).
- Receipt pinning, both trees: `.ufo/waves/round-26/observe-2.json` sha256 `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` == `DEFAULT_RECEIPT_SHA256` (BASE `corpus/release-clock.py:28`, candidate `:2068`) — the run measured the pinned receipt, not a substitute.

## 2. `corpus/release-clocks.tsv` unchanged

- `git diff --numstat 3553d499… 62a33b1b… -- corpus/release-clocks.tsv` → empty (exit 0); identical blob id both revs `883b23e01b84addf09fafaf9350131a97981dc02`; extracted file sha256 `99a9b4bc36df89a0a86ca7fe16f922aab0abf8f4c3a3380bacdd8924cd02e6fd`.
- `git diff --stat BASE…CAND -- corpus/` = 8 changed files (`QUALITY.md`, `README.md`, `SOURCES.md`, `claim-ledger.tsv`, `lessons/round-28.md`, `release-clock.py`, `source-fetches.tsv`, `stamps.tsv`); `release-clocks.tsv` absent from the list.

## 3. Independent recount (my parser `indep.py`, no lane code imported)

Same numbers at BASE and candidate: `rows=30 on_release=30 unbound=0 observed=30 fired=3 derived=15`; `fired_ids=S012,S027,S028`; `derived_ids=S008,S009,S010,S011,S013,S014,S015,S016,S021,S022,S023,S024,S025,S026,S029`; `unbound_ids= missing_obs= extra_obs=` (none); `on_release_ids=S005…S032,S040,S041` (30 ids). The six counters are independently confirmed, not merely echoed. (My `bound=20` counts feed-clock rows; the tool's `bound=30` counts all 30 rows, each bound to a feed source or to its own capture quote.)

## 4. Calibration spot-check of the 15 derived rows

Each `derived:` row's `anchored_version` vs the strict `X.Y.Z` token(s) in its `feed_source_id` registry row's **anchor** cell (the cell C2 binds to): S033→3.13.3 (S008–S011), S034→2.2.0 (S013, S022–S024), S035→2.7.1 (S014–S016, S021, S025, S026), S037→8.23.0 (S029) → `c2_binding_mismatches=0` at both revs. Candidate rule `corpus/release-clock.py:349` (`derived_anchor_bound`), enforced at `corpus/release-clock.py:618-625` (`errors.add(("DERIVATION", source_id))`); it reads only the anchor cell, never `teaches` (where curl's dev label 8.23.1 lives).

## 5. Non-vacuity control (own fixture, sandbox only)

Lowered ONE derived row (S029 `8.23.0`→`8.22.0`, observed likewise, receipt copy mirrored per the plan's L1 fixture correction) in copied sandbox trees:

```
cd …/ctrl-base && python3 -I -B corpus/release-clock.py --receipt … --receipt-sha <sha>   # exit 0
  → RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)
cd …/ctrl-cand && python3 -I -B corpus/release-clock.py --receipt … --receipt-sha <sha>   # exit 1
  → DERIVATION S029
    RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=14)
```

BASE accepts the lowered derived anchor (round-27 defect); the candidate emits a typed finding and exits 1 → the C2 gate runs on exactly the default data path, so the byte-identical default is a true negative, not a skipped check.

## 6. Frozen counting commands (sanctioned control channel)

`python3 -I -B .ufo/waves/round-28/tools/<tool> <rev> <label> <out.json>`, out.json in my sandbox; all four exit 0:

- `c1-measure.py 3553d499… base` → `mishandled=3/4 typed=0/4 other=1/4 control_exit=0 control_clean=True`
- `c1-measure.py 62a33b1b… cand` → `mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True`
- `c2-measure.py 3553d499… base` → `groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True default_exit=0`
- `c2-measure.py 62a33b1b… cand` → `groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0`

Both instruments' `control` stdout at both revs is the same single line (`c1-base.json` / `c1-cand.json` `stdout_repr` = `'RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)\n'`, stderr `''`). Sandbox selftests: BASE `RELEASE_CLOCK_SELFTEST: PASS (79 cases)` exit 0; candidate `PASS (106 cases)` exit 0.

## What I did NOT check (residual risk)

- No network: no `--observe`, no feed re-fetch → the three `fired` rows (S012, S027, S028) are confirmed only against the pinned round-26 receipt and the registry anchors, not against live feeds.
- Did not audit the frozen instruments' fixture construction (C1/C2 seats' scope); I consumed only their `control` channel; did not verify the truth of new registry rows S044–S049 in `SOURCES.md` / `source-fetches.tsv` (out of scope; all `recheck=90d`, no `on-release` row added — `on_release` stays 30).
- Did not execute host-private ledger rows, did not touch `claim-ledger.tsv` pins, did not run lane gates in the lane checkout; every execution ran in `.ufo/waves/round-28/sandboxes/KagiR28.CheckDefault/`. No tool installed or upgraded.

## Concrete counterexample

None for the assigned claim. The nearest falsification attempt — that the candidate's C1/C2 code never runs on the default tree, making the byte-identical output vacuous — is refuted by §5 (BASE exit 0 CLEAN vs candidate exit 1 `DERIVATION S029` on the same single-row fixture).
