# Receipts — R61ExecCounterC1 (kagi round 61, claim C1 counter)

Seat: R61ExecCounterC1. Instruments landed this seat:

- `plans/round-61-c1.sh` — thin driver, sha256 `e6c853236181d8a5bdec99e711da2376546a8bbfb2856be28a2e253710fa487f`
- `plans/round-61-c1-check.py` — seven-item checker with `--selftest`, sha256
  `d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812`

(sha256 taken 2026-11-07 ~17:2x -03; if a later mutant run moves the checker, the
re-pinged hash in the seat message supersedes these.)

All receipted commands ran from the lane root with `--repo <lane>`. No git/jj
mutation anywhere in the lane; fixture git commits happen only inside the seat
scratch (`/fast/scratch/hyaku/kagi-r61/R61ExecCounterC1/`), inside a fixture repo
whose `git rev-parse --show-toplevel` is asserted to be that fixture dir before
each commit.

## 1. BASE reading (acceptance leg 1)

`base-c1-driver.txt` — `bash plans/round-61-c1.sh c940f51689d702f1786989d56ad4663833c1452e`:

```
C1_ROUTED: value=FAIL population=7 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0 guard=0
c1-driver: measured=revision c940f51689d702f1786989d56ad4663833c1452e (git archive)
c1-driver: checker rc=1
c1-driver: verdict value=FAIL guard=0
```

rc 1. Every item FAILs for the frozen reason (the correction lines the round-61
fixes must append do not exist at BASE), so the guard challenge is not injectable
and the value reads FAIL — the acceptance's `value=FAIL` form. The K2 diagnostic
form is receipted separately:

`base-census-nochallenge.txt` — `python3 -I -B plans/round-61-c1-check.py --root
<base-tree> --repo <lane> --no-challenge`:

```
C1_ROUTED: value=7 population=7 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0 guard=0
```

rc 1. A tree byte-identical to BASE reads `value=7 population=7` (K2 holds: no
item is vacuous). `--tree` mode additionally exercised on the same tree: same
reading, rc 1, 10484 files copied.

## 2. Selftest receipt (acceptance leg 2)

`selftest.txt` — `python3 -I -B plans/round-61-c1-check.py --selftest`:

```
C1_CHECK_SELFTEST: PASS (52 cases)
```

rc 0, N=52 >= 20. The 52 cases cover: the derivations (results 16/3/4, mutant
output 3824 B, fixture-numstat 1 1, four committer stamps, `%ci` normalization),
the guard mutation (only the deletions digit moves), registry-row parsing
(including the escaped-`\|` cell split), the all-resolved aggregate, both
evaluate legs, the no-`--repo` shape-only fallback (HOLD) and its guard-fails-
closed consequence (FAIL), the empty tree (7 unresolved, guard fails closed),
each item resolving on its own `ONLY_FILES` tree (expected resolved sets asserted
in full, including the shared-lesson overlaps), per-item forgery/fail-closed
fixtures (I1 wrong bytes / no mutants.md / later restatement / decoy anchor /
before-row placement; I2 cases<6 / exit-1 PASS / no-needle / undetected mutation /
registry none-own / absent script unresolved-not-SETUP; I3 A7-before-A6 /
withdraws-nothing / lesson line without second instance; I4 missing D3 / wrong
count; I5 stated-deletions-vs-derived / missing mechanism / shape-only without
repo; I6 foreign timestamp / only two stamps; I7 wrong pct / wrong fraction), the
+1 challenge firing with unresolved items, the QM74 refusal, `parse_value`
tokens, the symlinked-LOG SETUP refusal, and the missing-root SETUP leg.

## 3. Challenge receipts (acceptance leg 3)

Fixture repo: a scratch git repo whose tags are LITERALLY named `a677c78e`,
`14a6c07d`, `818d2a82`, so the checker's frozen-revision derivations run
end-to-end: `git diff --numstat 14a6c07d 818d2a82 -- LOG.md` = 1 1 (the wave line
`dead seats 1` rewritten to `dead seats 0` in place) and
`git log --format=%ci a677c78e..818d2a82` carries four committer stamps
(15:06:58, 15:14:19, 15:18:26, 15:47:01 -0300).

`challenge-resolved-good-tree.txt` — fully resolved fixture tree (all seven items
HOLD, value=0):

```
c1-guard: copy delta deletions 1->2 on the evaluated I5 line: value=1 expect=1; stub value=0 fails=True
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=1
```

rc 0. The copy's ONLY delta is the I5 `deletions=1` -> `deletions=2` digit; the
checker prints exactly value+1; the always-`value=0` printer stub fails the
challenge (0 != 1).

`challenge-only-i5-unresolved.txt` — i5 resolved, the other six unresolved
(value=6):

```
c1-guard: copy delta deletions 1->2 on the evaluated I5 line: value=7 expect=7; stub value=0 fails=True
C1_ROUTED: value=6 population=7 i1=0 i2=0 i3=0 i4=0 i5=1 i6=0 i7=0 guard=1
```

rc 1 (value != 0 with guard=1). The +1 fires with unresolved items present.

## 4. Leg-C needle calibration receipt

`legc-needle-vs-working-counter.txt` — the declared needle
`verdict "$1" "T$i" | cut -c1)"` occurs exactly once in the working-tree
`plans/round-60-c2.sh` (the D2 fix's bytes, sha256 at capture
`135fc46f1a39036d0129a317d82caa79ff3ccdab6ee2562d3d6892f70b87fe95`; volatile
working-tree bytes, calibration only — the landed reading measures a committed
revision). The needle-mutated copy (`| cut -c1 | tr HB BH)`, the same inversion
the counter's own MUTVEC red witness declares) exits rc=1 printing 8
`FINDING C2-ST-*` lines and `C2_SELFTEST: FAIL (cases=36 failed=8)`.

## 5. Reading notes (where the plan wording allowed more than one structural read)

Recorded in the checker docstring; the load-bearing ones:

- I1's "after the line containing `R37`" anchors on the routed row
  `^\|\s*R37\s*\|` (last occurrence), not the last line *containing* R37 — the
  correction line itself contains R37 and the literal reading is unsatisfiable.
- I5/I6 derive from the lane repository via `--repo` with the plan's named
  revisions; without `--repo` they fall back to shape-only readings (noted in the
  item detail), and the guard cannot fire in that mode (fails closed to
  `value=FAIL guard=0`) — the driver always passes `--repo`.
- I6 excludes the launch stamp (15:03:17, a watchdog time) from the "at least
  three" census; `%ci` stamps are normalized (`2026-11-07 15:06:58 -0300` ->
  `2026-11-07T15:06:58-03:00`) before membership.
- I7's `B = A + (1 if sentinel present else 0)` derives "that number plus the
  sentinel" from the results file.
- The checker executes only the two `plans/round-60-c2.sh --selftest` invocations
  I2 names (leg A on the measured tree, leg C on the needle-mutated scratch
  copy), each with a 90 s timeout and TMPDIR/HYAKU_SCRATCH redirected into
  checker-owned scratch; the measured tree is never written; scratch is deleted.

## 6. Defects found and fixed during this seat (all pre-landing, caught by my own
debug + L1/mutation-tester measurement)

- `C2_PASS_RE` read `(\d+) cases` instead of `cases=(\d+)` (the frozen order).
- `_scan_registry_table` split cells on every `|`, mis-indexing rows whose cells
  carry an escaped `\|` (real SKILL.md row 855 does) — now splits on unescaped
  pipes only.
- The selftest's fixture repo dir was not created before `git init` (L1-measured
  rc-1 selftest).
- Two selftest case expectations were wrong (only-i3 resolved set; i2-absent
  premise) — fixed against measured behavior, not loosened.
