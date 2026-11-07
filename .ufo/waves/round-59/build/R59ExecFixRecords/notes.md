# R59ExecFixRecords — measurement notes (kagi round 59, seat notes)

All commands run from `/home/vgpnk/Projects/shokunin/kagi-shokunin` (lane root) on
2026-11-07 unless noted. Claim BASE `5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`.

## 1. SOURCES data-row counts (I1 derivations)

```
$ git show 1b13f5dad921f8901f56d30c428f89614dd74d8a:corpus/SOURCES.md | grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'
117
$ git show be8705f8:corpus/SOURCES.md | grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'
120
```
Measured 117 (BASE) / 120 (landing `be8705f8`) — matches the prompt's stated numbers.

## 2. source-fetches.tsv added rows (I2 derivation)

```
$ git diff 1b13f5da be8705f8 -- corpus/source-fetches.tsv | grep -c '^+S'
6
```
Measured 6 — matches.

## 3. controls-prefreeze.txt composition (I3a derivation)

File: `.ufo/waves/round-58/controls/controls-prefreeze.txt`

```
$ grep -c '^CONTROL ' controls-prefreeze.txt        -> 20
$ grep -c '^CONTROL C1-F' controls-prefreeze.txt    -> 9
$ grep -c '^CONTROL C2-F' controls-prefreeze.txt    -> 7
```
Checker derivation is unanchored substring (`"CONTROL " in ln`); verified identical:

```
total CONTROL-space: 20
C1-F: 9
C2-F: 7
(no line contains 'CONTROL ' without starting with it)
```
Last line of the file: `CONTROLS: match=20 mismatch=0`.
Measured 20/9/7 — matches.

## 4. Mission minutes (I5 derivation)

Driver-digest stamps in `corpus/lessons/round-58-verifier-spotcheck.md` §1:

```
2026-11-07T11:54:48-03:00 launch kagi round=58 pgid=2514153 driver=hyaku-inline attempt=1
2026-11-07T13:36:19-03:00 complete kagi round=58; hyaku-inline attempt=1
```

11:54:48 → 13:36:19 = 1 h 41 m 31 s = 101.52 min → 101 whole minutes
(`int(total_seconds // 60)` per `plans/round-59-c1-check.py derive_mission_minutes`).
Matches the stated 101.

## 5. Citation gate (I4 input)

```
$ bash corpus/claim-ledger.sh citations        # run ~14:0x, pre-correction tree
... (LABELED/UNRESOLVED/EPHEMERAL finding lines) ...
CITATION_GATE: BROKEN (cites=4291 docs=146 unresolved=13 ephemeral=0 labeled=23)
exit code: 1
```
Pre-fix reading: `unresolved=13` (U1). The gate needed >120 s (first attempt timed
out at 120 s; completed on a longer run). Post-fix reading is L1's to regenerate
(scope change 2026-11-07 ~14:0x: L1 owns the lesson append and
`.ufo/waves/round-59/final/citation-gate-r59.txt`).

## 6. Instruments observed landing this wave (siblings)

- `plans/round-59-c1-check.py` (33856 B), `plans/round-59-c1.sh` (4707 B) — R59ExecCounterC1
- `plans/round-59-c2.sh` — R59ExecCounterC2
- `corpus/openbao-transit-trial.sh` (16033 B) — R59ExecTrial

Checker contract read from `plans/round-59-c1-check.py`: REGISTRY_LINE_RE
`Registry\s+(\d+)\s*→\s*(\d+)\s+at the candidate` (first match per line, last matching
line wins); I2 first `\d+` after `corpus/source-fetches.tsv`; I3 last line naming
`controls-prefreeze.txt` must contain digit-runs {20,9,7} plus supplement script naming
`C1-F10`+`C2-F4` and receipt last line `SUPPLEMENT: match=2 mismatch=0`; I4
`CITATION_GATE:.*?unresolved=(\d+)` on gate file's last nonempty line must equal
`unresolved=(\d+)` on the lesson's last `citation-gate-r59.txt` line; I5 last line with
`stale-lane:`+`progressing`+digit-run 101.

## 7. Files this seat wrote

- `plans/round-58-controls-supplement.sh` — C1-F10 (real checker diagnostic value VAL
  on measured tree; challenge copy flips last Registry arrow M→M+1 must read VAL+1;
  constant-0 stub on same copy must read ≠ VAL+1) and C2-F4 (single-run trial copy —
  guard after `SHIM=` anchor lets exactly one empty-shim+bao leg run; second reads
  ERROR — must read value<5 under `plans/round-59-c2.sh --tree`).
- `corpus/lessons/round-58.md` — appended ONE `## Correction (round 59)` block
  (lines 110–136) before the L1 scope change; L1 confirmed sole ownership of further
  lesson edits. No earlier line was modified.
- `.ufo/waves/round-59/final/supplement-receipt.txt` — raw supplement stdout (below).

## 8. Supplement runs (full history, newest last)

```
# run 1 — instrument bug (report() printed $4 and required $5 under set -u)
plans/round-58-controls-supplement.sh: line 45: $5: unbound variable    RC=1
# fixed: report() now prints the computed MATCH|MISMATCH; both call sites pass 5 args

# baseline diagnostic (unmodified trial, minimal tree — what C2-F4 must move off 5)
$ bash plans/round-59-c2.sh --tree <minimal tree w/ unmodified trial>
C2_TRANSIT_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 cleanroom=1 secret=1)
rc=0    # 78.87 s wall

# run 2 — C2-F4 MISMATCH: the counter returned no C2_TRANSIT_TRIAL line at all
CONTROL C1-F10 expect=challenge+stub got=value=3 broken=4 stub=0 MATCH :: value=3 broken=4 expect=4 stub=0 (arrow 120->121)
CONTROL C2-F4 expect=<5 got=value=none MISMATCH :: unreadable counter output: none mut_rc=0; line: none
SUPPLEMENT: match=1 mismatch=1                                          RC=1
# judged environmental (mid-run contention at wave peak): the same invocation
# printed properly in the baseline diagnostic minutes later. Re-run, no script change.

# run 3 — clean receipt (committed at .ufo/waves/round-59/final/supplement-receipt.txt)
$ HYAKU_SCRATCH=/fast/scratch/hyaku bash plans/round-58-controls-supplement.sh
CONTROL C1-F10 expect=challenge+stub got=value=2 broken=3 stub=0 MATCH :: value=2 broken=3 expect=3 stub=0 (arrow 120->121)
CONTROL C2-F4 expect=<5 got=value=0 MATCH :: counter reads value=0 (<5 required); single-run guard inserted after SHIM= anchor; line: C2_TRANSIT_TRIAL: value=0 tests=5 pass=0 shims=5 vectors=ok/5 guard=1 (real=0 none=1 cleanroom=0 secret=1)
SUPPLEMENT: match=2 mismatch=0                                          RC=0
```

C2-F4 discrimination evidence: unmodified trial reads 5 (diagnostic); the single-run
copy reads 0 with `real=0` (the broken conjunct is the counter's two-independent-real-
runs requirement) while `shims=5 none=1 secret=1` stay intact — only the repeated-real-run
requirement is what refuses the copy. C1-F10: on the measured tree the checker's
diagnostic value=2 (i3/i4 pending the sibling receipts at run time); the challenge copy
(arrow 120→121) reads 3=value+1 and the constant-0 stub reads 0≠3 — the stub fails the
challenge leg. VAL being 2 or 0 does not affect the control (the comparison is VAL+1
on the broken copy vs the stub's constant 0).

## 9. Seat status

SEAT-STATUS: complete (receipt shipped; lesson block landed as lines 110–136 before the
L1 scope change; citation-gate-r59.txt left to L1 per scope change 2026-11-07).
