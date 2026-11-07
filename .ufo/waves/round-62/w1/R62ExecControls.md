# R62ExecControls — pre-freeze control battery (round 62, wave 1)

Seat: executor, `R62ExecControls`. Scope held: `plans/round-62-controls.sh` and
`.ufo/waves/round-62/controls/` only, plus scratch under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62ExecControls/`.

## Files changed

- `plans/round-62-controls.sh` — NEW, executable, sha256
  `93587e6d15d5c0ebb94fac3a6039235070632c45dd5c3db86ae7fbcf1107ea97`. One file, three
  modes: `bash plans/round-62-controls.sh [CANDIDATE_TREE]` (default candidate = the
  lane working tree), `--selftest` (fixture-driven, 14 cases, no instruments, no bao),
  and the battery itself. Honours `HYAKU_SCRATCH`; scratch under
  `kagi-r62/R62ExecControls/battery.$$`, trap-removed on exit; `TMPDIR` pointed into
  the scratch; umask 077; every captured instrument line redacted to shape (QM72) with
  the counter's own exceptions (pure-hex 43+ runs are sha-pin shapes, kept as
  `[HEXRUN]`; separator runs as `[SEPRUN]`).
- `.ufo/waves/round-62/controls/controls-prefreeze.txt` — receipt, installed every run
  (last run wins). Final committed-state run: 2026-11-07T22:00:35Z,
  `CONTROLS: match=14 mismatch=0`, battery rc 0, `SEAT-STATUS: complete`.

## Control map (14 lines; K1-BASE split into its two claim legs)

K1-BASE-C1 (BASE census: five bypass fixtures B3..B7 each forged onto a read-only
`git archive` extraction of 60b5b7b6, measured with the BASE checker bytes, pins
`d525ee28…`/`c7d9e272…` verified at extraction; expect accepted=5) · K1-BASE-C2 (the
two reviewer mutations M-A/M-B applied to BASE counter copies as byte-literal needles;
each must SURVIVE `--selftest` at `PASS (cases=11)`; plus the G challenge — a
valid-sha256 trial stub printing no expected observable — which must NOT fire at BASE,
guard=1; expect killed=0) · C1-B3..B7 (each bypass fixture on the candidate snapshot;
hardened checker must read exactly value=1 with exactly its own item unresolved;
anchor count must be exactly 1) · C1-F6 (a stub-checker tree must make the candidate
counter print no `C1_BYPASS:` verdict and exit non-zero, with a clean-tree pre-leg so a
SETUP cannot masquerade as refusal) · C1-F7 (paraphrases P3/P4/P5 must each read
value=0) · C2-F1/F2 (the `# BEGIN-DECIDE`/`# END-SHIMS` marker blocks replaced by
`  echo 5` / `  shims_ok=5`; `--selftest` must exit non-zero with a named FINDING) ·
C2-F3 (the G stub-trial tree must read guard=0 on the unmutated hardened counter) ·
C2-F4 (real bao trial on the candidate: value=5 shims=5 vectors=ok/5) · C2-F5 (a
constant-PASS-selftest counter copy must be refused by the wrapper, differentially:
stub tree guard=0 while the clean candidate reads guard=1, so a red claim leg cannot
satisfy the refusal vacuously). Readiness probes keyed to the frozen floors
(checker selftest ≥ 57 cases, counter selftest ≥ 17 cases) decide match vs
`observed=absent verdict=skip` with the absent instrument named.

## Verification evidence (all runs receipted; receipt file holds the last)

1. 21:28Z run, battery `f2965f12…`: match=8 mismatch=5 skip=1. K1 legs and C2-F1/F2/F3/
   F4/F5 green on the just-landed instruments (checker 75 cases, counter 21 cases).
   The five C1 fixture anomalies (B4→value=2 with i3 flagged, B5→3, B6→3, B7→3,
   P3→2/P4→1) and a C1-F6 counter SETUP (`fixture B5: tree copy failed`) were recorded.
2. Standalone probes (scratch-only fresh snapshots, never the working tree): P3→0,
   P4→0, baseline→0 on bytes identical to run 1's pinned checker — proving run 1's
   anomalies were not checker defects.
3. Root cause found in MY battery, not the grammar: `ctrl_c1_fixture`/`ctrl_c1_f7`
   restored only the fixture's own file, so later forged copies carried earlier
   fixtures' residue (B3's `not withdrawn` left in plans/round-60.md flags i3 on every
   subsequent copy; hand-simulation reproduces all seven measured vectors exactly).
   Fixed: every forged copy now resets all three carrier files (single-fixture
   isolation), documented in the battery header.
4. 21:42Z re-run, battery `f2965f12…` (pre-fix): reproduced the identical five
   mismatches deterministically AND captured C1-F6 flipping to match — the C1-counter
   seat fixed its tree-copy failure in between; the counter now refuses the stub-checker
   tree with rc 2 and no verdict line, and its clean-tree line reads
   `C1_BYPASS: accepted=0 population=5 guard=1 (real=1 selftest=1 stub=1 paraphrase=1
   chal=1)` — the C1 claim's own target state, measured.
5. 21:53Z run, fixed battery `93587e6d…`: match=13 mismatch=1. All C1 fixture controls
   green with surgical vectors (B3: i3=0 only … B7: i7=0 only; paraphrases 0/0/0).
   The one mismatch: C2-F4 — `C2_SEAL_TRIAL: value=0 … shims=0 vectors=0/5 …
   sh1=BHHEH` — a real-run FLAKE: T4 (generate-root OTP decode) ERRORed inside the SH1
   shim run, with counter bytes `20614697…` and trial bytes `a3bc8825…` (== BASE — the
   trial is untouched by the round) identical to the green runs. Same real leg was
   green at 18:36Z and 21:42Z and green again at 22:00Z ⇒ 3 green / 1 flaked over four
   runs, deterministic everywhere else.
6. 22:00:35Z final run, battery `93587e6d…`: **match=14 mismatch=0, rc 0** — the
   installed receipt.

Claim state measured on candidate bytes (all sha-pinned in the receipt head): hardened
checker `f2afd9b8…` (selftest 75 cases), hardened counter `20614697…` (21 cases), C1
counter `efe676eb…`, C2 wrapper `b26d4220…`, bypass/paraphrase TSVs `16fc5ba6…` /
`de5982b7…`, trial `a3bc8825…` (unchanged from BASE). C1: the counter's clean reading
`accepted=0 population=5 guard=1` and all five bypass fixtures individually rejected
with exactly their own item. C2: the wrapper's clean reading
`C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)`, both
mutation classes killed with named FINDINGs (`R61-C2-ST-decide-pass`,
`R61-C2-ST-shims-ok`), the guard now discriminating observables (G reads guard=0), the
real verdict preserved, and the constant-verdict counter refused.

## Findings for other seats

- **C2 real-leg stability (for R62ExecC2Counter / R62MutC2 / L1):** the counter's real
  trial leg flaked once in four runs (T4 ERROR under the SH1 shim, `sh1=BHHEH`,
  value=0 guard=0, rc 1) on identical instrument and trial bytes. Everything else in
  the counter is deterministic across runs. The L1's candidate reading could hit the
  same flake; a re-run clears it, but the T4-under-shim path is worth a look (timing/
  nonce sensitivity under load is the plausible shape — inference, not measured).
- **Control-fixture isolation class (for the lesson scribe):** a control harness that
  reuses a mutated work tree and restores only the fixture's own file measures residue,
  not the fixture — it produced five false grammar defects in my own first receipt
  before the restore discipline was fixed. Fix: reset every file a fixture class can
  touch before each application; the vectors of the false readings (exactly the union
  of the residues) are the fingerprint.
- The C1 counter's transient `SETUP … tree copy failed` (18:36Z) was fixed by its own
  seat in-flight; no action pending.
- No secret material anywhere in the receipt or this report: shapes only
  (`[REDACTED]`/`[HEXRUN]`/`[SEPRUN]`), counters' own hex-pin exception mirrored.

## Discipline

No git/jj mutation anywhere: the BASE tree comes from read-only `git archive | tar -x`;
the only other git use is the checker's own committed-revision derivations. Nothing
written inside any measured tree (candidate legs measure private snapshot copies; the
counter's read-only contract covers the one in-place leg). No /tmp evidence; scratch
dirs used: `battery.*` (self-cleaning), `study/`, `pvec2`, `dbg1`, `tiny.sh`, `pvec.*`,
`dbg.*` — all removed at seat close. No tools installed (pacman guard respected; none
needed). Registry row delivered to R62ScribeRecords (kind `gate`, entry command,
verdict map, `--selftest` spelling, PASS `CONTROLS_SELFTEST: PASS (cases=14)`).

## Risks / blockers

None blocking. The L1 re-runs `bash plans/round-62-controls.sh` before the candidate
reading; if instrument bytes move again, the receipt regenerates with fresh pins. The
C2-F4 flake (1/4) may recur under concurrent wave load and is a one-rerun clear.

SEAT-STATUS: complete
