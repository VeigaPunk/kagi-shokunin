# R61Reviewer — attack findings (round 61, kagi)

Seat: reviewer (attack). Read-only: no production file changed by this seat.
Measured tree: lane `kagi-shokunin` at BASE `c940f51689d702f1786989d56ad4663833c1452e`
plus the wave's uncommitted corrections; every attack tree is a copy under
`/fast/scratch/hyaku/kagi-r61/R61Reviewer/`.

Instrument bytes at this reading: `plans/round-61-c1-check.py` 67905 B (17:12:37),
`plans/round-61-c1.sh` 4932 B, `plans/round-61-c2.sh` 20130 B (17:09:56),
`plans/round-61-controls.sh` 39330 B (17:15:59), `corpus/openbao-seal-trial.sh` 46845 B (17:15:14).

Candidate readings (measured, not quoted):

```
$ bash plans/round-61-c1.sh --tree <cand copy of the lane tree>
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=1   rc=0
$ python3 -I -B plans/round-61-c1-check.py --selftest
C1_CHECK_SELFTEST: PASS (52 cases)                                          rc=0
$ bash plans/round-61-c1.sh c940f51689d702f1786989d56ad4663833c1452e
c1-driver: verdict value=FAIL guard=0                                       rc=1
$ python3 -I -B plans/round-61-c1-check.py --root <BASE copy> --repo <lane> --no-challenge
C1_ROUTED: value=7 population=7 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0 guard=0   rc=1
$ bash plans/round-61-c2.sh --tree <lane>
C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1
  (real=1 real2=1 none=1 ops=1 t2w=1 stubctl=1 secret=1 sh1=BHHHH … sh5=HHHHB
   trial=a3bc8825… cases=63)                                                rc=0
```

## C1 items I1–I7

Each attack tree is the candidate copy with exactly one item's substance removed while
the literal condition still reads true; the command is the checker on that tree with
`--no-challenge` (the diagnostic leg the controls use).

| id | attack (cheapest tree satisfying the literal condition) | command | observed | verdict |
|---|---|---|---|---|
| I1 | correction line names R37 and states `results=16 output=3824` + `mutants.md`, while the §Bounds line `corpus/lessons/round-60.md:129` ("the wave's 16th seat (mutation-tester) produced nothing") and R37's disposition are left as-is (the candidate's own correction names the §Bounds line; the item does not read it) | `python3 -I -B plans/round-61-c1-check.py --root <a1> --repo <lane> --no-challenge` | `value=1 … i1=1 …` | holds (residual: the condition reads neither the §Bounds line nor R37's disposition) |
| I2 | `plans/round-60-c2.sh --selftest` replaced by a delegating wrapper that relabels the trial's `APPROLE_SELFTEST: PASS (cases=45)` as `C2_SELFTEST: PASS (cases=45)`; SKILL row keeps "it runs the trial's `--selftest` as a conjunct" (contains `--selftest`, no `none of its own`) | `… --root <b2> …` | `value=1 … i2=0 …` (leg C mutation needle absent from the wrapper → mutated copy still PASSes → fail closed) | holds |
| I3 | candidate A7 with `**A3 item 2 is not withdrawn**` (all tokens `A3 item 2`, `form`, `l1-probe.txt` present; the word `withdrawn` present) | `… --root <b3> …` | `value=0 … i3=1 …` | **bypass** |
| I4 | candidate I4 line with `the round introduced no three new record defects it did not route: D1 … D2 … D3` (quotes `no new record defect`, names all three ids, states `three`) | `… --root <b4> …` | `value=0 … i4=1 …` | **bypass** |
| I5 | candidate I5 line with `it was not rewritten in place at 818d2a82` (`insertions=1 deletions=1` intact) | `… --root <b5> …` | `value=0 … i5=1 …` | **bypass** |
| I6 | candidate I6 line with `supersedes the round-60 stale-lane paragraph: the paragraph's times are correct` plus the launch line and four valid `%ci` stamps | `… --root <b6> …` | `value=0 … i6=1 …` | **bypass** |
| I7 | candidate I7 line with the pairing swapped: `3/16 = 25 %` and `4/16 = 18.75 %` (all four tokens present) | `… --root <b7> …` | `value=0 … i7=1 …` | **bypass** |

The exact conditions that let each through (all in `plans/round-61-c1-check.py`):

- I3 `:159` `WITHDRAWN_RE = re.compile(r"\bwithdrawn\b")` — a bare word test; `not withdrawn` matches.
- I4 `:165-166` `NO_NEW_RECORD_DEFECT_RE` (the quoted phrase) and `THREE_RE = re.compile(r"\bthree\b")` — `no three` matches both.
- I5 `:172` `REWITTEN_IN_PLACE_RE = re.compile(r"rewritten\s+in\s+place")` — `not rewritten in place` matches.
- I6 `:177` `STALE_LANE_RE` plus the launch-line and `TS_RE` membership test — the line may deny the defect and still carry the stamps.
- I7 `:184` `ATTACK_SHARE_RE` plus four independent token regexes in `item7` (`frac_a`, `frac_b`, `pct_a`, `pct_b`) — no pairing between a fraction and its percentage is required.

The bypasses are the class the controls C1-F3..C1-F7 do not build: those controls remove
a word or change a number (`restates` without `withdrawn`, two of three ids,
`deletions=2`, an invented launch stamp, an inverted verdict mapping). A negation
(`not withdrawn`, `no three`, `not rewritten`) or a swapped pairing keeps every token
the frozen text names, so the structural read holds while the statement says the
opposite. `plans/round-61.md` §C1 itself says an item's condition "is a structural read,
not a semantic proof that the corrected text is true" — these five items are the exact
place that ceiling bites, and none of the seven controls exercises it.

## C1 counter defects

### C1-1 (HIGH) — a printer-stub checker passes the driver

`plans/round-61-c1.sh:26` resolves `CHECKER="$LANE/plans/round-61-c1-check.py"` and
never hashes it; the GUARD lives inside the checker, so a stub checker self-attests
`guard=1`.

```
$ mkdir -p <stub>/plans; cp plans/round-61-c1.sh <stub>/plans/
$ printf 'print("C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=1")\n' \
    > <stub>/plans/round-61-c1-check.py
$ bash <stub>/plans/round-61-c1.sh --tree <BASE copy>
c1-driver: checker rc=0
c1-driver: verdict value=0 guard=1 (resolved and re-checkable)   rc=0
```

The controls battery's C1-STUB control runs the *real* checker's challenge leg; it does
not test a stub checker. The plan's "printer-stub control" is inside the checker
(`run_guard`), so it cannot see a replacement checker.

### C1-2 (MEDIUM) — the guard's third clause is vacuous (R40 repeat)

`plans/round-61-c1-check.py` `run_guard` writes a stub that prints `value=0` and
requires `not (sv == expect)`; `expect = value+1 ≥ 1`, so the clause is true for every
checker that runs it. The round-60 lesson R40 routed exactly this ("the GUARD's third
clause … discriminates nothing") and the round-61 frozen predicate restates it
unchanged. The second clause (the `deletions=1` → `deletions=2` copy must read value+1)
is the real challenge and it does fire:
`c1-guard: copy delta deletions 1->2 on the evaluated I5 line: value=1 expect=1; stub value=0 fails=True`.

### C1-3 (LOW) — the driver's BASE leg cannot print the K2 census

`bash plans/round-61-c1.sh c940f516…` prints `value=FAIL … guard=0` (the I5 line does
not exist to mutate), so the K2 `value=7 population=7` reading is only obtainable by
invoking the checker directly with `--no-challenge`; the driver has no such flag. The
plan's "Population census at BASE" says the census is taken with `--no-challenge`, so
this is consistent, but the driver alone cannot produce the K2 receipt.

## C2 counter (`plans/round-61-c2.sh`)

### C2-1 (recorded; fixed during review) — the trial was syntactically invalid

At 41278 B (16:59:17) `corpus/openbao-seal-trial.sh:839` passed a brace group to `ck`
(`ck F-STUB-SH2-VEC { …; }`); `bash -n` rc 2, both modes died at line 837
(`run_case: command not found`), and the counter read `value=0 … (real=0 real2=0
none=0 secret=0 …)`. Fixed at 17:03:57 (`bash -n` rc 0).

### C2-2 (recorded; fixed during review) — the secret scan's base64url class matched a run of hyphens

At 15391 B `SECRET_PCRE` ended `(?![0-9a-f]{43,}([^0-9a-f]|$))[A-Za-z0-9_-]{43,}`; a
60-dash separator comment in the trial (the lane's own style; the round-60 trial carries
six) read `secret=0` and value=0. Fixed at 17:03 with `(?![-_]{43})`; the same stub tree
now reads `value=5 … secret=1` and the counter's selftest carries a `sep60` fixture.

### C2-3 (HIGH) — a printer-stub trial still reads value=5, guard=1

The counter added two oracles: `ops_ok` (a `bao` shim logs argv to
`$SCR/log/<mode>.ops`; each real run must show `server`, `operator init`,
`operator seal`, `operator generate-root`, `operator rekey`) and `t2_ok` (each real
run's stdout must carry `progress=1/3`, `progress=2/3`, `sealed=false`, `t=3`, `n=5`).
Both are **string checks on output the trial itself prints**. A plain stub reads
`value=0 … ops=0 t2w=0` (the counter's internal stub control covers that); a stub that
runs each of the five argv with `--help` and prints the T2 markers passes:

```
$ bash plans/round-61-c2.sh --tree <ops+t2w-filling stub tree>
C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1
  (real=1 real2=1 none=1 ops=1 t2w=1 stubctl=1 secret=1 sh1=BHHHH … sh5=HHHHB … cases=8)  rc=0
```

The controls battery's new `C2-STUB` control (17 controls, 39330 B) generates a stub
that prints the text contract *without calling bao*; that stub reads `value=0` (ops=0),
so the control passes while this ops+t2w-filling stub reads 5. The control's stub is
strictly weaker than the counter's own oracles.

The stub is ~45 lines and never starts a server, never unseals, never touches a share.
The frozen predicate's "real run" stays a declared ceiling (K2), but `ops=1`, `t2w=1`
and `guard=1` present it as an executed trial.

### C2-4 (MEDIUM) — `guard` is a near-constant

`plans/round-61-c2.sh:266-269`: `guard=1` iff all nine legs have an rc and the trial
sha256 matches `^[0-9a-f]{64}$`; both are always true on a present trial. The
ops+t2w-filling stub reads `guard=1`. It is not a challenge leg.

### C2-5 (HIGH) — the counter's own `--selftest` cannot witness the verdict

The 11 cases test helpers (`vec`, `verdict`, `holds5`, `EXPECT`, `scan_hits`, the
absent/bad-tree paths). They do not execute the main aggregation:

```
[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && [ "$none_ok" = 1 ] \
  && [ "$selftest_ok" = 1 ] && [ "$ops_ok" = 1 ] && [ "$t2_ok" = 1 ] && value=5
```

Two mutations pass:

```
$ cp plans/round-61-c2.sh <tree>/plans/round-61-c2.sh
  # mutation A: the whole aggregation above -> 'value=5'
  # mutation B: shim aggregation -> 'shims_ok=$((shims_ok+1))' unconditionally
$ bash <tree>/plans/round-61-c2.sh --selftest
C2_SELFTEST: PASS (cases=11)   rc=0     (both mutations)
```

The four helper mutations the header claims *are* caught (verdict → `FINDING
R61-C2-ST-vec-dup`; summary → `…-summary-reject`; expectation → `…-expect-table`;
secret → `…-secret-fires`), so the claim is accurate as written, but the gate's
self-invocation mode does not witness its own `value`.

### C2-6 (LOW) — `--no-challenge` is not an option; it is read as a revision

`bash plans/round-61-c2.sh --no-challenge` → `value=0 … guard=0 (bad-revision)` rc 1.
The C1 checker's diagnostic flag has no C2 analogue.

### C2-7 (LOW) — TMPDIR is set for children, not honoured for the counter's own scratch

`plans/round-61-c2.sh:123` / `:232`: scratch is
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecCounterC2/…`; a caller `TMPDIR`
is ignored (`TMPDIR=/proc … --selftest` still PASSes). `HYAKU_SCRATCH=/proc` fails
closed (`SETUP no-scratch`, rc 2). No scratch leak (the counter dir is empty after
runs) and no write inside the measured tree (`find <tree> -newer <trial>` ⇒ none).

### C2-8 (recorded; fixed during review) — T4 generate-root failed; the counter read 0

At 43997 B (17:07:20) the real run read `TRIAL T4 ERROR decode-call` and
`OPENBAO_SEAL_TRIAL: ERROR holds=4 broken=0 error=1` rc 2; `$D/gr3.json` read
`{"errors":["permission denied"]}` (the third share submission), so `encoded_token` was
empty and `gr_decode` ran with an empty token; the CLI then asked for an unseal key on a
non-tty (`$D/decerr`: "file descriptor 0 is not a terminal"). The trial's `--selftest`
passed (`SEAL_SELFTEST: PASS (cases=63)`) while the real T4 failed, so the selftest did
not witness T4's real path. Fixed at 17:15:14 (46845 B): `TRIAL T4 HOLDS req3=1 prog=1
dec=1 wrong=1 tlen=26 ls=200 ss=200 wl=26 wls=403 wdrc=0` and
`OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` rc 0; the counter on the
candidate now reads `value=5 … cases=63` rc 0.

## Predicate arithmetic

- **Population 7, target 0, BASE 7 — measured.** The checker on a BASE copy with
  `--no-challenge` reads `value=7 population=7 i1..i7=0` rc 1. No item is vacuous at
  BASE. The driver's BASE leg reads `value=FAIL … guard=0` rc 1 (the I5 line does not
  exist to mutate), which the plan allows ("the guard-bearing line reads `value=FAIL …
  guard=0` only where the challenge cannot fire").
- **Candidate C1 — measured.** `value=0 population=7 i1..i7=1 guard=1` rc 0; checker
  `--selftest` PASS (52 cases). The guard challenge fires
  (`copy delta deletions 1->2 … value=1 expect=1`).
- **Candidate C2 — measured.** `C2_SEAL_TRIAL: value=5 … cases=63` rc 0; the trial's
  real run is `HOLDS 5/5`; five shim vectors `BHHHH/HBHHH/HHBHH/HHHBH/HHHHB`; the
  no-bao leg SETUP rc 2; the trial's `--selftest` PASS (63 cases).
- **Vacuity risks the checker does not take:** I7 is anchored on the full
  `supersedes the round-60 attack-share arithmetic` (R36 at
  `corpus/lessons/round-60.md:107` does not match); I2's registry parser handles the
  escaped `\|` in the entry-command cell and reads the real selftest cell; I6 requires
  *at least three* in-derived stamps (`distinct-stamps=5 in-derived=4` on the
  candidate), so the candidate's `2026-11-07T16:34:37-03:00` (the driver complete line,
  not a `%ci` stamp) rides along — that is the I6 residual, not a BASE vacuity.
- **The guard's third clause is vacuous (R40 repeat).** The expected value is
  `value+1 ≥ 1`; a stub printing 0 fails for every checker that runs it. The second
  clause is real and fires on the candidate.
- **The five C1 bypasses do not change the BASE census** (they are candidate-shaped
  trees, so BASE stays 7 and K2 is not voided). They do change the meaning of the
  candidate's `value=0`: five of the seven items would read 1 on a tree whose corrected
  sentence says the opposite of the measured state. The controls C1-F3..C1-F7 do not
  cover the negation/swap form, so `CONTROLS: mismatch=0` would not catch them.

SEAT-STATUS: complete
