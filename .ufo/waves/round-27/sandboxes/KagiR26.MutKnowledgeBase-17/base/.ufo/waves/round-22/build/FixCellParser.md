# FixCellParser — round 22

## Scope and base

- Axis moved: **calibration**. This repair allows the actual pre/post score sections to be parsed without treating the separately documented blocked round-20 attempt as a score section. It does not make a freshness claim or alter the historical scorecard.
- Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`jj log` resolved the exact ID). Source `jj status` showed an empty working-copy child of that revision and untracked `.ufo/waves/` and `plans/round-22.md`.
- Implementation is in the private clone `/tmp/kagi-r22-FixCellParser`, based on the frozen revision; only its `corpus/claim-ledger.sh` was edited. Clone status after resetting four copied worktree-drift paths to the base reported no changes, with an empty working copy whose parent is `c2cab35b`.

## Behavior changed

- `cells` exempts only the exact filed heading `## Round 20 — interactive attempt; blocked, not completed (2026-10-15)` from the malformed-round-heading refusal. It remains outside `in_set`, so its table cannot add cells, pointers, uncited findings, or satisfy a score-section requirement.
- Every other nonconforming `## Round ...` heading still fails as a setup error. The existing per-section six-axes-exactly-once check and zero-cell and no-claim-row vacuity guards are unchanged. No historical heading or scorecard text was rewritten.
- Added two isolated cell-audit cases: `cells-blocked-attempt-excluded` expects exactly 12 pointed cells from Round 21 pre/post fixtures, excluding an unpointed cell under the blocked attempt; `cells-malformed-score-after-blocked` expects exit 2 for the following five-axis scored section.
- Added strict `python3` policy support for only `corpus/feature-claims.py` and `corpus/revision-audit.py` as exact path tokens with a boundary after `.py`. Inline `-c`, `-m`, stdin `-`, unregistered/suffixed scripts are refused; existing metacharacter and denied-verb checks still apply.
- Added nine isolated policy cases: each registered scratch script is allowed, the five disallowed interpreter/path forms are refused, and registered paths still refuse metacharacters and denied verbs.

## Selftest count handoff

The base count is 97 (ledger R11-09 and R18-03); the cell-parser change added 2 cases, and this follow-up adds 9 more. The final static selftest expectation is **108**. The ledger rows are intentionally unchanged because this seat owns only `corpus/claim-ledger.sh`; integration should update both counts to 108.

## Evidence and limits

- `SCORECARD.md` read at the base: line 558 is the explicit blocked round-20 heading; lines 592–599 hold its six-axis attempt table; lines 615 and 633 begin the Round 21 pre/post score sections.
- `corpus/claim-ledger.tsv` read at the base: lines 23 and 50 pin the selftest count to 97.
- Implementation in the private clone: cell parser and fixtures near lines 672–718, 1046–1067, 1104, and 1308–1310; Python policy near lines 161–184, fixtures near 1125–1139, and cases near 1257–1265.
- No selftest, gate, build, lint, or formatter was run, per instruction. Parent should run `bash corpus/claim-ledger.sh --selftest` and `bash corpus/claim-ledger.sh cells` after integration; the selftest's scorecard cases are scratch-only.
- No LSP endpoint was exposed in this lane; this shell-script change used the repository's existing functions and selftest conventions. No tool was installed.

## Bounded clone-path incident

The first clone command archived `kagi-shokunin` and extracted it under `/tmp`, so it targeted `/tmp/kagi-shokunin`, not the assigned destination. That directory existed, but its pre-command contents and exact file-overlap effects were not observed; I did not inspect, delete, or restore it and make no claim of loss. The follow-on `jj` command failed because the intended `/tmp/kagi-r22-FixCellParser` path did not exist. Main reported it was not using `/tmp/kagi-shokunin` and routed the incident to L1 KagiR22. No production-file or live-lane edit was made in the source checkout; the only source-path write was the authorized advisory report. The subsequent clone used the correct `/tmp/kagi-r22-FixCellParser` destination; its first `jj edit c2cab...` was refused because the revision is immutable, after which the copied tracked worktree was reset inside that private clone to the frozen revision.
