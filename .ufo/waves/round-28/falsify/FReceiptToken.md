# FReceiptToken — receipt `parsed_version` malformed while the table stays canonical

**Verdict: FAIL** (this carrier). The clock fails closed and no fired release escapes, but a malformed token living in the **receipt** is never *typed*, and one 4301-digit receipt still dies with an uncaught `ValueError` traceback — the exact debt round-27 named and round-28 C1 claims to close.

Scope: only the receipt JSON is edited (except RC6, where table *and* receipt carry the same malformed token, to locate which side is checked); `corpus/release-clocks.tsv`, `corpus/SOURCES.md` and all code are untouched in RC0–RC5/RC7/RC8; no network (every run is `--receipt <file> --receipt-sha`).
Read-only exports: candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0` → `/fast/scratch/hyaku/kagi-r28/FReceiptToken/cand`; BASE `3553d499…` → `…/base`. Fixtures + log: `.ufo/waves/round-28/sandboxes/FReceiptToken/{fixtures,run-all.py,mkfix.py,mkfix2.py,run-log.txt}`.

## F1 (high) — a receipt-borne malformed token is untyped: generic RECEIPT-MISMATCH
- candidate `corpus/release-clock.py:491-495` (`receipt_matches`): the receipt's `parsed_version` is compared to the table's `observed_version` by string equality only; `non_canonical_version` (candidate `corpus/release-clock.py:395`) is never applied to it. BASE `corpus/release-clock.py:441-446` is the same code → the candidate did not extend the rule to this carrier (not a regression).
- The only typed receipt path is candidate `corpus/release-clock.py:679`: `receipt.get("error")` must literally start with `NON_CANONICAL_PREFIX` (`"non-canonical version token: "`, candidate `:391`). A receipt whose *field* is malformed carries no such string, so it can never be typed.
- **Counterexample** — copy the pinned default receipt `.ufo/waves/round-26/observe-2.json`, set S040 `parsed_version`=`"3.15.01"`; table stays verbatim (S040 observed_version=3.15.1, canonical): `python3 -I -B cand/corpus/release-clock.py --root <cand> --receipt fixtures/RC1-leading-zero.json --receipt-sha 1f62f500…` → **exit 1**, stdout `RECEIPT-MISMATCH S040` / `RELEASE_CLOCK: FAILED (… observed=29 fired=3 derived=15)`. Oversize *string* token (RC2, `"3.15."+"1"*4301`) → **exit 1**, same `RECEIPT-MISMATCH S040`, no traceback. BASE output byte-identical for both.
- The **same token** moved into the table *is* typed (RC6: table S040 observed_version=3.15.01 **and** receipt S040 parsed_version=3.15.01) → **exit 1**, stdout `NON-CANONICAL S040`, **no** `RECEIPT-MISMATCH` — the receipt's identical malformed token was accepted as "matching". That asymmetry is the defect: the receipt's own token is never what gets checked; under the frozen instrument's predicate this state is `OTHER` (neither TYPED nor MISHANDLED).

## F2 (high) — the >4300-digit ValueError traceback survives on the receipt carrier
- candidate `corpus/release-clock.py:523-524`: `json.loads` is guarded only by `except (UnicodeError, json.JSONDecodeError)`. CPython's int-string limit raises a **plain `ValueError`** from `json.loads` for a >4300-digit JSON integer → uncaught → traceback, no `RELEASE_CLOCK:` summary line. BASE `corpus/release-clock.py:473-474` is identical → pre-existing, unchanged.
- **Counterexample** — receipt S040 `parsed_version` = a 4301-digit JSON **number** (the token's *type* is malformed, not just its text): `python3 -I -B cand/corpus/release-clock.py --root <cand> --receipt fixtures/RC7-huge-json-number.json --receipt-sha 65bc8c4e…` → **exit 1** with `ValueError: Exceeds the limit (4300 digits) for integer string conversion: value has 4301 digits` plus a full Python traceback; stdout empty. BASE: identical traceback; the frozen predicate calls any "Traceback" MISHANDLED. The *string* form (RC2) does not trace back — nothing on the receipt path calls `int()`.

## F3 (medium, calibration) — the frozen C1 instrument cannot observe either gap
- Frozen predicate: `cand/.ufo/waves/round-28/tools/c1-measure.py:38-49` and `classify()` `:235-252`: TYPED requires a category outside the BASE-era set `{ORPHAN, UNBOUND, INCONSISTENT, BADFEED, REGRESSED, RECEIPT-MISMATCH, NOT OBSERVED}`; "generic receipt-integrity findings" are **OTHER**; any "Traceback" is MISHANDLED.
- Frozen fixture set (`c1-measure.py:9-27`) has **no receipt-alone fixture**: F1/F2 mirror the table edit *into* the receipt, so the receipt's malformed token always travels with the table's.
- Consequence: this candidate — receipt carrier untyped (F1), traceback-prone (F2) — still scores TYPED 4/4, MISHANDLED 0/4 on the frozen set, so the plan's before/after arithmetic cannot separate "typed on every carrier" from "typed on the table and feed carriers only". Reported as a defect of the frozen command; **not** redefined here.

## What the candidate does get right on this carrier
- No fired release escapes: RC3 (fired row S027, receipt parsed_version=3.15.01) → exit 1, `RECEIPT-MISMATCH S027`, `fired` falls 3→2; nothing is written (evaluate never writes; `--observe` writes `verdict=None` + typed error, candidate `:872`, `:913-914`). Fails closed: every malformed-receipt fixture exits 1; RC0 control is `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit 0.
- RC5 (receipt carrying the typed error string) → exit 1, `NON-CANONICAL S040`; BASE gives `RECEIPT-MISMATCH S040` for the same file → the candidate **did** add a typed receipt category, but keyed to `receipt["error"]`, not `receipt["parsed_version"]`.

## Commands (exit codes; `<cand>` = exported candidate tree; all via `python3 -I -B <tree>/corpus/release-clock.py --root <tree> --receipt <file> --receipt-sha <sha>`)
```
RC0-control.json exit 0  RELEASE_CLOCK: CLEAN (… observed=30 fired=3 derived=15)
RC1-leading-zero.json / RC2-oversize.json exit 1  RECEIPT-MISMATCH S040
RC3-fired-row-leading-zero.json exit 1  RECEIPT-MISMATCH S027 (fired 3→2)
RC5-typed-error-control.json exit 1  NON-CANONICAL S040
RC7-huge-json-number.json exit 1  ValueError traceback (no summary line)
RC6-mirrored-table-and-receipt exit 1  NON-CANONICAL S040 (table+receipt both malformed)
--selftest exit 0  RELEASE_CLOCK_SELFTEST: PASS (106 cases)
```
BASE re-runs of RC1/RC2/RC3 print identical stdout to the candidate's; RC7 raises the same `ValueError` from the same unguarded `json.loads` (`base/corpus/release-clock.py:473-474`). `run-all.py` re-runs all of it and re-classifies each run with the frozen `classify()`; log at `sandboxes/FReceiptToken/run-log.txt`.

## Residual risk / verification gaps (not checked here)
- Frozen `c1-measure.py`/`c2-measure.py` not run end-to-end (they need a git repo for `git archive`; the lane checkout is off-limits) — I imported the frozen `classify()` from the exported candidate tree instead.
- C2 (derived-anchor) carrier, the `--observe` feed-body carriers F3/F4 and the anchor carrier were not tested.
- Whether a malformed receipt can be *self-produced* by the candidate: `parse_latest_version` (candidate `:801-817`) rejects non-canonical feed tokens, so RC1/RC2/RC7 need a foreign/hand-edited receipt file; `--receipt` is digest-pinned by the caller, so the practical severity is "untyped/crash on a corrupted receipt", not a silent pass. No tool was installed or upgraded.
