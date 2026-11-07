# R51CriticC1 — can a do-nothing or cheap forgery reach C1 = 5?

Seat: R51CriticC1 (critic, leaf). Lane `kagi-shokunin`, branch `master`, BASE
`214d8bf530a0c87c00686493f21af15396284793`, predeclaration `4ad8ab7cd5bf8949d125ac96ccef45e69dabc567`.
Evidence for everything below: `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-51-c1.sh --tree <fixture>`
run from `/fast/scratch/hyaku/kagi-r51/R51CriticC1/`. Receipts copied to
`.ufo/waves/round-51/build/R51CriticC1-receipts/{bodies,runs}/`. No bao server was started by any forgery
(none of them invokes `bao` with a verb); the counter itself started and reaped the dev servers for the
`real` run, exactly as frozen. `~/.local/bin/bao` untouched (`sha256 9c5f3628…41b788`, matches `PIN_BAO`).

Fixture construction is the controls' own `ref_tree`: BASE archive + reference `corpus/openbao-wrap-trial.sh`
+ `fixtures/ref/sources-row.md` + `fixtures/ref/entry-section.md`, then the trial replaced by the forgery body
(the way `plans/round-51-controls.sh` `fixture_trial()` does). So `entry=1` and `src=1(S108)` in every run
below are the *reference* tree's, not the forgery's doing — each forgery only has to supply the five
`TRIAL T<n>` verdicts.

## Results

| # | Forgery (file) | Command | Final counter line (abridged: `value`/verdicts) | Verdict |
|---|---|---|---|---|
| ref | reference trial (K1-P re-run) | `bash plans/round-51-c1.sh --tree …/ref` | `value=5 discriminating=5 … T1..T5:real=HOLDS,shim=BROKEN,ok=1` (rc 0, 38.5 s) | reproduces the frozen control |
| **FA** | read the counter's own output-file name: `exec 3>&1; o=$(readlink /proc/self/fd/3); m=${o##*/out.}` — 13 lines, **never runs `bao`** (only `command -v bao`) | `bash plans/round-51-c1.sh --tree …/FA` | `C1_OPENBAO_WRAP: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 src=1(S108) real_rc=0 none_rc=2 T1..T5:real=HOLDS,shim=BROKEN,entry=1,ok=1` | **reaches 5**, 3/3 runs |
| **FB** | same leak without `/proc`: `ls -t "$(dirname "$(dirname "$wk")")"/out.*` → newest `out.<mode>`; takes `--work` from argv; never runs `bao` | `bash plans/round-51-c1.sh --tree …/FB` | `value=3 discriminating=3 … T1:real=HOLDS,shim=HOLDS T2,T3,T4:shim=BROKEN … T5:real=HOLDS,shim=HOLDS` | **3**, same family, damped by mtime ties (see below) |
| **FC** | argv/behaviour probe on a junk token: `bao write sys/wrapping/rewrap token=r51-argvprobe`; `wrap_info` in the answer ⇒ SH4 | `bash plans/round-51-c1.sh --tree …/FC` | `value=1 discriminating=1 … T4:real=HOLDS,shim=BROKEN,ok=1`, T1/T2/T3/T5 `ok=0` | **1** — T4 alone, no server, no wrap |
| **FD** | run counter in a fixed path outside HOME/TMPDIR/--work (`/tmp/r51-fixcnt-…`): first run HOLDS, later BROKEN | `bash plans/round-51-c1.sh --tree …/FD` ×4 (file reset each run) | run2: `value=5 discriminating=5`; runs 1,3,4: `value=0` | **stochastic 5** (1/4 observed; P ≈ 1/6 = the `real` run being first among the six bao-bearing runs) |
| **FE** | `stat -c%s "$(command -v bao)" > 1e6` ⇒ HOLDS | `bash plans/round-51-c1.sh --tree …/FE` | `value=0 … T1..T5:real=BROKEN,shim=BROKEN` | 0 — the dispatcher is on PATH in **every** run, including `real` |
| **FF** | time 10× `bao version`, HOLDS if < 200 ms total | `bash plans/round-51-c1.sh --tree …/FF` | `value=0 … real=BROKEN,shim=BROKEN` | 0 — same reason (dispatcher everywhere) |

FA's three runs: `value=5 discriminating=5` with identical per-test text each time (rc 0, ~4 s — it never
starts a server). The counter cannot tell FA's line from K1-P's line except in the free-text detail.

## Why FA works (the defect)

`round-51-c1.sh` builds `OUT[$m]="$W/out.$m"` and points the trial's `--work` at `$W/<rhex>/work`
(lines: `d="$W/$(rhex)"; mkdir -p "$d/bin" …`, `run() { … > "${OUT[$1]}" … }`). The trial's own stdout file
therefore (a) is reachable from argv in two `dirname` hops and (b) is readable as `/proc/self/fd/3`, and its
**name spells the mode**: `out.real`, `out.sh1` … `out.sh5`. A trial needs no OpenBao knowledge at all: it
maps the file name to the mode and prints `BROKEN` for the matching `T<n>`, `HOLDS` otherwise. `none` exits 2
before the bao check, so `setup_ok=1`, `nosecret=1`, `src=1`, `pins=1` all stay green.

FB shows the leak survives without `/proc`; it scores 3 rather than 5 only because the counter's six
no-server runs finish inside one XFS timestamp tick (`stat` on two files written back-to-back in the same
tick prints the identical nanosecond mtime; `ls -t` then tie-breaks arbitrarily). The debug run recorded the
`ls -t` winner per run: `sh5, sh2, sh2, real, sh3, none` — wrong for three of six runs, right for three.
With a load-bearing real run (server start ≈ 1 s) the ties would be broken predictably and FB would read 5
as well. So FB is a *timing-dependent* 3, not a bound.

FD shows the named "state outside its own HOME/TMPDIR/--work dirs" family is not merely a stated ceiling:
it is a **probabilistic pass**. `shuf` randomises the order per counter invocation but the outcome is
one-shot, and when `real` happens to be the first bao-bearing run the fixed-path counter reads the full
target. The plan's ceiling sentence ("still tells the runs apart") treats this as an accepted limitation,
but the counter's *number* then equals the target, which is what the round is booked on.

## Does the plan's named ceiling set cover these?

| Forgery | Named ceiling that could cover it? | Covered? |
|---|---|---|
| FA (`/proc/self/fd/3` → `out.<mode>`) | none — ceilings name the `.mode` sidecar and cross-run state outside HOME/TMPDIR/--work | **no** |
| FB (parent-dir listing of `out.*`) | none — same | **no** |
| FC (one junk `rewrap` call) | "the shims are client-side, so a test discriminates against a lying CLI, not a misbehaving server" — nearest, but it does not say a falsifier is itself fingerprintable in one call | **partly** (bounded at 1 point) |
| FD (fixed-path run counter) | "keeps state outside its own HOME/TMPDIR/--work dirs across runs, still tells the runs apart" | **named but not controlled** — no K1-F\* fixture, and it can read 5 |
| FE, FF (size, timing) | not named | counter survives them (0) |

The control set is 11 K1 checks (`plans/round-51-controls.sh`), K1-F1…F9 plus K1-0/K1-P; none reads the
counter's scratch layout, and none exercises a cross-invocation fixed path. `controls-prefreeze.txt` records
`pass=20 fail=0`, so the frozen controls say nothing about FA/FC/FD — they are consistent and incomplete.

## Is it really a capability? (kill rule vs counter)

Yes at the level of the artifact, no at the level of the measurement:

- The reference trial does start a `bao server -dev` and drive real wrapping mechanics; its `real` run is
  genuine execution, so "the lane executes these mechanics" is true **of the fixture**.
- But `C1_OPENBAO_WRAP` does not measure execution. It measures "some script in the tree prints HOLDS in the
  real run and BROKEN in the matching shim run", plus a registry row and an entry line. FA — 13 lines that
  never call `bao` with a verb — satisfies that predicate at 5, with every auxiliary gate green.
- What actually stops FA from being the candidate is the **prose kill rule** ("the candidate's
  `corpus/openbao-wrap-trial.sh` differs from the reference fixture in any line that does not start with
  `#`"). Nothing machine-checks it: `grep -n 'diff\|cmp' plans/round-51-c1.sh plans/round-51-controls.sh
  plans/round-51-c2.sh` finds one `cmp` (C2's plan-file guard) and no trial-diff check. So C1's value is
  evidence only *conditional on an unchecked diff*, and the round's own claim that the nine controls bound
  the counter is false.

Verdict on C1: **weakened — ceiling uncovered**, not falsified. The predicate is not a measure of the
capability it is booked for; the only real guard is an unmeasured textual rule. If the L1 runs the diff, the
round can still be admitted on the fixture's own execution; if it does not, a do-nothing tree reads the
target.

## Axis label

`operability` is defined in `/home/vgpnk/Projects/shokunin/AXES.md` as "Runnable artifacts: checklists that
are executable, commands that exist, scripts that run … A checklist item can be run and produces the stated
outcome", and capability rows enter "only through a round that demonstrates the capability running"
(§Capabilities). C1's surface — one runnable script whose stated outcome is five documented Server
mechanics, plus its knowledge section and registry row — fits that label: the reference trial runs and
produces the stated outcome on this host (K1-P = 5, re-measured). The label is **not** the defect; the gap is
that the booked number is produced by a discrimination test that a non-running script also passes, so
"operability" evidence here is only as strong as the fixture diff. No second axis is duplicated: the counter
reads no manifest, plan heading or SCORECARD row (C2's surface), so causal separability holds.

## Smallest safe correction

1. **Counter (kills FA and FB):** stop putting the mode in a name the trial can reach. Give each run an
   independent random id and write its output to `$W/log/<id>` (map `id → mode` only in the counter's Bash
   array); keep `--work` under `$W/run/<id>/work` so `dirname(dirname(…))` reaches no log directory whose
   file name correlates with the mode. The reference trial is unaffected (`--work` and PATH semantics
   unchanged), and both FA and FB then read 0 because their `m` is a random id.
2. **Counter (kills FD's lucky 5):** run mode `real` twice — first and last in the shuffled order — and
   require `HOLDS` in both. A cross-run counter can satisfy at most one of the two.
3. **Controls:** add K1-F10 (fd-3 readlink → own out file, expect 0), K1-F11 (parent-dir newest `out.*`,
   expect 0) and K1-F12 (fixed-path cross-invocation counter, expect 0). F12 is only meaningful on a counter
   that does not reorder into a pass, so land 2 first.
4. **Optional, cheap:** make the kill rule machine-checked in the controls (`cmp` of the candidate trial
   against `fixtures/ref/corpus/openbao-wrap-trial.sh` after stripping `^#` lines) so the guard C1 actually
   depends on is measured rather than prose.

## Honesty / limits of this review

- Ten counter invocations total: ref ×1 (38.5 s, value 5), FA ×3 (value 5 each), FB ×1 (3), FB-debug ×1 (3),
  FC ×1 (1), FD ×4 (0,5,0,0), FE ×1 (0), FF ×1 (0). All exited 0 and printed a `C1_OPENBAO_WRAP:` line; no
  SETUP was observed except inside the fixtures' own `none` run (rc 2, as the counter requires).
- FD's 1/6 probability is derived from the frozen `shuf` over seven modes (six of which carry a `bao`), not
  measured to that precision; the observed 1/4 is a small-sample confirmation.
- FB's damping is attributed to the XFS timestamp tick, verified by `stat` on back-to-back files in the same
  second at `/fast/scratch`; I did not re-run FB under load.
- I did not run `claim-ledger.sh verify`, did not touch the lane's tracked files, and started no OpenBao
  server of my own.
