# CheckOutputSafety — round-28 falsify, pinned candidate 62a33b1

**Verdict: FAIL** — 2 concrete output-safety defects at the pinned candidate (class+row-only and no-hidden-crash violated in the receipt path; the version-token paths themselves PASS). Scope: oversized-token error output must be class+row only and never echo the full untrusted token; no hidden crash on derived paths.

Candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (`corpus/release-clock.py`, 2081 lines); BASE `3553d49…`. All runs used `git archive` exports under `.ufo/waves/round-28/sandboxes/CheckOutputSafety/`; lane checkout never written, no lane gate run in the lane checkout, no host-private ledger rows executed.

## F1 (HIGH) — hidden crash: uncaught `ValueError` on an oversized JSON integer in the receipt

`corpus/release-clock.py:523-526` (candidate) ≡ `:473-476` (BASE), byte-identical: `try: document = json.loads(raw.decode("utf-8"))` / `except (UnicodeError, json.JSONDecodeError):`. CPython's int-string conversion limit raises a **plain `ValueError`** from `json.loads()` for an integer literal with >4300 digits; `json.JSONDecodeError` is only a *subclass* of `ValueError`, so the bare `ValueError` is not caught. It escapes `load_receipt_bundle` and `main()` (which catches only `SetupError`) and prints a full traceback to stderr — exactly the ">4300-digit ValueError" class C1 claims to eliminate, on the receipt path that C1's frozen F1–F4 never exercises.

Command (exit 1, traceback on stderr, no typed finding): `python3 -I -B <cand>/corpus/release-clock.py --root <root> --receipt <receipt.json> --receipt-sha <sha256>` with receipt body (3 identical-failure variants — `parsed_version`, `http_status`, `sha256` each as a bare 4301-digit JSON integer): `{"format":"release-clock-observations-v1","observations":[{"id":"S040", …, "parsed_version": <4301×"1" bare integer>, …}]}`. Observed stderr:

```
Traceback (most recent call last):
  File ".../corpus/release-clock.py", line 2081, in <module>  →  sys.exit(main())
  File ".../corpus/release-clock.py", line 2070, in main  →  receipts = load_receipt_bundle(receipt_file, expected_sha256)
  File ".../corpus/release-clock.py", line 523, in load_receipt_bundle  →  document = json.loads(raw.decode("utf-8"))
ValueError: Exceeds the limit (4300 digits) for integer string conversion: …
```

Evidence `probe5-result.json`: `R1-parsed_version-huge-int`, `R2-http_status-huge-int`, `R3-sha256-huge-int` — each `exit=1`, `traceback=True`. Guard at `:524`. Identically present at BASE (`:474`): C1 neither introduced it nor closes it.

## F2 (MEDIUM) — an oversized untrusted row id is echoed in full on stdout

`corpus/release-clock.py:715` prints `"%s %s" % (category, row_id)`; the *row id* is untrusted text taken verbatim from the receipt (`:536` `record_id = record["id"]`) or the TSV (`:115` `row_id = fields[0]`), with no length bound and no id pattern check, so an oversized id is echoed whole as the "row" of a typed finding. Counterexample 1 — receipt record `id` = 4301×"1" (a **string**, so `json.loads` succeeds; no crash, but the id is echoed): stdout `"RECEIPT-MISMATCH 111111111111111111111111111111111…"` (line length 4318). Counterexample 2 — a TSV row whose first field is 4301×"1": stdout `"ORPHAN 111111111111111111111111111111111…"` (line length 4308). Both exit 1, no traceback — but the finding line carries the entire oversized untrusted string, not a bounded class+row identifier. Paths: `:115`, `:536`, `:569` (`ORPHAN`), `:699` (`RECEIPT-MISMATCH`), `:715` (print). Same shape at BASE (`:119`, `:519`, `:630`, `:646`).

## What PASSES (evidence)

- **Oversized/leading-zero version token, table path.** S040 `observed_version` = `3.15.`+4301×"1" and `3.15.01` → exit 1, stdout exactly `NON-CANONICAL S040` + `RELEASE_CLOCK: FAILED …`, **no traceback, token not echoed** (`probe-result.json` `A-table-oversize`, `A2-table-leadzero`; `echoed=[]`, max line 87 chars). Path `:631`.
- **Oversized version token, feed path.** `--observe` over a feed whose newest stable item is `Python 3.15.`+4301×"1" → receipt `{"verdict":null,"error":"non-canonical version token: feed newest stable entry","parsed_version":null}`, stdout `NON-CANONICAL S040`, exit 1, no traceback; the 4301-digit token appears **nowhere** in stdout, stderr or the receipt file (`B-observe-oversize`; `receipt_echoes_oversize=False`).
- **No hidden crash on derived paths.** 73-case sweep (`probe4.py`: 17 anchored shapes × 4 feed_source_id targets + a registry-anchor cell holding a 4301-digit token): **0 anomalies** — all exit 0/1, no `Traceback` in stdout/stderr, oversized token never echoed (`probe4-result.json` `anomalies: []`).
- **Derived mismatches typed, class+row only.** S008 `anchored` lowered to `3.13.2` (feed row S033's anchor cell names `3.13.3`) → stdout `DERIVATION S008`, exit 1, no traceback, no echo (`probe2.py` `D1`; code `:625`). Leading-zero derived anchor → `NON-CANONICAL S008`; oversized derived anchor → `NON-CANONICAL S008`; 4-component anchor → `DERIVATION S008`+`INCONSISTENT S008`; missing feed row → `BADFEED S008`; non-feed feed_source_id → `BADFEED`+`DERIVATION`. All typed, exit 1.
- **No ReDoS.** `STABLE_TOKEN_RE.findall` over a 4301-digit anchor cell 0.0 s; `version_is_named` with a 4301-digit version 0.001 s (`probe2.py` `D10`). Ordering never calls `int()` (`:388`, comment `:387`).
- **Frozen instruments at the candidate** (commands unchanged): `c1-measure.py 62a33b1… candidate …` → exit 0, `mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True`; `c2-measure.py 62a33b1… candidate …` → exit 0, `groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0`. BASE control `c1-measure.py 3553d49… base …` → exit 0, `mishandled=3/4 typed=0/4 other=1/4`.
- **Selftest.** candidate `--selftest` → exit 0 `PASS (106 cases)`; BASE → exit 0 `PASS (79 cases)`.

## Adjacent (reported, not adjudicated here)

A non-canonical feed entry ordering **strictly below** the newest canonical one is silently ignored by `newest_stable` (`corpus/release-clock.py:784-798`): entries `Python 3.15.5` + `Python 3.14.01` (or `3.14.`+4301×"1") parse to `3.15.5`, exit 1 only via `RECEIPT-MISMATCH S040`, no typed finding for the bad entry (`probe3.py` `E1`/`E2`; BASE `E2` instead raised the 4300-digit `ValueError` into the receipt error field). The lane's FALSIFY dispositions record this as accepted/fixed in repair `5e84747`; it is still present at the pinned candidate. Counting-command result unaffected.

## NOT checked / residual risk

- No network fetch: every `--observe` run used the lane's own in-process `request_body` stub (as the frozen tool and the script's selftest do). Real transport behaviour unverified.
- No host-private ledger rows executed; `corpus/claim-ledger.tsv` pins not re-verified.
- F1/F2 were reproduced against the **pinned candidate only**. Not re-run against repair `5e847472a66fe0b41bfc4c374a3659eace3bd4f8`, whose diff widens the receipt guard to `except (UnicodeError, ValueError)` — left to the successor review.
- F2's unbounded-id echo was not re-checked against `5e84747`; its id handling is byte-identical to the candidate at `:533/:536/:717`, so it appears to survive the repair — flagged, not asserted.
- Multi-byte/non-ASCII oversized tokens, receipts with 10⁴+ observations, and concurrent `--observe` writes were not exercised. No tool installed or upgraded this session.

Artifacts retained (small): `.ufo/waves/round-28/sandboxes/CheckOutputSafety/` — `probe.py`…`probe5.py`, `probe-result.json`…`probe5-result.json`, `c1-base.json`, `c1-candidate.json`, `c2-candidate.json`. Exported candidate/BASE trees deleted after the runs.
