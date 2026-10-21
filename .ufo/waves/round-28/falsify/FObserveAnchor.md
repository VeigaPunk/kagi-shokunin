# FObserveAnchor — falsification of `--observe` over a derived row with a noncanonical anchor

Target: `kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (candidate), BASE `3553d499577084a6c98d7078906017840bbf7b28`.
Item: observe path, derived row anchor noncanonical → expect typed finding, **no** traceback, **no** fired verdict written.
Verdict: **PASS** (candidate behaves as claimed; BASE does not — concrete counterexamples below).

## Method (no production writes, no network)

Exported both revisions read-only into my sandbox
`.ufo/waves/round-28/sandboxes/KagiR28.FObserveAnchor/` (`git archive` → `cand/`, `base/`), then built
fixture trees (`work-cand*`, `work-base*`) that are copies of `corpus/` + the pinned receipt
`.ufo/waves/round-26/observe-2.json` (sha256 `13b8540c…4169`). Fixture: row **S008** (derived, feed S033 SOPS)
`anchored_version 3.13.3 → 3.13.03` (leading zero) and `3.13.3 → 3.13.<4301×'1'>` (oversize); `observed_version`
left canonical so the pinned receipt still matches the row (no receipt mirroring needed → no receipt mismatch).
Two execution modes, both offline: (a) the **real CLI** inside `unshare -rn` (no network namespace, so every
fetch fails), (b) an in-process probe (`probe.py`) that replaces only `request_body` with a static body map, the
same stubbing style as the tool's own selftest — everything else (`run_observe` → `write_receipt` →
`load_receipt_bundle` → `evaluate` → `print_result`) is the production code path.

## Candidate code under test (candidate path:line)

- `corpus/release-clock.py:870-872` — `observe_one` refuses a feed row whose anchor/observation is noncanonical:
  `raise ValueError(NON_CANONICAL_PREFIX + "row anchor or observation; no verdict written")` (raised **before**
  any fetch: the receipt keeps `http_status=null`, `sha256=null`).
- `corpus/release-clock.py:391` — `NON_CANONICAL_PREFIX = "non-canonical version token: "`; `:395-407`
  `non_canonical_version` (leading zero / >18-digit component); `:428` `numeric_version` no longer calls `int()`.
- `corpus/release-clock.py:679-681` — a receipt whose `error` starts with that prefix is typed **NON-CANONICAL**
  (not the generic `RECEIPT-MISMATCH`).
- `corpus/release-clock.py:617,628-632` — table path types **NON-CANONICAL** for a noncanonical anchor/observation.
- `corpus/release-clock.py:620-626` — the C2 **DERIVATION** check is short-circuited by `not non_canonical`, so a
  noncanonical derived anchor yields exactly one category.
- BASE `corpus/release-clock.py:380` (`int(part)`), `:404` (`feed_floors`), `:760` (feed `max(int(...))`) — the
  CPython int-string-limit traceback sources the candidate removed.

## Commands and results (exit codes verbatim)

1. `cd work-cand-lz && timeout 180 unshare -rn python3 -I -B corpus/release-clock.py --observe …/cli-cand-lz.json`
   → **exit 1**; stdout line 2 = `NON-CANONICAL S008`; stderr = **0 bytes** (no traceback).
   Receipt record S008 = `{"verdict": null, "parsed_version": null, "http_status": null, "located": null,
   "error": "non-canonical version token: row anchor or observation; no verdict written"}`; the receipt contains
   **zero** records with `verdict` in {fired, quote-missing}.
2. Same fixture at BASE: `… unshare -rn python3 -I -B corpus/release-clock.py --observe …/cli-base-lz.json`
   → **exit 1**; stdout `INCONSISTENT S008` + `RECEIPT-MISMATCH S008`; `grep -c NON-CANONICAL` = **0**; stderr 0 bytes.
3. Stub probe (network-capable shape), **BASE** `work-base-lz`: observe **wrote a fired observation** for the
   noncanonical derived anchor: S008 = `{"verdict": "fired", "parsed_version": "3.13.3", "http_status": 200,
   "error": null}` → BASE turns a noncanonical anchor into a release event. Candidate, same fixture: `verdict=null`,
   `parsed_version=null`, typed canonical error; `errors=[["NON-CANONICAL","S008"]]`; no fired verdict for S008.
4. Oversize anchor, **real CLI offline**: BASE `work-base-big` → **exit 1** with an *untyped* traceback on stderr
   (`ValueError: Exceeds the limit (4300 digits) for integer string conversion`, raised at BASE `release-clock.py:380`
   via `:404 feed_floors` via `:885 run_observe`), stdout empty. Candidate `work-cand-big` → **exit 1**, stdout
   `NON-CANONICAL S008`, stderr **0 bytes**.
5. Category precision (not a generic receipt mismatch): table path with the pinned receipt, fixture S008 `3.13.03`
   → candidate prints **only** `NON-CANONICAL S008` (exit 1, `observed=29`); BASE prints **only** `INCONSISTENT S008`
   (exit 1). Same fixture `3.13.<4301 ones>` → candidate `NON-CANONICAL S008` only (exit 1).
6. Category separation (C2): S008 anchor `3.13.2` (canonical but unbound to S033) → `DERIVATION S008`; with the
   noncanonical anchor the DERIVATION check is suppressed → only `NON-CANONICAL S008`, even when the feed serves a
   genuinely newer release (stub override 3.14.0 → S008 still `verdict=null`, no fired receipt).
7. Token fuzz (12 shapes: `3.13.03`, `3.13.003`, `03.13.3`, `3.013.3`, `v3.13.03`, 19-digit, 4301-digit, …) through
   `parse_latest_version` + `observe_one`: candidate → every noncanonical X.Y.Z token gives `verdict=null` +
   `error="non-canonical version token: …"` and a typed `ValueError: non-canonical version token: …` from the parser;
   BASE → `fired` verdicts for the four leading-zero shapes and the untyped `Exceeds the limit …` for the oversize
   ones. No unexpected exception type in either tree.
8. Controls: candidate default `python3 -I -B corpus/release-clock.py` → `RELEASE_CLOCK: CLEAN (on_release=30
   bound=30 unbound=0 observed=30 fired=3 derived=15)` **exit 0** (matches the plan's frozen control); BASE default →
   same CLEAN line, exit 0. `--selftest`: candidate `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` exit 0; BASE
   `PASS (79 cases)` exit 0 (+27 cases, none removed).

## Residual risk / limits (not blocking this item)

- Canonicality is **X.Y.Z-scoped** (`NUMERIC_VERSION_RE`, candidate `:392`). A non-X.Y.Z anchor (`3.13.3.1`,
  `3.13`, `3.13.3-rc1`) is *not* typed NON-CANONICAL: in `--observe` it still yields a written `fired` verdict
  (fuzz row `len=8/4/10`), and in the table path it is INCONSISTENT. Identical at BASE → pre-existing, and the lane
  documents "not ordered here … they keep the inequality rule" (candidate `:422-425`). Outside the frozen claim
  (leading-zero + oversize), but a reader of "a version token used for an anchor must be canonical" may read it
  as a gap.
- `newest_stable` (candidate `:784-799`, selftest `:1387-1392`) **silently ignores an older** noncanonical feed entry
  instead of typing it; only a noncanonical entry at/above the newest canonical token is typed. Declared design
  decision, not exercised by the frozen F3/F4 fixtures (which put the bad token newest).
- My probes stubbed HTTP; the live-feed shapes (python.org RSS / GitHub atom / curl.se text) were not exercised
  against the real network (per item: no network). The stub served a canonical `v3.13.3` atom and a `Version:` text file.
- Stub artifact, not a candidate defect: rendered-quote row S031 locates as `quote-missing` under my stub
  (`RECEIPT-MISMATCH S031` in probe outputs); in the offline CLI runs every row gets `network error`.

## Not checked (other seats' scope)

`c1-measure.py` / `c2-measure.py` frozen counting runs; C2 groups G1..G4 and the 15 derived rows' feed-anchor
binding; ledger pins / stamps / SC-PV-CLOCK-SELFTEST count bounds; END census; SHONEN marks; LSP semantic checks —
**no LSP device is mounted in this environment** (`xd://lsp` → "No such tool"), so callers/defs were read textually
and verified by execution. No production file was modified; no lane gate was run inside the lane checkout.
