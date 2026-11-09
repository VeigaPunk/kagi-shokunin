# R69Connector — sibling-overlap scan and fleet dead-receipt sweep (round 69, w1)

Seat: `R69Connector`, section-8 adversary (connector). Lane
`/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE `264917aa`, frozen plan
`plans/round-69.md` (`adb69726`) read first and not amended.
**Read-only on every production file**: the only paths this seat wrote are this
report and `.ufo/waves/round-69/w1/R69Connector/` (receipts). No sibling lane
file was edited, no fleet-root file written, no git/jj mutation run, no agent
dispatched. Scratch `/fast/scratch/hyaku/kagi-r69/R69Connector` deleted at exit
after copying receipts.

**Axes named before measuring.** Primary: `adjacency` (judged axis of this
seat). Secondary, because the finding lands on them: `operability` (C2's
surface) and `calibration` (C1's surface). Every claim below is a measurement
or a source-level read; anything unexecuted is marked `[READ, NOT EXECUTED]`.

## 0. Verdict in one line

No sibling lane holds kagi's C1/C2 instruments; the nearest neighbours are
tsukuroi's `check-appended-notices.py` (class a) and `check-cited-receipts-r62.py`
(class c), both **complements on a different surface**. The one non-obvious move
this round should take is not a new instrument: the lane already owns a
dead-citation gate (`corpus/claim-ledger.sh citations`) whose **line-scoped
dead-label rule** the L6 landing text must satisfy, or the round's own repair
adds a fifth unresolved token to a gate that already reads BROKEN at BASE.

## 1. Class (a) — append-only / supersession that names the superseded text and its receipt

| lane | path:line | one-line quote | relation to kagi C1 |
|---|---|---|---|
| tsukuroi | `tsukuroi-shokunin/tools/check-appended-notices.py:5-6` | "proves the declared bytes, append boundary, notice section, and cited capture line" | **COMPLEMENT** (nearest precedent, stronger on one axis) |
| tsukuroi | `…check-appended-notices.py:277` | `NOTICE-CONTENT … "notice section lacks " + ",".join(missing_content)` — the notice body must contain the record's `now` **and** its `capture_ref` | a correction must carry its receipt *inside the notice text*; kagi L3/L4 only requires the receipt path to exist |
| tsukuroi | `…check-appended-notices.py:291`, `:308` | `NOTICE-CAPTURE-MISSING` "cited capture absent at target revision"; `NOTICE-CAPTURE-QUOTE` "capture_quote is not an exact substring of cited line" | receipt existence **and** line-level byte binding — stronger than kagi L4/L5's "receipt exists, value parsed" |
| tsukuroi | `…check-appended-notices.py:258` | `STALE-UNFLAGGED` "{rid}: old quote is present and notice heading is absent" | the same M69-1 rule kagi freezes this round, enforced per record |
| kumitate | `kumitate-shokunin/.ufo/waves/round-47/quality/q35-append-only.sh:5-6` | "A correction is a new row whose `teaches` opens `supersedes S0NN —`" | **COMPLEMENT** (broader surface, weaker axis) |
| kumitate | `…q35-append-only.sh:16,143` | `Q35 rewritten=<n> removed=<m> base=<full-sha> tip=<full-sha>` | cell-level append-only diff of a registry row; `grep -c receipt` on the script → **0**, so it never requires the correction to name a receipt |

Duplicate test: none is a duplicate. tsukuroi's gate reads a **JSON registry of
97 records** (`corpus/knowledge/freshness-recheck-r18.json`, `records` length 97,
keys `schema|baseline|records`) against a **baseline/target git revision pair**; kagi's L3/L4/L5
derive the correction requirement from **the measured tree's own bytes** with no
registry and no revision argument. Same rule, disjoint mechanism and disjoint
scope (one lane's own historical notices vs another lane's tree-derived legs).
The diff is a real capability gap on both sides and it is named, not absorbed:
kagi's L4 parses the count from the receipt (tsukuroi's cannot — its records are
author-declared), while tsukuroi binds the receipt **line** and an exact quoted
substring (kagi's L4 does not).

## 2. Class (b) — a claim-ledger row whose expectation is executed through the gate's own runner

| lane | path:line | one-line quote | verdict |
|---|---|---|---|
| tameshi | `tameshi-shokunin/tools/ledger-witness.py:24,27` | "W_MAT the trace shows a successful `git ... show REV:PATH` execve per leg"; "W_EXEC every defect's mutant path was exec'd by the leg's interpreter" | **COMPLEMENT** — executed-not-text-matched, but on a mutation runner's leg ledger, proven by `strace` kernel observations |
| tameshi | `tameshi-shokunin/tools/evidence-disposition.py:10-11,181` | "It never executes receipt argv." | **NEGATIVE HIT** — the explicit boundary kagi C2's `ledger` leg crosses |
| tameshi | `tameshi-shokunin/tools/command-binding.py:10` | "Source-read counts, held flags and filenames never establish execution." | **PARTIAL** — binds argv/cwd/revision/exit/stdout of *retained* receipts; does not run them |
| kasegi | `kasegi-shokunin/corpus/instruments/r-defect-closure.sh:26-38` | "`.ufo/waves/round-34/c1-controls/fake-suite.sh` prints the same `closed=9/9 exit=0` line … the discriminator is the per-case evidence" + `:556` "It proves its discriminator twice on forged reports" | **COMPLEMENT** — same surrogate-killer shape C2(d) needs (constant-verdict / do-nothing control plus self-judging reparse), applied to nine routed defects |

No sibling holds a **claim-ledger row executed by the ledger's own runner**.
Measured: `grep -rn 'claim-ledger\|CLAIM_LEDGER'` outside the lane hits only
fleet report text (`.ufo/l0-questions.md:265,327,368`, `.ufo/reports/...`), no
lane script. kagi's C2 `ledger` leg is therefore **not duplicated anywhere**;
the class's only real precedent is tameshi's kernel-witness, which is the
stronger form of the same idea on another object.

## 3. Class (c) — dead-citation sweep for `.ufo/waves/*/final/*`

| lane | path:line | one-line quote | relation to kagi C1 L6 |
|---|---|---|---|
| tsukuroi | `tsukuroi-shokunin/tools/check-cited-receipts-r62.py:12-15` | "every `.ufo/waves/round-<N>/...` path named by any tracked text blob at that revision must exist as a blob in the SAME revision's tree … `CITED-RECEIPT-MISSING`" | **NEAR-DUPLICATE mechanism, COMPLEMENT surface** |
| tsukuroi | `…check-cited-receipts-r62.py:32-34` | "Only `.ufo/waves/round-<N>/` citations are checked. Fleet-repo surfaces (`.ufo/reports/`, …) live in another repository and are out of scope here by construction." | the D6 citation lives **in that excluded set** — `cf4e3e1b:.ufo/reports/round-68/kagi.md:106` |
| kasegi | `kasegi-shokunin/corpus/instruments/resolve.py:6-7` | "`<root>/SKILL.md` plus `<root>/corpus/**/*.md`" | **COMPLEMENT** — whole-corpus backticked-path resolvability census; `.ufo/` outside its scope |
| **kagi (own)** | `kagi-shokunin/corpus/claim-ledger.sh:36-42,48,777` | "`.ufo/…` (this lane's own `.ufo/` first, then the main-repo tree …)" / "a dead citation must be labelled dead where it is cited" / docs set = root docs + `corpus/knowledge/*.md` + `corpus/lessons/*.md` | **DUPLICATE SURFACE for the lesson half of L6** — the instrument already exists in the lane and is self-tested (`:1682` `cite-marked` expects `labeled=1`) |

The three sibling rows are source reads (`[READ, NOT EXECUTED]`, §8); the kagi
row is executed, and its readings are in §5.

Consequence for the plan's L6 (see §5): L6's landing text is *inside* kagi's own
citations docs set, so the new sentence is measured by an owned gate the moment
it lands. Nothing in the frozen predicate forbids satisfying it — the plan asks
only that the lesson "names the dead citation … and the corrected pointer".

## 4. Carried `ADJACENCY_SCOPE: DEFECT` breadth debt — measured, not absorbed

```
$ cd /home/vgpnk/Projects/shokunin/kagi-shokunin && bash corpus/scope-gate.sh; echo RC=$?
BREADTH_AUDIT: DEFECT (required=4 pins=4 checked=3 ok=0 children=125 declared=2 undeclared=123 missing=0 invalid=0 drift=5 exceeds=0 unverified=1)
ADJACENCY_ABSTAIN: rows=15
ADJACENCY_ASSET_ABSENT: rows=18 (asset rows: surface-census.sh owns the GONE verdict)
ADJACENCY_SCOPE: DEFECT (census=35 owned=27 shared=8 groups=4 owners=4 unresolved=1 contested=1 escapes=0 inbound=0 foreign=0 orphans=0 stale_basis=0 basis_escape=0 own_unlisted=0 breadth_required=4 breadth_pins=4 breadth_checked=3 breadth_ok=0 breadth_missing=0 breadth_invalid=0 breadth_drift=5 breadth_exceeds=0 breadth_unverified=1)
RC=1
```
receipt `.ufo/waves/round-69/w1/R69Connector/scope-gate-base.txt`. Debt carried
this round: `breadth_drift=5`, `breadth_unverified=1`, `unresolved=1`,
`contested=1`, `breadth_checked=3/4`, `breadth_ok=0`. The three class-(a)/(b)/(c)
hits above are **new rows of the same debt class** and are reported, not folded
into kagi's adjacency table by this seat.

## 5. Proposed move (one, bounded) — "label the dead token where it is cited"

**Evidence (measured at BASE, this seat's own runs):**

```
$ bash corpus/claim-ledger.sh citations --docs corpus/lessons/round-68-verifier-spotcheck.md; echo RC=$?
UNRESOLVED corpus/lessons/round-68-verifier-spotcheck.md:58 .ufo/waves/round-68/final/c1-base.txt (ufo)
UNRESOLVED corpus/lessons/round-68-verifier-spotcheck.md:202 /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-68/w1-results.json (sibling)
UNRESOLVED corpus/lessons/round-68-verifier-spotcheck.md:290 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md (sibling)
UNRESOLVED corpus/lessons/round-68-verifier-spotcheck.md:346 .ufo/waves/round-68/final/c1-base.txt (ufo)
CITATION_GATE: BROKEN (cites=44 docs=1 unresolved=4 ephemeral=1 labeled=0)
RC=1
```
receipt `…/R69Connector/cit-spotcheck-lesson-base.txt`. Fixture control (same
gate, two documents differing only by a marker word, receipt
`…/citfix-unmarked.txt` / `…/citfix-marked.txt`):

```
unmarked.md:1  Dead citation: `.ufo/waves/round-68/final/c1-base.txt` behind the BASE row.
  → UNRESOLVED unmarked.md:1 … ; CITATION_GATE: BROKEN (… unresolved=1 …) ; RC=1
marked.md:1    Dead citation: `.ufo/waves/round-68/final/c1-base.txt` (no longer present; corrected pointer `.ufo/waves/round-68/final/c1-candidate.txt`).
  → LABELED marked.md:1 … (unresolved, labelled on its line) ; CITATION_GATE: CLEAN (… labeled=1) ; RC=0
```

**The move.** When the L6 sentence is written into `corpus/lessons/round-69.md`,
place the dead path on a line that carries one of the lane's existing dead-label
words (`claim-ledger.sh:650`: `scratch|ephemeral|relocat|formerly|no longer|
removed|renamed|historical`), keep the corrected pointer on the same line, and
record the marginal reading
`bash corpus/claim-ledger.sh citations --docs corpus/lessons/round-69.md` in the
round's L6 evidence. No predicate, population, kill rule or target changes; no
new instrument; L6's leg ("names the dead citation … and the corrected path
exists") is untouched.

**Why this and not something wider.** The alternative — repairing the two
round-68 spot-check lesson lines (`:58`, `:346`) — is a filed-lesson append-only
correction, needs the closure-lesson's own owner, and is out of this seat's write
scope; it is named here as routed debt, not done.

**Affected axes.**
- `adjacency` — the move consumes an existing owned instrument instead of
  duplicating tsukuroi's `CITED-RECEIPT-MISSING` mechanism on a third surface;
  the fleet-report half (`cf4e3e1b:.ufo/reports/round-68/kagi.md:106`) is where
  no lane or fleet gate exists (measured: `scripts/hyaku/prefile-falsification.py`
  only checks ledger-row `artifact` paths under `.ufo/waves/round-<N>/`, `:29`)
  and is left named as the ceiling. No harm: no statement of another lane is
  absorbed or edited.
- `operability` — gains an executed check (rc 0/1) through a runner the lane
  already owns and self-tests, at the cost of zero new code.
- `calibration` — the round stops *adding* a citation that its own record calls
  dead; the SCORECARD row can print a measured `labeled=` delta instead of a
  CLEAN claim the bytes do not support.

**Risks.**
1. `MARK_RE` is **line-scoped** (`claim-ledger.sh:795,813`, `marked` computed once
   per line): a label word anywhere on the L6 line labels every unresolvable token on
   it. Keep the dead token alone on its line; the corrected pointer
   `.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt` resolves, so it is safe
   co-cited but must not be the only content.
2. A label on a *live* token would hide a real defect; the label is only correct
   while the token is genuinely dead (it is: `git -C kagi log --all -- …` empty).
3. The label word must not leak into the frozen predicate text: the plan's L6
   sentence is the plan's; the label is landing-surface prose only.
4. Ceiling unchanged: no instrument here can vouch for the *fleet report's*
   authorship or repair the round-68 report bytes (filed, last-writer rule).

**Verification a reader can re-run** (all read-only, all receipts cited above):
`bash corpus/claim-ledger.sh citations --docs corpus/lessons/round-68-verifier-spotcheck.md`
(RC 1, `unresolved=4`); the two `citfix` runs (RC 1 → RC 0 with `labeled=1`);
`bash corpus/scope-gate.sh` (RC 1, `ADJACENCY_SCOPE: DEFECT … breadth_drift=5
breadth_unverified=1`); `git -C kagi-shokunin log --all --oneline --
.ufo/waves/round-68/final/c1-base.txt` (empty).

## 6. Contradictions, stated rather than smoothed

1. **`verify` ≠ `citations`.** C2's `ledger` leg runs
   `bash corpus/claim-ledger.sh verify`, which calls `verify_stamps`,
   `verify_claims`, `idref_audit` only (`claim-ledger.sh:1243-1262`) — it never
   calls `citations`. So the L6 text **cannot** falsify C2's `ledger` leg; it can
   falsify a different owned gate. Stated because the two claims are one round and
   the intersection is easy to mis-attribute either way.
2. **BASE already reads BROKEN on the doc that routes D6, while the round-68
   record's last citations reading was CLEAN.** The delta is the closure's own
   spot-check lesson, which *named* the dead path twice (`:58`, `:346`) without a
   label. Two further unresolved tokens in the same lesson are absolute host paths
   (`:202`, `:290`). None of the four is among the 13 routed defects, and the plan
   does not route them: they are **new, unclaimed record-surface defects** in the
   class this round exists to repair. This seat measured them and does not edit
   them.
3. **The plan's own citations of the dead path are invisible to the gate.**
   `plans/round-69.md:35` and `:74` name
   `.ufo/waves/round-68/final/c1-base.txt`; `plans/` is not in the citations docs
   set (`claim-ledger.sh:777`), so a CLEAN reading after this round would not mean
   those two tokens resolve. Do not read the gate line as covering the plan.
4. **Full-doc-set reading is not claimed — it did not complete.** The
   whole-docs run from this seat (`timeout 240 bash corpus/claim-ledger.sh
   citations`) was killed at the budget while still inside `SKILL.md`
   (`lane_RC=124`, receipt `…/R69Connector/citations-fulldocs-timedout.txt`),
   so the 49-doc `CITATION_GATE` reading at BASE is **unmeasured** here — the
   same budget ceiling round 68 hit (`w1/R68ScribeLesson/c2-lane-run.txt:6`). Only
   the doc-scoped reading above is a receipt, and it is sufficient for the move:
   the L6 sentence lands in `corpus/lessons/round-69.md`, a doc the gate scans.

## 7. Fleet-report dead-receipt sweep (`.ufo/reports/`, read-only)

Method: every `.ufo/reports/**/*.md` whose basename is `<lane>` is resolved
against `<lane>-shokunin`; each `.ufo/waves/<x>/final/<y>` token is checked with
`git -C <lane> log --all -- <path>`, with a lane prefix honoured when the token
carries one, and `git -C <other> cat-file -e HEAD:<path>` across all 20 lanes for
rescue. Receipts `…/R69Connector/fleet-report-dead-sweep.txt` (+ `-verdicts.txt`,
`sweep2.py`).

Counts: **1556 reports scanned, 145 citations, 122 distinct (lane, path) pairs,
3 dead pairs.**

| # | report path:line | lane path | verdict |
|---|---|---|---|
| 1 | `.ufo/reports/round-18/tabi.md:45` | `tabi-shokunin .ufo/waves/round-18/final/binding-at-{checkpoint,delivered}.json` | **NOT DEAD** — brace set; both alternatives present in HEAD (v1 regex truncated at `{`) |
| 2 | `.ufo/reports/round-20/kama.md:67` | `kama-shokunin .ufo/waves/round-20/final/AuditCase07.md` | **FOREIGN, DISCLOSED** — resolves in `souji-shokunin` (3 commits); the report itself calls it an untracked fleet-root stray about `souji-seat-audit`; the fleet root has no `.ufo/waves/round-20/final/` at all |
| 3 | `.ufo/reports/round-34/kagi.md:20` | `kagi-shokunin .ufo/waves/round-34/final/c1-*-final-producer.txt` | **NOT DEAD** — glob; both producer files present |
| 4 | `.ufo/reports/round-67/kagi.md:57` | `kagi-shokunin .ufo/waves/round-67/final/c1-*.txt` | **NOT DEAD** — glob; `c1-base.txt`, `c1-candidate.txt` present |
| 5 | `.ufo/reports/round-68/kagi.md:106` | `kagi-shokunin .ufo/waves/round-68/final/c1-base.txt` | **DEAD** — `git log --all` empty, HEAD `final/` holds only `c1-candidate.txt`, `c2-candidate.txt`, `l1-derivation-recut-only.txt` (the plan's D6 / L6) |

Honest rate: **1 true dead citation in 145 (0.7 %), and it is kagi's** — the
class the round repairs is fleet-wide rare and kagi-local on the fleet surface.
That is a narrowing of the round's premise worth stating: the defect class is not
diffuse; the *lane-internal* instance count is where the breadth is (4 in one
lesson, §6.2).

## 8. Dead ends measured (commands and outputs)

- **Per-lane `corpus/*.sh` inventory**: `for d in *-shokunin; do ls "$d/corpus"/*.sh; done`
  → **every one of the 20 siblings printed nothing**. Instruments live under
  `tools/`, `corpus/instruments/`, `corpus/evidence/`, `verifiers/`, and
  `.ufo/waves/<round>/quality|probe|build/`, so the first idea (compare kagi's
  `corpus/*.sh` family against a sibling family) has no counterpart surface.
- **`grep -rIl 'expect-journal|row-identity|claim-ledger'` outside kagi**: no lane
  script hit; only fleet report prose. `corpus/expect-journal.sh` and
  `corpus/row-identity.sh` are kagi-only.
- **audio-shokunin `corpus/live/r6*/ledger-*.tsv`**: not a claim ledger — 4-column
  receipt index (`seq, exit, run path, defect note`), and no script references
  them (`grep -rln 'ledger-r[0-9]*\.tsv'` empty). Not a class-(b) precedent.
- **chousa `corpus/evidence/round25-ledger-recount.py`**: recounts 71 registry
  rows and applies hard-coded closure sets from prose ("the closure sets are read
  from the addenda text, not parsed") — a text-adjacent recount, the opposite of
  class (b); rejected as a precedent.
- **`grep -rn 'final/'` over sibling instruments**: the only `final`-path logic is
  chousa's `ExecE4Census/receipt-binding.py` (round-34 wave spec:
  `.ufo/waves/round-34/gen-w1-spec.py:95`), which binds receipts to a *gate
  sha256*, not to existence — a different question, not a class-(c) precedent.
- **Sibling instruments were not executed** (write scope: a `--selftest` that
  writes anywhere in a sibling lane is a misroot). All class-(a)/(b)/(c) sibling
  verdicts above are source reads; the executed receipts in this report are kagi's
  own instruments run read-only.

## 9. Tooling

No installs, no upgrades, no pacman. Tools used: `bash`, `python3`, `git`
(read-only), kagi's own `corpus/scope-gate.sh` and `corpus/claim-ledger.sh`
(both read-only modes; neither accepts an output-path argument for the modes run,
and `git -C kagi-shokunin status --porcelain` after both runs lists exactly two
new paths from this seat — `.ufo/waves/round-69/w1/R69Connector.md` and
`.ufo/waves/round-69/w1/R69Connector/` — beside the round's other seats' and the
L1's files, none of them touched by this seat).

## 10. Finding lines for `.ufo/waves/round-69/claim-falsification.tsv` (one per line, command + observed)

```
F1  claim=C1  L6's landing text is inside kagi's own citations docs set; an unlabelled dead token fails it  |  cd kagi-shokunin && bash corpus/claim-ledger.sh citations --docs corpus/lessons/round-68-verifier-spotcheck.md  |  UNRESOLVED corpus/lessons/round-68-verifier-spotcheck.md:58 .ufo/waves/round-68/final/c1-base.txt (ufo); UNRESOLVED …:346 (same token); CITATION_GATE: BROKEN (cites=44 docs=1 unresolved=4 ephemeral=1 labeled=0); RC=1
F2  claim=C1  the label rule is the discriminator, proven on one fixture differing by two words  |  bash corpus/claim-ledger.sh citations --root <fix> --docs <fix>/unmarked.md ; same with marked.md  |  unmarked: UNRESOLVED → CITATION_GATE: BROKEN (unresolved=1) RC=1 ;; marked ("no longer"): LABELED → CITATION_GATE: CLEAN (cites=2 docs=1 unresolved=0 ephemeral=0 labeled=1) RC=0
F3  claim=C1  BASE is already BROKEN on the doc that routes D6; the four unresolved are not among the 13 routed defects  |  git -C kagi-shokunin show 264917aa:corpus/lessons/round-68-verifier-spotcheck.md | sed -n '58p;202p;290p;346p'  |  :58 and :346 cite .ufo/waves/round-68/final/c1-base.txt; :202 and :290 cite absolute host paths under /home/vgpnk/Projects/shokunin/kagi-shokunin/… ; none carries a MARK_RE word
F4  claim=C1  the plan's own two citations of the dead path are outside the gate's docs set  |  grep -n 'final/c1-base.txt' plans/round-69.md ; grep -n 'DOCS_LIST' corpus/claim-ledger.sh  |  plans/round-69.md:35 and :74 cite it; claim-ledger.sh:777 scans root docs + corpus/knowledge/*.md + corpus/lessons/*.md only → plans/ not scanned
F5  claim=C2  the L6 text cannot falsify C2's ledger leg: verify() never calls citations()  |  sed -n '1243,1262p' corpus/claim-ledger.sh  |  verify) verify_stamps; verify_claims; idref_audit — no citations call; summary CLAIM_LEDGER: CLEAN is independent of CITATION_GATE
F6  no claim (adjacency)  kagi C2's ledger leg has no sibling duplicate; nearest executed-not-text-matched precedent is tameshi's kernel witness  |  grep -rn 'claim-ledger\|CLAIM_LEDGER' <fleet> | grep -v kagi-shokunin | grep -v '^./.ufo/reports'  |  no lane-script hit (fleet report prose only); tameshi tools/ledger-witness.py:24,27; tameshi tools/evidence-disposition.py:10 "It never executes receipt argv."
F7  no claim (adjacency)  the carried breadth debt measured at BASE, not absorbed  |  cd kagi-shokunin && bash corpus/scope-gate.sh; echo RC=$?  |  ADJACENCY_SCOPE: DEFECT (census=35 owned=27 shared=8 groups=4 … breadth_required=4 breadth_checked=3 breadth_drift=5 breadth_unverified=1) ; RC=1
F8  no claim (adjacency)  the fleet-report dead-receipt class is kagi-local and rare  |  python3 sweep2.py over .ufo/reports/**/*.md (receipt …/fleet-report-dead-sweep.txt)  |  reports_scanned 1556 citations 145 pairs 122 dead 3 ; one true dead (.ufo/reports/round-68/kagi.md:106 → kagi .ufo/waves/round-68/final/c1-base.txt), one foreign/disclosed (round-20/kama.md:67), one regex artifact (round-18/tabi.md:45 brace set, both files present)
```
