# R61Reviewer — C1 items I1–I7 and the two counters (attack seat)

Read-only. Candidate tree = lane `kagi-shokunin` copy at BASE
`c940f51689d702f1786989d56ad4663833c1452e` + the wave's uncommitted corrections.
Full evidence: `.ufo/waves/round-61/build/R61Reviewer/findings.md`.
Instrument bytes: c1-check 67905 B (17:12:37), c1.sh 4932 B, c2.sh 20130 B,
controls 39330 B, trial 46845 B (17:15:14).

Measured candidate readings: C1 `value=0 population=7 i1..i7=1 guard=1` rc 0
(`bash plans/round-61-c1.sh --tree <cand>`), checker `--selftest` PASS (52 cases);
BASE `value=7 population=7 i1..i7=0` (`--no-challenge`) and driver `value=FAIL
guard=0`; C2 `value=5 … cases=63` rc 0.

## C1 items

| id | attack | command | observed | verdict |
|---|---|---|---|---|
| I1 | correction names R37 + `results=16 output=3824` + `mutants.md`; §Bounds line `corpus/lessons/round-60.md:129` and R37's disposition left as-is | checker `--no-challenge` on `<a1>` | `i1=1` | holds (residual: condition reads neither the §Bounds line nor R37's disposition) |
| I2 | delegating `--selftest` relabelling the trial's `APPROLE_SELFTEST` as `C2_SELFTEST`; SKILL row keeps "runs the trial's `--selftest`" | checker on `<b2>` | `i2=0` (leg C mutation needle absent → mutated copy still PASSes → fail closed) | holds |
| I3 | A7 with `**A3 item 2 is not withdrawn**` (all tokens + the word `withdrawn`) | checker on `<b3>` | `i3=1` | **bypass** |
| I4 | `the round introduced no three new record defects it did not route: D1 … D2 … D3` | checker on `<b4>` | `i4=1` | **bypass** |
| I5 | `it was not rewritten in place at 818d2a82` (`insertions=1 deletions=1` intact) | checker on `<b5>` | `i5=1` | **bypass** |
| I6 | `supersedes the round-60 stale-lane paragraph: the paragraph's times are correct` + launch line + four valid `%ci` stamps | checker on `<b6>` | `i6=1` | **bypass** |
| I7 | pairing swapped: `3/16 = 25 %`, `4/16 = 18.75 %` (all four tokens) | checker on `<b7>` | `i7=1` | **bypass** |

Conditions that let them through: `plans/round-61-c1-check.py:159` `\bwithdrawn\b`;
`:165-166` `no new record defect` + `\bthree\b`; `:172` `rewritten\s+in\s+place`;
`:177` `STALE_LANE_RE` + `TS_RE` membership; `:184` `ATTACK_SHARE_RE` + four independent
token regexes in `item7`. The controls C1-F3..C1-F7 test missing words / wrong numbers,
not negations or swapped pairings, so `CONTROLS: mismatch=0` would not catch them.

## C1 counter defects

| id | defect | evidence |
|---|---|---|
| C1-1 | a printer-stub checker passes the driver (`CHECKER` never hashed; guard is self-attested) | `bash <stub>/plans/round-61-c1.sh --tree <BASE>` ⇒ `value=0 guard=1` rc 0 |
| C1-2 | guard third clause vacuous (R40 repeat): stub prints 0, expected `value+1 ≥ 1` | `run_guard` stub leg; the `deletions=1→2` clause is the real one and fires |
| C1-3 | driver BASE leg cannot print the K2 census (no `--no-challenge`) | `bash plans/round-61-c1.sh c940f51` ⇒ `value=FAIL guard=0` rc 1 |

## C2 counter defects

| id | defect | evidence |
|---|---|---|
| C2-1 | trial was syntactically invalid (`ck … { …; }`, `bash -n` rc 2); fixed 17:03:57 | `bash -n` rc 2 at 41278 B; counter `value=0 … real=0 real2=0 none=0` |
| C2-2 | secret scan matched 43+ hyphen runs; fixed 17:03 (`(?![-_]{43})`) | 60-dash comment ⇒ `secret=0` value=0; now `secret=1` |
| C2-3 | printer-stub trial reads `value=5 guard=1`: `ops` (argv strings) and `t2w` (stdout markers) are output-string checks | stub fills five `bao … --help` + prints `progress=1/3 …` ⇒ `value=5 … ops=1 t2w=1` rc 0 |
| C2-4 | `guard` near-constant (nine rcs + 64-hex sha) | stub reads `guard=1` |
| C2-5 | counter `--selftest` cannot witness the verdict: aggregation mutations PASS 11 cases | `value=5` unconditional; `shims_ok` unconditional ⇒ `C2_SELFTEST: PASS (cases=11)` rc 0 |
| C2-6 | `--no-challenge` is read as a revision | `value=0 … (bad-revision)` rc 1 |
| C2-7 | caller `TMPDIR` ignored for the counter's own scratch; `HYAKU_SCRATCH=/proc` fails closed | `TMPDIR=/proc … --selftest` PASS; no scratch leak, no measured-tree write |
| C2-8 | T4 generate-root failed (`gr3` 403 → empty encoded token → tty prompt); fixed 17:15:14 | `TRIAL T4 ERROR decode-call`; now `T4 HOLDS …` and `HOLDS 5/5` |

## Predicate arithmetic

- Population 7, target 0, BASE 7 **measured**: `value=7 population=7 i1..i7=0` with
  `--no-challenge`; no item vacuous at BASE.
- Candidate C1 **measured** `value=0 … guard=1`; guard challenge fires
  (`deletions 1->2 … value=1 expect=1`); checker `--selftest` PASS (52).
- Candidate C2 **measured** `value=5 … cases=63`; real `HOLDS 5/5`; vectors
  `BHHHH/HBHHH/HHBHH/HHHBH/HHHHB`; no-bao SETUP rc 2; trial `--selftest` PASS (63).
- Guard third clause vacuous (R40 repeat); the `deletions=1→2` clause is the real one.
- The five C1 bypasses are candidate-shaped, so BASE stays 7 and K2 is not voided; they
  do mean five of seven items would read 1 on a tree whose sentence says the opposite of
  the measured state.

SEAT-STATUS: complete
