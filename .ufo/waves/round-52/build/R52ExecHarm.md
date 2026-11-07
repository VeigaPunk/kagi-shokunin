# R52ExecHarm — harm baseline (claim ledger verify at BASE 1d984ad)

**Status: RUNNING** — full verify launched in scratch clone; will update with receipt.

- Scratch clone: /fast/scratch/hyaku/kagi-r52/R52ExecHarm/base @ 1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b (toplevel asserted before checkout)
- Ledger has NO per-row selection: `verify`, `citations`, `cells`, `selftest` all reject positional args (claim-ledger.sh:361-363). R11-08/R36-01 alone are therefore timed by running their underlying commands directly (bash corpus/claim-ledger.sh citations; bash plans/round-36-c1.sh), which is exactly what verify would run for those rows (exit+last-line policy).
- Receipts will live in this dir: verify-base.txt (full output), summary table below.
- Axes named: calibration (does the gate's verdict at BASE match commitments), freshness (does BASE still verify now), harm (what FAIL/POLICY rows exist at BASE — the baseline later rounds diff against).
