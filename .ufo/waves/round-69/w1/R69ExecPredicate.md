# R69ExecPredicate — D8 predicate floor repair

SEAT-STATUS: complete

## Files changed

- `plans/round-68-c1.sh` — sole writer. Three edits only:
  1. Header amendment comment (round 69, post-closure dated repair)
     naming defect D8 from
     `corpus/lessons/round-68-verifier-spotcheck.md` §7 item 8, the
     old body `guard == 1 and caught == 6 and defects == 0`, the new
     body with `verified >= 37 and col15 >= 32`, and the note that the
     round-68 C1 reading (38/33) still passes.
  2. `predicate_ok(verified, col15, caught, guard, defects)` now
     returns `guard == 1 and caught == 6 and defects == 0 and
     verified >= 37 and col15 >= 32`.
  3. Selftest cases added beside the existing `predicate-full` /
     `predicate-caught5` / `predicate-guard0` / `predicate-defect`:
     `predicate-subfloor = not predicate_ok(36, 31, 6, 1, 0)`,
     `predicate-floor-edge = predicate_ok(37, 32, 6, 1, 0)`,
     `predicate-floor-col15 = not predicate_ok(38, 31, 6, 1, 0)`.
- Receipts under `.ufo/waves/round-69/w1/R69ExecPredicate/`:
  `selftest-candidate.txt`, `selftest-base.txt`, `diff.txt`,
  `notes.md`.

## Behavior

`predicate_ok` is the frozen kill-rule gate for
`bash plans/round-68-c1.sh`: previously the frozen floors from
`plans/round-68.md` §C1 (missed if `verified < 37` or `col15 < 32`;
A1.2 records 37/32 as the recut-only reading and 38/33 as the
candidate) were never compared. Now a sub-floor tree (e.g. 36/31)
or a col15-short tree (e.g. 38/31) returns exit 1 from the counter
instead of green. The round-68 landed reading 38/33 still passes;
no other behavior or verdict format changed (every existing case
byte-identical; `diff.txt` shows only the three edits).

## Evidence

- `bash plans/round-68-c1.sh --selftest` (candidate) last line:
  `C1_VERIFIED_SELFTEST: PASS (62 cases)` (rc 0) —
  `.ufo/waves/round-69/w1/R69ExecPredicate/selftest-candidate.txt`.
- BASE control: `git archive 264917aa | tar -x -C <scratch>` then
  that copy's `--selftest` last line:
  `C1_VERIFIED_SELFTEST: PASS (59 cases)` (rc 0) —
  `.ufo/waves/round-69/w1/R69ExecPredicate/selftest-base.txt`.
- Case-count relation: N_cand (62) = N_base (59) + 3. The three new
  predicate cases account for the +3; the seat spec's "N_cand =
  N_base + 1" expectation is corrected here — three cases were
  specified, not one. The BASE run passes its pre-fix predicate,
  proving the BASE blindness witness is unchanged.
- Predicate truth table spot-check (exec of the extracted function):
  38/33→True, 37/32→True, 36/31→False, 38/31→False.
- `diff.txt` also records the exact three-edit diff.

## Risks / blockers

- None known. The live-counter path (`predicate_ok` call site at the
  verdict printer) is unchanged besides the new comparisons; the
  full counter run is the L1's post-integration check.
- Tooling: none installed or upgraded.

Checks for the L1: re-run both selftests and the case-count delta;
run `bash plans/round-69-c2.sh --tree <candidate>` subfloor leg
(extracts `predicate_ok` and replays 36/31, 37/32, 38/33).
