# R51MutCounters — mutation test of the round-51 counters

Probe: challenge the round-51 C1 (`plans/round-51-c1.sh`) and C2 (`plans/round-51-c2.sh`)
invariants with single-point defects in isolated scratch lanes, then re-run the frozen control
battery (`plans/round-51-controls.sh`, bytes unmodified) against the frozen fixtures. Baseline
first; a baseline failure would make a mutant inconclusive, not killed.

**Verdict: 16 mutants, 11 KILLED, 5 SURVIVED.** Every survivor is a control-battery blind spot
(coverage finding), not a licence to change a contract. No counter bytes were edited in the lane;
all mutation happened in throwaway scratch clones.

## Setup (absolute paths; read-only on the lane)

- Lane measured: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, HEAD
  `4ad8ab7cd5bf8949d125ac96ccef45e69dabc567` (predeclaration; the candidate is not landed).
  - `plans/round-51-c1.sh` sha256 `e71dc8ed1edfc8ce9979ed09de25467559a6ac9fbf0a4610924b440529fefa53`
  - `plans/round-51-c2.sh` sha256 `52790a353d52b1dbdaa976c06f01e85510cb2da91a8c1dba98a4ff9131b6bb62`
  - `plans/round-51-controls.sh` sha256 `a14d44e9ad0d66f00812e5a072e02dbfedcde318ef149a5e3db5eebf02e9e433`
- Scratch root `$S=/fast/scratch/hyaku/kagi-r51/R51MutCounters`.
  - `$S/lane` = `git clone -q --shared` of the lane; `git -C $S/lane rev-parse --show-toplevel`
    printed `$S/lane` before use; its two counters still hash to the pins above.
  - `$S/mut/<ID>/work` = one `git clone -q --shared $S/lane` per mutant; toplevel asserted equal
    to `$S/mut/<ID>/work` before anything else. The mutant bytes are written over
    `plans/round-51-c{1,2}.sh` in that clone only (uncommitted working-tree modification), so every mutant diff
    is exactly one hunk (`grep -c '^@@'` = 1 for all 16; anchored replacements asserted to match
    exactly once before writing).
- Detector invocation (unchanged battery, one sweep per mutant):
  `cd $S/mut/<ID>/work && env HOME=/home/vgpnk HYAKU_SCRATCH=$S/scr/<ID> R51_BAO=/home/vgpnk/.local/bin/bao bash $S/mut/<ID>/work/plans/round-51-controls.sh <c1|c2>`
  C1 sweeps measure with `--tree fixture`; C2 sweeps clone the mutant lane into `$G` and copy the
  mutant `plans/round-51-c2.sh` in as `$G/plans/round-51-c2.sh.ctl` (the battery's own mechanism).
- bao: `/home/vgpnk/.local/bin/bao`, OpenBao v2.7.2. Every trial run is its own throwaway
  `bao server -dev` on 127.0.0.1 with a random port and a random root token kept only in scratch;
  the trial's own cleanup kills it. No token, wrapping token, root token, password or nonce value
  is printed in any receipt or in this report.
- No host mutation, no package operation, no network write; `/tmp` unused (all scratch is under
  `/fast/scratch`).

## Baseline (pristine counters, same battery, same fixtures)

| sweep | command | receipt last line | exit | wall |
|---|---|---|---|---|
| C1 | `bash plans/round-51-controls.sh c1` | `CONTROLS: pass=11 fail=0` | 0 | 3m23.8s |
| C2 | `bash plans/round-51-controls.sh c2` | `CONTROLS: pass=9 fail=0` | 0 | 25.7s |

C1 readings: K1-0 0, K1-P 5, K1-F1 0, K1-F2 0, K1-F3 0, K1-F4 0, K1-F5 5, K1-F6 0,
K1-F7 0, K1-F8 0 (`nosecret=0`), K1-F9 0 — every control MATCH.
C2 readings: K2-0 3 (M=2 V=1), K2-P 0, K2-F1 3, K2-F2 5,
K2-F3 `SETUP reason=g2-changed:plans/round-50.md`, K2-F4 `SETUP reason=g1-gate-changed`,
K2-F5 `SETUP reason=g3-row-missing:47 C1 calibration`, K2-F6 1, K2-F7 1 — every control MATCH.

So the detector is live before any mutation; kills below are attributable to the mutant.

## C1 mutants — diff, sweep, verdict

Each row was run as a full 11-control C1 sweep on a fresh clone; `pass/fail` is the battery's own
summary. The mutated line numbers refer to the pristine `plans/round-51-c1.sh`.

| id | single-point diff | sweep | verdict (control that flips) |
|---|---|---|---|
| C1-M1 | line 146: drop `[ "$sv" = BROKEN ]` from `ok=0; …` | 9/11 | **KILLED** — K1-F3 `expect=0 got=5`, K1-F4 `expect=0 got=5` (all five tests scored with `shim=HOLDS,ok=1`) |
| C1-M2 | line 127: drop `\| shuf` — fixed run order | 11/11 | **SURVIVED** |
| C1-M3 | line 106: `d="$W/bin-$m"` instead of a fresh random hex dir | 9/11 | **KILLED** — K1-F2 `expect=0 got=5` (PATH carries `real`), K1-F3 `expect=0 got=5` (dir name carries `sh<n>`) |
| C1-M4 | line 153: final guard loses `&& [ $src -eq 1 ]` | 9/11 | **KILLED** — K1-F6 `expect=0 got=5`, K1-F9 `expect=0 got=5` (both `src=0`) |
| C1-M5 | line 146: drop `&& [ "$ev" = 1 ]` from the discriminator | 10/11 | **KILLED** — K1-F7 `expect=0 got=5` (`entry=0,ok=1`) |
| C1-M6 | line 150: NOSECRET loses the `\|r51-[0-9a-f]{24}` alternative | 10/11 | **KILLED** — K1-F8 `expect=0 got=5` (`nosecret=1`, the leaked nonce is no longer seen) |
| C1-M7 | line 153: final guard loses `[ $setup_ok -eq 1 ] &&` | 11/11 | **SURVIVED** |
| C1-M8 | line 150: NOSECRET keeps only `r51-…`, drops the token-shaped alternative | 11/11 | **SURVIVED** |

Survivor arguments (each is a coverage gap, not an equivalent mutant):

- **C1-M2 (run order)** — the predicate's "the six runs execute in a random order" clause is not
  observable to any fixture: F2/F3 read PATH, F4 reads the dispatcher content, F5 reads `.mode`,
  F6/F7 read registry/entry, F8 reads stdout. Each run already owns fresh HOME/TMPDIR/work/bin
  dirs, so order cannot change a well-behaved trial's verdict. The battery would need a fixture
  that records its invocation sequence in a path that survives across runs (e.g. beside `--work`)
  and asserts the order varies; none exists. Mutant is control-equivalent; the declared clause is
  currently unfalsifiable.
- **C1-M7 (`setup_ok`)** — no fixture combines a discriminating real run with a broken none-run:
  F1 has `none_rc=0` but scores 0 (its shims also print HOLDS); every discriminating fixture
  (reference, F3/F4/F5) has `none_rc=2`. Not equivalent in general: a trial that discriminates but
  exits 0 (or prints a HOLDS line) with no `bao` on PATH would score 5 under the mutant and 0 under
  the pristine counter. Needs a fixture "discriminates in the six runs, does not fail closed in the
  none run".
- **C1-M8 (token half of NOSECRET)** — K1-F8 leaks only the `r51-` nonce; no fixture leaks an
  `s.`/`b.`/`hvs.`-shaped string, so the token-shaped alternative is never exercised. Not
  equivalent: the pristine counter catches both classes, the mutant only one. A fixture trial
  echoing a synthetic token-shaped constant (e.g. `s.` + 24 filler characters, never a real token)
  would kill it.

## C2 mutants — diff, sweep, verdict

Full 9-control C2 sweeps on fresh clones; line numbers refer to pristine `plans/round-51-c2.sh`.

| id | single-point diff | sweep | verdict (controls that flip) |
|---|---|---|---|
| C2-M1 | lines 39–43: guard g2 (BASE `plans/round-*.md` identity) deleted | 8/9 | **KILLED** — K2-F3 `expect=SETUP got=1` |
| C2-M2 | lines 44–48: guard g3 (BASE manifest rows) deleted | 8/9 | **KILLED** — K2-F5 `expect=SETUP got=5` |
| C2-M3 | line 55: `M=$(grep -c 'MISMATCH' …)` — anchor dropped | 6/9 | **KILLED** — K2-0 3→4, K2-F1 3→4, K2-F2 5→6 (summary line counted as a mismatch) |
| C2-M4 | line 61: `V=0` — round-48 reading ignored | 4/9 | **KILLED** — K2-0 3→2, K2-F1 3→2, K2-F2 5→4, K2-F6 1→0, K2-F7 1→0 |
| C2-M5 | line 37: guard g1-gate (`claims-declared.sh` sha256 pin) deleted | 8/9 | **KILLED** — K2-F4 `expect=SETUP got=3` (M=0 V=3) |
| C2-M6 | line 33: `git archive "$BASE"` into `$W/t` instead of `"$REV"` | 2/9 | **KILLED** — K2-P 0→2, K2-F2 5→3, K2-F3 SETUP→3, K2-F4 SETUP→5, K2-F5 SETUP→3, K2-F6 1→3, K2-F7 1→3 (K2-F1 coincidentally still 3) |
| C2-M7 | line 58: guard g1-r48-working-copy (lane working-copy pin) deleted | 9/9 | **SURVIVED** |
| C2-M8 | line 54: g4's claims-declared final-line shape check deleted | 9/9 | **SURVIVED** |

Survivor arguments:

- **C2-M7** — every control runs the counter from inside a clone whose working copy is at BASE, so
  `$LANE/plans/round-48-c2.sh` is always the pinned bytes; no fixture drifts it. Not equivalent:
  a drifted working copy would silently change V (the guard exists precisely for that). The battery
  needs a fixture that overwrites the lane's untracked `plans/round-48-c2.sh` before measuring.
- **C2-M8** — g1 pins the gate by sha256, so the only script reaching the final-line check is the
  frozen gate; the one constant/malformed printer fixture (K2-F4) is killed by g1 before g4 runs.
  Not equivalent: a gate that crashes or is killed by the `timeout 300` prints no final line, and
  the mutant would then emit a number (M=0 + V) instead of SETUP. No fixture exercises a truncated
  gate run, so the control battery cannot see it.

## Findings for round 51 (coverage, not contract change)

1. The C1 "random run order" clause, the `setup_ok` conjunct, and the token-shaped half of
   NOSECRET are currently unfalsifiable by `plans/round-51-controls.sh` (C1-M2, C1-M7, C1-M8).
2. The C2 working-copy pin and the claims-declared final-line check are unfalsifiable by the
   current C2 fixtures (C2-M7, C2-M8).
3. Every other single-point weakening tested — the shim-BROKEN conjunct, path-blind bin dirs, the
   SRC guard, the knowledge-entry conjunct, the r51 NOSECRET half, g1-gate, g2, g3, the MISMATCH
   anchor, V, and measuring the wrong tree — is killed by at least one frozen control.
4. Suggested fixtures (for the owner of the plan, not applied here): a trial that records its
   invocation order and one that discriminates but exits 0 without `bao`; a synthetic
   token-shaped leak; a C2 fixture that edits the lane's working-copy `plans/round-48-c2.sh`; and
   a C2 fixture whose pinned gate is replaced by a crashing/truncating stub that still hashes to
   nothing (i.e. a gate run that dies mid-way — requires a way to simulate truncation without
   changing the pinned bytes).

## Restoration / hash evidence

- Pristine bytes verified after the whole probe:
  `sha256sum /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-51-c1.sh` →
  `e71dc8ed…fefa53`; `…-c2.sh` → `52790a35…b6bb62` (identical to the pre-probe pins).
- `$S/lane/plans/round-51-{c1,c2}.sh` hash to the same values and
  `git -C $S/lane status --porcelain -- plans` is empty (the scratch "pristine" copy was never
  mutated).
- Every mutation lives only in `$S/mut/<ID>/work` (disposable per-mutant clones), recorded in
  `R51MutCounters/<ID>.diff`, `<ID>.sha256.txt`, `<ID>.sweep.txt`, `<ID>.rc.txt`. Post-sweep the
  lane still carries only its pre-existing untracked `plans/round-51-c1h.sh` (not mine).
- No `bao` server remains: `ps -eo pid,args | grep '[b]ao server' | wc -l` → 0.

## Receipts

All in `.ufo/waves/round-51/build/R51MutCounters/`:
`baseline-c1.stdout.txt`, `baseline-c2.stdout.txt`, `baseline-summary.txt`,
`<ID>.diff` (single hunk each), `<ID>.sha256.txt` (mutated counter hash), `<ID>.sweep.txt`
(full 11- or 9-control battery output), `<ID>.rc.txt` (exit code, wall time, last line),
`<ID>.stderr.txt` (all empty), `<ID>.note.txt`.
Scratch harnesses: `$S/gen_mutants.py` (asserts one anchored replacement each),
`$S/run_mutants.sh` (bounded sweeps, `timeout 2400`).
