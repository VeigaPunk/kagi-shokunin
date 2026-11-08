# R63Critic — raw receipts

All commands run 2026-11-07 from `/home/vgpnk/Projects/shokunin/kagi-shokunin` or the
scratch tree; scratch `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63Critic/`.
No secret value appears here (shapes and counts only).

## 1. BASE extraction and instrument pins

```
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 0c07aab8df64b673a54a5113aebd7f34b622adbc | tar -x -C <scratch>/base
sha256sum base/plans/round-61-c1-check.py   ⇒ f2afd9b8f538…  (1710 lines)
sha256sum base/plans/round-62-c1.sh        ⇒ efe676ebb0d0…  (451 lines)
sha256sum base/plans/round-62-c2.sh        ⇒ b26d42207ff5…  (331 lines)
sha256sum base/plans/round-62-controls.sh  ⇒ 93587e6d15d5…  (904 lines)
git show 12c9e428:plans/round-63.md | grep -c 'Amendment A2'  ⇒ 0
git show 12c9e428:plans/round-63.md | wc -l                   ⇒ 277
sha256sum plans/round-63.md (lane HEAD)                       ⇒ e1d62c9c…  (303 lines)
```

## 2. C1 BASE census (16 fixtures, independent)

Driver: `run_fixtures.py`; each fixture: `cp -a base`, assert anchor count == 1,
byte-exact replace, run

```
python3 -I -B plans/round-61-c1-check.py --root <copy> --repo <lane> --no-challenge
```

Observed (402 s):

```
F1  count=1 rc=1 C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
F2  count=1 rc=1 C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
F3  count=1 rc=1 C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
F4  count=1 rc=1 C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
F5  count=1 rc=1 C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
F6  count=1 rc=1 C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
F7  count=1 rc=1 C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
F8  count=1 rc=1 C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
F9  count=1 rc=1 C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
F10 count=1 rc=1 C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0
P1  count=1 rc=1 C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0
P2  count=1 rc=1 C1_ROUTED: value=1 … i3=0 … guard=0
P3  count=1 rc=1 C1_ROUTED: value=1 … i4=0 … guard=0
P4  count=1 rc=1 C1_ROUTED: value=1 … i4=0 … guard=0
P5  count=1 rc=1 C1_ROUTED: value=1 … i5=0 … guard=0
P6  count=1 rc=1 C1_ROUTED: value=1 … i5=0 … guard=0
```

Unmodified BASE copy:

```
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0   rc=1
```

Anchor uniqueness: every anchor count == 1; F9/F10 anchor `launch 15:09:28 −03`
(U+2212) count 1, ASCII-hyphen variant count 0.

## 3. Frozen C1 command with `--fleet`

```
python3 -I -B plans/round-61-c1-check.py --root <base> --repo <lane> \
  --fleet /home/vgpnk/Projects/shokunin --no-challenge
⇒ usage: round-61-c1-check.py [-h] [--root ROOT] [--repo REPO] [--no-challenge]
        [--json] [--verbose] [--selftest] [--work WORK]
  round-61-c1-check.py: error: unrecognized arguments: --fleet /home/vgpnk/Projects/shokunin
  rc=2
```

Without `--fleet`: the unmodified copy reads `value=0` rc 1 (above). The L1 census
command block also omits `--fleet`.

## 4. C2 legs at BASE

```
# CM2a (stub composition → stub=1; needle count 1 at :324)
bash plans/round-62-c1.sh --selftest --tree <cm2a>
⇒ C1_COUNTER_SELFTEST: PASS (8/8 checks)   rc=0

# CM2b (SL_OK=1 appended before stub_leg's closing brace; needle count 1)
bash plans/round-62-c1.sh --selftest --tree <cm2b>
⇒ C1_COUNTER_SELFTEST: PASS (8/8 checks)   rc=0

# GM5 (I6 conjunct dropped; needle count 1 at :756)
python3 -I -B plans/round-61-c1-check.py --selftest
⇒ C1_CHECK_SELFTEST: PASS (cases=75)       rc=0

# S3 tree (markers removed, aggregation text altered)
bash plans/round-62-c2.sh --tree <s3>
⇒ C2_HARDENED: SETUP needle-ma             rc=2

# real trial on the BASE tree
bash plans/round-62-c2.sh --tree <base>
⇒ C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)  rc=0
```

`plans/round-62-c2.sh:279` ⇒ `[ "$ma_applied" = 1 ] || setup needle-ma`.

## 5. Lookup-table checker counterexample

`lookup/round-61-c1-check.py`: 15-string table (F1..F10 + B3..B7 replacements),
`--selftest` ⇒ `C1_CHECK_SELFTEST: PASS (cases=91)` rc 0; table hit ⇒ `value=1`; else
`value=0`.

```
unmodified BASE  ⇒ C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0   rc=1
F1..F10          ⇒ value=1 (10/10)
P1..P6           ⇒ value=0 (6/6)
B3..B7           ⇒ value=1 (5/5)
P3..P5 (r62)     ⇒ value=0 (3/3)
```

Round-62 counter on a tree whose checker is the lookup table:

```
bash plans/round-62-c1.sh --tree <lktree>
⇒ c1-counter: selftest rc=0 pass=1 cases=91 (guard needs >= 57)
  c1-counter: unmodified value=0
  c1-counter: stub c1_rc=2 c1_ok=1 c2_rc=2 c2_ok=1
  c1-counter: paraphrase leg=1
  c1-counter: checker challenge=0 (emptied negator set)
  C1_BYPASS: accepted=0 population=5 guard=0 (real=1 selftest=1 stub=1 paraphrase=1 chal=0)  rc=1
```

## 6. B6 and the I6 denial phrases

```
# B6 replacement: the lane was progressing, not stale. → the paragraph's times are correct.
C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0   rc=1
c1: i6 FAIL launch=yes distinct-stamps=5 in-derived=4 derived-set=9 \
    superseded-stamp=15:09:28,16:34:37 denial=are correct|times are correct
```

`I6_DENY_PHRASES = ("times are correct", "times are right", "is correct", "are correct")`
at `plans/round-61-c1-check.py:212` (Amendment A1 clause (d)).

## 7. I4/I5 line scope

```
plans/round-61-c1-check.py:667-670  candidates = [... QUALITY_TREND_RE ...]; last = candidates[-1]
plans/round-61-c1-check.py:694-697  candidates = [... SUPERSEDES_LOG_WAVE_RE ...]; last = candidates[-1]
grep -rIl 'rewritten in place' --exclude-dir=.git . | wc -l   ⇒ 71
```

## 8. C1 separability

```
# without plans/round-60-c2.sh
C1_ROUTED: value=1 population=7 i1=1 i2=0 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0   rc=1
# without plans/round-61-c2.sh, plans/round-62-c2.sh, corpus/openbao-seal-trial.sh
C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0   rc=1
```

## 9. Identity / wave shape

```
.ufo/waves/round-63/w1-dispatch.json counts.spawn ⇒ 15
registry milestone (all 15 members) ⇒ "C2 C2_REFUSAL killed 0->6"
plans/round-63.md A2 ⇒ "C2 population is therefore 5, target killed=5"
base/census.md ⇒ "killed = 0 over the five non-vacuous legs"
```

## 10. Scratch

`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63Critic/` (base, fx, cm2a, cm2b, l6,
lktree, lookup, s3, noc2, noc2b, b6, hyaku/). The round-62 counter writes its own scratch
under `${HYAKU_SCRATCH}/kagi-r62/R62ExecC1Counter/` (hardcoded in the counter), observed
in every run.

## 11. Controls battery on the extracted BASE tree

First run (fleet load 19–33, a concurrent fixture job):

```
bash plans/round-62-controls.sh <base>
CONTROL C2-F4 expect=value=5;shims=5;vectors=ok/5 observed=value=0;shims=0;vectors=0/5 verdict=mismatch
DETAIL C2-F4 real-verdict-weakened rc=1 line=C2_SEAL_TRIAL: value=0 tests=5 pass=5
  shims=0 vectors=0/5 selftest=1 guard=0 (real=1 real2=1 none=1 ops=1 t2w=1
  stubctl=1 secret=1 sh1=BHHHH sh2=HBHEH sh3=HHBEH sh4=HHHEH sh5=HHHHB trial=[HEXRUN] cases=63)
CONTROL C2-F5 expect=guard=0;cleanguard=1 observed=guard=0;cleanguard=0 verdict=mismatch
SKIPS: 0
CONTROLS: match=12 mismatch=2
SEAT-STATUS: partial mismatch-count=2
rc=1
```

Re-run alone, same tree:

```
bash plans/round-62-controls.sh <base>
DETAIL C2-F4 real-trial rc=0 line=C2_SEAL_TRIAL: value=5 tests=5 pass=5 shims=5
  vectors=ok/5 selftest=1 guard=1 (… sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH
  sh5=HHHHB … cases=63)
CONTROL C2-F5 expect=guard=0;cleanguard=1 observed=guard=0;cleanguard=1 verdict=match
SKIPS: 0
CONTROLS: match=14 mismatch=0
SEAT-STATUS: complete
rc=0
```

The `E` in the first run's shim vectors (`sh2=HBHEH sh3=HHBEH sh4=HHHEH`) is the
trial's `verdict` mapping an errored T-leg to `ERROR` (the trial's T3 seal / T4
generate-root legs errored under fleet load 19–33). The battery reads it as
`real-verdict-weakened`.
