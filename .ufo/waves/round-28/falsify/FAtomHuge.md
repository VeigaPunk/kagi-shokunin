# FAtomHuge — round-28 C1 falsification: Atom newest oversized title

Target `62a33b1bd15217ed729df2ca40c8a30aba3076c0`; BASE `3553d499577084a6c98d7078906017840bbf7b28`.
Carrier: C1 freshness, non-canonical version token in an Atom feed title. Trees exported read-only via `git archive` into `.ufo/waves/round-28/sandboxes/FAtomHuge/{base,cand}` (no network; `request_body` stubbed as the script's own selftest does). Trees deleted at completion; receipts + `harness.py` retained there.

## Verdict

**PASS on the frozen carrier** (Atom feed whose *newest* stable entry title carries a 4301-digit patch component): exact typed category `NON-CANONICAL`, exit 1, **no fired observation written**, **no traceback**. BASE on the same input raised an untyped CPython int-limit `ValueError` and ended in a generic `RECEIPT-MISMATCH`.

**One defect found (adjacent shape, same rule):** a feed holding a non-canonical token that orders *below* the canonical newest is silently accepted and the clock **writes a fired observation** — no typed finding. Fail-open where BASE was fail-closed. (Parent reports repair revision `5e847472` covers "total feed rejection"; I did not review it.)

## Commands run (exit codes observed; cwd = sandbox unless noted)

| command | exit | result |
|---|---|---|
| `python3 -I -B harness.py cand cand-result2.json` | 0 | candidate behaviour below |
| `python3 -I -B harness.py base base-result.json` | 0 | BASE behaviour below |
| `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1b… cand c1-cand.json` | 0 | `mishandled=0/4 typed=4/4 other=0/4`; control `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit 0 |
| `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 3553d49… base c1-base.json` | 0 | `mishandled=3/4 typed=0/4 other=1/4`; same control CLEAN exit 0 |
| `python3 -I -B corpus/release-clock.py --selftest` (cand tree) | 0 | `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` |

`harness.py` (mine, not the lane tool) drives `parse_latest_version`, `observe_one` and the tree's own `main(["--root",…,"--observe",…])`.

## Evidence — the carrier (candidate)

Candidate `corpus/release-clock.py`: `388` `VERSION_COMPONENT_MAX_DIGITS = 18`; `391` `NON_CANONICAL_PREFIX`; `395` `non_canonical_version`; `784-799` `newest_stable()`; `798` `raise ValueError(NON_CANONICAL_PREFIX + "feed newest stable entry")`; `848` `return newest_stable(stable)` (BASE `760`: `return max(stable, key=lambda v: tuple(int(part) for v in v.split(".")))`); `679-681` receipt error with that prefix → `errors.add(("NON-CANONICAL", source_id))`; `869-872` `observe_one` refuses a non-canonical row anchor/observation, "no verdict written"; `913-914` `except (OSError, ValueError) as exc: receipt["error"] = str(exc)`.

Candidate, Atom titles `["Python 3.15." + "1"*4301, "Python 3.15.0"]`: `parse_latest_version` → `ValueError: non-canonical version token: feed newest stable entry`; end-to-end `--observe` exit **1**, stdout `NON-CANONICAL S040` then `RELEASE_CLOCK: FAILED (on_release=1 bound=1 unbound=0 observed=0 fired=0 derived=0)`; receipt record `{"id":"S040","parsed_version":null,"verdict":null,"error":"non-canonical version token: feed newest stable entry","http_status":200}` → **no fired observation**, no `Traceback` in stdout/stderr. Same typed result for RSS `<item><title>`, `/releases/tag/v…` href, plain-text `Version: 3.15.<4301>` (`:816`), leading-zero newest `3.15.01`, oversize-only feed (`:793`).

BASE, same oversize feed: `ValueError: Exceeds the limit (4300 digits) for integer string conversion…` — untyped; end-to-end ends in generic `RECEIPT-MISMATCH S040`, **not** a typed category. The generic mismatch is what this attack must reject as proof; the candidate's `NON-CANONICAL` at `:679-681` is a new category (outside the BASE-era set) reached *before* `receipt_matches`, so it is not a re-labelled receipt mismatch. Frozen-tool agreement: candidate F3/F4 → `NON-CANONICAL S040`, exit 1, `traceback_in_output=false`, `fired_observation_written=false`; BASE F3 → fired observation written; BASE F2 → traceback.

## Finding 1 (medium) — non-canonical token below the newest canonical is ignored; fired verdict written

Candidate `corpus/release-clock.py:784-799`: `newest_stable()` drops every non-canonical token ordering *below* the newest canonical token (docstring `785-790`), so the feed is accepted and the clock fires. Counterexample (candidate tree, same 4301-digit component):

    titles = ["Python 3.16.0", "Python 3.15." + "1"*4301]
    parse_latest_version -> "3.16.0"                 # no ValueError
    --observe receipt    -> {"id":"S040","parsed_version":"3.16.0","verdict":"fired"}
    stdout               -> no NON-CANONICAL line (exit 1 only from table/receipt disagreement)

BASE on the identical feed: `ValueError: Exceeds the limit (4300 digits)…`, receipt `error` set, `verdict: null` — fail-closed, no fired observation. The candidate is thus *less* strict than BASE here and contradicts plan C1 ("a version token used for … a feed entry must be canonical … otherwise the row or feed gets a typed finding (exit 1), **never a release event**"): the feed holds a non-canonical entry, no typed finding is emitted, and a release event is written. The frozen F3/F4 fixtures put the oversize token *newest*, so the frozen predicate cannot see this shape. Fix direction: reject the feed on *any* non-canonical entry token, not only tokens at-or-above the canonical newest.

## Finding 2 (low) — the component bound is 18 digits, not CPython's 4300

`corpus/release-clock.py:388` (rationale `384-387`). Plan C1 names the trigger "components beyond CPython's integer-string conversion limit" (4300). A 19-digit component — which BASE ordered without error — is now a typed `NON-CANONICAL` finding (`395-406`). Stricter than the stated trigger; the safety property holds, but the change is wider than the frozen defect.

## Residual risk / NOT CHECKED

- Repair revision `5e847472` not reviewed; findings are against the pinned candidate only.
- No network used or attempted; live python.org feed behaviour unverified.
- C2, the other C1 fixtures' internals, the S044/S045 sourcing rows and the lane's `round-conformance.py` / `separability.py` gates were not run.
- BASE `--selftest` case count not measured (candidate = 106); no production file modified; no lane gate run inside the checkout; no git/jj mutation.
