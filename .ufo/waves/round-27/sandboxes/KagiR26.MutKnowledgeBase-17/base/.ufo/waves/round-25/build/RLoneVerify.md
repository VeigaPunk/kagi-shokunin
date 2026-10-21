# RLoneVerify-2 — C2 before-measure: lone-clone `claim-ledger.sh verify` at BASE

Seat: KagiR25.RLoneVerify-2 (leaf reviewer) · 2026-10-21 · no installs performed (none needed).
Sandbox: `/fast/scratch/kagi-r25/RLoneVerify-2` (`<sbx>` below); lane tree clean, at BASE.

## Setup (exit 0 each step)
```
$ mkdir -p <sbx>/home && git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin <sbx>/lane && git -C <sbx>/lane checkout -q 4587c61a348e4528717404a68912c373f3ef4d03
$ git -C <sbx>/lane rev-parse HEAD
4587c61a348e4528717404a68912c373f3ef4d03
$ git -C <sbx>/lane status --porcelain | wc -l
0
```

## Run (default mode; `--allow-host-rows` NOT passed; empty scratch HOME)
```
$ cd <sbx>/lane && env -i PATH=/usr/bin:/bin HOME=<sbx>/home timeout 900 bash corpus/claim-ledger.sh verify > <sbx>/verify.out 2>&1
EXIT=1    (wall ≈ 77 s, well under the 900 s cap; output is 34 lines)
```
Terminal line:
```
CLAIM_LEDGER: FAIL (claims=61 failed=1 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=0 labeled_ids=20 host_skipped=12)
```

## Failing-row census (every FAIL/STALE/MISSING line in the output)
- FAIL lines — exactly 1: `FAIL R11-08 reason=exit-mismatch exit=1 want=0`
- STALE lines: 0 (`grep -cE '^(STALE|MISSING|NOT-A-FILE) ' verify.out` → 0; also
  `stale=0 missing=0` in the summary; STALE/MISSING printers: claim-ledger.sh:502, :508)
- MISSING / NOT-A-FILE: 0
- By-design policy skips, NOT failures — 12 × `HOST-SKIP <id> reason=host-row-not-authorized`:
  R11-01 R11-02 R11-03 R11-04 R11-06 R12-01 R15-01 R13-03 R16-01 R16-03 R17-01 R18-01
- Informational, not failures — 20 × `LABELED-ID <doc>:<line> <id> (labelled on its line)`
  (e.g. `LABELED-ID LOG.md:401 R13-99 …`; counted `labeled_ids=20`, idref rule claim-ledger.sh:820)

## Classification of the failing row
**R11-08 = LAYOUT-BOUND** (needs fleet root/siblings). Executed evidence, not just its note:
1. The row (corpus/claim-ledger.tsv:22) is `bash corpus/claim-ledger.sh citations`
   expecting `^CITATION_GATE: CLEAN (… unresolved=0 ephemeral=0`, exit 0. Its own
   note already declares: "requires the fleet checkout layout … fails by design".
2. Reproduced its command in the lone clone:
   `$ env -i PATH=/usr/bin:/bin HOME=<sbx>/home timeout 300 bash corpus/claim-ledger.sh citations`
   → EXIT=1 (≈54 s), `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)`
3. All 88 UNRESOLVED tokens carry a layout class tag; lane-local = 0:
   `(ufo)` = 31, `(sibling)` = 57 (`grep -cE`; 31+57=88; 0 lines with any other class).
   `ufo/…` and lane-missed `.ufo/…` resolve via `$ROOT/../.ufo` (main-repo tree) and
   `<lane>-shokunin/…` via a sibling lane dir (class definitions in the
   claim-ledger.sh header; lane-first fallback code at claim-ledger.sh:628-632) —
   both absent in a lone clone. Per plan C2 a lane-local miss must stay
   `UNRESOLVED` after the change, so this row's redness is 100% layout.
4. No other candidate: `[fleet]` tag count at BASE = 0 (`grep -cE '\[fleet\]'`
   corpus/claim-ledger.tsv → 0; `[host]` = 1, R18-01). The only other
   layout-adjacent row, R13-03 (`cells` over the real tree, claim-ledger.tsv:38),
   is a host row and was HOST-SKIPped — it never runs in default lone-clone
   verify, so it needs no `[fleet]` tag for lone-clone purposes.

**→ [fleet] tag set = exactly {R11-08}.** Matches plan C2's "R11-08 and any other
row the wave proves layout-bound" — no second row proved layout-bound.

## Cross-checks vs plan C2 before-figures (round-25.md, claim 2)
- `verify` before: `FAIL R11-08` exit 1 — reproduced exactly.
- `citations` before: `unresolved=88` (57 sibling + 31 ufo, all layout) — reproduced exactly.
- BASE `verify` summary carries no `layout_skipped=` / `fleet_absent=` fields (C2 adds them);
  FAIL reason classes at claim-ledger.sh:577-591, FAIL summary at :1127-1128.

## UNRUN (out of this seat's scope, not passed off)
- Fleet-layout control run (needs siblings present) — not attempted; gate runs on
  the real lane tree are forbidden for this seat.
- Planted lane-local-broken-cite control and after-state counting — implementer's
  C2 acceptance, not this before-measure.

## Tool notes
- No tool installed/updated (none needed).
- Host `/usr/bin/grep` is pi-uu-grep 0.2.0; its `-o` flag silently yields nothing
  (worked around with `grep -cE`; counts verified against `od -c`/`cat -A` byte
  dumps of a sample line). GNU-grep environments are unaffected.
