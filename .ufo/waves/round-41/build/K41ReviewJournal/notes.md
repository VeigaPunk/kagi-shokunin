# K41ReviewJournal — notes (commands, exit codes, durations, teardown)

Seat: kagi round 41, BEFORE evidence and attacks on C1. Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin,
branch master, predeclaration commit 5142b52 (working tree untouched by this seat). P0 = 6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0.
Scratch: /fast/scratch/hyaku/kagi-r41/K41ReviewJournal (HYAKU_SCRATCH unset → default /fast/scratch/hyaku).

## 1. Fixture construction (executed)

Read `plans/round-41-c1.sh` (frozen) in full; reproduced its `python3 - "$ROOT" <<'PY'` fixture block
byte-for-byte, redirected into four sandbox clones instead of the counter's scratch dirs:

- `git clone --shared /home/vgpnk/Projects/shokunin/kagi-shokunin $S/F<i>` → rc 0, ×4
- `git -C $S/F<i> checkout --detach 6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0` → rc 0, ×4
- `git -C $S/F<i> rev-parse --show-toplevel` printed exactly the clone path, ×4 (asserted before any write)
- `git -C $S/F<i> rev-parse HEAD` = 6f1588c…, ×4
- committed bytes extracted: `git -C <lane> show 6f1588c:corpus/claim-ledger.tsv` (48369 B, 104 rows),
  `git -C <lane> show 6cc8850:corpus/claim-ledger.tsv` (47501 B), `git -C <lane> show 6f1588c:.ufo/waves/round-40/expectation-migrations.json` (3695 B) — all rc 0.

Forges (same code paths as the counter: `edit_row` col2/col1, `mig()`, `json.dump(indent=1)`):

| Clone | claim-ledger.tsv | expectation-migrations.json | stamped size |
|---|---|---|---|
| F1 | R13-01 expect := `^[0-9]+$` | R13-01 entry removed (5 entries remain) | 48373 B |
| F2 | unchanged (P0 bytes) | R21-02 old_expect := its new_expect | 48369 B |
| F3 | R13-01 expect := `^[0-9]+$` | R13-01 new_expect := `^[0-9]+$` | 48373 B |
| F4 | R24-06 command := `echo 'ROW_IDENTITY: scorecard-rounds count=54 sha256=52e7ba8d9b4de4a3aa7543b7f0370361dd17c2ae18b98c0c318618917dfe50c7'` | unchanged (committed bytes) | 48443 B |

Post-forge verification printed the edited cells and journal id lists (all as the table above);
fixture build wall time 1.7 s. Byte receipts of every fixture copied to
`build/K41ReviewJournal/fixtures/` (listed in §5).

## 2. The pre-change gate run (executed once per clone)

```
st=$(date +%s)
( cd "$S/F<i>" && timeout 900 bash corpus/claim-ledger.sh verify ) > "$S/out-F<i>.raw" 2>&1
rc=$?   # captured from the subshell, not masked
```

Four clones launched in parallel, `wait`. Total wall 5m45s. `claim-ledger.sh` is byte-identical
between 6f1588c and 5142b52 (`git diff --stat 6f1588c 5142b52 -- corpus/claim-ledger.sh` → empty).
Lane invocations of `verify`: **zero** (all four runs were inside scratch clones).

| Run | rc | Summary line (last gate line) | Duration | Line naming the forged id |
|---|---|---|---|---|
| F1 | 2 | `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)` | 345 s | **none** (`grep -n R13-01 before-F1.txt` → no match) |
| F2 | 2 | `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)` | 345 s | **none** (`grep -n R21-02 before-F2.txt` → no match) |
| F3 | 2 | `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)` | 346 s | **none** (`grep -n R13-01 before-F3.txt` → no match) |
| F4 | 2 | `CLAIM_LEDGER: POLICY (claims=86 policy=4 stamped=122)` | 346 s | `16:POLICY R24-06 reason=first-token:echo` |

Every before-F<i>.txt carries the full gate output followed by `RC=<n>` and `DURATION=<n>s`.

## 3. What the measurements establish (BEFORE evidence for C1)

1. **F1, F2, F3: the pre-change gate accepts them silently.** No FAIL/STALE/MISSING line names
   R13-01 (F1, F3) or R21-02 (F2). The forged rows PASS their own verdict match and the run's
   shape is identical to the P0 baseline (F2 = unmodified P0 ledger + forged journal) apart from
   the lines itemized in §4. The round-40 journal forgery in F2 is definitionally invisible: the
   old gate never reads journals.
2. **F4: the pre-change gate does NOT silently accept it — the plan's phrasing is measured false
   for this construction.** `POLICY R24-06 reason=first-token:echo`: the policy allowlist
   (`bash|grep|sha256sum|wc|test|python3`) refuses the `echo` rebind BEFORE execution
   (policy=4 vs 3; the forged command never ran, so "still matches what the command prints" was
   never exercised). Erratum candidate for the round report / K41CriticClaims: the existing-gate
   control reads "accepts F1–F3 silently; refuses F4 on first-token policy (a different mechanism,
   whole-run rc 2, no journal semantics)". The C1 discrimination still holds — the new gate must
   refuse F4 with `EXPECT_JOURNAL: REFUSE COMMAND_MISMATCH R24-06` and rc 1 — but "accepts F1–F4
   by construction" is not what the sandbox shows for F4.
3. **Whole-run verdict is rc 2 POLICY in all four runs** — three standing operator-owned rows at
   P0 (R29-01, R29-02 `first-token:python`; R38-03 `python-script`), identical in the F2 baseline,
   inherited state named in the round-40 journal's `outside_population_untouched`. The POLICY
   branch preempts the FAIL summary, so STALE/FAIL never reach the final line. Any landing-time
   reading of this control must adjudicate per-row lines, not the run rc.
4. **Environmental deltas, fully attributed (none forgery-caused):**
   - F1/F3/F4 open with `STALE corpus/claim-ledger.tsv sha=434b8233ee23->fc46b61a7b8d|bc61279ed189`
     — the stamps layer notices the edited ledger FILE (bytes drift). It is informational here
     (POLICY preempts it) and names the file, never the row id.
   - R22-03/R24-15 FAIL-reason flip (F1/F3/F4 `exit-mismatch exit=1|2` vs F2 `verdict-not-final
     exit=0`): in the pristine F2 clone both commands exit 0 and print
     `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=59 invalid=0)` /
     `ROW_IDENTITY: revision-added count=59 sha256=50b86d2b…` (executed directly in F2, rc 0,
     <1 s each) — the ledger expects `added=49`/`count=49`, measured at the round-40 landing tree
     which held 10 more (uncommitted) entries than a clean clone. In the edited clones the stamps
     STALE drives revision-audit to exit 1 and row-identity to exit 2. Both flips are
     clone-vs-landing-tree and edit-detection effects on STAND-BY rows, not on the forged rows.
5. **MISSING-ID (~70 idref lines: LOG.md/SCORECARD.md/lessons citing R32-*/R33-*/R34-*/R35-*/R36-*),
     HOST-SKIP rows (17, incl. R31-01), and the four inherited FAIL rows (R11-08, R22-03, R24-15,
     R25-02, R36-03)** are byte-identical across F1–F4 (verified by pairwise diff) — standing P0
     state, part of the baseline this control measures against.
6. Pairwise diffs of the four outputs: `diff before-F2 before-F1` and `diff before-F2 before-F3`
   show exactly {STALE line, R22-03 line, R24-15 line, DURATION}; `diff before-F2 before-F4` adds
   {POLICY R24-06 …, policy=4}. Nothing else differs.

## 4. Constraint compliance

- `bash corpus/claim-ledger.sh verify`: 4 invocations total, one per clone, each under
  `timeout 900`, none in the lane. No second run of verify anywhere.
- Extra direct row commands executed once each in F2 for §3.4 grounding:
  `timeout 130 python3 corpus/revision-audit.py --history c2cab35…` rc 0;
  `timeout 130 bash corpus/row-identity.sh revision-added` rc 0. Not `verify`.
- No git mutating command anywhere (clone/checkout --detach/rev-parse/show only, all `-C`-named);
  no writes outside $S and the deliverable dir; no pacman/uv installs (tooling: **none**, stock
  bash/git/python3); no `agent://all`, no delegation, no ask tool.
- Deliverables written only under
  `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-41/build/K41ReviewJournal/`
  (before-F1..F4.txt, attacks.md, ambiguities.md, notes.md, fixtures/) plus the seat report
  `build/K41ReviewJournal.md`. Report trailer paths relative to the lane root.

## 5. Receipt inventory (build/K41ReviewJournal/)

- before-F1.txt … before-F4.txt — full gate stdout+stderr, RC, DURATION (§2 table).
- fixtures/base-6cc8850-claim-ledger.tsv, fixtures/p0-claim-ledger.tsv,
  fixtures/p0-expectation-migrations.json — committed-byte inputs.
- fixtures/F<i>-claim-ledger.tsv, fixtures/F<i>-expectation-migrations.json — the four forged
  pairs, byte-exact (48373/48369/48373/48443 B ledgers; 3297/3564/3568/3695 B journals), enabling
  the L1 to re-run this control without rebuilding fixtures.
- attacks.md (11 attacks, 7 required classes + 4 extra), ambiguities.md (15 sentence-level items).

## 6. Sandbox teardown

`trap 'rm -rf -- /fast/scratch/hyaku/kagi-r41/K41ReviewJournal' EXIT` set in the seat shell, then
explicit `rm -rf -- /fast/scratch/hyaku/kagi-r41/K41ReviewJournal` executed before yield;
confirmation appended below after execution.

TEARDOWN: OK (/fast/scratch/hyaku/kagi-r41/K41ReviewJournal absent) — `rm -rf` executed after all
receipts were copied into fixtures/; exit trap also armed in the seat shell. Confirmed by
`[ -e … ]` → false.
