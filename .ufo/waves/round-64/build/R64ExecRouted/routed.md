# R64ExecRouted — `plans/round-64-routed.sh` receipt

Seat `R64ExecRouted`, kagi round 64 attempt 2, wave `kagi-r64-w1`, 2026-11-08.
Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin` (HEAD `eb647d2`, claim BASE
`09cbee831d57be7c4edfbe77bf238f46bf729047`, frozen predeclaration
`plans/round-64.md` at `dff0929` incl. Amendment A1).
Work item, **not a claim**: the round's claims are `C1_HELDOUT` and `C2_REFUSAL`.

Owner of exactly one lane file: `plans/round-64-routed.sh`
(sha256 `2689cdec055eadd5bb3e5b2881e3432fad1a1fa298e6116ac499b22ca3d0db05`,
401 lines), plus this receipt and `.ufo/waves/round-64/w1/R64ExecRouted.md`.
No `git`/`jj` mutation was run in the lane or anywhere else; nothing was written
outside the lane file above, this receipt, the w1 report and
`${HYAKU_SCRATCH}/kagi-r64/R64ExecRouted/` (deleted before yield).

## What the script is

`bash plans/round-64-routed.sh [--tree DIR] [--repo DIR]` prints three
`routed-leg d1|d2|d3:` detail lines and exactly one verdict line

```
ROUTED: d1=<0|1> d2=<0|1> d3=<0|1>
```

exit 0 iff all three read 1, 1 otherwise, 2 SETUP (unknown arg, bad tree/repo,
missing `python3`/`git`, unusable scratch, scratch at/inside the measured tree).
`--help` prints the whole header.

| leg | routed defect | what makes it 1 | what makes it 0 |
|---|---|---|---|
| `d1` | D-63-1 (spot-check §6; M63-6) | `plans/round-64-c1.sh` or its build receipt names the A4 vehicle AND codes a `vehicle` leg; the seal matches; the A4 vehicle re-derived here reads `accepted=0 rejected=0` on the round-63 tables AND `heldout>=1` on the sealed held-out set | no counter, no vehicle leg, no A4 naming, seal mismatch, or a vehicle that also answers the held-out set (`heldout=0`) |
| `d2` | D-63-2 (M63-LEN) | one `timeout 1200` invocation on a scratch copy prints exactly one `C2_REFUSAL:` line and exits 0/1; `C2_RECURSION_BOUND=0` under `timeout 240` prints none and exits 124 | counter absent, no verdict line inside 1200 s (still recursing), or the unbound run terminates |
| `d3` | D-63-3 (carried) | the six round-63 final receipts exist with their label lines and are cited by the round-63 lesson and `LOG.md` | any receipt absent or uncited (named in the detail line) |

Design notes that matter for reading the detail line:

- `d1` re-derives the vehicle **independently of the counter**: it builds its
  own checker (a literal table of the committed tables' replacement strings, a
  constant `C1_CHECK_SELFTEST: PASS (cases=91)` selftest, `value=1` on a hit
  else `value=0`) — it does not import the counter's `make_vehicle_tree`. It
  also refuses to run against an unsealed held-out table (`seal=mismatch` ⇒
  `d1=0`, never a pass and never a hidden SETUP).
- The vehicle reads only `LOG.md`, `plans/round-60.md` and
  `corpus/lessons/round-60.md` (measured: the counter's vehicle also reads
  `SKILL.md`, and `SKILL.md` carries 0 of the 15 table strings — my three-file
  root is therefore equivalent for the hit test). Its fixture trees are ~1 MB
  roots, not 24 full-tree copies.
- `d2` copies the measured tree **with `.git`** (`cp -a`), so the copied
  counters' read-only `git archive` legs read what the lane reads. One copy is
  used for both halves. Each half runs in its own session and the leg kills the
  process group on timeout, so a recursive child cannot outlive it.
- `d3` substitutes nothing: an absent receipt is named in the detail line and
  reads 0.

## Instrument bytes measured

```
$ sha256sum plans/round-64-c1.sh plans/round-64-c2.sh plans/round-64-controls.sh plans/round-64-heldout.tsv
e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484  plans/round-64-c1.sh
e2d8171f4da7b5501906d643c98fe6f822b46baf266f19f2fe81ca5bb7f37e4b  plans/round-64-c2.sh
7e7492affc22c99def4dfb2eb47f108157fafbea0f57f45c46657b729f173e4f  plans/round-64-controls.sh
b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2  plans/round-64-heldout.tsv
```

The held-out table matches the seal the plan froze (`b0f51e2a…`, 20 rows). The
two round-64 counters named above are the bytes the authoritative run (M1)
measured: `round-64-c2.sh` mtime 03:09, `round-64-c1.sh` mtime 03:13, and both
are the sha256 the C1/C2 seats' own build receipts record. They are uncommitted
working-tree files at this writing (the L1 commits them); a later edit changes
the reading, and the L1's integration run is the one that counts.

```
$ sha256sum .ufo/waves/round-63/final/*.txt
8b725e4bc6b98fc22aa733bcba0047b425526e85046f97291e35156567d0591b  .ufo/waves/round-63/final/c1-residual.txt
3c13c15c9ae4b0a41a8499a7a2b1ec2f3b679fb18874bca4ad743aa6173d5f4b  .ufo/waves/round-63/final/c2-refusal.txt
0f197c12c1487a5a2d8a1cb16cde2d70c8047e7f0724797c53382ef0c8614416  .ufo/waves/round-63/final/claims-declared.txt
6b83965b6fff51045f8146b5e4787fa68964dd16e1ea44ed0fc069d627134d27  .ufo/waves/round-63/final/doc-audit.txt
b8d4bd2002088d9307d1774a1dc1f4fe067936d19d17486b97bbfe730ca46c9f  .ufo/waves/round-63/final/release-clock.txt
```

Five files; `controls.txt` is absent (finding F1).

## Measured readings

### M1 — the lane tree, run alone (the authoritative receipt run)

```
$ cd /home/vgpnk/Projects/shokunin/kagi-shokunin
$ bash -n plans/round-64-routed.sh && sha256sum plans/round-64-routed.sh
syntax-ok
2689cdec055eadd5bb3e5b2881e3432fad1a1fa298e6116ac499b22ca3d0db05  plans/round-64-routed.sh
$ echo "start $(date -Is)"; time bash plans/round-64-routed.sh; echo "rc=$?"; echo "end $(date -Is)"
start 2026-11-08T03:58:01-03:00
routed-leg d1: counter=ok src=counter+receipt a4=1 lookup=1 seal=match table=15 r63 accepted=0 rejected=0 heldout_vehicle=5 h=5 q=0 setup_bad=0
routed-leg d2: bounded lines=1 rc=0 line=[C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)] unbound lines=0 rc=124 bound_off=1
routed-leg d3: receipts=5/6 absent=controls lesson-db=1
ROUTED: d1=1 d2=1 d3=0
rc=1
real	8m34.639s
end 2026-11-08T04:06:35-03:00
$ sha256sum plans/round-64-c1.sh plans/round-64-c2.sh
e03a4d69f7f13e5e4a731082bac4684f5014f105237e81834489ccdd62368484  plans/round-64-c1.sh
e2d8171f4da7b5501906d643c98fe6f822b46baf266f19f2fe81ca5bb7f37e4b  plans/round-64-c2.sh
```

Reading:

- `d1=1` — the counter names the A4 vehicle and carries the leg (both the
  script header and its build receipt name it: `src=counter+receipt`); the
  independently derived vehicle reads `accepted=0 rejected=0` on the committed
  tables (`table=15`) and `heldout_vehicle=5` on the sealed held-out set
  (`h=5 q=0`).
- `d2=1` — one bounded invocation produced exactly one `C2_REFUSAL:` line,
  `killed=5 population=5 guard=1 … terminates=1 bound=1`, rc 0, in 8m34s
  (inside `timeout 1200`); with `C2_RECURSION_BOUND=0` under `timeout 240` it
  produced no verdict line and exited 124. The bound is real and the end-to-end
  claim is reproduced.
- `d3=0` — `.ufo/waves/round-63/final/controls.txt` is absent (finding F1); the
  other five receipts are present with their label lines and are cited.

### M1b — the same leg under the wave's load (why M1 is run alone)

Two earlier lane runs, taken while this seat also had four other measurements
running (the wave's other seats were still measuring too), read the same d1
and termination verdict but different counter fields:

```
routed-leg d2: bounded lines=1 rc=1 line=[C2_REFUSAL: killed=5 population=5 guard=0 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=0 terminates=1 bound=1)] unbound lines=0 rc=124 bound_off=1
routed-leg d2: bounded lines=1 rc=1 line=[C2_REFUSAL: killed=3 population=5 guard=0 (l1=0 l2=0 l3=1 l4=1 l6=1 selftest=0 real=0 terminates=1 bound=1)] unbound lines=0 rc=124 bound_off=1
```

The isolated controls pass:

```
$ bash plans/round-64-c2.sh --selftest
C2R64_SELFTEST: PASS (cases=21)                     # 5.1 s
$ bash plans/round-62-c1.sh --selftest --tree .
C1_COUNTER_SELFTEST: PASS (15/15 checks)            # 111 s, copied 13890 files
```

and the C2 seat's own isolated receipt (`.ufo/waves/round-64/build/R64ExecC2Counter/e2e-bound1-final.txt`)
reads `killed=5 population=5 guard=1 (l1=1 … selftest=1 real=1) terminates=1
bound=1`, elapsed 501 s. The stable fact across every run is the one `d2`
requires: exactly one verdict line, rc 0/1, inside 1200 s. The counter's
`guard`/`killed` fields are load-sensitive through its internal fixed-window
selftests (`timeout 5` around the fixture battery) and the real trial's
readiness loop, so the integration reading of the claim must be taken on a
quiet host — see finding F2.

### M2 — a tree that makes all three legs read 1 (the positive fixture)

`fixtures/golden`: the lane's three fixture-carrier files and its four TSVs,
the five round-63 final receipts plus a `controls.txt` carrying
`CONTROLS: match=5 mismatch=2`, a `plans/round-64-c1.sh` whose header names the
A4 lookup-table vehicle (`leg_vehicle: … (vehicle=1)`), and a
`plans/round-64-c2.sh` that prints one verdict line at bound 1 and re-enters
forever at `C2_RECURSION_BOUND=0`.

```
$ bash plans/round-64-routed.sh --tree /fast/scratch/hyaku/kagi-r64/R64ExecRouted/fixtures/golden
routed-leg d1: counter=ok src=counter a4=1 lookup=1 seal=match table=15 r63 accepted=0 rejected=0 heldout_vehicle=5 h=5 q=0 setup_bad=0
routed-leg d2: bounded lines=1 rc=0 line=[C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)] unbound lines=0 rc=124 bound_off=1
routed-leg d3: receipts=6/6 lesson-db=1
ROUTED: d1=1 d2=1 d3=1
rc=0
real	4m1.5s
```

### M3 — `d1` able to fail: a counter with no vehicle leg

`fixtures/d1-no-vehicle-leg` is `golden` with `plans/round-64-c1.sh` replaced by
a counter that prints the target line but carries neither a vehicle leg nor the
A4 naming.

```
$ bash plans/round-64-routed.sh --tree /fast/scratch/hyaku/kagi-r64/R64ExecRouted/fixtures/d1-no-vehicle-leg
routed-leg d1: counter=no-vehicle-leg src=none a4=0 lookup=0 seal=match tables=ok
routed-leg d2: bounded lines=1 rc=0 line=[C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)] unbound lines=0 rc=124 bound_off=1
routed-leg d3: receipts=6/6 lesson-db=1
ROUTED: d1=0 d2=1 d3=1
rc=1
real	4m0.1s
```

`d1=0` with the other two legs reading 1: the leg fails on its own condition.

### M4 — `d1` able to fail: the fresh-lookup vehicle (the plan's K5 ceiling)

`fixtures/d1-fresh-lookup` is `golden` with the five held-out H replacements
appended as extra rows to `plans/round-63-residual.tsv`, so the derived table
carries 20 strings and answers the held-out set as well as the committed one.

```
$ bash plans/round-64-routed.sh --tree /fast/scratch/hyaku/kagi-r64/R64ExecRouted/fixtures/d1-fresh-lookup
routed-leg d1: counter=ok src=counter a4=1 lookup=1 seal=match table=20 r63 accepted=0 rejected=0 heldout_vehicle=0 h=0 q=0 setup_bad=0
routed-leg d2: bounded lines=1 rc=0 line=[C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)] unbound lines=0 rc=124 bound_off=1
routed-leg d3: receipts=6/6 lesson-db=1
ROUTED: d1=0 d2=1 d3=1
rc=1
real	4m1.7s
```

`heldout_vehicle=0` on the table that carries the held-out entries: the leg's
`heldout>=1` half is load-bearing, and a lookup table that learns the held-out
fixtures is refused (the plan §C1 named ceiling, demonstrated rather than
asserted).

### M5 — `d3` able to fail: a missing receipt

`fixtures/d3-no-controls` is `golden` minus
`.ufo/waves/round-63/final/controls.txt`.

```
$ bash plans/round-64-routed.sh --tree /fast/scratch/hyaku/kagi-r64/R64ExecRouted/fixtures/d3-no-controls
routed-leg d1: counter=ok src=counter a4=1 lookup=1 seal=match table=15 r63 accepted=0 rejected=0 heldout_vehicle=5 h=5 q=0 setup_bad=0
routed-leg d2: bounded lines=1 rc=0 line=[C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)] unbound lines=0 rc=124 bound_off=1
routed-leg d3: receipts=5/6 absent=controls lesson-db=1
ROUTED: d1=1 d2=1 d3=0
rc=1
real	4m1.5s
```

This is the same reading the lane tree produces (M1): the absent receipt names
itself and nothing is substituted for it.

### M6 — `d2` able to fail: a tree that still hangs

`fixtures/d2-hang` is `golden` with `plans/round-64-c2.sh` replaced by a counter
that re-enters on both paths (the BASE defect shape).

```
$ bash plans/round-64-routed.sh --tree /fast/scratch/hyaku/kagi-r64/R64ExecRouted/fixtures/d2-hang
routed-leg d1: counter=ok src=counter a4=1 lookup=1 seal=match table=15 r63 accepted=0 rejected=0 heldout_vehicle=5 h=5 q=0 setup_bad=0
routed-leg d2: bounded lines=0 rc=124 unbound lines=0 rc=124 bound_off=1
routed-leg d3: receipts=6/6 lesson-db=1
ROUTED: d1=1 d2=0 d3=1
rc=1
real	24m1.5s
```

The bounded half spent its whole 1200 s budget with no verdict line
(`lines=0 rc=124`) and the unbound half produced none either: `d2=0` on a tree
that still recurses, which is the round-63 BASE shape (the committed
`c2-refusal.txt` is 7 bytes `rc=124`). The leg waits out the full budget rather
than guessing, which is why this demonstration is the expensive one.

### M7 — the setup paths

```
$ bash plans/round-64-routed.sh --tree /nope
ROUTED: SETUP bad-tree /nope
rc=2
$ bash plans/round-64-routed.sh --bogus
ROUTED: SETUP unknown-arg --bogus
rc=2
$ bash plans/round-64-routed.sh --help | tail -3
#   ROUTED: d1=<0|1> d2=<0|1> d3=<0|1>
# Exit 0 iff all three read 1; 1 otherwise; 2 SETUP (unknown arg, bad
# tree/repo, missing python3/git/scratch).
rc=0
$ bash -n plans/round-64-routed.sh
syntax-ok
```

## The vehicle re-derivation, fixture by fixture

The A4 vehicle's table is the 15 replacement strings of
`plans/round-63-residual.tsv` (F1..F10) and `plans/round-62-bypass.tsv`
(B3..B7). Supplementary probe (an ad-hoc python3 heredoc carrying the same
vehicle source as the script's `d1`, run against a three-file root; each anchor
asserted to occur exactly once). On the unmodified root it reads `value=0`; a
table hit reads `value=1`:

```
unmodified       value=0
F2  value=0   F6  value=0   F8  value=0   F10 value=0   B4  value=0     (H: accepted)
P6  value=0   B5  value=0   P7  value=0                                (Q: accepted)
```

So `h=5 q=0 heldout_vehicle=5`: the vehicle accepts every held-out forgery
(the C1 target it would have to reject) and also accepts the three benign
rewrites it would have to accept — it reaches 5, not 0. That is the vacuum
D-63-1 names, re-derived independently of the counter that now guards it.

None of the eight held-out H/Q replacement strings occurs verbatim in, or
contains, a committed table string:

```
$ python3 …   # table (15 strings) vs the eight held-out H/Q rows
F2 F6 F8 F10 B4 P6 B5 P7  exact-table-hit=0  contains-table-string=0
$ python3 …   # the committed tables' strings vs the carrier files
SKILL.md hits: 0   LOG.md hits 0   corpus/lessons/round-60.md hits 0   plans/round-60.md hits 0
```

so the held-out set is not vacuous against the committed tables, and the
three-file vehicle root is equivalent to the counter's four-file corpus for the
hit test.

## Findings

**F1 — D-63-3's "six receipts (present)" is off by one.** The spot-check §6
D-63-3 records the D-B disposition as "six receipts under
`.ufo/waves/round-63/final/` (present)". Measured: five are present
(`c1-residual.txt`, `c2-refusal.txt`, `release-clock.txt`, `doc-audit.txt`,
`claims-declared.txt`) and `.ufo/waves/round-63/final/controls.txt` does not
exist — it is in no commit (`git ls-files .ufo/waves/round-63/final/` lists
five), and the round-63 LOG entry says why: the battery's full candidate run
re-enters the C2 recursion and "is scrapped as the candidate receipt" (the
point observation is `build/R63ExecControls/controls.md`). So D-63-3 is not
"nothing open": the controls receipt is a casualty of D-63-2's ceiling.
`leg d3` reads 0 and names it. This is reported, not amended: the receipt
requirement stands as the plan and the spot-check state it, and the disposition
is the L1's to record (land a `controls.txt` from a bounded battery run, or
record the receipt as superseded by the round-64 bounded battery). Note also
that the round-63 lesson cites only `c1-residual.txt` and `c2-refusal.txt` by
full path; the other four are named by stem in the lesson's D-B row, which is
what `d3` accepts.

**F2 — the C2 counter's guard and kill fields are load-sensitive; the
termination claim is not.** The authoritative run (M1) reproduces the claim
exactly (`killed=5 population=5 guard=1 … terminates=1 bound=1`, 8m34s, rc 0).
Two earlier runs taken while this seat had four other measurements running read
`killed=5 guard=0 real=0` and `killed=3 guard=0 selftest=0 …` — the same
number of verdict lines and the same `terminates=1 bound=1`, different internal
fields. Isolated, the components pass: `round-64-c2.sh --selftest` ⇒
`C2R64_SELFTEST: PASS (cases=21)` in 5.1 s; `round-62-c1.sh --selftest --tree .`
⇒ `C1_COUNTER_SELFTEST: PASS (15/15 checks)`; and the C2 seat's own isolated
receipt reads `killed=5 population=5 guard=1 … terminates=1 bound=1` at 501 s.
The mechanism is the counter's own fixed windows (`timeout 5` around the
fixture-battery composition) plus the real trial's readiness loop
(`corpus/openbao-seal-trial.sh` picks free ports and waits), which fail under a
loaded host. Consequence: the integration measurement of `guard=1` must be taken
on a quiet host and recorded verbatim; a `guard=0` under load is not evidence the
bound failed. `d2` therefore reads only termination (one verdict line plus rc
0/1, as the seat spec states) and prints the verdict line so the fields are
visible.

**F3 — named ceiling on `d2`.** The leg reads termination, not authenticity: a
counter that prints one `C2_REFUSAL:` line and exits 0 passes `d2=1` (the
`golden` fixture is exactly such a stub, and M2 shows it). A stub is refused by
the counter's own guard/selftest and by `plans/round-64-controls.sh`, not by
this leg. `d2=1` therefore means "the tree terminated with a verdict line", and
nothing stronger.

**F4 — named ceiling on `d1`.** `d1` proves the *instrument* (a vehicle leg
exists, is named, and the A4 vehicle is refused on the held-out set); it cannot
prove the counter's leg is wired to its verdict line rather than printed. The
counter's own `--selftest` and the controls battery carry that. And, as the plan
states, a lookup table carrying a new entry per held-out fixture would still
reach `heldout=0` — M4 shows this leg refuses that table on *this* receipt's
vehicle, which is a statement about the derivation, not a grammar proof.

**F5 — operational note.** A bash script must not be edited while a process is
executing it: one fixture run (the first `d2-hang`) was polluted by an edit
made during its execution and printed a shell parse error after its verdict. It
was discarded and every reading above was re-taken on the frozen
`2689cdec…` bytes. No tool was installed or upgraded (no pacman, no `uv`).

## Appendix — how the demonstration fixtures were built

Every fixture lives under
`${HYAKU_SCRATCH}/kagi-r64/R64ExecRouted/fixtures/<name>/` and was built by one
python3 heredoc (`build-fixtures.py`, run once; reproduced here as the recipe,
since the scratch dir is deleted before yield). Base file set copied verbatim
from the lane: `LOG.md`, `plans/round-60.md`, `corpus/lessons/round-60.md`,
`plans/round-63-residual.tsv`, `plans/round-63-benign.tsv`,
`plans/round-62-bypass.tsv`, `plans/round-64-heldout.tsv`,
`corpus/lessons/round-63.md`; final-receipt set: the lane's five
`.ufo/waves/round-63/final/*.txt` plus a written `controls.txt` containing
`CONTROL C1-F8 verdict=mismatch`, `CONTROL C2-F6 verdict=mismatch`,
`CONTROLS: match=5 mismatch=2`.

- `golden` = base set + receipt set + `plans/round-64-c1.sh` (a bash stub whose
  header carries `leg_vehicle: the A4 lookup-table vehicle is refused on the
  held-out set (vehicle=1)` and prints
  `C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)`,
  exit 0) + `plans/round-64-c2.sh` (a bash stub: if
  `${C2_RECURSION_BOUND:-1}` = 0 it loops `sleep 5` forever, else it prints one
  `C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)`
  and exits 0), both executable.
- `d1-no-vehicle-leg` = `golden` with `plans/round-64-c1.sh` replaced by a stub
  that prints `C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1)`
  and exits 0 — no `vehicle` leg, no A4 naming.
- `d1-fresh-lookup` = `golden` with five rows appended to
  `plans/round-63-residual.tsv`, ids `X0..X4`, carrying the held-out H rows'
  `file`/`anchor`/`replacement` (F2, F6, F8, F10, B4).
- `d2-hang` = `golden` with `plans/round-64-c2.sh` replaced by a stub that
  loops `sleep 5` forever on every path.
- `d3-no-controls` = `golden` minus `.ufo/waves/round-63/final/controls.txt`.

The golden stub counters are demonstration instruments only; they are not, and
are not cited as, the lane's counters. C2's `d2=1` on `golden` is the named
ceiling in finding F3.

## Scratch

Everything under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecRouted/`
(vehicle roots, the build fixtures, the copy probe, the d2 copy) was deleted
before yield; no `/tmp` path is cited as evidence, and no copy ever sat inside
the measured tree.
