# round-18 — OMP/ufo-fsd re-census: substrate loss, not path drift

2026-10-14. This round was imposed from outside: the fleet substrate
`ufo-fsd-alpha` relocated and restructured on 2026-10-12, and every lane was
ordered to re-verify its frozen claims against the moved tree. **kagi's
re-census found a different drift class than its siblings**: zero references to
the origin tree exist anywhere in this repo (`grep -r 'origin-work|ufo-fsd'`
is empty — the lane censes the the-janitor host surface, not the fleet tree),
so the `--src` derivation pattern and deleted-file citations that define the
other lanes' rounds are *vacuously satisfied* here. The blocker this lane
actually has is worse and simpler: **the substrate itself is gone**.

## Measured host state (all commands re-runnable)

- `test -x ~/.local/bin/the-janitor` → absent; `ls ~/.config/the-janitor` → no
  such dir; `ls ~/.local/state/the-janitor` → no such dir;
  `~/.config/opencode/agents/janitor.md`, `~/.local/state/tac/`, `tac-check`,
  `~/.local/share/the-musketeer` all absent. `~/.config/opencode/` exists but
  holds only `cli.json opencode.json service.json frecency.jsonl model.json
  prompt-history.jsonl` (plus `latest`, `locks`) — 3 of its 20 pinned
  children remain.
- Live verdicts before repair: `SURFACE_CENSUS: DRIFT (diverged=1 gone=23
  link=0 unlisted=0 crosscheck=0 shape=0 unverified=0 ok=0 absent=37)` exit 1;
  `DRIFT_PINS: DRIFT (files_ok=0 files_bad=15 symbols_ok=0 symbols_bad=20)`
  exit 1; `transcript-scan: db not found` exit 2; `OP_REF_PROBE: SETUP` exit 2;
  `CHECKLIST_RUN: BROKEN (items=16 runnable=9 by_hand=7 failed=6)` exit 1;
  `ADJACENCY_SCOPE: DEFECT (… breadth_drift=6 breadth_unverified=1)` exit 1;
  `CLAIM_LEDGER: FAIL (claims=32 failed=11 …)` exit 1 — all 11 fails
  `reason=exit-mismatch`, every one substrate-caused.

## The defect worth fixing (class d)

Two gate defects were *lane* bugs, not host facts:

1. `surface-census.sh --selftest` failed 2/16 cases (`verbs-sandboxed`,
   `verbs-break-injection`) on any host without the handler — the selftest is
   advertised as hermetic proof on a scratch tree, but these two cases execute
   the REAL handler (`$JANITOR` from PATH). Fixed: when
   `command -v "$JANITOR"` fails the cases print `skip-case … substrate-absent`
   instead of `bad-case`. The case count stays 16; the distinction between
   "proved" and "not provable here" is now visible in the output instead of
   collapsed into a failure.
2. `claim-ledger.sh verify` reported `FAIL … exit-mismatch` for 11 rows whose
   only fault was measuring an absent substrate — indistinguishable in the
   verdict from a genuine regression. Fixed per
   `knowledge/substrate-deferral.md`: a row tagged `substrate` in note defers
   (`DEFER … reason=substrate-absent`, `deferred=N` on the summary) rather than
   failing; `cells` carries `row_deferred=N`; `KAGI_SUBSTRATE=` forces either
   arm so the selftest proves both on any host (cases 95–97).

Not fixed, deliberately: the DRIFT/DEFECT verdicts themselves. They are the
correct output on this host — the surfaces genuinely are gone — and re-pinning
baselines to an empty host would destroy the preserved record of what the
substrate was. The carried debt is named in the scorecard.

## Superseded-revision claims

All round 9–17 evidence quotes remain *historical*: they measured
`~/.local/bin/the-janitor` (755, 333 lines, last stamped sha
`2eb86e1f…` of the pin list — described, not re-derivable here) and a host tree
that no longer exists. Per the falsified-pointer convention they stay verbatim
with this erratum; no claim was deleted or rewritten.

## Honest-closure accounting

- a) stale `--src`/origin path failures: **0** (no such references exist).
- b) upstream-deleted-file citations: **0** (same reason).
- c) moved-file line drift: **0**.
- d) genuine lane defects: **2** (selftest hermeticity; indistinguishable
  failure class), both repaired above.
- substrate-absent verdicts carried as named debt: the 6 live-gate verdicts and
  10 deferred ledger rows, unblock action = restore/reinstall the-janitor
  substrate, whereupon `substrate_present()` un-defers every row in one run.

## Round-19 erratum (appended 2026-10-14)

The sentence naming `2eb86e1f…` as the handler's last stamped sha is wrong:
that prefix belongs to `corpus/surface-census.sh` at `301b9ec`. The pin-list
handler hash is `2408b0c9…` (`corpus/drift-baseline.tsv`). Append-only: the
original sentence stands; this entry supersedes it for readers.
