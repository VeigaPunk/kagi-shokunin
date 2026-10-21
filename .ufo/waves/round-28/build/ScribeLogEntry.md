# ScribeLogEntry — round-28 LOG skeleton (UNLANDED) and frozen-fixture findings

Seat `KagiR28.ScribeLogEntry-7` (leaf, no dispatch). BASE `3553d499577084a6c98d7078906017840bbf7b28`.
Plan text: claims commit `bdf90f58` (91 lines) plus appended correction `b9a42c0` (lane working copy equals `b9a42c0`; `diff` exit 0). Line refs are BASE `corpus/release-clock.py` unless marked. Sandbox `.ufo/waves/round-28/sandboxes/ScribeLogEntry/{base,exp}`. No production writes, no git mutation, no installs.

## Findings

1. **F1: table-only C1 fixture is vacuous (predicate gap).** Editing only S040 in `corpus/release-clocks.tsv` to `3.15.01`/fired ends exit 1 with `RECEIPT-MISMATCH S040` (`:613-615`). Nothing touches canonicality, yet the frozen TYPED predicate ("names a typed finding for the fixture's row") matches. Same edit with a mirrored receipt (`--receipt` + sha): exit 0 `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)` = MISHANDLED. Correction `b9a42c0` fixes the construction; the predicate still accepts any row-level finding. Counter-proposal: TYPED must name the canonicality finding code.

2. **F2: table-only C2 fixture is EXACT at BASE by accident.** Lowering S013,S022,S023,S024 to 2.1.0 (table only) gives exit 1, `RECEIPT-MISMATCH` for exactly those four ids. Matching by id alone yields "EXACT" before the fix. Mirrored receipts give exit 0 `CLEAN (... fired=3 derived=15)` = ACCEPTED 4/4 at BASE, so "before EXACT" must read 0/4.

3. **F3: F2 oversize tracebacks; F4 does not at BASE.** Table path (F2): exit 1, `Traceback`, `ValueError: Exceeds the limit (4300 digits)` at `:380`, reached via `is_regression` (`:567-568`). Observe path (F4, 4301-digit patch title): exit 1, no traceback; `observe_one` catches it (`:822-823`) and stores the raw message in receipt `error`, S040 verdict None. Under the frozen predicate F4 is TYPED at BASE. The plan's "untyped traceback" narrative covers F2 only. [INFERENCE] predicted BASE MISHANDLED k=3 (F1 mirrored, F2, F3), not 4.

4. **F4: leading-zero observe fires as narrated.** `STABLE_TITLE_RE` (`:710`) accepts `3.15.01`; `parse_latest_version` max-by-int (`:760`) returns it; run E writes S040 `verdict=fired parsed_version=3.15.01`. `numeric_version("3.15.01")` = (3,15,1) and `is_regression("3.15.1","3.15.01")` = False (`:366-380`, run D). Guard for the fix: a canonicality failure must become a typed finding, not a silent skip in `max()`, or a real newer release vanishes silently.

5. **F5: F3/F4 are not reproducible through `--observe` on "a local copy".** `request_body` refuses non-public HTTPS (`:669-671`; `valid_public_https_url` `:176-211`; `public_addresses` `:309-331`). Runs E/F required in-process injection of `request_body` (harness, not CLI). The frozen text and `b9a42c0` say neither; `c1-measure.py` must say so.

6. **F6: C2 "located anchor" has no code path; BASE data satisfies it.** `parse_sources` takes raw cell 5 (`:88`); nothing locates it. Feed anchors: `corpus/SOURCES.md:39` S033 `v3.13.3`, `:40` S034 `v2.2.0`, `:41` S035 `v2.7.1`, `:43` S037 `8.23.0`. All 15 `derived:` rows (`release-clocks.tsv` lines 5-8, 10-13, 18-23, 26) equal the first strict X.Y.Z of their feed anchor (run I: 15/15 True). Predicted after-state control CLEAN30 holds only if the fix uses this same rule; "located" must be defined in a plan correction.

7. **F7: C1 sourcing is not in the registry; "bounded" is unnumbered.**
   a. SemVer §2 ("no leading zeroes") has no located quote. `SOURCES.md:49` S042 teaches §11.2 only; `corpus/source-fetches.tsv:85` holds the §11.2 capture; grep for a leading-zero or §2 quote in SOURCES/source-fetches matched nothing.
   b. S042's own scope (`:49`): vendors "are not asserted to follow SemVer's API semantics". Applying §2 to vendor tags needs a Gate decision.
   c. No CPython integer-string-limit row exists; the only mention is `corpus/lessons/round-27.md:225`. S044 must be opened this round.
   d. Frozen text gives no bound. Default `sys.get_int_max_str_digits()` = 4300 (python3 3.14.8, env unset); `PYTHONINTMAXSTRDIGITS` changes it when `-I` is absent. The bound needs a literal value in a plan correction.

8. **F8: pins the LOG must move (not moved here).** `corpus/claim-ledger.tsv:82` R25-03 `PASS \(79 cases\)`; `corpus/self-counts.tsv:22` SC-CLOCK-SELFTEST and `:38` PV-CLOCK-SELFTEST; `corpus/stamps.tsv:77` release-clock.py (1758 lines, 75422 bytes) and `:78` release-clocks.tsv (31 lines, 5944 bytes); `SKILL.md:48,787,791`, `PROVINCE.md:54`. `claim-ledger.tsv:83` R25-04 pins `derived=15`; C2 must keep it.

9. **F9: round-27 conformance defects (frontier input, verified).** No round-27 START census at BASE (`.ufo/waves/round-27/` has `final/census-end.json` only; `git ls-tree` grep). First commit of `plans/round-27.md` is `144babc` ("(candidate)"), which also carries `.ufo/waves/round-27/build*` artifacts. C2 scope widened in-round, disclosed at `plans/round-27.md:50-56`. Named debt: `corpus/lessons/round-27.md:221-226`.

10. **F10: lane history.** Unnamed jj commits `d0f217f`, `1ddc2cf`, `e53d73c`, `35a1b59` and untracked round-28 build files sit in the lane; only `git show --stat` on `d0f217f`/`e53d73c` was inspected.

## LOG.md round-28 entry (draft; append after `LOG.md:1528`; every hash UNLANDED)

```markdown
## Round 28 — canonical version tokens; derived anchors bound to their feed rows (2026-10-21)

Two declared claims on the tied-lowest axes (all at 9): C1 freshness, C2 calibration.
BASE `3553d499577084a6c98d7078906017840bbf7b28`, `plans/round-28.md` (frozen in claims commit
`bdf90f58e43fdcae6291224197afe17812a16b55`; correction `b9a42c0e947648ad9f3cf0245784fcb08dc1a442`).
Motivation: round27 named debt (`corpus/lessons/round-27.md:223-226`: `3.15.01` compared by string;
a >4300-digit component raises ValueError) and the derived-anchor forgery limit (`corpus/release-clock.py:565-566`).

START census `.ufo/waves/round-28/census-start.txt` (plan states exit 0, 11 W04; not re-run here). END census: UNLANDED.

- C1 freshness, 9 → 9: canonical, bounded version tokens; typed findings, never a release or traceback.
  `.ufo/waves/round-28/tools/c1-measure.py` UNLANDED. MISHANDLED k/4 → 0/4 (BASE k UNLANDED); TYPED → 4/4 UNLANDED; control CLEAN30 UNLANDED.
- C2 calibration, 9 → 9: `derived:` anchors bound to `feed_source_id` registry anchors (S033–S037).
  `.ufo/waves/round-28/tools/c2-measure.py` UNLANDED. ACCEPTED k/4 → 0/4 (BASE k UNLANDED); EXACT → 4/4 UNLANDED; control CLEAN30 UNLANDED.
- Fixtures: receipt mirroring per `b9a42c0`; in-process feed injection for F3/F4 UNLANDED (plan silent).
- Sourced: S044 CPython integer-string limit UNLANDED; SemVer §2 quote or scope decision UNLANDED (S042 admits §11.2 only).
- Pins: selftest 79 → UNLANDED (`claim-ledger.tsv:82`, `self-counts.tsv:22,38`); `stamps.tsv:77-78` UNLANDED; R25-04 `derived=15` kept.

### Gate — sources opened and decided this round
| Candidate | Decision | URL, access date, located quote |
|---|---|---|
| S044 CPython integer-string limit | UNLANDED | UNLANDED |
| SemVer §2 (S042 extension) | UNLANDED | UNLANDED |

### Mistakes
| id | class | evidence | captured-by | fix (shown able to fail) |
|---|---|---|---|---|
| M28-1 | predicate vacuity (table-only fixture) | scribe F1/F2 | UNLANDED | UNLANDED |
| M28-2 | UNLANDED | UNLANDED | UNLANDED | UNLANDED |

Measured revision `UNLANDED`; final Gate receipts `.ufo/waves/round-28/final/` UNLANDED; END census UNLANDED.
Limits: UNLANDED.
```

## Commands run (cwd lane root unless noted; all read-only or sandbox-only)

| command | exit |
|---|---|
| `git -C <lane> archive 3553d49… \| tar -x -C sandboxes/ScribeLogEntry/base` | 0 |
| `git show bdf90f58:plans/round-28.md > sandbox/round-28.md` (91 lines) | 0 |
| `git show bdf90f58:.ufo/waves/round-28/census-start.txt` (11 `W04` rows) | 0 |
| `git show b9a42c0:plans/round-28.md \| diff -q - plans/round-28.md` | 0 |
| `git log --all -- plans/round-28.md`, `git show --stat` (144babc, d0f217f, e53d73c), `git ls-tree` / `git branch --contains` | 0 |
| `python3 -I -B corpus/release-clock.py` (sandbox base) | 0 (`CLEAN … observed=30 fired=3 derived=15`) |
| `python3 -I -B corpus/release-clock.py --selftest` (sandbox base) | 0 (`PASS (79 cases)`) |
| Experiments A–I via subprocess/in-process harness in `sandboxes/.../exp/` | A 1, B 0, C 1, G 1, H 0; E/F harness-only; D/I in-process |
| greps over SOURCES, source-fetches, lessons, knowledge, ledger, stamps | 0 (matches shown above) |

Tools installed or updated: none.

## Not checked

- The frozen `c1-measure.py` / `c2-measure.py` (absent at BASE; to be written by L1). Their predicates were tested by hand, not by those scripts.
- Post-fix behaviour: no fix exists here; all "after" values are predictions, not measurements.
- Live feeds, vendor pages, Python docs, SemVer text (no web fetch; no network). The §2 and integer-limit quotes are unverified.
- Full contents of `release-clock.py` lines 1-500 and 830-1700 beyond the functions cited; the selftest body beyond its count.
- The stagnation-window timing claim (plan: "cannot fire before round29"); only `SCORECARD.md:694` text was read.
- The `round-27` START-census absence beyond the file tree at BASE.
- Lane commit contents beyond `--stat` for `d0f217f`/`e53d73c`; untracked round-28 build artifacts.
- Gate receipts, END census, and ledger replay (`claim-ledger.sh`), all lane-gated and forbidden to me.
