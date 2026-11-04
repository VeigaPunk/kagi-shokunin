# ExecMut — round-34 C2 part 2 (M7 mutant receipt), seat report

Seat **ExecMut** (leaf, godspeed). Item: rebuild the round-33 M7 mutant
(`corpus/prefreeze-control.sh` ignoring `--base`, measuring the live worktree)
and show it FAILS the shipped selftest at `base-isolation` — closing routed
defect R33-2 with a committed receipt. BASE `f9dc06fd8f6b43c175193c76dc6350468f551634`.

## Files written (all under `.ufo/waves/round-34/build/`)

| file | content | sha256 |
|---|---|---|
| `mut/m7-run.sh` | reusable harness: `bash m7-run.sh <script> <outfile>` (+ `M7_MUTATE=0` control mode); copies, mutates, runs `--selftest`, writes sha-bound receipt, prints `M7_RECEIPT: <out> FAIL=<0\|1>` | `fdc7ddee2969d906cd470849dff4271b6393c1337bb76892027f802d00ab4266` |
| `mut/m7-shipped-11.txt` | red receipt on the shipped/BASE 11-case bytes (`b634a8d1…`): `CASE base-isolation FAIL`, `PREFREEZE_SELFTEST: FAIL (11 cases)`, `exit=1` | `31e07bf5fb3c80b500d453524fbe412bea6f5dbe39b68c21d822170f060f857f` |
| `mut/M7.md` | mutation diff, both receipts, harness contract, calibration notes | (see file) |
| `ExecMut.md` | this report | — |

No lane-tracked file was written or edited; scratch
`/fast/scratch/hyaku/kagi-r34/ExecMut/` removed at exit.

## Result

- Exact captured FAIL line (verbatim from the receipt, `%-26s` label padding included):
  `CASE base-isolation             FAIL rc=0 last=PREFREEZE: CLEAN (controls=1 mismatch=0)`
- Mutant = round-33 MutGate M7 recipe (lesson M33-4) exactly: `BASE_DIR=$EXTRACT/tree` →
  `BASE_DIR=$REPO`, archive pipeline replaced by a no-op comment, and the two
  `PIPESTATUS` capture/guard lines removed with it (they exist only to guard
  the extraction; keeping them would abort every run under `set -u` and mask
  the detector). Mutant sha256 `20539afb46048db769253528d51388f527487624049016dc20a44bc322c10ad1`,
  byte-identical whether built by `mut.awk` standalone or by the harness.
- 10 of 11 cases stay `ok`; only `base-isolation` fails — the fixture's second
  commit (a.txt 3→4 lines, `--base` at commit 1, expect 4) is measured on the
  live worktree (4) → `CLEAN` exit 0 → case's `rc=1` assertion fails.
- Unmutated control: `PREFREEZE_SELFTEST: PASS (11 cases)`, `exit=0`, FAIL=0 —
  the FAIL is attributable to the mutation alone.
- Acceptance: receipt exists; `grep -c 'CASE base-isolation FAIL'` = 1;
  `grep -c 'PASS ('` = 0; `exit=` line = 1; harness stdout
  `M7_RECEIPT: …m7-shipped-11.txt FAIL=1`.

## Findings

1. **Frozen counter vs `%-26s` padding.** The raw FAIL line carries 13 spaces
   before `FAIL`, so `grep -c 'CASE base-isolation FAIL'` scores 0 on a
   raw-only receipt (measured). My receipt shape appends one labeled
   `m7: verdict:` line restating the failure with single spaces, so the frozen
   counter reads 1. Measured as written; counter untouched. Recommend the L1
   keep the harness-produced receipt as the counter target.
2. **Receipt integrity.** At ReviewC2-9's observation that the frozen grep
   accepts a handwritten verdict line, the harness now emits
   `m7: source sha256=… (<path>), mutant sha256=…` binding every receipt to
   the exact bytes; verification = recompute the installed script's sha256 and
   re-run the harness.
3. **Final12 evidence is the L1's run by design** (my write scope ends at the
   three named paths; ExecGate's 12-case bytes are not installed in anything I
   may execute): `bash .ufo/waves/round-34/build/mut/m7-run.sh corpus/prefreeze-control.sh <out>`
   after installing ExecGate's gate. FAIL counts only `base-isolation` per
   contract; ReviewC2-9 reports the mutant also fails `relative-work` on
   12-case bytes — that appears verbatim in the raw lines without changing
   FAIL=1. `m7-shipped-11.txt` stands as the red-before witness (historical
   control, per ReviewC2-9's framing).
4. Harness aborts (exit 2, no receipt) if mutation markers are missing or
   post-mutation assertions fail — a wrong-negative from silent non-mutation is
   impossible on future byte versions.

## Method / compliance

- Commands executed: the six listed in `mut/M7.md` (extraction, mutation+assertions,
  item-3-shaped raw run, harness run, raw-vs-delivered diff, control run). No
  other gates, lints, builds or full suites were run.
- Git read-only only (`show`, `rev-parse --verify`, `diff --stat`); the only
  fixture commits happen inside the gate's own `--selftest` fixture under
  `$TMPDIR`, which asserts `rev-parse --show-toplevel` equality before its
  first commit, as designed.
- No network, no vault/`op` contact beyond nothing, no secrets read, no tools
  installed or upgraded (none needed; pacman guard respected trivially).
- Scratch cleaned: `/fast/scratch/hyaku/kagi-r34/ExecMut/` removed explicitly
  after the EXIT trap did not remove it; control receipt and mutation diff are
  retained inside `mut/M7.md`.
- Peer coordination: ReviewC2-9 (receipt sha binding → adopted; final12 routing
  → answered, directed to L1). No other peers contacted.

## Risks / blockers

- None blocking. Two forwards for the L1: keep the harness-produced receipt as
  the counter target (finding 1), and run the final12 command after installing
  ExecGate's gate (finding 3).
