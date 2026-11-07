# R58CriticClaims — scoped findings (kagi r58, attempt 1)

Read-only seat. BASE `1b13f5d`; frozen predeclaration `0085a5f`. Full evidence:
`.ufo/waves/round-58/build/R58CriticClaims/report.md` and `…/receipts/` (base-census.txt,
i2-receipts.txt, scope-gate.txt, sources-count.txt, c2-t5.txt, plan-amendment.txt, commands.txt).

## Verdicts

**C1 (calibration, 8 -> 0): falls as frozen, fixable.** The BASE census is correct: I re-read
all eight conditions on a `git archive 1b13f5d` tree and an independent scratch checker prints
`value=8` (no item holds at BASE). But the predicate reaches 0 through:
- **I2**: a one-line edit of the receipt's `INSTRUMENT … plans/round-57.md` hash to `76e836ee…`
  (the other four pins already match; the last line already reads `match=13`). No battery re-run
  is needed, and the checker cannot distinguish it from a re-run. The real 15-match re-run
  (untracked `controls-prefreeze-epochC-final.txt`, five pins correct) fails the frozen
  `match=13` because the frozen controls script counts two REF legs; the on-disk A1 amendment
  loosens I2 to `N>=13` but is an uncommitted change to a frozen predicate and does not close the
  hand-edit path. A1 + the untracked receipt also resolves I2 on the live worktree, so the BASE
  no-work control must be measured on 1b13f5d, not the worktree (else 7, not 8).
- **I4**: the count is not stable at the final tip. BASE SOURCES = 117; the round's own C2 adds
  S118/S119 (entry cites S118 x7 / S119 x5), moving the measured count to 119. A 117 statement is
  unresolved at the tip; a 119 statement makes the round-57 post-move row claim a round-58 fact
  (the r57 D5 class recurs). A naive `N -> N` scan also catches the score arrows (15 "bad"
  counts); the exact statement set must be named (post-move row + §Sources current/end; the
  pre-move/`start` counts are historical 114/116 at their revisions).
- **I8**: the token append test — appending `opencode` to the unrelated `SCORECARD.md:54` yields
  `stale_basis=0` with `--lane-root /home/vgpnk/Projects/shokunin`; the substantive repair is the
  `corpus/adjacency.tsv` basis repoint (line 81) to `SCORECARD.md:65` (a row that names
  `~/.config/opencode`). A copied candidate tree reads `stale_basis=2` after any fix without the
  explicit lane-root; the C1 counter must pass it or run the live lane.
- **Population/scope**: the routed list is D1-D12; the POP is 8 items. D2, D9, D10 and D11's
  checklist half are not covered; I6's label "D7 + D8" is false provenance — D8 is
  `plans/round-57-c1-check.py` (docstring lines 22-23 vs code line 133), which no item reads.
  The claim's name "the round-57 routed record defects" overstates the POP.

**C2 (operability, 0 -> 5): survives as a capability acquisition.** No ACL-policy-semantics
trial exists at BASE; the four OpenBao trials only write grant policies (`auth/token/create`,
`pki/issue/trial`), and the token entry bounds itself to the default + two trial policies. The
surface moved: SCORECARD §Capabilities row + the ACL entry + S118/S119. Unmoved-at-BASE commands:
`test -e corpus/openbao-policy-trial.sh` false; `bash plans/round-58-c2.sh 1b13f5d` -> value=0;
`git grep 'path ".*" { capabilities' 1b13f5d -- corpus/openbao-*-trial.sh` -> only two grants.
**T5**: the counter (lines 32-37/82-88/132) requires a PATH wrapper lying on `bao token
capabilities` to flip exactly T5 (`HHHHB`), so the client-side introspection leg is load-bearing,
not decoration — but it makes T5 a CLI-capability check, and the K2 ceiling is exactly a
shape-keyed + introspecting trial. The plan's T5 row lists effects only. Fix: T5 prints
`effects=` and `introspect=` vectors; the wrap receipt shows effects H under the lie; the entry
names the effect vector as enforcement evidence. The counter is necessary, not sufficient; the
receipts + the non-author probe are the check.

## Separability

C2 verifies without C1. C1 cannot be re-checked at the final tip without C2: `corpus/SOURCES.md`
is read by I4 and written by C2's S118/S119 (117 -> 119); `SCORECARD.md` is written by both
(different sections; the C1 statement set must be scoped to the round-57 row/§Sources). The
coupling is one-directional (C2 -> C1/I4), and it is the same class as r57 D5.

## Ranked rejection reasons + cheapest pre-emptive edit

1. **C1/I4 count vs the round's own registry additions.** Fix: revision-qualified statements —
   `117 at 1b13f5d (S115-S117); 119 at the round-58 tip (S118/S119)` and `114 at 1cda9e7; 116 at
   the r57 landing d857f344; 117 at the r57 tip` — with the checker resolving each named
   revision; or take C1 on a pinned C1 commit before the S118/S119 rows and name it. Scope the
   checker to the post-move row + §Sources current/end.
2. **C1/I2 receipt.** Fix: revert A1; run the frozen controls with no REF over the final bytes
   (13 lines, all five pins), commit that receipt; keep the 15-match REF run separate; sentinel
   re-runs; measure BASE on 1b13f5d. If A1 is kept, commit it as a named freeze epoch before any
   reading and state that the five pins do not prove the run.
3. **C2/T5 introspection.** Fix: two T5 vectors (`effects=`, `introspect=`); wrap receipt shows
   effects H; the entry names the effect vector as the enforcement evidence; the non-author probe
   reads the trial's commands.

Next: I8 lane-root/token-pass (pass `--lane-root`; repoint to `SCORECARD.md:65`); population
scope (D2/D9/D10/D11-half/D8 erratum); self-authored C1 forgeries (mutation-tester owns them);
wave shape 13 vs the plan's 14 (no labrat; name the C2 probe seat).

## Axis impact

calibration: the eight record repairs are real, but the tip re-check (I4) and the receipt-run
evidence (I2) are not yet established; report C1 as 8 -> 0 at a named C1 reference commit with
revision-qualified counts. operability: genuine new executed capability; the counter is
necessary not sufficient, the K2 ceiling and T5 client leg are declared. depth/freshness/
adjacency unaffected; coverage moves 117 -> 119 from S118/S119 (a coverage fact, not a C2 score
move). No harm found to any axis from the corrections.

## Process

`plans/round-58.md` on disk differs from predeclaration 0085a5f: uncommitted A1/A2/A3 (+39/-1
at 12:21; A3 is covered in the addendum). The
round rule says never amend a frozen predicate; A1 is avoidable via the no-REF 13-match receipt;
A2 is a whitespace clarification (S117 quote is split by a newline). If retained, commit as a
named freeze epoch before any candidate reading. The C1 checker/counter/controls are not yet on
disk; the C2 counter's BASE control reads value=0 (absent). The untracked epochC-final receipt
must be committed if used. No installs/updates, no network, no secret values. Scratch deleted
before yield.

## In-flight addendum (12:19-12:21; receipts/live-worktree.txt)

The round is landing the C1 repairs: SOURCES = 119; the r57 post-move row/lesson now carry the
117 landing + 119 tip counts + the gates.txt 116/predates-S117 note (A3); `corpus/adjacency.tsv`
basis repointed 54 -> 70; SKILL.md current-claims row; `--round` + `--selftest PASS (19 cases)`;
S117 Gate row; live S115 heading; LOG D1/D2 correction. A1/A2/A3 are on disk but uncommitted
(predeclaration 0085a5f says "(none)").

New live counterexample: `python3 -I -B corpus/current-claims.py --round 57` reads
`CURRENT_CLAIMS: value=13 population=15 mismatches=13 unbound=6 … guard=1`, rc 1. It flags the
r57 SCORECARD/lesson's *quoted* round-56 numbers as current statements; the r57
`--selftest 13 cases` is now stale (live 19) and UNBOUND because CASES only names
recheck-replay; the pre-epoch `controls-prefreeze.txt` `11 MATCH` is `nearest-epoch-` UNBOUND.
The I6 letter passes, but the round's own gate rejects the r57 surface; fix the surface/classes
or name the red reading as a residual. Revised ranking: 1. live `--round 57` gate red / I6;
2. I2 run proof (A1 pins bind identity, not the run; sentinel no-REF re-run); 3. C2/T5.
The I4 content fix is in flight (A3); the residual is the amendment form + the checker's four
clauses. C1 stays "falls as frozen" until the gate is green or the red is named, the amendments
are a named freeze epoch or the frozen 13 rule is used, and BASE=8/C1=0 receipts exist on a
stable tree.
