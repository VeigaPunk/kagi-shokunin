# FLegacyUfo — legacy fleet citation mutation
Axes: calibration (bounded claims), operability (resolvable legacy references), freshness (frozen revision; no live-feed claim).
Revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (scratch `git rev-parse HEAD`, exit 0, exact stdout plus newline).
Scope: only this report written in production; all fixtures and the single mutation were isolated in the seat sandbox. No integration or production repair.

## Setup / argv
All process probes ran with `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FLegacyUfo-4/home`; cwd `/fast/scratch/kagi-r25/FLegacyUfo-4` unless noted.
Clone command (cwd `/fast/scratch/kagi-r25`), exit 0; stdout was the revision above; stderr empty:
```sh
mkdir -p /fast/scratch/kagi-r25/FLegacyUfo-4/home && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FLegacyUfo-4/home git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/FLegacyUfo-4/lane && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FLegacyUfo-4/home git -C /fast/scratch/kagi-r25/FLegacyUfo-4/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FLegacyUfo-4/home git -C /fast/scratch/kagi-r25/FLegacyUfo-4/lane rev-parse HEAD
```
Fixture directory command, exit 0, stdout/stderr empty:
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FLegacyUfo-4/home mkdir -p /fast/scratch/kagi-r25/FLegacyUfo-4/fleet-positive/.ufo/reports /fast/scratch/kagi-r25/FLegacyUfo-4/fleet-positive/lane/corpus /fast/scratch/kagi-r25/FLegacyUfo-4/fleet-missing/.ufo/reports /fast/scratch/kagi-r25/FLegacyUfo-4/fleet-missing/lane/corpus
```
Tool-written fixtures: both `fleet-{positive,missing}/lane/corpus/legacy-ufo.md` contain exactly `cites \`ufo/reports/x.md\` here\n` (newline, no escape characters in the file). Only positive has `.ufo/reports/x.md`, containing `synthetic evidence\n`. Both parents have `.ufo`, so these are synthetic FLEET layouts, not lone clones.
Same detector: sandbox `legacy-ufo-probe.py` invokes the two following argv in order, timeout 10 seconds each; it asserts fixture existence/absence, exact exit/stdout, and empty stderr. No ledger rows execute.
```sh
/usr/bin/bash /fast/scratch/kagi-r25/FLegacyUfo-4/lane/corpus/claim-ledger.sh citations --root /fast/scratch/kagi-r25/FLegacyUfo-4/fleet-positive/lane --docs /fast/scratch/kagi-r25/FLegacyUfo-4/fleet-positive/lane/corpus/legacy-ufo.md
/usr/bin/bash /fast/scratch/kagi-r25/FLegacyUfo-4/lane/corpus/claim-ledger.sh citations --root /fast/scratch/kagi-r25/FLegacyUfo-4/fleet-missing/lane --docs /fast/scratch/kagi-r25/FLegacyUfo-4/fleet-missing/lane/corpus/legacy-ufo.md
```
Detector commands actually run (all stderr empty):
```sh
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FLegacyUfo-4/home python3 -B /fast/scratch/kagi-r25/FLegacyUfo-4/legacy-ufo-probe.py pristine
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FLegacyUfo-4/home python3 -B /fast/scratch/kagi-r25/FLegacyUfo-4/legacy-ufo-probe.py mutated
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FLegacyUfo-4/home python3 -B /fast/scratch/kagi-r25/FLegacyUfo-4/legacy-ufo-probe.py restored
```

## Mutant / expected detector
Single behavior-bearing deletion at `corpus/claim-ledger.sh:667` in the clone: remove `[[ -e $ROOT/../.ufo/$r ]] &&`, leaving `r=${t#ufo/}; printf '%s' "$ROOT/../.ufo/$r" ;;`. No other script bytes changed.
Expected positive: exit 0, stdout C below. Expected missing: exit 1, stdout U then B below. Each line ends with newline; all child stderr was empty.
```text
C = CITATION_GATE: CLEAN (cites=1 docs=1 unresolved=0 ephemeral=0 labeled=0)
U = UNRESOLVED corpus/legacy-ufo.md:1 ufo/reports/x.md (ufo)
B = CITATION_GATE: BROKEN (cites=1 docs=1 unresolved=1 ephemeral=0 labeled=0)
```

## Actual outputs / verdict
| Bytes | Positive exit / stdout | Missing exit / stdout | Detector exit / final stdout |
|---|---|---|---|
| pristine | 0 / C; PASS | 1 / U then B; PASS | 0 / `DETECTOR: PASS (failures=0/2)` |
| mutated | 0 / C; PASS | 0 / C; FAIL | 1 / `DETECTOR: FAIL (failures=1/2)` |
| restored | 0 / C; PASS | 1 / U then B; PASS | 0 / `DETECTOR: PASS (failures=0/2)` |
KILLED: a nonexistent, unlabelled legacy `ufo/reports/x.md` becomes falsely CLEAN when the existence guard is removed; the identical bounded detector rejects it. Baseline and restored detector both pass, so this is not an inconclusive baseline failure.

## Restoration evidence / limits
SHA-256 of `lane/corpus/claim-ledger.sh`, printed by the detector in each phase:
- pristine: `2c8e07ea5e7d0a8e77390dc044f0a225d06dff464318a62e36a371607058cf41`
- mutated: `04b3c8bf92d0a86bd860a971e7207fdba87ad685c34b43aaa2b55e14ac047be5`
- restored: `2c8e07ea5e7d0a8e77390dc044f0a225d06dff464318a62e36a371607058cf41`
PASS restoration: immediately restored line 667 after the failing mutant probe; original/restored hashes match exactly, followed by the same passing detector.
Source pointers: legacy classification `:645`, resolver `:666-667`, output-presence decision `:815-816`, fleet miss `:829-831`, verdict `:1265-1276`. Committed selftest positive legacy citation is `:1446/:1607`; round-25 fleet-negative fixture/assertion `:1766/:1777` uses `.ufo/`, not legacy `ufo/`.
UNRUN: full candidate `--selftest` (including mutant survival there); prior BASE MutCitations survival is task-provided context, not re-observed. This result proves the custom detector kills the mutant, not that shipped selftests do.
UNRUN: full verify/cells, real fleet operations, C1 self-counts, C3 release clocks, network/public-feed checks. No pristine falsifier found within these two fixtures; no broader correctness or freshness verdict.
Tools: no installs/updates; no credentials, accounts, vaults, handlers, CDP, package transactions, production index or jj mutations.
