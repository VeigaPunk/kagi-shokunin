# XRegressDraft — C2 release-clock regression refusal (sandbox draft)

Lane: kagi-shokunin · Round 27 · seat `KagiR26.XRegressDraft-17` · Frozen BASE `0a47dd189356ea66ec83c3891eed54526e95b89b` · Axis served: freshness (C2 only).

Status: DRAFT in sandbox. No production file written. Selftest NOT run. Every expectation below is either a hand trace against BASE/draft logic or a parse-only check. Nothing here is a pass.

## 1. Artifacts

Under `.ufo/waves/round-27/sandboxes/XRegressDraft/`:

| Item | Path | Verification |
|---|---|---|
| Draft (BASE + C2) | `corpus/release-clock.py` | edited from BASE blob only |
| Pristine BASE copy | `base/corpus/release-clock.py` | `git hash-object` = `40c1ba127e21cb8a1ee765afcbb17894aad0ecfb` = `git rev-parse 0a47…:corpus/release-clock.py` |
| Unified diff | `release-clock-C2.diff` | `diff -u` with `a/` `b/` labels; 94 added, 6 removed lines |

Production working tree is not BASE. `corpus/release-clock.py` carries an uncommitted +76/−8 L1 integration (`git diff --stat` at read time; it has `feed_floors` and a `regressed` count). I drafted from the BASE blob. The working tree was read for comparison only.

## 2. Change, with BASE anchors

1. **Helpers.** `NUMERIC_VERSION_RE = [0-9]+\.[0-9]+\.[0-9]+` (ASCII digits, `fullmatch`, no strip). `numeric_version(v)` = `norm_version(v)` then int tuple or `None`. `is_regression(anchored, observed)` = both numeric and `observed < anchored`. Inserted after BASE `corpus/release-clock.py:362-363` (`norm_version`). Uses the existing `norm_version` convention (strips one leading `v` or `V`), so no second convention.
2. **evaluate, feed rows.** BASE `:518-523`: REGRESSED branch placed first, `if verdict == "regressed" or is_regression(anchored, observed_version)` → `errors.add(("REGRESSED", …))`, row invalid. The old INCONSISTENT gate becomes `elif`. A regressed row never reaches the `fired` branch (BASE `:524-525`), so it is never counted in `observed` or `fired`.
3. **evaluate, receipts.** After BASE `:555-557` (receipt-mismatch chain): receipt `verdict == "regressed"` → `REGRESSED`, row invalid.
4. **observe_one.** BASE `:728-734` (feed verdict expression) becomes three-way: `regressed` / `not-fired` / `fired`. `run_observe` fired count (BASE `:822-823`) is unchanged, so a regressed receipt is not counted as fired.
5. **Exit path.** `main` always runs `evaluate` on the receipts (observe-then-evaluate in one call included), and returns `0 if result["passed"] and observation_failures == 0 else 1` (BASE `:1604`). A regressed observation therefore cannot leave `main` with exit 0 (traced, not run).

## 3. New selftest cases (12 total; BASE count not measured)

Evaluate level (`run_case`, inserted after BASE `:993`):
- `downgrade fired lie refused`
- `table downgrade lie refused`
- `downgrade un-fire refused`
- `regressed verdict refused`
- `downgrade observe receipt refused`
- `newer numeric fires`

Observe level (loop over `observe_one`, inserted after BASE `:1329`):
- `downgrade observe`
- `equal observe`
- `newer fires`
- `non-numeric anchor unchanged`

Unit (after the observe loop):
- `numeric_version strict X.Y.Z core`
- `prerelease ignored`

Traced expectations (NOT RUN). "BASE" column is the BASE logic traced by hand. Red means the case fails at BASE.

| Case | Draft expectation | BASE (traced) |
|---|---|---|
| downgrade fired lie refused | errors `{REGRESSED}`, observed 0, fired 0 | CLEAN, fired 1 (red) |
| table downgrade lie refused | `{REGRESSED}` | `{INCONSISTENT}` (red, label changes) |
| downgrade un-fire refused | `{REGRESSED}` | `{INCONSISTENT}` (red, label changes) |
| regressed verdict refused | `{REGRESSED}` | `{INCONSISTENT}` (red) |
| downgrade observe receipt refused | `{REGRESSED, RECEIPT-MISMATCH}` | `{INCONSISTENT, RECEIPT-MISMATCH}` (red) |
| newer numeric fires | no errors, observed 1, fired 1 | same (control) |
| downgrade observe | verdict `regressed`, no error | verdict `fired` (red) |
| equal observe | verdict `not-fired` | same (control) |
| newer fires | verdict `fired` (1.10.0 over 1.2.3) | same (control; a lexical comparison would fail it) |
| non-numeric anchor unchanged | verdict `fired` (anchor `1.2`) | same (control) |
| numeric_version / prerelease ignored | unit assertions | NameError at BASE: draft-only, not red-before evidence |

Every BASE `run_case` expectation was re-traced against the draft and is unchanged. The only BASE-visible behavior change is the label of a downgrade table row that BASE already refused (`INCONSISTENT` becomes `REGRESSED`, both exit 1).

## 4. Counterexamples (concrete)

**C1. BASE accepts a downgrade as CLEAN (the defect C2 fixes).** Feed title `v1.2.2`, row S001 anchored `1.2.3`. BASE `observe_one` writes `fired` (`:728-734`). Table row `fired`. BASE evaluate counts it fired with no error (`:524-525`). `passed` (`:579`) is true, so `RELEASE_CLOCK: CLEAN (… fired=1 …)` prints (`:586`). Draft: `regressed`, then REGRESSED, FAILED, exit 1. Traced, not run.

**C2. Table-only downgrade lie is refused at BASE, but with the wrong label.** Table `not-fired` with observed `1.2.2` against anchored `1.2.3`. BASE `:519-523` → `INCONSISTENT`, exit 1. Draft: `REGRESSED`, exit 1. Only the `fired` form is a CLEAN-accepted lie at BASE.

**C3. Leading zero, and why the regex is deliberately lenient.** Feed title `v01.2.2`. BASE `STABLE_TITLE_RE` (`:649`, `[0-9]+`) matches (`:691`), `max` returns `01.2.2` (`:699`), and BASE writes `fired` → CLEAN. Draft: `(1,2,2) < (1,2,3)` → REGRESSED. A SemVer-strict core regex such as `(0|[1-9][0-9]*)` would return `None` for `01.2.2`, fall back to inequality, and yield `fired` → CLEAN, a false CLEAN. Probe (CPython 3.14.8): `[0-9]+` fullmatches `01.2.2` (True), rejects `1.2.3\n` (False) and Arabic-Indic digits (False).

**C4. Numerically equal, string-different reads `fired` (pre-existing, not fixed).** Observed `01.2.3` vs anchored `1.2.3`: `is_regression` is False (equal), but the retained string comparison (BASE `:730-734` shape, kept in the draft's `elif`) yields `fired`, which evaluate counts as CLEAN with fired+1. The draft leaves this; making equal cores compare equal is a scope decision for L1.

**C5. Shared-feed blind spot, per row (draft limit).** BASE `corpus/release-clocks.tsv`: python.org feed rows S027/S028 (anchored `3.15.0`) and S040/S041 (anchored `3.15.1`). If the feed reads `3.15.0` (stale): S027/S028 are `not-fired` (equal), so those two rows read per-row CLEAN; S040/S041 are REGRESSED, so the aggregate is FAILED. No aggregate false CLEAN in this pair, but two rows read clean against a feed the table itself proves stale. The draft's rule is per-row only. The working tree's `feed_floors` (as observed at read time) closes this; the draft does not.

**C6. Non-numeric anchor on a real row (declared limit).** BASE S012 anchored `v1.21.x`, observed `2.2.0`, verdict `fired`. Draft leaves it unchanged. A stale vault feed reading `2.1.0`: S012 reads `fired` per row; S013/S022/S023/S024 (anchored `2.2.0`) are REGRESSED, so the aggregate is FAILED.

**C7. Prerelease table cell (declared limit).** Observed `2.2.2-rc1` against anchored `2.2.3`: SemVer precedence says older, but `numeric_version` returns `None`, so the inequality rule yields `fired`. The parser cannot produce a prerelease (`:649-651`, `:699` admit only `X.Y.Z`), so only a hand-authored table cell reaches this.

**C8. Untyped crash on a huge table component (not fixed).** A table component of 4301+ digits makes `int()` raise `ValueError` (probe: `sys.get_int_max_str_digits()` = 4300; `int("9"*5000)` raises). In the draft this call sits in `evaluate`, outside the observe `try`. BASE catches the same error only on the observe path (`:751-756`, where feed titles are converted at `:699`). Result: uncaught, traceback, exit 1 [INFERENCE: standard Python exit status for an uncaught exception; not run], and no `RELEASE_CLOCK:` line. Non-CLEAN but untyped.

**C9. Rendered-quote row labelled `regressed`.** BASE quote branch (`:532-536`, verdict whitelist) makes it `INCONSISTENT`. The draft applies REGRESSED only to feed rows and receipts. A literal reading of "accept verdict regressed only as REGRESSED" would extend it to quote rows. Flagged for L1.

## 5. Verification performed (and what each one is)

- Byte identity: BASE blob via `git archive`; hash `40c1ba127e21cb8a1ee765afcbb17894aad0ecfb` matches `git rev-parse 0a47…:corpus/release-clock.py`.
- `ast.parse` on the draft: OK (parse only; the module was not executed).
- Language probe, one-liner under `python3` 3.14.8, not a gate: `int_max_str_digits=4300`; `[0-9]+` accepts leading zeros; rejects trailing newline and Unicode digits (C3, C8).
- Hand traces: all BASE `run_case` expectations plus all 12 new cases (table in §3).
- Not run: selftest (BASE or draft), build, lint, formatter, gate, network, live feeds, receipt verification.

## 6. What I did NOT check

- Selftest pass/fail, the BASE PASS count, and the exact +12 total (BASE count unmeasured).
- Live feeds; the live default receipt (`CLEAN30` claim); `DEFAULT_RECEIPT_SHA256` interplay; the 2026-10-21 feed values. The BASE table itself has no numeric downgrade (checked by inspection of every feed row's anchored and observed columns).
- SemVer §11.2 wording: cited from memory of SemVer 2.0.0, not fetched in this lane. [INFERENCE]
- Sources: BASE `corpus/SOURCES.md` has no S042/S043 rows and no SemVer/PyPA/precedence text (grep). The draft cites SemVer by name only, so it has no dangling ID. If the comment should carry IDs, L1 must add the rows.
- `StaticOpener`/`StaticResponse` internals beyond the shape used by BASE's live-feed case (`:1328` region). `parse_latest_version` on bodies with no `<link>` (inferred from that shape).
- Python versions other than 3.14.8. No new syntax was introduced by reading; not verified.
- Quote-clock, digest, and `run_observe` end-to-end paths: unchanged by the draft, not exercised.
- Lint (pyflakes/ruff): not run.
- C1 (knowledge-entry calibration): not my item.

## 7. Tooling and writes

- Installed or upgraded: none. Used system `git` (read-only: `rev-parse`, `show`, `archive`, `hash-object`, `diff --stat`, `status`), `tar`, `diff`, `grep`, and `python3` (parse and probe). Disclosure: `git status`/`git diff` may opportunistically refresh the lane index stat cache. Nothing was staged, committed, or otherwise written to the index.
- Writes: only under `.ufo/waves/round-27/sandboxes/XRegressDraft/` and this report.
- Subagents: none (the optional labrat was not used).

## 8. For L1 (decisions, not closure)

1. C8: typed `INCONSISTENT` via a guard in `evaluate`, or compare digit strings instead of `int()`.
2. C9: quote-clock `regressed` label, INCONSISTENT (draft) or REGRESSED.
3. C5: adopt cross-row floors (working tree `feed_floors`) or accept the per-row limit and name it in the declared-limit wording.
4. C4: numeric equality for strict cores (currently `fired`).
5. SOURCES.md: add the version-precedence rows if the code comment should cite IDs. The draft does not depend on them.
6. Optional: observe print `regressed=` count (present in the working tree, absent from the draft).
7. After integration, run `python3 corpus/release-clock.py --selftest` once. Expect BASE count + 12 and zero new failures; investigate any.
