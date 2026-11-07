# R51ReviewerC2 — review of the round-51 C2 counter and its controls

Seat: R51ReviewerC2, 2026-11-07. Scope: `plans/round-51-c2.sh` (frozen at predeclaration
`4ad8ab7cd5bf8949d125ac96ccef45e69dabc567`), the C2 half of `plans/round-51-controls.sh`,
`corpus/claims-declared.sh`, `plans/round-48-c2.sh`, receipt
`.ufo/waves/round-51/controls/controls-prefreeze.txt`. All runs on BASE
`214d8bf530a0c87c00686493f21af15396284793` unless stated; scratch under
`/fast/scratch/hyaku/kagi-r51/R51ReviewerC2/`. Receipts copied next to this file:
`R51ReviewerC2-run-base.txt`, `R51ReviewerC2-run-predecl.txt`, `R51ReviewerC2-fixtures.log`,
`R51ReviewerC2-controls-c2.log`.

## 1. Counter re-runs (both lines)

- `bash plans/round-51-c2.sh 214d8bf530a0c87c00686493f21af15396284793` (rc 0):
  `C2_SELF_ASSESSMENT: value=3 M=2 V=1 rev=214d8bf530a0c87c00686493f21af15396284793`
  detail: `MISMATCH 50 C1 no-manifest-row`, `MISMATCH 50 C2 no-manifest-row`,
  `K07 DIFF stated=[CLAIMS_DECLARED: CLEAN (claims=23)] executed=[CLAIMS_DECLARED: MISMATCH (claims=25 mismatch=2)]`,
  `claims-declared: CLAIMS_DECLARED: MISMATCH (claims=25 mismatch=2)`.
- `bash plans/round-51-c2.sh 4ad8ab7cd5bf8949d125ac96ccef45e69dabc567` (rc 0):
  `C2_SELF_ASSESSMENT: value=3 M=2 V=1 rev=4ad8ab7cd5bf8949d125ac96ccef45e69dabc567` — same detail
  lines. The predeclaration adds only plan/counters/controls/fixtures/wave artifacts (25 manifest
  rows unchanged, SCORECARD unchanged), so the value is unchanged at 3, as the plan's problem
  statement says.

Both first lines match the pre-freeze receipt's K2-0 line byte-for-byte
(`value=3 M=2 V=1 rev=214d8bf…`), and the plan's claim "BASE 214d8bf reads 3: M 2 = round-50
C1/C2 no-manifest-row, V 1 = K07" is exactly what printed.

Pin audit (sha256): working-copy `corpus/claims-declared.sh` = PIN_GATE
`6e779fe8…bb863`, working-copy `plans/round-48-c2.sh` = PIN_R48 `15f7a0c3…4fce`; both equal their
BASE blobs. Working-copy `plans/round-51-c2.sh` = `52790a35…6bb62` = the predeclaration blob;
same for `plans/round-51-controls.sh` (`a14d44e9…e433`). Instruments are byte-identical between
working copy and predeclaration, so the kill rule "instruments differ between predeclaration and
candidate" is currently satisfied and the counter I ran is the frozen one.

## 2. Guard fail-closed fixtures (g1–g4 + working-copy leg)

Method: scratch `git clone --shared` of the lane at BASE, toplevel asserted, counter copied in
untracked, each fixture committed with a throwaway identity, counter run at the fixture commit.
Results (full log in `R51ReviewerC2-fixtures.log`):

| leg | fixture | observed |
|---|---|---|
| g1 (gate sha) | BASE + `# revc2 fixture g1a` appended to `corpus/claims-declared.sh`, committed in the scratch clone | `C2_SELF_ASSESSMENT: SETUP reason=g1-gate-changed` PASS |
| g1 (r48 sha) | same with `plans/round-48-c2.sh` appended (leg absent from the pre-freeze receipt) | `SETUP reason=g1-r48-changed` PASS |
| g1 (working copy) | second scratch clone; its `plans/round-48-c2.sh` working file appended one comment line, counter run from that clone (leg absent from the receipt) | `SETUP reason=g1-r48-working-copy` PASS — V is only ever produced by PIN_R48 bytes |
| g2 | one blank line appended to `plans/round-50.md` (present at BASE) | `SETUP reason=g2-changed:plans/round-50.md` PASS |
| g3 | BASE manifest row `47 C1 calibration` deleted | `SETUP reason=g3-row-missing:47 C1 calibration` PASS |
| g4 (gate verdict) | `SCORECARD.md` deleted (not covered by g1–g3; gate prints `CLAIMS_DECLARED: SETUP missing-input`, rc 2) | `SETUP reason=g4-claims-declared(rc=2)` PASS — leg absent from the receipt |
| g4 (r48 verdict) | `corpus/feed-token-agree.py` deleted (K01 exec emits nothing; not covered by g1–g3) | `SETUP reason=g4-r48(rc=2)` PASS — leg absent from the receipt |
| g4 (M NaN) | not fixtureable: `M=$(grep -c '^MISMATCH ' cd.out)` always emits a decimal count, even on empty input | defensive-only leg, unreachable in practice |

Every failure path prints `SETUP reason=…` and exits 2; no fixture produced a value on a mutated
tree. `g4-m` is the only leg not exercised, and it guards an impossible state (grep -c cannot print
a non-number).

## 3. M counts the right lines

Three independent evidences:

1. **BASE re-run detail**: the counter echoes the exact lines it counted (`  50 C1
   no-manifest-row`, `  50 C2 no-manifest-row` — the `grep '^MISMATCH '` set printed under the
   value line), and the gate's own verdict carries `mismatch=2`, equal to M=2. M, the gate's
   internal `bad`, and the verdict's `mismatch=` agree line for line.
2. **Static**: every MISMATCH the gate can print is a column-0 `MISMATCH <round> <claim> <reason>`
   line; each failure branch prints exactly one line and increments `bad` once (dup-row prints one
   and `continue`s); the verdict line starts `CLAIMS_DECLARED`, so it is never counted; stderr is a
   separate stream never counted. Additionally g4 requires the verdict to be the *last* nonempty
   stdout line, so trailing MISMATCH lines after a verdict cannot hide, and a crashed run with
   dangling MISMATCH lines SETUPs instead of scoring.
3. **K2-F2 re-run (live)**: swapping round-50's two axes in the manifest reads `value=5 M=4 V=1` —
   per claim one `plan-heading-not-<axis>` plus one `axis-cell-not-<axis>`, i.e. exactly the four
   real mismatch lines, no more, no fewer.

No undercount or overcount route found.

## 4. V zeroing / K07

Two fixtures decide it (revs in `R51ReviewerC2-fixtures.log`):

- **vzero-truth**: append to §Capabilities a readings line stating the *executed* BASE reading
  `CLAIMS_DECLARED: MISMATCH (claims=25 mismatch=2)` (extracted live from a BASE archive, not
  copied from the plan) and change nothing else → `value=2 M=2 V=0`. V reaches 0 exactly when the
  K07 statement becomes true; M keeps the value honest at 2.
- **vzero-lie**: same insertion but stating a lie, `CLEAN (claims=25)` → `value=3 M=2 V=1` (K07
  still DIFF).

Structural closure of the remaining routes to V=0 without a true K07 statement: V is the count of
K01–K10 whose stated ≠ executed; V=0 requires every key MATCH, K07's match mode is byte-exact
`stated == executed`, and the executed side is produced by the PIN_R48 counter (working-copy leg
fixture above) running the PIN_GATE gate in a fresh shared clone — so the only way to move the
executed side is to change the tree, and the tree routes are guarded: shrinking the manifest to
make `claims=23` true trips g3 (BASE rows must survive), replacing/breaking the gate trips g1/g4,
and deleting the readings pair makes K07 MISSING (`deleting a pair is not a fix` per the counter
header). A stale-but-superseded line is not enough: `stated_of` takes the last occurrence, so the
landing must append a line whose text is byte-true *at the revision it names*. No route found.

## 5. The claims count the landing must state

BASE manifest has 25 data rows (verified: `git show BASE:corpus/claims-declared.tsv` filtered the
same way the counter's g3 filter does). The declared change appends 4 rows (50 C1, 50 C2, 51 C1,
51 C2) → 29 rows, and the pre-freeze positive fixture K2-P (receipt) shows the gate printing
`CLAIMS_DECLARED: CLEAN (claims=29)` at value 0. **The landing's current-readings line must state
`CLAIMS_DECLARED: CLEAN (claims=29)`** (the exact executed verdict, byte-exact per K07's exact
match mode), naming the revision it measured. Note the counter itself does not pin 29 — any larger
conforming claim set with a matching readings line also reads 0; 29 is pinned by the declared
change, not by the counter.

## 6. Predicate sentence: plan vs counter header vs receipt label

Normalized (backticks stripped, whitespace collapsed) the two sentences are word-for-word equal
except two counter-side insertions, neither contradicted by the plan:

1. `…round-48-c2.sh <rev>` **(this lane's working copy, sha256-pinned)** `prints…` — elaboration
   of where the counter executes from; the code does exactly this.
2. target parenthetical: counter `(BASE 214d8bf5 reads 3: M 2 = round-50 C1/C2 no-manifest-row,
   V 1 = K07)` vs plan `(BASE 3)` — the counter is more specific; both state target 0.

All 9 receipt K2 lines carry exactly one `C2_SELF_ASSESSMENT` label, matching the counter's output
name and the plan's predicate name. Verdict: agreement holds at operative-word level; the two
insertions are information-preserving elaborations, not divergences. No defect.

## 7. Defect list

**None found.** Tried: both counter re-runs (§1); nine fail-closed fixtures covering every g1–g4
leg plus the working-copy pin leg, three of them absent from the pre-freeze receipt (§2); live
M-precision via the BASE detail and the K2-F2 class (§3); V-zeroing by truth, by lie, and the
structural closure of the remaining routes (§4); manifest row counts at BASE and predeclaration
(25/25, §5); sha audit of both pins, both counters and the controls against the predeclaration
blobs, all equal (§1); normalized word-level diff of the predicate sentence in plan vs counter
header plus the receipt labels (§6); full re-run of the C2 control battery reproducing the receipt
line-for-line (`CONTROLS: pass=9 fail=0`, rc 0, fresh fixture commit hashes as expected).

Observations, none rising to a defect:

- O1 `plans/round-51.md` is absent at BASE, so g2 cannot guard it; its freeze is enforced by the
  landing kill rule "instruments differ between predeclaration and candidate", not by the counter.
  By construction, not a hole in the measured quantity.
- O2 The counter does not pin the exact claims count: any manifest superset of BASE's 25 rows that
  is fully conforming with a byte-true readings line also reads 0. 29 comes from the declared
  change (§5), which is what the landing is judged against.
- O3 The counter header's predicate carries two insertions relative to the plan sentence (§6);
  both are elaborations, the plan contradicts neither.
- O4 `g4-m` guards a state `grep -c` cannot produce; unexercised by design.
- O5 The round-48 counter's exec env isolates TMPDIR/HYAKU_SCRATCH but not HOME (inherited
  round-48 design); grep over the six K-exec instruments finds no `$HOME`, `.ssh`, `.config`,
  sops/age/op references, so the refusal boundary is not implicated.

## 8. Residual risk / verification gaps

- `g4-m` is the only counter leg never exercised (§2, O4) — unreachable, not a risk to scoring.
- The C1 half of the pre-freeze receipt was not re-run by this seat (C1 has its own reviewer); the
  K1 lines in the receipt were not independently verified here.
- A landing can zero the counter only by landing all four pieces (4 manifest rows, the Round 51
  SCORECARD section with correctly tagged rows, the frozen plan headings, and a byte-true
  readings line naming the revision); each omission is detected (K2-F6/F7, vzero fixtures), but
  the counter reads 0 only at the exact revision measured — a later commit that changes the
  manifest without updating the readings line re-opens both M and V, which is the counter's
  designed property (named ceiling), not a gap.
- All runs executed the pinned instruments with the host environment as in the pre-freeze run;
  scratch dirs of the counters/controls self-remove via their own traps, and this seat's scratch
  (`/fast/scratch/hyaku/kagi-r51/R51ReviewerC2/`) was removed after copying receipts.
