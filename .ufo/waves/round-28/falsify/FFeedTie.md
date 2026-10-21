# FFeedTie — round-28 falsification: canonical/non-canonical numeric tie, both orders

Seat `KagiR28.FFeedTie` (leaf, no subagents). Carrier: the C1/C2 **tie** — a canonical token `X.Y.Z` and a non-canonical token with the **same numeric value** (`3.15.01` vs `3.15.1`) — in both orders (canonical first / nc first), feed path and table path. Judged axes: freshness, calibration.
Target `62a33b1bd15217ed729df2ca40c8a30aba3076c0`; BASE `3553d499577084a6c98d7078906017840bbf7b28`. Isolated `git archive` exports under `/fast/scratch/hyaku/kagi-r28/` (deleted at completion); no lane file written but this report and my own sandbox; no network (feed transport stubbed in-process as the script's own selftest does).

## Verdict

**PASS** on the tie carrier at the pinned candidate: the tie is refused in both orders, feed path and table path, with the exact typed category `NON-CANONICAL` (never a generic `RECEIPT-MISMATCH`), no traceback, no fired verdict written. Three residual defects (F1–F3) follow; none is tie-specific, and all three are already closed by the L1's repair `5e847472` (outside my target; verified separately).

## Findings

**F1 (medium; closed by `5e847472`) — a non-canonical token below the newest canonical token is silently ignored and a fired verdict is written.** `corpus/release-clock.py:784-798` (`newest_stable`) tests only the newest canonical token. Feed titles `Python 3.16.0`, `Python 3.15.1`, `Python 3.15.01`, row `S040` anchored/observed `3.15.1` → `RELEASE_CLOCK_OBSERVE: wrote 1 observations (failed=0 fired=1 regressed=0)`, `RECEIPT-MISMATCH S040`, exit 1, receipt `{"verdict": "fired", "parsed_version": "3.16.0"}`. `3.15.01` appears in no finding; exit 1 is only the generic receipt pin, and a fired release observation was written. `5e847472` replaces the ordering test with total validation (`if any(non_canonical_version(token) for token in tokens): raise`); the same fixture then yields `NON-CANONICAL`, `fired=0`. Not tie-specific: the "older non-canonical entry" case the candidate's own docstring allows (`release-clock.py:785-789`; `corpus/lessons/round-28.md` §C1). Plan text (`plans/round-28.md:21-23`) says a non-canonical token used for "a feed entry" gets "a typed finding (exit 1), never a release event" — the candidate's narrower reading is arguable; the repair chose the total rule.

**F2 (low; closed by `5e847472`) — a non-canonical observation suppresses the C2 `DERIVATION` finding for the same row.** `release-clock.py:617-618` guards the `DERIVATION` check with `not non_canonical`, where `non_canonical` = `non_canonical_version(anchored) or non_canonical_version(observed_version)`. Row `S029` (derived, feed `S037`), anchored `8.23.1` — the curl development label the feed cell does not name:

    observed=8.23.01  -> S029: NON-CANONICAL, RECEIPT-MISMATCH   (no DERIVATION)
    observed=8.23.0   -> S029: DERIVATION, RECEIPT-MISMATCH, REGRESSED

Same anchor, same exit 1; the calibration category vanishes only because the observation is non-canonical. `5e847472` narrows the guard to `not non_canonical_version(anchored)` → `S029: DERIVATION, NON-CANONICAL, RECEIPT-MISMATCH` (verified).

**F3 (low; closed by `5e847472`) — a receipt-side non-canonical `parsed_version` is not typed at the pinned candidate.** `evaluate()` types `NON-CANONICAL` from a receipt only when `receipt["error"]` starts with the prefix (`release-clock.py:679-680`); a receipt whose `parsed_version` is the twin `3.15.01` with no `error` field yields only generic `RECEIPT-MISMATCH`. `5e847472` adds `or non_canonical_version(receipt["parsed_version"])`.

## Exact candidate behaviour on the tie (the assigned carrier)

Pinned candidate `62a33b1`; feed path via `--observe` with stubbed transport (`release-clock.py:784-798`, `:801-816`). Every case: exit 1, category `NON-CANONICAL S040`, **no fired verdict written**, **no traceback**: `3.15.1`+`3.15.01` (canon first), `3.15.01`+`3.15.1` (nc first), `3.15.1`+`3.15.0000000000000000001` (oversize twin) → ValueError "non-canonical version token: feed newest stable entry"; `3.15.01` alone → ValueError "…feed has no canonical stable X.Y.Z entry"; control `3.15.1`+`3.15.0` → named `3.15.1`, exit 0, no finding, not-fired.

Table path (`:617`, `:627-632`), row `S040`, receipt mirrored per the plan correction so the run cannot end on the receipt pin: anchored `3.15.1` / observed `3.15.01` / fired → exit 1, `NON-CANONICAL S040`, no fired; anchored `3.15.01` / observed `3.15.1` / fired → exit 1, `NON-CANONICAL S040`, no fired. C2 tie direction (`S029`/`S037`): feed cell names the twin `8.23.00` → exit 1 `DERIVATION S029`; row anchor is the twin `8.23.00` → exit 1 `NON-CANONICAL S029` (once, not double); row anchor raised to `8.23.1` → exit 1 `DERIVATION S029` (+`REGRESSED`); unmodified control → exit 0 `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`.

BASE on the same fixtures: BASE **names** the non-canonical token (`3.15.01`) as the release and writes a fired receipt for the nc-first order (BASE `corpus/release-clock.py:760` uses `max(stable, key=int(part)…)`, and `int("01") == 1`), and raises the untyped `ValueError: Exceeds the limit (4300 digits) for integer string conversion` for the oversize twin — precisely the two defects C1 claims to close. The candidate refuses both.

## Commands run (exit codes explicit)

    python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1… candidate <out>   # exit 0
      C1_MEASURE candidate: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True
    python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 3553d49… base <out>         # exit 0
      C1_MEASURE base: mishandled=3/4 typed=0/4 other=1/4 control_exit=0 control_clean=True
    python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 62a33b1… candidate <out>   # exit 0
      C2_MEASURE candidate: groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0
    python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 3553d49… base <out>         # exit 0
      C2_MEASURE base: groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True default_exit=0
    python3 -I -B harness.py <exported-tree> {CANDIDATE,BASE,REPAIR} <out>           # exit 0 each
    python3 -I -B tie_probe.py <tree> {CANDIDATE,BASE,REPAIR} <out>                  # exit 0 each
    python3 -I -B c2_tie_probe.py <tree> {CANDIDATE,BASE} <out>                      # exit 0 each
    python3 -I -B c2_suppress_probe.py <tree> {CANDIDATE,REPAIR} <out>               # exit 0 each
    python3 -I -B corpus/release-clock.py --selftest   # exit 0: BASE 79 cases, candidate 106 cases

Harness sources + receipts: `.ufo/waves/round-28/sandboxes/KagiR28.FFeedTie/` (`harness.py`, `tie_probe.py`, `c2_tie_probe.py`, `c2_suppress_probe.py`, `receipt-*.json`, `c1-measure-*.json`, `c2-measure-*.json`). Other cited candidate paths: `corpus/release-clock.py:395` `non_canonical_version`, `:409-416` `version_order` (its `lstrip("0")` makes `3.15.01` and `3.15.1` *equal* under ordering), `:870-872` the `--observe` row-anchor refusal.

## Not checked / residual risk

- No live feed was fetched; python.org / GitHub bodies are fixtures. Real-feed behaviour (a live feed that itself carries a leading-zero tag) unverified.
- The 15 derived rows' binding was exercised only for `S029`/`S037`; `S033`/`S034`/`S035` are covered only by the frozen `c2-measure.py`.
- `REGRESSED` × non-canonical interaction (a non-canonical observation that also regresses) was not separately probed.
- `5e847472` was used only to confirm F1–F3 are closed there; it is outside my assigned target and its claim/lesson edits were not audited.
- The candidate's `VERSION_COMPONENT_MAX_DIGITS = 18` bound (lane policy, not a SemVer rule) was not attacked; a legitimate 19-digit component is refused.
- No lane gate, selftest or fleet build was run in the lane checkout (`--selftest` ran only inside isolated exports).
