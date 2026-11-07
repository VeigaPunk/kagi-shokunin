# R58CriticClaims — falsification report (kagi round 58, attempt 1)

Seat: R58CriticClaims (critic). Read-only: no lane edit, no commit, no mutating git/jj, no
subagent. BASE `1b13f5dad921f8901f56d30c428f89614dd74d8a`; frozen predeclaration commit
`0085a5f76c9dc7e977f6606324e873d25b4fc44d`. Reviewed files: `plans/round-58.md` (frozen text at
0085a5f and the amended on-disk copy), `corpus/lessons/round-57-verifier-spotcheck.md`, the
BASE tree, `plans/round-58-c2.sh` (on disk), and the seat-local round-58 artifacts. The C1
checker/counter/controls do not exist on disk yet (`plans/` holds only `round-58.md` and
`round-58-c2.sh`), so the C1 verdict is on the frozen text; the C2 verdict includes the on-disk
counter. Receipts: `.ufo/waves/round-58/build/R58CriticClaims/receipts/`.

## 0. Bottom line

- **C1 (calibration, 8 -> 0): falls as frozen, fixable.** The BASE census is correct (8/8
  unresolved, re-read by me), so the claim's target is not wrong. But the frozen predicate
  reaches value=0 through one-line receipt/hash and token-string edits without the routed
  substance (I2, I8), its I4 count is not stable at the final tip once the round's own S118/S119
  registry rows land (the r57 D5 class recurs), and the on-disk A1/A2 amend the frozen I2/I3
  conditions (the predeclaration commit says "(none)"). The claim can survive with the
  corrections in §5.
- **C2 (operability, 0 -> 5): survives as a capability acquisition.** No ACL-policy-semantics
  trial exists at BASE; the lane's four OpenBao trials only use grant policies for token/PKI
  creation, and the token entry explicitly bounds itself to the default and two trial policies.
  The counter is necessary, not sufficient: the frozen guard forces a client-side
  `bao token capabilities` dependency for T5, and the plan's own K2 ceiling is a shape-keyed +
  introspecting trial. The claim's truth rests on the receipts + the non-author probe, as the
  plan declares; T5 must print its effect vector separately or it is a CLI re-score.
- **Separability: C2 can be verified without C1; C1 cannot be re-checked at the final tip
  without C2's registry landing.** `corpus/SOURCES.md` is read by C1's I4 and written by C2's
  S118/S119 rows; `SCORECARD.md` is written by both (different sections, same file). The
  coupling is one-directional (C2 -> C1/I4). Details in §4.

## 1. BASE census — verified 8 unresolved (the claim's BASE 8 is correct)

I read the eight conditions and the BASE tree (`git archive 1b13f5d`), and ran an independent
scratch checker (`receipts/base-census.txt`, `receipts/commands.txt`). It prints
`items={I1..I8: 1}, value=8`. No item holds at BASE, so the claim's target/population is not
wrong on that ground.

| id | routed | BASE reading (why unresolved) |
|---|---|---|
| I1 | D1 | `LOG.md:1935` names epoch B `03cbf656` and the epoch-B receipt, not epoch C; `SCORECARD.md` 1861-1896 names epoch B, not epoch C. |
| I2 | D3 | `controls-prefreeze-epochC.txt` pins `plans/round-57.md` at `b130bb83…`; BASE `plans/round-57.md` is `76e836ee…`. Last line `CONTROLS: match=13 mismatch=0` already holds. |
| I3 | D4 | `corpus/lessons/round-57.md` `## Gate` has S115/S116 rows and two rejects, no S117; `source:` names S115/S116 only. S117 `used-by` already names the lesson. S117.body present. |
| I4 | D5 | measured `corpus/SOURCES.md` data rows = 117. SCORECARD post-move coverage row says `114 -> 116`; lesson §Sources says `114 -> 116` and `end … 116 rows`. Current-tense 116 != 117. |
| I5 | D6 | `SKILL.md` has no `current-claims` row (grep 0 over 832 lines; gate-registry tables 695/747/783/817). |
| I6 | D7 + D8 | `corpus/current-claims.py` argparse has no `--round` (`--round 57` -> rc 2); literal `round-56` in the docstring/surface list (lines 10,15,20,113,129,150). Already true: `--selftest` PASS (13 cases) rc 0; the EPOCHS docstring names `plans/round-56.md`, the code's authority. **D8 is not read by this item:** D8 is `plans/round-57-c1-check.py` (docstring lines 22-23 say "number of controls-prefreeze-epoch*.txt files"; code line 133 counts distinct `epoch-[A-F]` tokens in `plans/round-56.md`). No item reads that file. |
| I7 | D12 | lesson S115 Gate row says "(§Enabling and disabling audit devices)"; S115.body line 47 is `Enabling/Disabling audit devices`. |
| I8 | D11 (stale basis) | lane `bash corpus/scope-gate.sh` -> `stale_basis=1`, `SCOPE STALE-BASIS $HOME/.config/opencode basis=SCORECARD.md:54 lines=54-54 token=opencode`. |

Partial clauses already true at BASE (the item is still unresolved, but a narrowed checker
would read 0 on it): I2's `match=13`; I3's S117 `used-by`; I6's `--selftest` + EPOCHS; I8 only
the `stale_basis` field. The plan's pre-freeze control "C1 value=8 on the BASE tree" is the only
thing that catches a checker that reads a satisfied clause instead of the named conjunction; it
must be run on 1b13f5d, not the live worktree (see §2/I2 and §5).

## 2. C1 — the do-nothing paths (assignment items a-d)

**(a) Wording-only edits.** I1, I3, I5, I7 are record additions; that is the intended repair and
the conditions read the added text. The do-nothing cases are where the condition is a shallow
proxy for a substantive repair:
- I2: edit the one `INSTRUMENT … plans/round-57.md` line in the old receipt to `76e836ee…`; the
  item's condition then holds. The receipt's other four pins already match BASE.
- I8: append the literal token `opencode` to the unrelated `SCORECARD.md:54` (a round-10
  pre-move depth row that says nothing about the opencode surface); with
  `--lane-root /home/vgpnk/Projects/shokunin`, the gate reads `stale_basis=0`. Measured. The
  legitimate repair is the adjacency.tsv basis repoint (line 81) to `SCORECARD.md:65`, a row that
  actually names `~/.config/opencode`; it also reads 0. The gate cannot tell them apart.
- I4: edit the registry instead of the statements — delete one source row (e.g. one of the 19
  standing W04 duplicate-URL rows) so the measured count is 116 and the stale `114 -> 116`
  statements become true. The registry is the authority and the target; no C1 item pins the row
  set. (Adding rows is the opposite direction and cannot help I4.)

**(b) A checker that trusts a file it should not.** I2 trusts the receipt (the run is not
observable); I4 trusts `corpus/SOURCES.md` as the authority while the statements are the target;
I8 trusts the token occurrence on the cited line, not that the line is about the surface. The
plan's named ceiling says "the checker trusts the files it reads (a forged authority that
satisfies the condition passes)" — this is declared for I2/I4/I8, so it is a tradeoff, not a
hidden defect; the counter alone cannot establish the substance.

**(c) Items whose BASE condition already holds.** None: all eight fail at BASE. The population
is not vacuous, and the claim's "BASE 8" is correct. Four items have a satisfied clause, as
above; that is a checker-precision risk, not a BASE-census error.

**(d) I2 without re-running the battery. Yes — and the frozen 13/15 trap.**
- The old receipt already ends `CONTROLS: match=13 mismatch=0`; only the plan hash is stale. A
  one-line hash edit satisfies the frozen I2 with no run. The no-REF re-run of the same frozen
  `plans/round-57-controls.sh` produces the same 13 control lines with the correct pins, so the
  checker cannot distinguish a hand-edit from a re-run.
- The untracked `.ufo/waves/round-57/controls/controls-prefreeze-epochC-final.txt` is a real
  re-run: five pins all match BASE, but its last line is `CONTROLS: match=15 mismatch=0` because
  the frozen controls script counts the two REF legs when a REF tree is given (its own header:
  REF-dependent controls print PENDING and are not counted; the pre-freeze receipt is the no-REF
  run). **The correct "regenerate over the final bytes" repair with a REF tree fails frozen I2.**
- The on-disk A1 amendment loosens I2 to `match=N, N>=13` + five pins. It resolves the 15-match
  receipt, but it is an uncommitted change to a frozen item (see §5/process) and it does not
  close the hand-edit path: the five pins bind instrument identity, not that the control lines
  were produced. A1 + the untracked -final receipt also resolves I2 on the live worktree; if the
  C1 checker reads the worktree, the BASE no-work control reads 7, not 8. The BASE control must
  be revision-bound to 1b13f5d.

**I4 is not stable at the final tip.** BASE count 117; the round's C2 adds S118/S119 rows (the
entry cites S118 x7 / S119 x5; the scout seat opens them; both rows are absent from SOURCES.md
today). Count -> 119. I4's condition is a function of the measured tree's count, so:
- a statement repaired to 117 is unresolved at the final tip (117 != 119);
- a statement repaired to 119 makes the round-57 post-move row state a round-58 fact (false
  provenance), and the historical `114 at the BASE` / `116 at the landing d857f344` statements
  (both true at their revisions) become collateral.
This is the r57 lesson's own D5 mechanism (S117 landed after the 116 statement) reproduced one
round later. The plan does not pin the evaluation tree or the revision for I4.

**Ambiguity demonstrated.** A naive scan for `N -> N` / `N rows` over the named surfaces catches
the SCORECARD score arrows (`9 -> 9`, `3 -> 0`, `0 -> 5`, …) and returns 15 "bad" counts; only
the registry statements (post-move row; §Sources arrow + `end`) are registry counts (the
pre-move `114 at the BASE` and the `start 114` are historical). The frozen item says "every
registry-count statement" but the parenthetical names only the post-move row and §Sources; a
verifier reading the broad wording flags the arrows, a verifier reading the parenthetical does
not. The checker must state its exact statement set in the receipt.

**Population/scope gap.** The routed list is D1-D12 (12 defects); the POP is 8 items covering
D1, D3, D4, D5, D6, D7, D8-label, D11-stale-basis, D12. Not covered: D2 (report commit order),
D9 (wave shape), D10 (fleet-scope prompt), D11's checklist-substrate half (CHECKLIST_RUN BROKEN
failed=7), and D8's actual file (I6's label says D7 + D8 but its condition reads
current-claims.py only). The claim's name "the round-57 routed record defects are resolved" is
broader than its POP; an independent spot-check can reject the overstatement even at value=0.
The cheapest fix is a scope sentence in the round's lesson/report and an erratum for D8, not a
predicate change.

## 3. C2 — capability vs re-score, surface, and T5

**It is a capability acquisition, not a re-score.** BASE has four OpenBao trials (token r49,
wrap r51, KV r52, audit r57). Their policy writes are grants only:
`path "auth/token/create" { capabilities = ["create","update"] }` (token trial 128-131) and
`path "pki/issue/trial" { capabilities = ["update"] }` (150-153). The token/lease entry bounds
itself: "no policy model beyond the `default` policy and the two trial policies" (lines
209-210/251). No deny precedence, `*`/`+` matching, exact-vs-prefix, union-vs-priority is
measured at BASE. The scribe entry is grounded in S118/S119 quotes (deny-by-default, `*` last
char, deny precedence, `+` one segment, union/priority).

**Surface it moves:** `SCORECARD.md` §Capabilities row, `corpus/knowledge/openbao-acl-policy-
semantics.md`, and `corpus/SOURCES.md` S118/S119. Commands that would show it unmoved: at BASE
`test -e corpus/openbao-policy-trial.sh` is false; `bash plans/round-58-c2.sh 1b13f5d` reads
`value=0 … (absent)`; `git grep -n 'path ".*" { capabilities' 1b13f5d -- corpus/openbao-*-trial.sh`
finds only the two grants. At the tip, a non-empty diff for the trial + entry is the capability;
a SCORECARD-only diff is a re-score.

**T5's client-side introspection leg: load-bearing, not decoration — but it is also the ceiling.**
The on-disk counter (`plans/round-58-c2.sh` lines 32-37, 82-88, 132) requires a PATH wrapper
that answers `bao token capabilities` with `deny` to flip exactly T5 (`HHHHB`, rc 1); an
effects-only T5 cannot satisfy the frozen predicate. So the leg forces a real CLI call and is
not decoration. But it makes T5 a client-side capability-introspection check, and the plan's own
K2 ceiling is exactly "a trial that shape-keys the shim vectors and introspects the PATH wrapper
reads 5 without measuring anything". The plan's T5 row (line 105) lists only server effects
(read/update/delete outcomes); the counter's requirement adds the introspection. That is a
predicate-vs-row inconsistency: the trial must read a CLI value for T5, and a lying CLI can
break a correct server. The counter is necessary, not sufficient; the receipts + the non-author
probe are the check (the plan says so, and the seat roster must name that probe — see §6).

**Smallest safe correction:** T5 prints two vectors, `effects=` (the read/update/delete
outcomes) and `introspect=` (the `bao token capabilities` result). The wrap receipt shows
`effects=HHH` unchanged and `introspect=B` under the lie. The capability row/lesson names the
effect vector as the enforcement evidence and the introspection as the direct observable of
S118's union/priority sentence. Then a shape-keyed/introspecting mock is visible in the receipt
instead of hidden behind one HOLDS/BROKEN character.

## 4. Causal separability

| file | C1 use | C2 use | coupled? |
|---|---|---|---|
| `corpus/SOURCES.md` | I4 reads the measured data-row count | adds S118/S119 rows (117 -> 119) | **yes — one-directional (C2 -> C1/I4)** |
| `SCORECARD.md` | repairs the round-57 post-move row (I1/I4); appends to epoch C | appends the capability row | same file, different regions; a C1 scan that reads the whole file can catch C2's own numbers; the I4 statement set must be scoped to the round-57 row/§Sources |
| `corpus/lessons/round-57.md` | I3/I7 | no | no |
| `corpus/current-claims.py`, `SKILL.md`, `corpus/adjacency.tsv` | I5/I6/I8 | no | no |
| `corpus/openbao-policy-trial.sh`, `plans/round-58-c2.sh`, entry | no | yes | C2 is verifiable without C1 |

- **C2 without C1: yes.** The trial/counter/entry do not read the C1 items; the shared
  SCORECARD file is a different section. A C2 run at the tip is unaffected by the C1 repairs.
- **C1 without C2: only at a pinned tree.** I4's reading is a function of the measured tree's
  SOURCES count. At the final tip with S118/S119, a C1 statement repaired to 117 reads
  unresolved; the claim's "re-checkable" at the tip fails. The C1 seed tree must be a pinned C1
  reference commit before the C2 rows (and the receipt must name it), or the count statements
  must be revision-qualified. This is the same class as r57 D5.

## 5. Ranked rejection reasons and the cheapest pre-emptive edit

1. **C1/I4: the count is not stable at the final tip and the statement set is ambiguous.**
   A non-author reruns `bash plans/round-58-c1.sh` at the tip after S118/S119 and reads I4=1
   (117 vs 119) or sees the round-57 row claiming 119; a naive scan also flags the score arrows.
   *Fix:* make the two r57 statements revision-qualified — `117 at 1b13f5d (S115-S117);
   119 at the round-58 tip (S118/S119)` and `114 at 1cda9e7; 116 at the r57 landing d857f344;
   117 at the r57 tip` — and have the C1 checker resolve each statement's named revision
   (or take the C1 reading on a pinned C1 commit before the S118/S119 rows and name that commit
   in the receipt). Scope the checker's statement set to the post-move row + §Sources
   arrow/current/end; treat the pre-move/start counts as pinned historical values.
2. **C1/I2: a one-line receipt edit reaches 0; the correct 15-match re-run fails the frozen 13;
   the on-disk A1 amends the frozen predicate.** The predeclaration commit says "(none)";
   A1 + the untracked -final receipt also makes the BASE worktree census read 7.
   *Fix:* revert A1; run the frozen `plans/round-57-controls.sh` with no REF over the final
   bytes (13 controls, PENDING REF lines not counted), commit that receipt with all five pins
   correct, and keep the 15-match REF run as a separate post-landing battery. The sentinel
   re-runs the no-REF controls independently and the LOG names both receipts. Measure the BASE
   control on 1b13f5d, not the worktree. If A1 is retained, commit it as a named freeze epoch
   before any candidate reading and state that the five-pin equality does not prove the run.
3. **C2/T5: the client-side introspection is forced by the guard and is the K2 ceiling.**
   A judge sees T5 pass/fail on a CLI value while the plan's T5 row claims server effects.
   *Fix:* print `effects=` and `introspect=` for T5, require the wrap receipt to show effects H
   under the lie, and name the effect vector as the enforcement evidence in the entry/capability
   row; have the non-author probe read the trial's commands and the two vectors.

Next most likely (pre-empt if room):
4. **C1/I8 environment + token pass.** A copied tree reads stale_basis=2 even after the fix
   without `--lane-root /home/vgpnk/Projects/shokunin`; the token append to SCORECARD.md:54
   passes. *Fix:* the C1 counter passes `--lane-root` explicitly; the adjacency row is repointed
   to `SCORECARD.md:65` (substantive), not token-appended; the receipt records the invocation.
5. **C1 population scope.** D2/D9/D10 and D11's checklist half are not in I1..I8; D8's file is
   not read by I6. *Fix:* a scope sentence in the round-58 lesson/report ("C1 covers the eight
   fixed I1..I8 items; D2/D9/D10 are out of population; D11's checklist gap is registered;
   D8 is an erratum against the frozen round-57 checker") and an erratum line for D8.
6. **C1 forgery controls are self-authored.** The plan names the eight C1-F forgeries but not
   their mutations; the checker author and the forgery author would be the same seat. *Fix:* the
   mutation-tester seat authors or independently reviews the eight mutations and commits them
   with expected values; the receipt names the author seat.
7. **Wave shape.** The plan's §Shape says 14 seats including a labrat; `w1-spec.json` has 13 and
   no labrat; the assignment header says 13. The C2 K2 ceiling says the non-author probe checks
   the trial; name that seat (sentinel/reviewer) in the round report or dispatch the labrat.

## 6. Axis impact

- **calibration** (C1): the record repairs are real on the eight items, but the re-checkability
  at the tip (I4) and the receipt-run evidence (I2) are not yet established; the claim should be
  reported as 8 -> 0 at a named C1 reference commit with the revision-qualified counts, not as a
  final-tip reading. The I8 token-pass and the I2 hand-edit are calibration-fraud vectors; the
  sentinel/probe must read the repairs.
- **operability** (C2): genuine capability acquisition (new ACL semantics trial, new entry,
  S118/S119). The counter is necessary, not sufficient; the K2 ceiling and the T5 client leg are
  declared, and the score's truth depends on the receipts + probe. No score change is claimed
  for the other axes; the S118/S119 rows move coverage 117 -> 119, which is a coverage fact, not
  a C2 score move.
- **depth/freshness/adjacency**: unaffected by the claims; the C1 fixes are record-level and the
  C2 trial does not absorb a sibling surface.
- **No harm found to any axis from the corrections above**; the corrections remove false-green
  routes without widening the claims.

## 7. Process findings (read-only)

- `plans/round-58.md` on disk differs from the predeclaration commit: uncommitted A1/A2/A3
  (md5 `fc1b0629…` at 0085a5f vs `4c6ea63e…` on disk at 12:21; diff +39/-1; A3 was added after
  this report's first draft and is covered in §9). The round's instruction is
  "never amend a frozen predicate, target, POP or kill rule". A1 is avoidable (no-REF 13-match
  receipt); A2 is a whitespace-normalization clarification (the S117 quote is split by a newline
  in the raw body). If retained, commit as a named freeze epoch before any candidate reading and
  cite it; otherwise revert. See `receipts/plan-amendment.txt`.
- The C1 checker/counter/controls are not yet on disk; the C2 counter's BASE no-work control
  reads `C2_POLICY_TRIAL: value=0 … (absent)` rc 0. The C1 pre-freeze control (value=8) and the
  C2 no-work control (value=0) must be receipts before any candidate measurement.
- The untracked `controls-prefreeze-epochC-final.txt` is not in any revision. If it is used, it
  must be committed; the frozen I2 (13) rejects it. The BASE census must be measured on
  1b13f5d, not the live worktree (A1 + the untracked receipt would read I2=0 there).
- The wave is 13 seats (`w1-spec.json`), the plan §Shape says 14 (labrat). The plan's C2
  non-author probe is not assigned a seat; the sentinel/reviewer must cover it or the labrat must
  be dispatched.
- No tool installs/updates; no network; no secret values or token shapes in this report. Scratch
  under `/fast/scratch/hyaku/kagi-r58/R58CriticClaims` and deleted before yield.

## 8. Reproduce

See `receipts/commands.txt`. The key independent reading: `python3 census.py <git-archive-of-
1b13f5d>` -> `value=8`; the I2 receipts -> old pin mismatch / new 15-match; the SOURCES counts
per revision -> 114/116/117/117/117; the scope-gate copies -> 3/1/0/2; the C2 counter lines ->
wrap `HHHHB`.

## 9. In-flight addendum (observed 12:19-12:21; `receipts/live-worktree.txt`)

The round was landing the C1 repairs while this seat ran. Observed, read-only:
SOURCES = 119 with S118/S119; the round-57 post-move row and lesson §Sources now carry the
114 -> 117 landing count + the 119 tip count + the `gates.txt` 116/predates-S117 note (A3);
`corpus/adjacency.tsv` basis repointed `SCORECARD.md:54` -> `:70` (substantive; live
`stale_basis=0`); `SKILL.md` has the current-claims row; `current-claims.py` has `--round` and
`--selftest PASS (19 cases)`; the lesson has the S117 Gate row, the live S115 heading and the
S117 source line; `LOG.md` has the epoch-C + D2 correction. A1/A2/A3 are on disk but
uncommitted (predeclaration 0085a5f still says "(none)").

Consequences for the verdict:
- The §2/I4 *content* finding is addressed by A3 in the worktree. The residual is form and
  implementation: A3 amends the frozen I4 condition; the C1 checker must implement its four
  clauses (landing N=117; tip count = the measured live count; a `gates.txt` count equal to the
  file plus the "predates S117" note; at least one statement per location), and the C1 receipt
  must cite the amendment commit. If the operator enforces the frozen single rule literally, A3
  must be committed as a named freeze epoch before any candidate reading, or the C1 reading must
  be taken on a pinned C1 reference commit before the S118/S119 rows.
- **New live counterexample (C1/I6): the new gate's own `--round 57` run is red.**
  `python3 -I -B corpus/current-claims.py --round 57 --verbose` reads
  `CURRENT_CLAIMS: value=13 population=15 mismatches=13 unbound=6 cases=3 match=6 epochs=6
  clocks=0 pop=0 guard=1`, rc 1. It flags (i) the round-57 SCORECARD/lesson's *quoted* round-56
  numbers ("18 cases", "four/Three freeze epochs", the "23 MATCH" repair history) as current
  statements; (ii) the round-57 SCORECARD's now-stale current-tense `--selftest 13 cases` (the
  live gate's selftest is 19) as `UNBOUND` because the CASES class only names `recheck-replay`;
  (iii) the pre-epoch `controls-prefreeze.txt` `11 MATCH` as `nearest-epoch-` UNBOUND. The I6
  item's letter (accepts `--round`, paths, docstring, `--selftest` 0) passes, but the round's own
  calibration gate rejects the round-57 surface, and an independent spot-check will run it.
  *Fix:* scope the `--round N` surface to the round's landing claims and exclude quoted
  earlier-round history; bind the current-claims selftest count (extend CASES or add a
  self-description class) and update/qualify the r57 `13 cases` to 19; bind the pre-epoch
  `controls-prefreeze.txt` receipt; add these cases to the gate selftest; record the `--round 57`
  reading in the C1 receipt with each flagged line explained, or report the red reading as a
  named residual rather than hiding it.
- Revised ranking (supersedes §5's ordering; §5's #1 content is now in flight):
  1. the live `--round 57` gate red / I6 own-audit (above);
  2. I2's run proof — A1's five pins bind instrument identity, not the run; the untracked
     `-final` is a real 15-match re-run but the checker cannot distinguish it from a hand-edit;
     the sentinel's independent no-REF re-run is the proof; if A1 is kept, cite the amendment
     commit, otherwise use the frozen 13-match receipt;
  3. C2/T5 introspection (unchanged: two vectors + the non-author probe).
  The §5 #4-7 (I8 lane-root, population scope/D8, self-authored forgeries, wave shape) remain.
- C1 verdict stays "falls as frozen" until (a) the `--round 57` reading is green or the residual
  is named, (b) A1/A2/A3 are a named freeze epoch or the frozen 13 rule is used, and (c) the C1
  BASE=8 and C1=0 receipts exist on a stable tree. C2 verdict unchanged (capability acquisition;
  T5 fix + probe).
