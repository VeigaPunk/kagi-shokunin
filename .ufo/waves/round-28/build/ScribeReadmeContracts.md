# ScribeReadmeContracts — round-28 README draft, debt mapping, frozen-command defects

Seat: KagiR28.ScribeReadmeContracts-7 (scribe, leaf). Frozen BASE `3553d499577084a6c98d7078906017840bbf7b28`.
Lane checkout is byte-identical to BASE for the files that matter: `corpus/release-clock.py` and `corpus/release-clocks.tsv` sha256 equal BASE (`53823416…136dc`, `99a9b4bc…4fd`). No production file was written. Scratch copies live only under `.ufo/waves/round-28/sandboxes/ScribeReadmeContracts/` (`base/`, `fx/`).

Bottom line: the README section below is drafted but **not applied** (production read-only; the scribe does not edit `corpus/README.md`). Three of the frozen measurement predictions in `plans/round-28.md` do not hold at BASE, so the planned before→after numbers cannot be quoted as written. Closure of the three round-27 debts is **open** and must not be marked closed before the candidate's receipts exist.

## Findings (exact BASE path:line)

**F1. Frozen C1 fixture F1 (table leading zero) is caught by the receipt, not by the canonicality rule.** `plans/round-28.md:33`. Scratch copy with S040 `observed_version=3.15.01, verdict=fired` (TSV-only, the frozen edit set) → `RECEIPT-MISMATCH S040`, `RELEASE_CLOCK: FAILED (... observed=29 ...)`, exit 1, no traceback. Cause: the default run is pinned to `.ufo/waves/round-26/observe-2.json` (`release-clock.py:495-497`, sha `DEFAULT_RECEIPT_SHA256` at `:28`); `receipt_matches` compares `norm_version(parsed_version) == norm_version(observed_version)` (`:444`) and `3.15.1 != 3.15.01` as strings. Under the predicate this is TYPED, not MISHANDLED. The leading-zero string compare at `:582` and `:585` is never reached.

**F2. Frozen C1 fixture F2 (oversize component) reproduces the untyped traceback at BASE.** `plans/round-28.md:33` → scratch `S040 observed=3.15.`+4301×`1`, exit 1, last line `ValueError: Exceeds the limit (4300 digits) for integer string conversion: value has 4301 digits`. Trace runs `evaluate` → `is_regression` (`release-clock.py:386`) → `numeric_version` (`:380`). `main` catches only `SetupError` (`:1749-1751`). MISHANDLED, as the plan predicts.

**F3. Observe path, leading zero: BASE writes a fired observation.** `plans/round-28.md:34`. Run in-process (CLI cannot reach a local feed, see F7): `Python 3.15.01` → `parse_latest_version` returns `3.15.01` (`STABLE_TITLE_RE` `:710`, max by int at `:760`), then `observe_one` writes `verdict=fired` for S027 (`:798` string compare). MISHANDLED under the predicate ("a written fired observation").

**F4. Observe path, oversize: caught as a receipt error, not a traceback.** `plans/round-28.md:35`. Same harness, 4301-digit patch → `observe_one` records `error: Exceeds the limit (4300 digits) ...` via `except (OSError, ValueError)` (`release-clock.py:822`). `run_observe` prints only counts (`:894-896`), so stdout names no row. The predicate's "names a typed finding for the fixture's row" is not met on stdout. Classification: ambiguous, not MISHANDLED.

**Measured C1 BASE tally (predicate as written):** MISHANDLED 2/4 (F2, F3); TYPED 1/4 (F1); F4 ambiguous. The plan's "MISHANDLED k/4 → 0/4, TYPED → 4/4" has no fixed k, and F1's BASE TYPED status means the frozen set does not isolate the leading-zero rule.

**F5. Frozen C2 fixtures G1–G4 (TSV-only) do not reach derived-anchor logic at BASE.** `plans/round-28.md:61-68`. Scratch G1 (S008–S011 lowered to 3.13.0, observed equal, not-fired): `RECEIPT-MISMATCH S008..S011`, exit 1, `derived=11`. Cause: the receipt still records `parsed_version 3.13.3` (`observe-2.json`), and `receipt_matches` `:444` compares it to the lowered observed value. BASE ACCEPTED is therefore **0/4, not the planned 4/4**. The "ACCEPTED k/4 → 0/4" half of the before→after claim cannot move. Only EXACT (typed derivation findings naming exactly the group) can distinguish before from after, and BASE gives exit 1 for receipt reasons. G2–G4 were not executed; same mechanism expected ([INFERENCE] from G1 and the receipt pin).

**F6. CritFinalC2 #1 is reachable at BASE with no production-code edit.** `corpus/lessons/round-27.md:213-218` says the attack "requires editing both the pinned table and receipt". True but understated: `main` accepts an explicit receipt and sha (`release-clock.py:1744-1747`: `expected_sha256 = args.receipt_sha or ...`). Reproduction: scratch G1 table + a forged receipt (S008–S011 `parsed_version` set to 3.13.0, rest copied from `observe-2.json`), then `--receipt <forged> --receipt-sha <sha256(forged)>` → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0. The C2 fix must reject this on the derived binding alone, independent of the receipt.

**F7. Frozen F3/F4 are not executable through the unmodified CLI.** `plans/round-28.md:34-35` says "`--observe` over a local copy". `valid_public_https_url` (`release-clock.py:176-211`) accepts only public HTTPS with a global host; `request_body` (`:669-671`) rejects anything else. A local copy needs an in-process stub like the selftest's, or a live fetch of python.org (not a copy). The plan must name the mechanism, or F3/F4 are not measurements of the CLI.

**F8. Frozen C1 "sourced" requirement is unmet.** `plans/round-28.md:24-25` requires a registry row opened this round for the Python integer-string limit. `corpus/SOURCES.md` has zero hits for `4300`, `set_int_max_str_digits` or `int-max-str` (grep exit 1). Also `plans/round-28.md:21-22` cites "SemVer S042 §2" for the leading-zero rule, but the S042 row (`SOURCES.md:49`) quotes only §11.2, and "leading zero" appears zero times in `SOURCES.md`. [INFERENCE, not opened:] SemVer 2.0.0 §2 forbids leading zeros in numeric identifiers; the registry does not carry that quote.

**F9. "Bounded" is undefined in the frozen plan.** `plans/round-28.md:21` says "bounded" with no number. Python's default limit is 4300 digits; F2 is 4301 (`plans/round-28.md:33`), so F2 tests the edge only if the candidate's bound is ≤4300. The candidate must pin a value and the measurement must test the boundary (4300 passes int conversion, 4301 does not).

**F10. Extraction of "the version named by the located anchor" is undefined.** `plans/round-28.md:52-53`. The anchors are free prose (`SOURCES.md:39-43`); S034 and S035 each contain the version twice, which is harmless, but the rule must say how a version is extracted. Live check: `version_is_named(registry anchor, anchored)` holds for **15/15** derived rows, so the CLEAN30 control should survive a C2 binding (`release-clock.py:341-346`).

**F11. Bookkeeping that the candidate must move.** `corpus/claim-ledger.tsv:82` (R25-03, `RELEASE_CLOCK_SELFTEST: PASS \(79 cases\)`) and `:83` (R25-04, `derived=15`) pin counts that the candidate's new selftest cases will change. Stamps pin `corpus/release-clock.py` and `corpus/release-clocks.tsv` (`corpus/stamps.tsv:77-78`) and `SOURCES.md` (`:8`); any edit requires restamp. README/PROVINCE numbers are self-count-bound (`corpus/self-counts.tsv`, population at `:4`); the draft below contains no count.

**F12. Frozen tools do not exist yet.** `.ufo/waves/round-28/tools/` in the lane is empty (0 entries at inspection). `plans/round-28.md:29,59` names `c1-measure.py` and `c2-measure.py` as the frozen counting commands; no measured receipt exists at inspection time.

## Round-27 named debts, status at BASE

| Debt | Source (BASE) | Status |
|---|---|---|
| Leading-zero equality (`3.15.01` read as fired) | `round-27.md:223-224`; plan `:15-26`; reproduced F1/F3 | **open** |
| >4300-digit untyped ValueError | `round-27.md:225-226` (XRegressDraft); plan `:21-23`; reproduced F2 | **open** |
| CritFinalC2 #1 (derived anchors trusted) | `round-27.md:213-218`; plan `:46-55`; reproduced F6 | **open** |

No debt is closed by this report. Each closes only when the measured candidate's frozen predicates pass on the candidate revision.

## Draft README section (not applied; ≤10 lines; for planner to insert after `corpus/README.md:228`)

```
## Round-28 active contracts

- `corpus/release-clock.py` C1 (planned, unmeasured): a version token used as an anchor, table observation or feed entry must be canonical (no leading zero in a multi-digit component) and bounded; otherwise a typed finding, exit 1, never a release event or traceback.
- C2 (planned, unmeasured): a `derived:` row's anchored version must equal the version its `feed_source_id` registry row names in `corpus/SOURCES.md` (S033–S037); mismatch is a typed finding, exit 1, checked independently of the pinned receipt.
- Round-27 debts targeted, status open: leading-zero string equality, the >4300-digit untyped ValueError, CritFinalC2 #1 (derived anchors trusted).
- Closure evidence is the frozen `.ufo/waves/round-28/tools/c1-measure.py` and `c2-measure.py` receipts only; this text claims no closure.
```

Planner notes for the draft: (a) the section has no counts; (b) "closed" wording must wait for receipts; (c) if a candidate adds a `derived:` binding, the README line must cite `release-clocks.tsv` rows, not just "derived".

## Commands run (sandbox/BASE copies; exit codes)

- `git -C <lane> rev-parse 3553d499…` → hash, exit 0 (read-only).
- `git -C <lane> archive 3553d499… | tar -x -C …/sandboxes/ScribeReadmeContracts/base` → exit 0.
- `python3 -I -B corpus/release-clock.py` (BASE copy, Python 3.14.8) → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0.
- `python3 -I -B corpus/release-clock.py --selftest` (BASE copy) → `RELEASE_CLOCK_SELFTEST: PASS (79 cases)`, exit 0.
- Scratch F1 (S040 table lie, TSV only), default run → `RECEIPT-MISMATCH S040`, exit 1, no traceback.
- Scratch F2 (4301-digit observed), default run → ValueError traceback, exit 1.
- Scratch G1 (S008–S011 lowered, TSV only), default run → `RECEIPT-MISMATCH` ×4, `derived=11`, exit 1.
- Scratch C2 forgery, explicit `--receipt <forged> --receipt-sha <sha>` → `RELEASE_CLOCK: CLEAN (… derived=15)`, exit 0.
- In-process `observe_one` harness with stubbed `request_body` (F3, F4) → F3 `verdict=fired parsed=3.15.01`; F4 receipt `error=Exceeds the limit (4300 digits)`; no exception raised.
- In-process `version_is_named` over 15 derived rows → 15/15 named.
- `sha256sum` lane vs BASE `release-clock.py` and `release-clocks.tsv` → equal, exit 0.
- `grep` SOURCES.md for `4300|set_int_max_str_digits|int-max-str` → no match, exit 1; `grep -c 'leading zero'` → 0.
- `ls .ufo/waves/round-28/tools/` → empty.

Tools installed or updated: none (Python 3.14.8 was already present; not changed).

## Not checked

- No candidate revision exists; nothing after-fix is measured. The C1/C2 "after" column is unverified.
- G2–G4 and F1–F4 were not run as the frozen command set (tools absent); results are scratch-copy runs with the same edits.
- No network: feeds and vendor pages were not fetched; the Python integer-limit documentation and SemVer §2 were not opened.
- Ledger rows R25-03/R25-04 were not executed; stamps were not recomputed; the sources census gate was not run.
- Lane gates were not run in the lane checkout (per contract). No git mutating command, no commit, no push, no subagent, no SHONEN mark.
- The derived-anchor binding was checked only for the 15 live rows, not for future registry moves (a registry bump forces a matching TSV edit; the coupling was not costed).
