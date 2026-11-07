# R51ExecHarm — harm baseline: full claim ledger on BASE + timing debt (D1)

- Clone: `/fast/scratch/hyaku/kagi-r51/R51ExecHarm/c`, toplevel asserted = that dir, HEAD `214d8bf530a0c87c00686493f21af15396284793`
- Verify command: `nice bash corpus/claim-ledger.sh verify > verify-base.txt 2>&1; echo rc=$?` → `rc=2`, 103 lines, wall 632.51s
- Load: start `22.99 21.26 27.38` end `59.20 47.42 36.93` (see `loadavg-verify-*.txt` in receipts)

## Counts

- `grep -c '^FAIL'` = **3**
- `grep -c '^POLICY'` = **3**
- Final line: `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=124)`

## FAIL lines (id + reason field)

- `FAIL R11-08 reason=exit-mismatch exit=1 want=0`
- `FAIL R25-02 reason=exit-mismatch exit=2 want=0`
- `FAIL R36-01 reason=timeout exit=124 tmo=300`

## POLICY lines (id + reason field)

- `POLICY R29-01 reason=first-token:python`
- `POLICY R29-02 reason=first-token:python`
- `POLICY R38-03 reason=python-script`

No `LAYOUT-INCOMPLETE` line in this run. All other output (HOST-SKIP / LABELED-ID / MISSING-ID) is in `verify-base.txt` — saved verbatim in receipts.

## R36-01 — value-vs-expect, wall-vs-budget

- Ledger row: `bash plans/round-36-c1.sh`, expect `^0$`, exit 0, timeout 300
- Alone, unbounded (`/usr/bin/time -v`, no timeout): last line `0`, rc 0 → **matches expect `^0$`** ✓
- Wall: `7:15.84` (435.85s) **vs budget 300s → over budget by 135.85s** (this is why verify records `reason=timeout`)
- Max RSS: 31480 kB; loadavg start `63.16 49.48 37.94`, end `27.99 42.45 40.84` (ran concurrently with R11-08 — see load files)
- Receipts: `r36-01.out`, `r36-01.time`

## R11-08 — value-vs-expect, wall-vs-budget

- Ledger row: `bash corpus/claim-ledger.sh citations`, expect `^CITATION_GATE: CLEAN \(cites=[1-9][0-9]* docs=[1-9][0-9]* unresolved=0 ephemeral=0`, exit 0, timeout 300
- Alone, unbounded (`/usr/bin/time -v`, no timeout): rc 1, last line `CITATION_GATE: BROKEN (cites=3600 docs=127 unresolved=3 ephemeral=0 labeled=33)` → **does NOT match expect** ✗ (BROKEN ≠ CLEAN; unresolved=3)
- Unlike verify's lone-clone expectation, the isolated run printed `CITATION_LAYOUT: lone-clone fleet_absent=159` and `BROKEN`, not `INCOMPLETE`/exit 3 — 3 lane-owned `UNRESOLVED` remain:
  - `corpus/lessons/round-30-verifier-spotcheck.md:41 corpus/README.md:64/65/67 (local)`
  - `corpus/lessons/round-32-verifier-spotcheck.md:54 corpus/README.md:64/65/67 (local)`
  - `corpus/lessons/round-33-verifier-spotcheck.md:90 knowledge/corpus/knowledge/ (shorthand)`
- Wall: `6:06.81` (366.83s) **vs budget 300s → over budget by 66.83s** (yet verify recorded `exit-mismatch exit=1`, not timeout — the verify run finished this row under 300s)
- Max RSS: 4704 kB; loadavg start `70.80 54.16 40.28`, end `27.99 42.70 40.91` (concurrent with R36-01)
- Receipts: `r11-08.out`, `r11-08.time`

## Reading

- Round-50 D1 timing debt reproduces on BASE under this host's load (loadavg 23–71 during the window): both rows exceed their 300s timeout when run alone. R36-01's underlying value is correct (`0`) — pure budget failure. R11-08 fails on value too (3 genuine unresolved citations), and also runs over budget when alone.
- Interpretation [INFERENCE]: timeout failures here are load-sensitive, not deterministic slowness claims — verify's own R11-08 completed inside budget at higher load than R36-01's isolated run started. Any timeout budget change should be calibrated on a quiet host, not this 12-seat window.

## Receipts (.ufo/waves/round-51/build/R51ExecHarm/)

`verify-base.txt` (103 lines), `r36-01.out`, `r36-01.time`, `r11-08.out`, `r11-08.time`, `loadavg-verify-start.txt`, `loadavg-verify-end.txt`, `loadavg-R36-01-start.txt`, `loadavg-R36-01-end.txt`, `loadavg-R11-08-start.txt`, `loadavg-R11-08-end.txt`

No tooling installed. No OpenBao started. No git writes anywhere.
