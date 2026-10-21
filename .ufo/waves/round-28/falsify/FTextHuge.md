# FTextHuge — round-28 falsify: curl `Version:` text carrier, oversized component

**Verdict: PASS (candidate 62a33b1)** for this carrier: no behavioural defect found; F1/F2 below
are coverage/limit observations, not misbehaviour.

Scope: `corpus/release-clock.py` only; curl carrier only (clock row **S029**, feed row **S037**,
`https://curl.se/info`). Candidate `62a33b1…3076c0` vs BASE `3553d49…f7b28`.

## Method (isolated, no network)

- Trees exported read-only (`git archive`); lane checkout never executed/modified. Exports were
  staged off-lane under `/fast/scratch/hyaku/kagi-r28/FTextHuge/{cand,base}` and deleted at
  completion (reproducible with `git archive`); harness/fixtures/receipts kept in
  `.ufo/waves/round-28/sandboxes/FTextHuge/`.
- Fixture root from the export: `corpus/SOURCES.md` narrowed to S029+S037 (verbatim),
  `corpus/release-clocks.tsv` narrowed to row S029 (verbatim), `source-fetches.tsv` +
  `rendered-text-v1.py` copied verbatim. Feed body = plain-text curl release file
  `Version: 8.23.<N ones>\nDate: 2026-10-14\n`.
- Transport stubbed: module `request_body` serves the fixture bytes, `utc_timestamp` pinned to the
  row's observed date — the substitution the frozen instrument documents
  (`.ufo/waves/round-28/tools/c1-measure.py`). No network. `python3 -I` ignores `PYTHON*` env
  vars, so the int-limit control was set inside the child (`sys.set_int_max_str_digits`).
- My harness (not the frozen tool): `sandboxes/FTextHuge/harness/probe.py` + `run-observe.py`,
  JSON receipts under `sandboxes/FTextHuge/runs/`.

## Commands and results (exit codes)

| # | command (cwd `sandboxes/FTextHuge`) | exit | result |
|---|---|---|---|
| 1 | `python3 harness/probe.py cand CAND-oversize-4301 fixtures/curl-oversize-4301.txt runs/cand-oversize-4301` | 0 (clock **1**) | stdout `NON-CANONICAL S029` + `RELEASE_CLOCK: FAILED (on_release=1 bound=1 unbound=0 observed=0 fired=0 derived=0)`; no `Traceback`; receipt `verdict=null`, `parsed_version=null`, `error="non-canonical version token: text release version"` |
| 2 | same, `base` (BASE) | 0 (clock **1**) | stdout `RECEIPT-MISMATCH S029`; receipt `error="Exceeds the limit (4300 digits) for integer string conversion: value has 4301 digits…"` |
| 3 | `… base BASE-641-lim640 …` vs `… cand CAND-641-lim640 …`, both `PROBE_INT_MAX_STR_DIGITS=640` | 0 (clock **1**) | BASE `RECEIPT-MISMATCH S029` + receipt error `Exceeds the limit (640 digits)…`; CAND `NON-CANONICAL S029` + `non-canonical version token: text release version` |
| 4 | `… base BASE-comp19 …` vs `… cand CAND-comp19 …` (19-digit component) | 0 (clock **1**) | BASE receipt record `verdict="fired"` (release event written) + `RECEIPT-MISMATCH S029`; CAND `NON-CANONICAL S029`, receipt `verdict=null` |
| 5 | `… cand CAND-comp18 …` / `… base BASE-comp18 …` | 0 (clock 1) | identical in both: `verdict="fired"` + `RECEIPT-MISMATCH` (18-digit bound parity, F2) |
| 6 | `(cd cand && python3 -I -B corpus/release-clock.py)` / same in `base` | **0** / **0** | both `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` (frozen control parity) |
| 7 | `(cd cand && python3 -I -B corpus/release-clock.py --selftest)` | **0** | `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` (BASE: `PASS (79 cases)`) |
| 8 | `python3 -I -B …/tools/c1-measure.py 62a33b1 CAND runs/c1-measure-CAND.json` | **0** | `mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True` |
| 9 | same, BASE `3553d49` | **0** | `mishandled=3/4 typed=0/4 other=1/4` — F4-observe-oversize is **OTHER** at BASE (F3) |

## Exact candidate path:line (tree `cand/` = candidate 62a33b1)

- `corpus/release-clock.py:816` — `raise ValueError(NON_CANONICAL_PREFIX + "text release version")`
  in `parse_latest_version` (`:801`), the plain-text/`Version:` branch (`:781` `TEXT_VERSION_RE`).
- `corpus/release-clock.py:391` — `NON_CANONICAL_PREFIX = "non-canonical version token: "`.
- `corpus/release-clock.py:679-680` — receipt error prefix ⇒ `errors.add(("NON-CANONICAL", source_id))`,
  checked **before** `receipt_matches` (`:682`), so a generic `RECEIPT-MISMATCH` cannot mask it.
- `corpus/release-clock.py:388` `VERSION_COMPONENT_MAX_DIGITS = 18`; `:395` `non_canonical_version`;
  `:409` `version_order` (no `int()` on any version component).
- BASE `corpus/release-clock.py:715-718` text branch has no canonical check; `:380` `tuple(int(part)
  for part in value.split("."))` is the only numeric conversion; `:822` catches `ValueError` into a
  generic receipt error.

## Findings

- **F1 (low, coverage — not a defect).** The curl text carrier is outside the frozen measurement *and* outside the candidate's selftest for the oversize case: `c1-measure.py` builds only an Atom feed, so F1–F4 never touch the text branch (F3/F4 use the python.org XML feed); the selftest covers the text branch only for the canonical file (`cand:1342`) and the leading-zero case (`cand:1373`) — its oversize cases (`cand:1370/1383`) are Atom. I verified the oversize text case independently (commands 1/3) → correct typed behaviour.
- **F2 (informational).** The candidate's bound is 18 digits (`cand:388`), stricter than the plan's
  literal "beyond CPython's int-string conversion limit" (4300): 19–4300-digit components are typed
  `NON-CANONICAL` although CPython can `int()` them; an 18-digit component stays canonical and the
  clock fires exactly as at BASE (command 5) — BASE-parity, no regression.
- **F3 (informational, method trap).** At BASE this carrier is **not** a traceback but a generic
  receipt-integrity finding (`RECEIPT-MISMATCH S029`), so "BASE exits 1" alone is no proof of the new
  rule: the discriminators are the category token (BASE `RECEIPT-MISMATCH` vs candidate
  `NON-CANONICAL`) and the absent fired verdict. The frozen instrument shows the same trap
  (command 9: BASE `other=1/4` at F4).

## Concrete counterexamples

1. BASE, 19-digit component (`Version: 8.23.111…1`): receipt record `verdict="fired"`,
   `parsed_version="8.23.111…"` — a written release event for an over-bound token. Candidate:
   `verdict=null`, `parsed_version=null`, `NON-CANONICAL S029`, exit 1.
2. BASE, 4301-digit component: receipt `error="Exceeds the limit (4300 digits) for integer string
   conversion…"` → generic `RECEIPT-MISMATCH`. Candidate: `NON-CANONICAL S029`, `error="non-
   canonical version token: text release version"`, `verdict=null`; identical with the interpreter
   limit lowered to 640 → the candidate decides on token text, never `int()`-converting a component.
3. Unit level (`parse_latest_version` on the fixture bytes): CAND → `ValueError: non-canonical
   version token: text release version` (4301-digit, 19-digit and leading-zero bodies); BASE →
   parses `8.23.111…` (len 4306), `8.23.111…` (len 24), `8.23.01`.

## Residual risk / what I did NOT check

- Transport stubbed: the assertion covers parser + clock + receipt, **not** the real served
  `curl.se/info` layout (a `Version:` line that is not line 1 falls to `raise ValueError("text
  release file has no Version: X.Y.Z line")`, `:818` — generic error, BASE-parity, not exercised).
- Fixture root narrowed to one row; the whole-tree CLEAN control (command 6) was run separately to
  show the narrowing did not manufacture the typed result.
- Not checked: C2 derived-anchor binding for other feeds; the frozen F1–F4 fixtures beyond the two
  aggregate runs; the claim ledger (`corpus/claim-ledger.tsv`) and round-28 bookkeeping; the lane's
  own gates/selftests (run only inside my exported trees); any host-private read, vault or network
  action; per-case audit of the 27 new selftest cases.
- Tooling: no installs or upgrades performed; stock `python3` 3.14.8 and read-only `git archive`.
