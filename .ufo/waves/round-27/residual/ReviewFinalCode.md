# ReviewFinalCode — round-27 residual: surgical correctness review of `corpus/release-clock.py`

- Seat: KagiR26.ReviewFinalCode-27-t3 (reviewer, advises; L1 integrates). Date: 2026-10-21.
- Inputs: BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`, candidate `144babcb892f0a30154880a9f94aa59ca8ddf9c5`, lane `/home/vgpnk/Projects/shokunin/kagi-shokunin` (read-only; no Git/jj mutation, no commits, no lane-checkout execution).
- Scope: the diff `git diff 0a47dd18 144babcb -- corpus/release-clock.py` only (138 insertions, 10 deletions; 1608 → 1736 lines, arithmetic consistent). Candidate commit 144babc touches many more files (knowledge, wave records); only release-clock.py is reviewed here.
- Production writes: none. My writes: this report and `/fast/scratch/ReviewFinalCode-t3/{base,cand}.json`.

## Verification log (exact commands, exits, last lines)

1. Diff extraction — `git -C <lane> diff 0a47dd189356ea66ec83c3891eed54526e95b89b 144babcb892f0a30154880a9f94aa59ca8ddf9c5 -- corpus/release-clock.py` → exit 0; stat `148 +…, 138 insertions(+), 10 deletions(-)`; `wc -l` candidate 1736, `git show BASE | wc -l` 1608 (Δ=+128=+138/−10 ✓).
2. BASE instrument — `python3 <lane>/.ufo/waves/round-27/tools/c2-measure.py 0a47dd189356ea66ec83c3891eed54526e95b89b BASE /fast/scratch/ReviewFinalCode-t3/base.json` → exit 0, last line:
   `C2_MEASURE BASE: downgrades_accepted_clean=4/4 regressed_exact=0/4 control_clean=True default_exit=0`
3. Candidate instrument — same argv with `144babcb892f0a30154880a9f94aa59ca8ddf9c5 CAND …/cand.json` → exit 0, last line:
   `C2_MEASURE CAND: downgrades_accepted_clean=0/4 regressed_exact=4/4 control_clean=True default_exit=0`
4. Per-fixture runs are performed by the instrument as `python3 -I -B <clone>/corpus/release-clock.py --root <temp>/fixture-<name> --receipt <temp>/fixture-<name>/receipt.json --receipt-sha <sha256>` (cwd=clone, env PATH/HOME/LC_ALL=C/PYTHONDONTWRITEBYTECODE, timeout 120). Control receipt sha = the file's own `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169`; unfire `26e5901e…5444fb`; nonnumeric `0658a65d…c3651`. Fixtures edit only TSV fields[5]=observed_version and fields[7]=verdict plus the matching receipt records — anchors stay put.

| fixture | BASE exit / last line | CAND exit / findings |
|---|---|---|
| lie (S040 obs→3.15.0 fired) | 0 `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)` | 1 `REGRESSED S040`; FAILED observed=29 fired=3 |
| rollback (S027/S028→3.15.0 not-fired; S040/S041→3.15.0 fired) | 0 CLEAN observed=30 fired=3 | 1 `REGRESSED S027,S028,S040,S041`; FAILED observed=26 fired=1 |
| unfire (S027/S028→3.15.0 not-fired) | 0 CLEAN observed=30 fired=1 | 1 `REGRESSED S027,S028`; FAILED observed=28 fired=1 |
| nonnumeric (S012 obs→1.20.0 fired; anchor stays `v1.21.x`) | 0 CLEAN observed=30 fired=3 | 1 `REGRESSED S012`; FAILED observed=29 fired=2 |
| control (untouched) | 0 `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` | 0 same line |
| default (`python3 corpus/release-clock.py`) | 0 same CLEAN line | 0 same CLEAN line |

All four `regressed_exact` flags true at CAND (findings exactly the expected sets, no RECEIPT-MISMATCH noise — receipts were rewritten consistently by the fixture). This is the plan's C2 counting command measured: downgrade CLEAN at BASE → REGRESSED exit 1 after; live default receipt still CLEAN(30) at both revs.

5. Function-level probes — executed, not hand-waved: I imported the read-only production file (`importlib.spec_from_file_location`) in my own scratch process and drove `evaluate`/`observe_one`/`numeric_version`/`is_regression`/`feed_floors` with synthetic sources/rows/receipts (no gates, no selftest, no lane writes). Results quoted under Findings.

## Findings (by severity)

### LOW-1 — `feed_floors` admits invalid rows; a junk row misattributes `REGRESSED` to an innocent row (no exit-code change)
`feed_floors(rows)` (release-clock.py, new function after `norm_version`) filters only `row["malformed"]`, `clock != "feed"`, and non-numeric anchors. It never checks that the row's id resolves to an `on-release` source, so ORPHAN rows (unknown id, or bound to a `90d` feed source) contribute floors.
Probe (executed): bound S001 row `1.2.3/1.2.3/not-fired` with a consistent receipt plus orphan row `S999 → clock=feed, anchored 9.9.9, same feed_url` gives errors `{('ORPHAN','S999'), ('REGRESSED','S001')}`; without the orphan row the same tree is CLEAN. The bound row is blamed for the junk row's anchor.
Impact is bounded: any floor-contributing invalid row already fails the run (ORPHAN/INCONSISTENT), so this can never flip exit 1 → 0; it is misattribution and `REGRESSED`-count inflation inside an already-failing run. Duplicate rows do NOT misattribute (the `len(matches)!=1 → INCONSISTENT; continue` happens before value checks), probe-confirmed: duplicate 9.9.9 row → `{INCONSISTENT, RECEIPT-MISMATCH}` only.
Selftest blind spot of the same class: the existing `unknown id` case uses an orphan whose anchor EQUALS the bound observation, so it cannot detect poisoning. Advice (not applied; production read-only): restrict floors to rows whose id is a bound on-release source (requires passing `sources` into `feed_floors`), or name the limit next to QM25.

### LOW-2 — selftest has no case where the MAJOR component decides `is_regression` (corroborates the round's one mutant survivor)
Enumerated every version pair that reaches `is_regression` in the selftest: 1.2.2/1.2.3, 1.1.9/1.2.3, 1.10.0/1.2.3, 1.2.3 vs floors 1.2.4, 1.2.x/1.1.0/1.2.4, observe tests 1.2.2/1.2.3/1.2.4 — all share major 1 (live fixtures 3.15.x share major 3). A mutant that drops the major component (`seen[1:] < anchor[1:]`) passes all cases; parser cases with differing majors only exercise `parse_latest_version`, not ordering. This independently corroborates `.ufo/waves/round-27/residual/MutFinalClock.md` (5 killed / 1 survived / 0 inconclusive) by case enumeration, not by rerunning their mutant. Missing case: `fixture_row(anchored="2.2.0", observed="1.9.9", verdict="fired")` → must be `REGRESSED`. c2-measure's `nonnumeric` fixture does exercise a major-deciding comparison against pristine code (floor 2.2.0 vs observed 1.20.0 → REGRESSED S012), but that lives in wave tooling, not the shipped selftest.

### INFO-3 — `REGRESSED` takes typing precedence over field-validity `INCONSISTENT`
In the evaluate feed branch the new `is_regression(anchored|floor, observed)` test runs before the `anchor_ok`/date/verdict checks, so a row that is both below-anchor and field-invalid reports only `REGRESSED` (e.g. observed 1.2.2 with `observed_at 2026-02-30`). Exit unchanged; consistent with C2's "typed REGRESSED … exit1, never CLEAN". No case found where this hides a failure.

### INFO-4 — the receipt-verdict guard can never be the sole error, and its selftest case cannot kill its removal
`receipt_matches` requires the receipt verdict to equal the row verdict, and row verdicts are only `not-fired|fired`, so a `regressed` receipt ALWAYS also yields `RECEIPT-MISMATCH`; the new guard at the tail of evaluate adds the `REGRESSED` typing on top. The new case `regressed receipt refused` asserts both errors — delete the guard and the case still passes (RECEIPT-MISMATCH, exit still 1). The guard is defense-in-depth for TYPING; that typing is actually pinned by c2-measure's `regressed_exact` expectations and the observe-side tests, not by this case. Noted so nobody over-trusts the case's killing power.

### INFO-5 — `--observe` exits 0 after writing regressed receipts
`run_observe` counts `failures` (network errors) only; `regressed` receipts are neither failed nor fired (print gains `regressed=%d`). A pure-regression observe run exits 0; enforcement happens at the subsequent offline check (exit 1) plus the receipt guard. Matches the C2 wording (exit 1 belongs to the check). Flag only: an operator scripting on observe's exit code must read `regressed=N` from stdout, not the exit status.

### INFO-6 — remaining selftest gaps (behavior probe-verified correct today; gaps only weaken future protection)
No ordering case (higher-anchor row listed before the lower — probe: reversed order still REGRESSED); no explicit cross-feed isolation case (structurally enforced for valid rows because `feed_url` must equal the feed source's URL or BADFEED fires — probe confirmed); no malformed-row floor-exclusion case (probe: `feed_floors` skips malformed and rendered-quote rows); no `numeric_version` unit cases (probe: `"1.02.3"→(1,2,3)`, `"1.2"→None`, `"1.2.3-rc1"/"+build"→None`, `""/None/"-"→None`, `"1.2.3\n"`, `" 1.2.3"`, `"1.2.3.4"` all rejected; `is_regression("1.2.3","1.2.3")→False`; two-component anchor not ordered, as declared).

## Verified correct (positives)

- Red-before comment (release-clock.py:1059-1061) is accurate against BASE code: `downgrade fired lie` was CLEAN at BASE (fired branch needs only norm-inequality); `feed floor catches un-fire` CLEAN at BASE (both rows internally consistent); `feed floor lifts non-numeric anchor` CLEAN at BASE; `below-anchor not-fired` was already INCONSISTENT at BASE (comment says exactly that); `regressed receipt refused` was RECEIPT-MISMATCH-typed at BASE (failed either way — the comment's "typed" framing holds).
- Implementation matches QM25 (corpus/QUALITY.md:132) clause for clause: check-time floors = own anchor + highest numeric anchor on the same feed URL; observe-time floors = own anchor + row's recorded observation; equal-to-floor and unorderable (non-X.Y.Z, two-component, suffixed) inputs named limits. README.md:224-227 and lessons/round-27.md:85-89 describe the same rule. S042's captured quote ("Major, minor, and patch versions are always compared numerically.", §11.2) is the real SemVer 2.0.0 wording; I recognized it but did not re-fetch the page.
- `nonnumeric` fixture mechanics confirmed against the live table: S012 (`v1.21.x`, fired) shares `github.com/hashicorp/vault/releases.atom` with S013/S022/S023/S024 (numeric 2.2.0 anchors) — the feed floor lifts the non-numeric anchor exactly as the plan correction declares. Live registry satisfies the floor rule: S027/S028 observed 3.15.1 == python.org floor; S012 observed 2.2.0 == Vault floor; hence control/default CLEAN(30, fired=3, derived=15) exit 0 at both revs.
- `observe_one` verdict matrix (probe, 8 combos): below-anchor → regressed; return below a recorded higher observation → regressed; re-observe at the recorded value → fired (idempotent, receipt stays matchable); advance → fired; equal → not-fired; non-numeric anchor keeps the inequality rule; prerelease titles never parse so they cannot mask a downgrade.
- v-prefixed floors work (`floors` stores the raw string, comparisons re-normalize; probe: floor `v1.2.4` REGRESSEDs a 1.2.3 observation).
- Selftest count 67 → 76: +9 = 7 new `run_case` + 2 new `observe_one` cases ("grows only by the new cases" holds). Grounds: static grep (`run_case(` 32→39 lines incl. the def; explicit `cases += 1` 26→28 static, loops expand identically in both revs), committed receipts (round-25/26 `PASS (67 cases)`), and the round's own separability record (`SEPARABILITY c2-only: … selftest='RELEASE_CLOCK_SELFTEST: PASS (76 cases)'`, .ufo/waves/round-27/measurement-invocations.json:72). Integrated pin consistent: ledger R25-03 pins `PASS \(76 cases\)`, SKILL.md:48 / PROVINCE.md:54 say 76, and SC/PV-CLOCK-SELFTEST bind them (I did not rerun self-counts; CritFinalHarm records `SELF_COUNTS: CLEAN (claims=60 stale=0)` on this tree).

## What I did NOT check

- The selftest itself was never executed (contract: no selftests mid-flight; L1 runs final checks). All execution evidence is c2-measure in /fast/scratch clones and my importlib probes.
- Live network `--observe`, and any re-fetch of semver.org / PyPA pages (S042/S043 captures were taken as pinned data).
- Every other file in candidate commit 144babc (knowledge entries, ledger pins, SKILL/PROVINCE text beyond the 76-count cross-check).
- c1-measure.py / separability.py (other seats' items), and no mutant builds were rerun (MutFinalClock survivor corroborated by enumeration only).

## Residual risk

The floor rule makes every numeric anchor on a shared feed a refuser for all rows on that feed: any future feed where rows arm at different times must rearm together or the check fails by design (a re-verification stop per QM25/lessons, not a bug). The two cheapest hardening targets remain LOW-1 (floor-source filter) and LOW-2 (one major-deciding case).

Tool installs/updates: none. Pacman: untouched (host-wide pause respected).
