# FBound18 — PASS on behaviour, 2 residual findings: 18-digit component canonical control (candidate 62a33b1)

Scope: **only** the C1 freshness carrier `VERSION_COMPONENT_MAX_DIGITS = 18` (`corpus/release-clock.py:388`) at pinned candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`. Isolation: read-only `git archive` exports of candidate and BASE `3553d49…` into `/fast/scratch/hyaku/kagi-r28/FBound18/` (trees + my clone deleted at completion); **no network** (the clock's `request_body` stubbed in-process, as the candidate's own selftest does); no production byte edited, no lane gate run. Lane-authored advice, not closure.

## Findings

1. **MEDIUM (control gap, not behaviour) — the declared value 18 is pinned only from above; every lane-owned check stays green with the cap at 3.** `corpus/release-clock.py:388` cap constant; the cap test is `corpus/release-clock.py:405` (`len(part) > VERSION_COMPONENT_MAX_DIGITS`). The candidate's selftest pins only the upper side — `corpus/release-clock.py:1260-1262` `run_case("nineteen-digit component refused", observed="1.2.9999999999999999999")` — and has **no** case asserting an 18-digit component is *accepted*. Measured (one line at `:388` mutated in a copy of the candidate tree): cap 19 → selftest **FAIL exit 1** (`nineteen-digit component refused: observed=1 != 0`); cap 17 → **PASS (106 cases) exit 0**; cap 3 → **PASS (106 cases) exit 0**; cap 2 → **PASS (106 cases) exit 0**; cap 4300 / 4301 / 1 → FAIL exit 1. The frozen counting command is equally blind: a commit whose only change is cap 18→3 reads `C1_MEASURE cap3: mishandled=0/4 typed=4/4 other=0/4` — identical to the candidate — because F1 (`3.15.01`, `tools/c1-measure.py:351`) and F2 (4301 digits, `:68`, `:354`) sit outside the 3..18 window.
   **Concrete counterexample:** with cap=3 the 18-digit token `3.15.111111111111111111` flips from *accepted* (`T18` → exit 0, `RELEASE_CLOCK: CLEAN … fired=4`) to *refused* (`T18` → exit 1, `NON-CANONICAL S040`) while the selftest still prints `PASS (106 cases)` and c1-measure still reads `mishandled=0/4`. So `corpus/lessons/round-28.md` §C1 ("at most 18 digits"), QM27 ("a declared lexical length bound") and README's "over-18-digit component is NON-CANONICAL" name a policy value no owned check distinguishes from 3; a later edit lowering the cap would refuse legitimate 4..18-digit components undetected.
2. **LOW (typed-category gap) — a non-canonical token carried by a *retained* receipt is reported as a generic `RECEIPT-MISMATCH`, never `NON-CANONICAL`.** `corpus/release-clock.py:679-681` types `NON-CANONICAL` only when the receipt carries an `error` string with the prefix (an observe-time failure); `corpus/release-clock.py:490-496` (`receipt_matches`) compares the receipt's `parsed_version` against the table observation with no canonicality test. **Counterexample:** table row S040 canonical (`3.15.1` / `not-fired`), retained receipt record `parsed_version = "3.15.01"` → run prints `RECEIPT-MISMATCH S040`, exit 1 — no `NON-CANONICAL` anywhere. Hard predicates still hold (exit 1, no traceback, no fired verdict, no release event) and BASE prints the same generic line, so this is not a regression; but on this path a failing run is *not* evidence that the new rule fired — the exact generic-mismatch trap this item forbids accepting as proof.
3. **No behavioural defect found for this carrier.** Every bad input below yields the exact typed category `NON-CANONICAL`, exit 1, no `Traceback`, no fired verdict written, no release event; the 18-digit token is fully canonical (ordered, parsed, fireable) on every path.

## Candidate code path exercised (path:line at 62a33b1)

- `:388` cap constant; `:395-406` `non_canonical_version()`; `:409-416` `version_order()` (orders by `(len, digits)`, never `int()`); `:417-430` `numeric_version()` (returns `None` for a non-canonical token → never ordered).
- Table path: `:617` computes `non_canonical` over anchor+observation; `:627-632` adds `("NON-CANONICAL", source_id)` + `row_valid = False`, so the fired/not-fired branch (`:633-651`) is never reached; `:715` prints `NON-CANONICAL S040`; `:2077` returns exit 1.
- Feed path: `:784-798` `newest_stable()` (`:791` drops non-canonical tokens; `:795-797` refuses a token at/above the newest canonical one); `:815-816` plain-text `Version:` line; `:870-872` `--observe` refuses a non-canonical row anchor/observation before any fetch; receipt path `:679-681` observe-time receipt error → `NON-CANONICAL` (finding 2 is the retained-receipt hole). Fixture row `corpus/release-clocks.tsv:30` = S040 (feed S039).

## Measured behaviour (candidate vs BASE) — my own harness, not the frozen instrument

| case | candidate 62a33b1 | BASE 3553d49 |
|---|---|---|
| T18 observation `3.15.111111111111111111` (18 digits) | exit 0 CLEAN `fired=4` (canonical, fires) | exit 0 CLEAN `fired=4` (same) |
| T19 observation `…1111111111111111111` (19 digits) | **exit 1 `NON-CANONICAL S040`**, `fired=3` | exit 0 CLEAN `fired=4` (read as a release) |
| T18zero `3.15.011111111111111111` (18 chars, leading zero) | exit 1 `NON-CANONICAL S040` | exit 0 CLEAN `fired=4` |
| T4301 `3.15.`+4301×`1` | exit 1 `NON-CANONICAL S040`, no traceback | exit 1, **`Traceback`** (ValueError) |
| A19-anchor (19-digit anchor) | exit 1 `NON-CANONICAL S040` only | exit 1 `REGRESSED S027/S028/S040/S041` (generic) |
| O19 Atom feed entry 19 digits | exit 1 `NON-CANONICAL S040`; receipt `verdict=None`, `error="non-canonical version token: feed newest stable entry"` | receipt **`verdict=fired` written**; only `RECEIPT-MISMATCH S040` |
| O19-only (feed's only entry 19 digits) / O19-below (19 zeros below newest) | `…feed has no canonical stable X.Y.Z entry` / exit 0 CLEAN `not-fired` (ignored, as declared) | fired verdict written / exit 0 CLEAN `not-fired` (same) |
| O19-tie (19-char leading zero, value 1) | exit 1 `NON-CANONICAL S040` | exit 0 CLEAN (silently ignored) |
| O18 Atom feed entry 18 digits | exit 0 CLEAN; receipt `parsed_version=3.15.111111111111111111`, `verdict=fired` | same |
| text feed `Version: 3.15.1111111111111111111` | error `non-canonical version token: text release version`, `verdict=None` | receipt **`verdict=fired` written** |
| default run (unmodified tree) | exit 0 `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` | identical |

## Commands (exit codes observed; no network)

```sh
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 62a33b1… | tar -x -C /fast/…/FBound18/cand   # exit 0
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 3553d49… | tar -x -C /fast/…/FBound18/base   # exit 0
python3 -I -B b18-probe.py cand CAND | base BASE | mut3 CAP3   # exit 0 each (per-case clock exits in the table)
python3 -I -B b18-receipt.py cand    # harness exit 0; clock exit 1, `RECEIPT-MISMATCH S040`
python3 -I -B b18-text.py cand 3.15.1111111111111111111   # harness exit 0; clock exit 1, NON-CANONICAL S040
(cd cand && python3 -I -B corpus/release-clock.py)             # exit 0, CLEAN (30/30/0/30/3/15)
(cd cand && python3 -I -B corpus/release-clock.py --selftest)  # exit 0, PASS (106 cases)
# same selftest with :388 mutated: 19/4300/4301/1 → exit 1;  17/3/2 → exit 0 PASS (106 cases)
TMPDIR=/fast/…/tmp python3 -I -B lanecopy/.ufo/waves/round-28/tools/c1-measure.py 62a33b1… cand out/c1-cand.json   # exit 0, mishandled=0/4 typed=4/4
TMPDIR=/fast/…/tmp python3 -I -B lanecopy/.ufo/waves/round-28/tools/c1-measure.py 3553d49… base out/c1-base.json   # exit 0, mishandled=3/4 typed=0/4 other=1/4
TMPDIR=/fast/…/tmp python3 -I -B lanecopy/.ufo/waves/round-28/tools/c1-measure.py <cap-3 commit> cap3 out/c1-cap3.json  # exit 0, mishandled=0/4 typed=4/4
```

Note (not a finding against the frozen text): at BASE the frozen instrument reads F4 (`--observe` oversize) as **OTHER**, not MISHANDLED — BASE's oversize *feed* path fails generically (`RECEIPT-MISMATCH`) while the traceback is the *table* path (F2). The plan's `MISHANDLED k/4 → 0/4` holds with k=3; `corpus/lessons/round-28.md` M28-2 claims only F1/F2/F3 for BASE, so nothing is contradicted. Tooling: no installs (system `python3` 3.14.8, system `git`); no runtime judge invoked.

## What I did NOT check

- C2 (derived-anchor binding) and every other round-28 carrier — out of scope for this item.
- The five live feeds and vendor truth; **no network was used at all** (feed bodies were local fixtures served through the clock's own `request_body` seam).
- `corpus/claim-ledger.sh`, `drift-pins.sh`, stamp regeneration, the END census, `separability.py`, `round-conformance.py` — not run; ledger rows were read, not executed. Whether an 18-digit component is *desirable* is lane policy, not falsifiable from the tree (the round declares the 19+ refusal a limit, `corpus/lessons/round-28.md` §Limits); the §C1 claim that no real feed tag exceeds 3 digits (1,256 tokens) was not re-measured.
