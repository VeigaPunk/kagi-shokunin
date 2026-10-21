# FMinorZero — round-28 falsify, carrier: table observation `3.015.1`

**Verdict: PASS** (candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, BASE `3553d499577084a6c98d7078906017840bbf7b28`)
Scope: C1 / freshness only — the table-observation path for one non-canonical token. C2 not attacked.

## Finding 1 (LOW, scope over-reach, does not break the carrier) — component bound is 18 digits, not CPython's 4300

`corpus/release-clock.py` (candidate 62a33b1) `:388` `VERSION_COMPONENT_MAX_DIGITS = 18`, applied at `:405`
`len(part) > VERSION_COMPONENT_MAX_DIGITS`. `sys.get_int_max_str_digits()` is 4300 here, so the candidate refuses
canonical SemVer tokens with 19–4300-digit components — tokens CPython converts fine and BASE accepted.
- candidate: `python3 -I -B d19-cand/corpus/release-clock.py --root d19-cand --receipt receipt-mirror.json --receipt-sha <sha>` (S040 `observed_version=1.2.9999999999999999999`) → `NON-CANONICAL S040`, `RELEASE_CLOCK: FAILED (… observed=29 fired=3 derived=15)`, exit 1.
- BASE: same fixture → `REGRESSED S040`, exit 1 (BASE ordered it fine; `base/corpus/release-clock.py:380` `tuple(int(part) …)`).

The plan's C1 defect is "a component longer than CPython's integer-string conversion limit"; 19–4300 digits are
inside that limit, so this refusal is broader than the stated defect. It is *declared* (`SKILL.md`: "component
over 18 digits"; `PROVINCE.md` mirrors it; ledger `R25-03` pins the count) and frozen `F2` (4301 digits) is
satisfied by either threshold, so no frozen measurement fails and no live row is affected. Not a carrier defect;
recorded so the bound is an owned decision, not an accident.

## Carrier result — exact typed category, no traceback, no fired verdict

Isolated exported trees: `git archive 62a33b1` → sandbox `{cand,base}`. All fixtures = `corpus/release-clocks.tsv`
S040 edit **mirrored into a copy of the pinned receipt** (`--receipt receipt-mirror.json --receipt-sha <sha>`),
so the pinned receipt's own pin is not the observation.

| # | fixture | candidate (62a33b1) | BASE (3553d49) |
|---|---|---|---|
| A | S040 `observed_version=3.015.1` (middle component leading zero), `verdict=fired` | `NON-CANONICAL S040` / `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=15)` **exit 1**, no `Traceback` | `RELEASE_CLOCK: CLEAN (… observed=30 fired=4 derived=15)` **exit 0** — the lie is accepted and counted as a fired release |
| B | S040 `observed_version=3.15.01` (patch component; frozen F1 shape) | `NON-CANONICAL S040`, `observed=29 fired=3` **exit 1** | `RELEASE_CLOCK: CLEAN … fired=4` **exit 0** |
| C | control: unmodified table + mirrored receipt | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit 0 | identical, exit 0 |
| D | A with S040's receipt record **deleted** | `NON-CANONICAL S040` **and** `NOT OBSERVED S040`, exit 1 → the category is row-derived, not receipt-derived | n/a |
| E | A with the **pinned default receipt** (no mirroring) | `NON-CANONICAL S040` **and** `RECEIPT-MISMATCH S040`, exit 1 → the typed finding survives the generic receipt mismatch | n/a |
| F | S040 `observed_version=3.15.` + 4301×`1` (oversize sibling) | `NON-CANONICAL S040` exit 1, **no `Traceback`** | `ValueError: Exceeds the limit (4300 digits) …` traceback at `base/corpus/release-clock.py:380`, exit 1 |

Concrete counterexample against BASE (the round-27 named debt "leading-zero equality", still live at BASE): A's
`fired=4` vs control `fired=3` — BASE's `numeric_version` (`base/corpus/release-clock.py:369-380`,
`int("015") == 15`) makes `3.015.1` numerically equal to the anchor `3.15.1`, while `norm_version` keeps the
strings unequal, so the row takes the `verdict == "fired"` branch at BASE and the clock reports a release event
that no canonical token names.

"Exact typed category": `NON-CANONICAL` (candidate `corpus/release-clock.py:631`, row-level) — outside the
BASE-era set `{ORPHAN, UNBIND, INCONSISTENT, BADFEED, REGRESSED, RECEIPT-MISMATCH, NOT OBSERVED}`, so it is not a
receipt-integrity finding in disguise. D and E isolate that.

"No fired verdict written" (observe path, offline; `request_body` stubbed to the local fixture feed — the same
substitution the script's own selftest uses; no network):
- candidate: `RELEASE_CLOCK_OBSERVE: wrote 1 observations (failed=1 fired=0 regressed=0)`; S040 record
  `verdict=null, parsed_version=null, error="non-canonical version token: feed newest stable entry"`;
  stdout `NON-CANONICAL S040`, exit 1. Refusal happens **before** any fetch (`corpus/release-clock.py:870-872`).
- BASE: `wrote 1 observations (failed=0 fired=1)`; S040 record `verdict="fired", parsed_version="3.015.1"` — a
  fired release event written from a non-canonical token.

## Frozen instrument, run independently (not redefined)

`python3 -I -B .ufo/waves/round-28/tools/c1-measure.py <rev> <label> <out.json>` (tool read-only from the lane):
- candidate: `C1_MEASURE candidate: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True`, exit 0;
  F1/F2/F3/F4 all `TYPED`, finding line `NON-CANONICAL S040`, `fired_observation_written=false`.
- BASE: `C1_MEASURE base: mishandled=3/4 typed=0/4 other=1/4 control_exit=0 control_clean=True`, exit 0; F1
  `MISHANDLED` (exit 0 CLEAN), F2 `MISHANDLED` (traceback), F3 `MISHANDLED` (`fired_observation_written=true`),
  F4 `OTHER`.
Control identical at both revs: `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`.

Pinned candidate's own selftest: `python3 -I -B cand/corpus/release-clock.py --selftest` →
`RELEASE_CLOCK_SELFTEST: PASS (106 cases)` exit 0 (BASE: `PASS (79 cases)` exit 0) — 106 matches the count
declared in `SKILL.md`/`PROVINCE.md` and pinned by ledger `R25-03` **at 62a33b1**. (Lane HEAD is a later repair
revision `5e84747` declaring 114; out of my pinned scope.)

## Frozen-fixture coverage gap (report only; fixture set NOT changed)

The frozen F1 token is `3.15.01` (patch component). My carrier `3.015.1` (middle component) is **not** in the
frozen fixture set, so the frozen command cannot detect a middle-component regression. The candidate handles it
correctly (row A): `non_canonical_version` checks every component (`:405`). I did not redefine the frozen commands.

## Not checked / residual risk

- C2 (`DERIVATION`) not attacked; live network feeds, real `--observe` runs, and the `op`/vault surfaces never
  contacted (all feed bytes local). `c2-measure.py`, `separability.py`, `round-conformance.py` and the
  claim-ledger/self-counts gates were not run in the lane checkout; no claim-ledger row was executed — pins read
  from `corpus/claim-ledger.tsv` only.
- Ordering equivalence spot-check: candidate `version_order` vs BASE int-order over 400 random X.Y.Z tokens →
  0 mismatches (candidate `corpus/release-clock.py:409-416`). Calibration of the 18-digit bound (Finding 1) was
  not audited beyond the three declarations named above.

## Artifacts retained (small), exported trees deleted

Sandbox `.ufo/waves/round-28/sandboxes/KagiR28.FMinorZero/`: `receipts-fminorzero.txt` (per-fixture stdout/exit
log), `out/c1-{candidate,base}.json` (frozen instrument output), `probe{3,5,6,7}.py` (offline observe/feed
probes), `observe-runner.py` (request_body stub). Exported trees (~2.2 GB) deleted; nothing written outside my
sandbox and this report.
