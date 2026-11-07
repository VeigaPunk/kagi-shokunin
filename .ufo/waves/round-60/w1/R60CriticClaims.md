# R60CriticClaims — falsification of the round-60 claim sizing and freeze

Seat report (wave `kagi-r60-w1`, seat `R60CriticClaims`, role critic). Findings file:
`.ufo/waves/round-60/build/R60CriticClaims/attack.md` (identical body; this copy is the seat
report). Verdicts: **C1 holds** as a BASE reading (7/7 unresolved, re-derived) but carries two
**high** reachability defects (the guard's `dead=`/`dead seats=` field split; I6's missing
`75165a07` anchor) and one **medium** control gap (no regression read on the round-59 capability
that I7 mutates). **C2 holds** on absence, reachability and novelty (4/5 mechanics never executed
by the lane) but carries two **high** defects in §A3 (an item condition restated under a "nothing
changes" sentence; its cited probe receipt does not contain two of the three restated T1
observables and contradicts one) and one **medium** free pass (`--selftest` unmutated by any
control). **Hygiene holds** on distinct axes, separability and the do-nothing test; the attack-share
parenthetical (4/16 = 25 %) is arithmetically wrong without an unstated revenger≈labrat
substitution (literal: 3/16 = 19 %).

Seat: critic (attack share). Read-only: no lane file written outside this seat's two report
paths; no git/jj mutation; no citable evidence under /tmp. BASE
`a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`; plan of record `plans/round-60.md` at
`5e1649a39667201e883bab4adee5a3ab7d3ef037` (predeclaration `cd631737`, which carries §A1 only).
Scratch `/fast/scratch/hyaku/kagi-r60/R60CriticClaims/` (created, deleted before yield).

Every verdict below is one of **holds** (the frozen statement survives the strongest local
counterexample), **ambiguity** (two readers derive different readings; repairable by a sentence),
**defect** (the statement is false, unreachable, or unenforceable as written). Severity is for the
round's admission, not for the lane's history.

---

## C1 — calibration: `C1_ROUTED` 7 → 0

### C1.1 The BASE reading is really 7 — **holds**

Re-derived item by item over committed bytes at BASE (no instrument executed; the checker is not
yet on disk, so the frozen text is the object under test). Every command below is pinned to
`a677c78e` (`git show a677c78e:<path>`): the worktree is being modified by sibling seats while this
is written, so an unpinned `grep` is not BASE evidence.

| item | command | observed at BASE | verdict |
|---|---|---|---|
| I1 | `tail -1 LOG.md`; `grep -c '^## Round 59 — correction' LOG.md`; `python3 -c` over `.ufo/waves/round-59/w1-results.json` | last line ends `dead seats __DEAD__`; 0 correction blocks; **14 results, 0 with an empty `output`** (R=14, D=0) | unresolved |
| I2 | `git show a677c78e:corpus/lessons/round-59.md \| grep -n 'R31'`; `cat .ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt`; same `git show` for `grep -c 'supersedes R31'` | one occurrence, line 206, states the receipt reads `(32 cases)`; the receipt reads `C1_CHECK_SELFTEST: PASS (33 cases)`; **0** `supersedes R31` lines at BASE (the worktree now carries the fix at line 208 — in-flight sibling work, not BASE evidence) | unresolved |
| I3 | `ls corpus/lessons/round-60.md` | absent | unresolved |
| I4 | `grep -c '(21 controls;' SCORECARD.md`; `grep -cE '^CONTROL ' .ufo/waves/round-59/controls/controls-prefreeze.txt` | 1 at line 1971; receipt holds **20** `CONTROL` lines; no `supersedes SCORECARD.md:1971` line | unresolved |
| I5 | `ls .ufo/waves/round-59/final/`; `git show a677c78e:SCORECARD.md \| grep -c 'supersedes the round-59 gate-evidence pointer'` | 6 files, none release-clock/doc-audit/scope; **0** in `SCORECARD.md` (the only tree occurrence is the plan's own item text) | unresolved |
| I6 | `git show a677c78e:SCORECARD.md \| grep -c '75165a07'` | **0** at BASE and 0 in the worktree; no `c1-landed.txt` line either | unresolved (see C1.5) |
| I7 | `git show a677c78e:corpus/openbao-transit-trial.sh \| grep -c selftest`; `grep -n 'openbao-transit-trial' SKILL.md` | **0** selftest occurrences; SKILL.md:847 selftest cell reads `none — its own five shims and the clean-room leg are the falsifiers` | unresolved |

`value=7` at BASE is therefore a true reading **provided** the checker derives each number (C1.9).
The seven routed defects are real: each is a place where the lane's own record states a fact the
tree contradicts, and no lane gate reads any of them.

### C1.2 No item passes on a do-nothing tree — **holds**, with one-file margin

No item's condition is satisfied by BASE bytes. The margin is thin in exactly one place: the only
text in the tree carrying both `c1-landed.txt` and `measured=revision 160caf75…` is
`corpus/lessons/round-59-verifier-spotcheck.md:188`, and the only `75165a07` occurrences are in
that same lesson and in `plans/round-60.md`. I6 is saved from vacuity only by its own file pin
("`SCORECARD.md` carries …"). A checker that scanned the tree instead of `SCORECARD.md` would
resolve I6 at BASE and print 6; K2 would catch it, but the K2 census must be run, not assumed.

### C1.3 Two of the seven items are shape-only — **ambiguity** (severity low)

I5 reads three files' last non-empty line prefixes; I6 reads one appended line. Neither reads
whether the gates ran or whether the citation is true. This is the plan's own named ceiling
(§Named ceilings, K3), and it is honestly declared — but the round must not report I5/I6 as
"verified" without saying "existence and shape verified; the gate readings are the ceiling".
Smallest repair: the report's C1 row states the ceiling inline (one clause), and the three
receipts each carry a `measured=<revision|tree-hash>` line so a reader can tell which tree they
describe (see C1.8).

### C1.4 The guard's challenge field cannot be both read and flipped — **defect** (severity high: reachability)

Counterexample from the frozen text alone. I1 requires a line "matching `results=<R> dead=<D>`"
(plan:63). The guard requires the challenge copy's "only delta is the digit in the I1 correction
line's `dead seats=<n>` field changed from 0 to 1" (plan:51). These are two different fields:

- If the correction line reads `results=14 dead=0` (as I1 requires), there is no `dead seats=`
  field to mutate → the challenge cannot fire → guard=0 → the predicate's "when GUARD = 1, else
  FAIL" makes the line read `value=FAIL` → **C1 can never print `value=0 … guard=1`**.
- If the line reads `results=14 dead=0 dead seats=0`, flipping `dead seats=` leaves the `dead=`
  the item compares intact → the challenge prints `value`, not `value+1` → guard=0 again.
- Only an implementation that treats `dead=<D>` and `dead seats=<D>` as **one** field satisfies
  both sentences. The frozen text does not say so, and the plan's own convention ("this sentence
  is the plan's, the counter's code and the receipt's label") makes the divergence a calibration
  defect of the round that measures calibration.

Observed in flight, not hypothetically: the correction a sibling seat is landing right now
(`LOG.md`, worktree, uncommitted) reads `results=14 dead seats=0` — it satisfies the guard's
spelling and does **not** match the item's `results=<R> dead=<D>` spelling. Two readers of the
same frozen sentence have already diverged on the artifact the round will measure.

Impacted axes: calibration (primary; the claim is unreachable as literally specified).
Smallest safe correction (no truth condition changes — the two spellings denote the same fact):
declare that the I1 line is `results=<R> dead=<D> dead seats=<D>`, that the item match and the
guard challenge both read the `dead seats=` group, and that the checker's regex is
`results=(\d+) dead(?: seats)?=(\d+)` with the challenge rewriting that same captured group.

### C1.5 I6's anchor does not exist, and the plan's motivating evidence for D6 is false — **defect** (severity high: reachability)

I6 requires a line "after the round-59 line containing `75165a07`" (plan:68). `git grep -n
'75165a07' -- SCORECARD.md` returns **nothing**; SCORECARD:1962 says only "Candidate: the
round-59 landing commit (recorded in the report)". The plan's motivating bullet (plan:27) asserts
"the round-59 Before → after table names `75165a07` as the measured commit" — that sentence is
false about `SCORECARD.md`; it is true only of the spot-check's own D6 row
(`corpus/lessons/round-59-verifier-spotcheck.md:188`). So the routed defect D6 is real in
substance (the receipt's `measured=revision` is `160caf75…`, not the tip) but its quoted evidence
is wrong, and the item built on it has no anchor.

Consequences: a checker that anchors on the first/last `75165a07` line in `SCORECARD.md` finds
nothing → I6 never resolves → target 0 unreachable. A checker that restricts the anchor to the
`## Round 59` section (lines 1939–1976) is unsatisfiable even after the fixer appends a correction
at EOF. Only a checker that anchors on "the last line in `SCORECARD.md` containing `75165a07`,
wherever it is" is reachable — and then the anchor is text the fixer itself writes, i.e. the item
partly certifies its own premise.

Impacted axes: calibration (primary), and it is the same class as D6 itself.
Smallest safe correction: the correction block must quote `75165a07` on a line **before** the
`c1-landed.txt` line (honest wording: "the spot-check routed D6 against `75165a07`; the receipt's
measured revision is …"), and the plan states the anchor as "the last `SCORECARD.md` line
containing `75165a07`, the correction's own quotation included". One sentence; no predicate change.

### C1.6 The guard can fire spuriously and still print guard=1 — **ambiguity** (severity medium)

The predicate (plan:49–52) does not say the challenge copy must be built by rewriting a field the
checker **resolved**. A checker that synthesizes the copy by *adding* `dead seats=1` to a tree
with no correction block fires the challenge at BASE (7+1=8), prints `guard=1`, and never tests
the real correction line. The plan's census sentence ("the guard-bearing line reads `value=FAIL …
guard=0` only where the challenge cannot fire", plan:85–86) implies the intended behaviour but
does not mandate it, so the guard has a path where it cannot fail and the harness still prints 1.
Smallest repair: the challenge must rewrite the field resolved in the measured tree and report
`challenge=not-applicable` → guard=0 when no line resolves.

### C1.7 The pre-freeze text names one BASE reading where the predicate names two — **ambiguity** (severity low; precedent resolves it)

Predicate: "when GUARD = 1, else FAIL" (plan:47). K2: "The BASE census is taken with
`--no-challenge`" (plan:87). Pre-freeze: "both counters on the BASE tree: C1 value=7" (plan:175).
The round-59 battery already encodes the correct two-row form
(`report K1-BASE 5 …` + `report K1-BASE-GUARD FAIL …`, `plans/round-59-controls.sh:111–112`), so
a reader with the precedent lands correctly — but a battery written to plan:175 literally reports
MISMATCH on the guard leg. Smallest repair: name both rows in the pre-freeze paragraph.

### C1.8 No control protects the landed capability the round mutates — **defect** (severity medium: admission rule)

I7 edits `corpus/openbao-transit-trial.sh`, which is the evidence pointer of the round-59
operability capability row (SCORECARD:722; `bash plans/round-59-c2.sh` → `value=5`). The
pre-freeze set (plan:175–190) contains no control that re-reads that capability after the edit,
and `plans/round-59-controls.sh` pins the trial's sha256 into its receipt (line 104), so the
round-59 battery cannot serve as the regression read either. The admission rule ("no axis is
harmed") therefore has no instrument for the one tracked file this round mutates that backs a
landed capability. Counterexample: an I7 edit that adds `--selftest` but breaks the shim dispatch
makes `plans/round-59-c2.sh` read < 5, and every listed control still reads match.
Smallest repair: one control — re-run `bash plans/round-59-c2.sh <candidate>` and require
`value=5` (about a minute; the counter does not pin the trial).

### C1.9 I7 does not require the selftest to be bao-free — **ambiguity** (severity low)

I7's condition is "exiting `bash <tree>/corpus/openbao-transit-trial.sh --selftest` … exits 0 and
prints `TRANSIT_SELFTEST: PASS (cases=N)` with N >= 6" (plan:69). The Gate standard D7 invokes is
"a self-invocation mode over isolated fixtures" — isolation is not in the item. A selftest that
starts a real dev server satisfies I7 while failing the standard it claims to close. C1-F6 tests
the mutated mapping but not the isolation. Smallest repair: the receipt records the selftest run
under a bao-less `env -i PATH=…` (the C2 counter already does this for its own selftest), and
C1-F6 runs its mutant under the same PATH.

---

## C2 — operability: `C2_APPROLE_TRIAL` 0 → 5

### C2.1 Genuinely absent at BASE — **holds**

```
git cat-file -e a677c78e:corpus/openbao-approle-trial.sh   → rc 128 (does not exist)
grep -ril approle corpus/                                  → no match
bash plans/round-60-c2.sh a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2
  → C2_APPROLE_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0 (absent), rc 1
```
The absent leg exits 1, not 0 — the frozen "exit 0 iff value=5" contract holds, and the BASE
reading is 0 by measurement, not by assumption.

### C2.2 Five tests are reachable in one round by one seat — **holds**

Round 59 landed a 355-line, five-test trial with five shims, a no-bao leg and a clean-room leg in
one round; this trial's counter runs ten legs (real, real2, ambient, none, selftest, SH1–SH5),
each a fresh dev server, with two ≥3 s TTL waits per leg — minutes, not hours. The L1 probe
already measured T1(a), T2, T3, T4 and T5 end to end on the pinned binary. No reachability doubt.

### C2.3 Overlap with the existing capabilities is 1/5, not 5/5 — **holds**, with a naming note

Checked against the lane's own entries: `vault-openbao-token-lease-lifecycle.md` has **no**
`num_uses` trial and no accessor lookup/destroy trial (`grep -c num_uses` = 0);
`openbao-acl-policy-semantics.md` has **no** `bound_cidrs` (`grep -ci cidr` = 0). So T2
(the use-count counter), T4 (the accessor as a non-secret handle) and T5 (a CIDR binding) are
mechanics the lane has never executed, and T1 is AppRole-specific. T3 (`secret_id_ttl` expiry) is
a re-instantiation of round-49 T1's observable shape ("alive before the TTL, refused after it")
on a different credential class — the same mechanic, a new object. The claim is a new surface, not
a re-score, but the record should say T3 re-applies a measured mechanic rather than counting five
wholly new classes (severity low; one clause in the capability row).

### C2.4 `--selftest` is a real conjunct in the counter but a free pass in the battery — **defect** (severity medium)

Inside the value: yes — the counter sets `value=0` unless the selftest exits 0 with exactly one
`APPROLE_SELFTEST: PASS (cases=N)` and N ≥ 8 (`plans/round-60-c2.sh:171–178`), run under a
bao-less PATH. Not a free pass in the predicate; a free pass in the control set: a trial whose
`--selftest` is `echo "APPROLE_SELFTEST: PASS (cases=8)"; exit 0` satisfies every listed control
(C2-F3 only *removes* the selftest; nothing mutates it). K5's "must be able to fail: a mutated
copy whose shim resolution or verdict mapping is broken must exit non-zero with a named finding
id" (plan:154–156) has no control, while the analogous C1-F6 exists for the transit selftest.
Counterexample: the stub above reads `selftest=1 value=5` with `CONTROLS: match=N mismatch=0`.
Smallest repair: add C2-F9 = a copy whose selftest verdict mapping is mutated must exit non-zero
with a named finding id, and C2-F10 = the selftest runs rc 0 under `env -i PATH` with no `bao`.

### C2.5 K3's argv clause has no instrument — **ambiguity** (severity medium)

K3 (plan:149–151) forbids a `secret_id` value "on any argv", but the counter scans captured
output only (`plans/round-60-c2.sh:188–191`: `cat "$SCR"/log/* | grep -Ei …`). No listed
instrument can observe a child process's argv. The transit precedent shows the satisfiable form
(`bao write <path> -` with the JSON body on stdin, `corpus/openbao-transit-trial.sh:57,158`), so
the requirement is implementable but unmeasured. Smallest repair: the trial's `--selftest`
includes a static read of its own source asserting every secret-bearing body is piped on stdin
(a `grep -nE '(role_id|secret_id)=' ` over its own `bao`/`curl` command lines), and the receipt
records that grep's output.

### C2.6 §A3 restates an item condition under a "nothing changes" sentence — **defect** (severity high: freeze discipline)

§A3 (plan:223–246) says "Nothing in the predicate, the target, the five-test population or any
kill rule changes; T1's observables are restated to the measured form", then restates T1 as three
observables including "(b) creating a role with `bind_secret_id=false` and no other constraint is
refused with that 500 text; (c) … `bind_secret_id=false` plus `secret_id_bound_cidrs=127.0.0.1/32`
makes a role_id-only login return 200". T1 **is** an item of the five-test population (plan:117,
127), and its frozen condition at plan:127 still reads "after `bind_secret_id=false` on the same
role the same body logs in (a token is issued)". The file now carries two contradictory statements
of T1's condition, and the amendment is not marked as superseding the row — against the round's
own correction convention ("a correction is appended, never rewritten into the line it corrects",
plan:59–60) and against the freeze rule that an item condition is not amended. The restatement is
the *right* engineering (the probe shows the original leg is impossible), but it is a declared
defect, not a silent clarification.
Impacted axes: calibration (primary), operability (T1's reachability).
Smallest repair: A3 item 4 carries "supersedes the §C2 T1 row" and states plainly that the frozen
T1 condition was defeated by measurement before the candidate reading; no truth condition is
changed by adding that marker.

### C2.7 A3's cited receipt does not carry two of its three T1 observables, and contradicts the third — **defect** (severity high: false provenance)

`.ufo/waves/round-60/final/l1-probe.txt` is the receipt A3 cites as the measurement behind the
restatement. `grep -c 500` on it = **0**; the only `bind=false` line is
`T1 login role_id only (bind=false): http=400 has_token=false` (line 12). So:
(a) "a default role refuses a role_id-only login with 400 `missing secret_id`" — evidenced (line
11); (b) "creating a role with `bind_secret_id=false` and no other constraint is refused with that
500 text" — **not in the receipt**; (c) "`bind_secret_id=false` plus `secret_id_bound_cidrs=
127.0.0.1/32` makes a role_id-only login return 200" — **not in the receipt**, and the receipt's
only bind=false login reads 400. A3 therefore presents as measured two observables its own receipt
does not contain, one of which the receipt contradicts. This is the D-class defect the round is
supposed to resolve (a record stating a fact the tree contradicts), committed into the frozen plan
before the candidate reading.
Impacted axes: calibration (primary), operability (if (c) cannot be produced, T1 reads BROKEN and
`value<5`).
Smallest repair: re-issue the probe receipt with the role-creation 500 and the role_id-only 200
under `bind=false` + CIDR (or mark (b)/(c) as "to be measured by the trial, not by this probe"),
and cite the receipt line numbers in A3. Until then A3's "measured" label is unsupported.

### C2.8 T1(c) and T5 share `secret_id_bound_cidrs`, so a field-keyed shim flips two tests — **ambiguity** (severity medium: K4)

T1(c) needs a role with `secret_id_bound_cidrs=127.0.0.1/32`; T5 needs the same field at
`10.0.0.0/8` and `127.0.0.1/32`. A shim implemented as "skip the CIDR check" (the transit trial's
`KAGI_TRANSIT_SHIM` style) flips T1 and T5 together → vector `HBHHB`, `shims_ok<5`, claim void
under K4. The counter's convention ("replaces one test's observable evaluation") permits a
verdict-scoped shim, so this is avoidable — but the plan does not say so, and the trial seat may
choose the field-keyed form. Smallest repair: T1(c) satisfies the role's "at least one constraint"
check with a *different* constraint (`token_bound_cidrs`), or the trial states SH5 is scoped to
T5's verdict only.

### C2.9 `guard=1` is printed unconditionally — **ambiguity** (severity low)

`plans/round-60-c2.sh:194–196` prints `guard=1` on every completed run, including `value=0`. The
C2 predicate defines no guard, so this is cosmetic — but it is the exact shape C1 is asked to
police ("cannot fail, still prints 1"). Smallest repair: either define the flag ("all legs ran")
in the output-line spec or drop it from the C2 line.

---

## Hygiene

### H1 Two claims, distinct axes, causally separable — **holds**

C1 reads `LOG.md`, `corpus/lessons/round-59.md`, `corpus/lessons/round-60.md`, `SCORECARD.md`,
`SKILL.md` and the transit trial; C2 reads `corpus/openbao-approle-trial.sh` and the counter. No
item of either reads the other's artifacts, and neither can be satisfied by the other's landing.
Axes are distinct (calibration, operability) per `AXES.md` §"a round is 1–3 claims".

### H2 No universal clause in the predicates — **holds**, with one caveat

Both predicates are itemized (7 and 5). The caveat is the universal sentence "Every number an
item compares is derived by the checker … no constant in the checker carries a fact the measured
tree asserts" (plan:54–56): the table's parentheticals (14/0, 33, 20, `160caf75…`) are exactly
the constants a checker would hardcode, and only C1-F1..C1-F5 can catch that. Those controls are
not yet on disk, so this is unverified at review time — the battery must mutate each *derived*
fact (the results file, the receipt's case count, the controls receipt's line count, the
`c1-landed.txt` hash), not the record text.

### H3 No narrowing after landing — **defect** (severity high; same finding as C2.6)

§A1 and §A2 change only the seat count (15 → 16) and land before any candidate reading — fine.
§A3 changes an item condition (T1) while asserting it does not. The predeclaration commit
`cd631737` carries §A1 only; §A2 and §A3 land in `5e1649a` (15:14:18) bundled with the wave
spec, the dispatch and the probe receipt, so a reader re-deriving "was the amendment before any
reading?" has only the clock (probe 15:14:04, commit 15:14:18), not commit order. Both facts are
acceptable in themselves; the unmarked item-condition change is not.

### H4 Admission rule ("every claim verifies, no axis harmed") — **defect** (severity medium; C1.8)

C1's landing mutates the file that backs the round-59 operability capability with no regression
read; C2's landing mutates nothing else. So the "no axis harmed" half of the admission rule has
no instrument for the one real harm path this round has.

### H5 Attack-share arithmetic — **ambiguity** (severity low-medium)

Exact sentence (plan:219–220): "attack share 6/16 = 37 % (4/16 = 25 % on the addendum's literal
reviewer/critic/mutation-tester/labrat list)". The dispatch has 16 seats and **no labrat**
(`.ufo/waves/round-60/w1-dispatch.json` registry: 6 executor, 2 scout, 2 scribe, 1 reviewer,
1 critic, 1 mutation-tester, 1 sentinel, 1 connector, 1 revenger). On the literal list as seated,
three of its four roles exist → 3/16 = 18.75 % ≈ 19 %, not 25 %. The 4/16 figure is only right if
the revenger is counted as the labrat substitute — the mapping round 59 used and its spot-check
recorded as a "noted, not routed" imprecision, asking the lane to state which definition it uses.
A2 does not state it. Smallest repair: one clause — "revenger substitutes the refused labrat role
(round 59 precedent), so the literal list reads 4/16 = 25 %; without that substitution it is
3/16 = 19 %". The broad 6/16 = 37.5 % is correct as truncated to 37 %.

### H6 `final/` now holds pre-candidate artifacts — **ambiguity** (severity low)

`.ufo/waves/round-60/final/l1-probe.txt` is a pre-freeze probe, and I5 requires three more
receipts in the same directory to exist *in the measured tree* — i.e. they are pre-candidate by
construction. A directory named `final/` that cannot contain a reading of the final tree is the
D5/D6 provenance class in a new place. Smallest repair: each of the three receipts carries a
`measured=<revision|tree-hash>` line and the SCORECARD line quotes it, so "final" is a location,
not a claim.

---

## Smallest repairs the L1 can land before the candidate reading (ordered, none changes a target)

1. **A3 provenance (C2.6, C2.7, H3):** add "supersedes the §C2 T1 row" to A3 item 4; re-issue
   `final/l1-probe.txt` with the role-creation 500 and the role_id-only 200 under
   `bind=false`+CIDR, or relabel (b)/(c) "to be measured by the trial". Cite receipt lines.
2. **I1 guard field (C1.4):** declare `dead=<D>` and `dead seats=<D>` one field; the item match
   and the challenge read the same captured group.
3. **I6 anchor (C1.5):** state the anchor as the last `SCORECARD.md` line containing `75165a07`
   (correction's own quotation included), and correct plan:27's false evidence sentence.
4. **Guard applicability (C1.6):** the challenge rewrites only a field the checker resolved;
   otherwise `challenge=not-applicable` → guard=0.
5. **Battery additions (C1.8, C2.4, C2.5):** one r59-capability regression control
   (`plans/round-59-c2.sh` → 5); C2-F9 mutated approle selftest; C2-F10 bao-less selftest; the
   trial's own-source argv grep recorded in the receipt.
6. **Pre-freeze text (C1.7, C2.9, H5, H6):** name both BASE rows (diagnostic 7 / guard FAIL);
   define or drop C2's `guard`; state the labrat substitution; require `measured=` in the three
   `final/` receipts.

## What survives

- `value=7` at BASE is a true reading; the seven defects are real and unresolved.
- C2 is genuinely absent at BASE (rc 128, counter reads `value=0 … (absent)` rc 1), reachable in
  one round, and 4/5 of its mechanics are surfaces the lane has never executed.
- The two claims are on distinct axes and causally separable; no universal clause; no item passes
  on a do-nothing tree.

SEAT-STATUS: complete
