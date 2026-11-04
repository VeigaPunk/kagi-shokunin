# CriticClaims — round-33 build: frozen claims contract, routed items, frontier step

Seat: `CriticClaims` (leaf critic). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Frozen BASE: `76f4eeae7aa9af4dbb9423f5632b55791824253a`. Plan: `880824b1d3da5f70b2fe489a34fe866a47314672`
(`plans/round-33.md`, committed alone with `plans/round-33.controls.tsv`,
`plans/round-32.controls.tsv` and `.ufo/waves/round-33/controls/`).
Reviewed: the frozen plan as committed; both controls files; the pre-freeze gate bytes as built
(uncommitted live tree, `corpus/prefreeze-control.sh`); the C2 entries, registry rows, frontier
surfaces, round-33 lesson, QUALITY/QM34 and SCORECARD changes.
Method: read-only git from the lane; the plan's counting commands run once each; the ten NIST
URLs re-opened with `curl -fsSL --compressed` (no other network); no vault, `op` reference,
account or handler contact; no tools installed; scratch at
`/fast/scratch/hyaku/kagi-r33/CriticClaims` (removed after the review). All `git` calls name the
lane with `-C`; extractions were `git archive` into that scratch, never a checkout.

## Measurements actually taken

| # | command (exact) | result |
|---|---|---|
| 1 | `git -C <lane> archive 76f4eea \| tar -x -C <scratch>` then `test -e corpus/prefreeze-control.sh && echo 1 \|\| echo 0` | `0` (absent at BASE) |
| 2 | same extraction, `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md` | `72` |
| 3 | same extraction, `ls corpus/knowledge/nist-*.md 2>/dev/null \| wc -l` | `0` |
| 4 | same extraction, `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md \| grep -c 'NIST'` | `1` |
| 5 | same extraction, `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=72 A=69 B=1 C=2 queued=1 mined=68 rejected=3 entries_sourced=10 legacy=21 captures=72 inrow=16 inrow_only=0 inrow_nonreproducing=12)` exit 0 |
| 6 | round-32 replay at `32c35fe` with the lane sweep: `bash corpus/self-description-sweep.sh --root <scratch32>` | `SD5=1`; final line `SELF_DESCRIPTION: MISMATCH n=8 (SD1=2 SD2=2 SD3=0 SD4=1 SD5=1 SD6=2)` |
| 7 | live C1 receipts (`.ufo/waves/round-33/build/prefreeze-33.txt`, `prefreeze-32.txt`, `prefreeze-selftest.txt`; read, not re-run) | `PREFREEZE: CLEAN (controls=4 mismatch=0)` exit 0; `PREFREEZE: MISMATCH (controls=2 mismatch=2)` exit 1 with `sd5 expect=3 measured=1`, `total expect=10 measured=8`; `PREFREEZE_SELFTEST: PASS (10 cases)` exit 0 |
| 8 | live C2 counts | `ls <two named entries> \| wc -l` → `2`; rows → `82`; README `## Frontier` NIST lines → `0`; lane census → `SOURCES_CENSUS: CLEAN (rows=82 A=79 B=1 C=2 queued=1 mined=78 rejected=3 entries_sourced=12 legacy=22 captures=82 …)` exit 0 |
| 9 | `.ufo/waves/round-33/final/c1-captures-red.txt` (read) | `MISMATCH captures expect=101 measured=72`; `PREFREEZE: MISMATCH (controls=1 mismatch=1)` exit 1 |
| 10 | `grep -n 'NIST_CORE' corpus/lessons/round-33.md SCORECARD.md .ufo/waves/round-33/final/*` | no match — the C2 predicate sentence is not in the lesson Gate or any final receipt |
| 11 | `grep -n 'NIST leads stay leads' PROVINCE.md`; `sed -n '124,145p' corpus/SOURCES.md`; `grep -n 'Held core since round 33' corpus/README.md` | PROVINCE line 90 keeps "the NIST leads stay leads"; SOURCES §Leads lines 129–130 keep both NIST leads and line 139–140 says "SP 800-133 Rev. 3 stays a lead"; README line 97 says "the frontier list holds release clocks only" |
| 12 | `grep -n 'latest first-working round' SCORECARD.md` vs `grep -n '^| pre-freeze BASE control execution' SCORECARD.md` | prose says `29`; the new capability row says `33` |
| 13 | NIST re-open, 2026-11-04: `csrc.nist.gov/pubs/sp/800/57/pt2/final` and `pt3/final` | pages print `Withdrawn on May 23, 2019` / `Withdrawn on January 22, 2015` and `Superseded by SP 800-57 Part 2 Rev. 1` / `Part 3 Rev. 1`; the 2005/2009 PDFs open with `Withdrawn NIST Technical Series Publication` / `Archived NIST Technical Series Publication` |

The live tree is the L1's work-in-progress, not the frozen contract; it is used here only as the
measurement the contract's own predicates choose. No lane-tracked file was written by this seat.

## (a) C1 — capability acquisition: `corpus/prefreeze-control.sh`

**Capability, not a self-referential echo.** The gate takes a controls file
(`id<TAB>expect<TAB>command`), extracts the named revision with `git archive`, runs each command
in that extraction with `BASE`/`LANE` exported, reads the last non-empty stdout line's final
integer and compares it with the declared `expect`. The verdict is not the declaration restated:
the round-32 controls carry the round-32 plan's own frozen estimates (`SD5=3`, `total=10`) and
the command measures the delivered counter's values (`SD5=1`, total `8`). My own replay at
`32c35fe` printed exactly `SD5=1` and `n=8`, independent of the live gate; the committed
round-32 lesson (`M32-2`) and the non-author spot-check (§2 C1) record the same two numbers.
The live red-witness receipt prints `MISMATCH (controls=2 mismatch=2)`, exit 1. The gate can
fail, and it fails on the class the plan names.

**Do-nothing control holds.** At `76f4eea` the artifact is absent (`test -e` → 1), the
capabilities count is 0, and the four targets (a)–(d) are unreachable without the artifact.
Leaving the tree alone keeps the artifact absent; the target is not reachable by
re-describing the tree. The live tree's three receipts meet (a)–(d): CLEAN 4/0 exit 0,
MISMATCH 2/2 exit 1, `PREFREEZE_SELFTEST: PASS (10 cases)` (≥8), capability row 33 in the
table.

**The red witness is genuinely M32-2, not a fixture dressed as one.** The `expect` values are
copied from the *frozen* round-32 plan text (`SD5` = 3; `BASE sum = 10`), not invented in round
33; the measured values come from the round-32 delivered sweep run against the round-32 BASE
tree; the round-32 lesson and spot-check independently record 1 and 8. The controls file is a
re-expression of a real frozen estimate, not a synthetic mismatch. The mismatch is reproducible
today because the sweep script did not change after round 32 (`git log 32c35fe..HEAD --
corpus/self-description-sweep.sh` → the single round-32 commit).

**Caveat, not a break of C1:** the four controls (`nist_entries`, `registry_rows`,
`prefreeze_artifact`, `frontier_nist`) are the declared set; the plan's own C2 `captures=101` is
*outside* it. The gate's predicate sentence says "every declared BASE value", but the script's
declared set is the controls file, and the plan did not put its census value there. The gate
would have caught the plan's own error if the row existed — the live `c1-captures-red.txt`
prints `MISMATCH captures expect=101 measured=72` — which is the strongest evidence that the
capability is real and that the *application set* was incomplete. That incompleteness is
reported under (c); C1's own targets are met.

**VERDICT: HOLDS**

## (b) C2 — coverage/expansion: NIST key-management frontier → core

**The row count is coverage, not bookkeeping.** The ten rows are ten distinct published
documents/editions (SP 800-57 Part 1 Rev. 5; SP 800-133 Rev. 3 IPD and Rev. 2; SP 800-57 Part 2
and Part 3 pages and PDFs; Part 2 Rev. 1; Part 3 Rev. 1; SP 800-131A Rev. 2), on ground the lane
did not hold (`corpus/knowledge/nist-*.md` = 0 at BASE). Each is used by one of the two named
entries; the live census's capture handshake passes (`entries_sourced=12`, `captures=82`). A
junk-row append would fail the entry count and the used-by handshake; the live rows do not.

**The entry count adds knowledge the lane did not hold.** The two entries carry facts absent
from BASE: Part 2/Part 3 are withdrawn (with the exact CSRC dates), Part 2 Rev. 1 and Part 3
Rev. 1 are the current revisions with DOIs, and SP 800-131A Rev. 2 is the transition reference.
The live withdrawal entry is *more* precise than the staged text: its headline is now "their
CSRC pages still print '(Final)'", and the body says the pages do carry a `Withdrawn on` field.
That is the correct reading of the live pages (measurement 13), and it fixes the staged
headline "the CSRC pages do not say so", which the live pages falsify.

**The refusal of `nist-key-management-family-status.md` is honest, not a dodge.** The staged
entry's Part 2 and Part 3 rows say `Final — "08/25/05…"` and `Final — "12/28/09…"` and its prose
says Part 2 "has not been revised"; the live pages say `Withdrawn on May 23, 2019` (superseded
by Rev. 1) and `Withdrawn on January 22, 2015` (superseded by Rev. 1), and the PDFs carry the
withdrawal wrappers. The refusal quotes the wrong rows and states the flip (a version with the
withdrawal date and the Rev. 1 successor). The two admitted entries are that flip in substance.
The `part2-part3-substance.md` deferral under the 1–3 entry cap is a deferral, correctly not a
reject.

**BROKEN — the frozen C2 target names a number no tree produces.** The plan declares BASE
`captures=101` and target `captures=111`. The lane census at `76f4eea` measures `captures=72`
(my run; the committed round-32 census receipt `rows=72 … captures=72`; the live `R21-02`
expected line before the migration already carried the measured value). Ten added capture rows
give `captures=82`, which is what the live census prints. The plan's `captures=101` has no
committed receipt behind it: the committed `.ufo/waves/round-33/controls/census-start.txt` is the
*fleet* validator's W04/`ok` output and contains no `entries_sourced`/`captures` totals; the
only lane-census receipt at round-32 close prints 72. The plan's own kill rule then fires:
"any of the four target readings unmet … → C2 not admitted and reported honestly", and the live
round-33 lesson does exactly that (Migrations row for `plans/round-33.md` §C2: "C2 is reported
not admitted under the kill rule because its fourth reading names a capture number the tree
cannot produce"; M33-3). The live SCORECARD post-move row, however, presents "the frozen
readings … `captures=82`" and `coverage 9 → 9` with "C2 … moves to core"; substituting 82 for
the frozen 111 is the post-data re-scope the plan forbids. The final report must keep C2 **not
admitted** and must not present 82 as the frozen reading.

**BROKEN — the frontier-to-core move is incomplete outside the two measured files.** The
discharged NIST bullet is gone from `corpus/README.md` `## Frontier` and from `PROVINCE.md`, and
the README `## Frontier` NIST count is 0. But:
- `corpus/SOURCES.md` `## Leads (unopened)` lines 129–130 still name "NIST SP 800-57 Rev. 5 final
  and Rev. 6 IPD publication status — leads only, not evidence" and "NIST SP 800-133 Rev. 3 IPD
  — lead only, not evidence"; the round-28 disposition at lines 139–140 still says "SP 800-133
  Rev. 3 stays a lead".
- `PROVINCE.md` line 90, the round-31 Core bullet, still says "the NIST leads stay leads", one
  line above the new round-33 Core bullet that says NIST is core.
- The live `corpus/README.md` line 97 says "the frontier list holds release clocks only", which
  is false while §Leads still lists NIST.
The C2 predicate's "the discharged Frontier bullet is gone from both files" is true for the two
Frontier bullets, but the C2 counting block measures only `corpus/README.md`; the §Leads list
and the PROVINCE stale clause are outside every counter. QM33's intent (a frontier-to-core move
removes the frontier entry) is met only literally, not across the lane's frontier surfaces.

**BROKEN — the counting command and the quoted metric are different instruments.** The plan's
C2 counting block names `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate
--root … kagi`, whose output is W04 warnings plus `kagi ok <path>` and exit 0; it never prints
`entries_sourced` or `captures`. The numbers the target quotes come from the lane's
`corpus/sources-census.sh` (my run prints them). The plan's "census exit 0 with
`entries_sourced=12` and `captures=111`" cannot be produced by the command it names. The live
work uses the lane census; the contract does not.

**Smallest fix:** one pre-data correction commit was required to make this claim admitted
(`captures` BASE 72 / target 82, and the lane census named); that window is closed because the
data exists. The smallest honest correction now is a lesson/report fix, not a re-scope: keep
C2 **not admitted** on the frozen `captures=111` (the live lesson already does), remove the
NIST entries from `corpus/SOURCES.md` `## Leads` and the round-28 "SP 800-133 Rev. 3 stays a
lead" sentence, edit `PROVINCE.md` line 90's "the NIST leads stay leads" clause old→new, and add
a `SOURCES.md §Leads` NIST counter (expect 0) plus the lane census command to the C2 counting
block and receipt. The SCORECARD post-move row must say "C2 not admitted; measured
`captures=82`; M33-3", not "frozen readings … `captures=82`".

**VERDICT: BROKEN: correct the C2 target/readings by the honest not-admitted verdict (no
substitution of 82 for 111), and close the frontier move in `SOURCES.md §Leads` and the
`PROVINCE.md` stale clause with a `§Leads` counter; name the lane census as the counting
command.**

## (c) Both — separability, axis harm, predicate/script/receipt identity

**Causal separability is conditional, not stated.** C1 verifies without C2: its three counting
commands run against `76f4eea`/`32c35fe` extractions plus the SCORECARD capability count; none
reads the C2 entries or rows. C2's four stated target readings also verify without C1 in the
live tree, but only because the live C1 entry (`corpus/knowledge/prefreeze-controls.md`) is
own-work with no `source:` line: `entries_sourced` stays 12 and `legacy` moves 21 → 22. The
plan does not state that classification; its C1 "Sourced claim" says the entry "cites
S072-class provenance", which, if written as a `source:` line, would make `entries_sourced=13`
and fail the frozen C2 target. The live `R33-02` ledger row states the own-work choice and
`legacy=22`, but the frozen plan's C2 "Census before" says `legacy=21` and its frontier step
says "Census after … `entries_sourced=12`" without the population change. The two claims are
therefore separable only under a classification the contract left open.

**C1's controls omit the C2 counter, so the round commits the class it claims to close.** The
round-33 controls file has four rows; `captures` is not one. The plan's own C2 BASE
`captures=101` is an unmeasured declared value in the same plan, the exact QM34 weak signal; the
live `c1-captures-red.txt` (`MISMATCH captures expect=101 measured=72`) shows the gate would
have caught it, and the live M33-3 records it. The plan's C1 predicate sentence "every declared
BASE value" overstates what the script can check: the script checks the controls file, not every
number the plan declares. The live `corpus/QUALITY.md` QM34 repeats the overstatement in its
first sentence ("A plan's declared BASE values are executed") while its mechanism sentence
correctly scopes to the controls file; the round-33 plan is its own red witness.

**C2's predicate is stated more broadly than its receipts measure.** The plan says "the
discharged Frontier bullet is gone from both files" — the counting command measures only
`corpus/README.md`. The plan says "every id they cite resolves in the registry as `mined`" — the
named fleet census does not parse entries; the lane census's `SC_ENTRY_CITE` does, and the plan
does not name it. The plan says the predicate is the "identical sentence in this plan, the round
lesson's Gate and the receipt label" — the live round-33 lesson's Gate contains the decision
table but no `NIST_CORE: CLEAN` sentence, and no final receipt prints `NIST_CORE`
(measurement 10); the receipts print `SOURCES_CENSUS: CLEAN`. C1's predicate sentence *is*
identical in the plan and the live script header; its verdict labels are the expected
`PREFREEZE:` lines. The asymmetry is real: the C2 label identity the plan promises does not
exist in the live record.

**Axis harmed: calibration.** The round's frozen C2 target is the same class (an unexecuted
BASE value) the round's C1/QM34 is built to prevent; the SCORECARD pre-move row copies
`captures=101`; the post-move row substitutes `captures=82` for the frozen `111`; the
capability-table prose now says the latest first-working round is `29` while the new row is
`33`; and the live lesson's Self-evaluation says "no in-place corpus rewrite" while the
Migrations table records the in-place `corpus/lessons/round-32.md` `captured-by` edit (R32-2).
None of these is a coverage harm — the ten rows and two entries are genuine — but each is a
calibration harm, and the C2 claim must be reported not admitted to keep the axis honest.

**Smallest fix:** one appended round-33 lesson correction (not a plan re-freeze) that (i) pins
the C1 entry's population effect (`own-work`, `legacy` 21 → 22, `entries_sourced` 12), (ii)
names the lane census and a `SOURCES.md §Leads`/`PROVINCE.md` frontier counter in the C2
measurement set, and (iii) carries the exact `NIST_CORE:` predicate sentence in the Gate and a
dated C2 receipt label; the SCORECARD post-move row must label `captures=82` measured and
`captures=111` frozen/unmet, not "frozen readings".

**VERDICT: BROKEN: pin the C1 entry's census classification and add the lane census plus the
`§Leads`/`PROVINCE` frontier counters to C2's measurement set; add the exact `NIST_CORE:`
sentence to the lesson Gate and a C2 receipt label; keep C2 not admitted.**

## (d) The frontier step — mistake mined, fix shown able to fail, routed items

**The fix is genuinely able to fail.** The live red-witness receipt and my independent replay
both give `sd5 3 → 1` and `total 10 → 8`; the gate prints `MISMATCH (controls=2 mismatch=2)`
exit 1 on `plans/round-32.controls.tsv` and `CLEAN (controls=4 mismatch=0)` exit 0 on
`plans/round-33.controls.tsv`; the selftest proves ten cases, including `NORESULT`, malformed
rows, a missing controls file and a timeout. The fix is not a disposition: it is a command with a
red witness.

**BROKEN — M33-1 as frozen restates round 32.** The plan's `Mistake mined: M33-1` is
"an unmeasured BASE expectation frozen as fact, and a plan target that counts an
author-inaccessible file". Both halves are already in `corpus/lessons/round-32.md`: M32-2
("unmeasured BASE expectation frozen as fact", with the same 3/10 vs 1/8 evidence) and M32-3
("counter includes author-inaccessible correction"). The plan's own evidence is the round-32
spot-check §2/§6; the replay reproduces the old mismatch. The only new element in M33-1 is the
gate. The round's *new* mistake is M33-3, which the live lesson records — "the round that builds
the pre-freeze control froze its own plan with an unmeasured census figure" (`captures=101`/
`111` vs measured `72`/`82`, the exact QM34 class) — but the frozen frontier step does not name
M33-3. So the frontier step's "Mistake mined" is a re-mine of round 32, while the genuinely new
mine is one row later. The plan's M33-1 should be framed as the R32-2 closure (the row-shape
defect: prose `captured-by` plus a disposition-fix) and M33-3 as the round's new mistake; the
live lesson already splits M33-1/M33-2 and adds M33-3, but the frontier step's text does not.

**BROKEN — R32-4 is repaired to a value that is already stale.** The plan says the stale
capabilities-prose sentence is repaired in the round-33 SCORECARD section. The live diff changes
"The latest first-working round in this table is 25" to "… is 29 (differential feed-token
agreement gate)" while the same diff adds a capability row with first-working round **33**
(measurement 12). The stale sentence is one row short again. The smallest fix is 29 → 33 (or
"the table's last row, round 33"), logged old→new; the round-33 section should not claim R32-4
closed while the sentence names 29.

**BROKEN — R32-5 and R32-2 contradict each other in the plan and in the live lesson.** The
plan's R32-2 handling says the round-32 lesson's M32-2/M32-3 `captured-by` cells are edited to
`QM34`/`none`; R32-5 says "note only; no in-place corpus rewrite this round" and "corpus
corrections are new entries; keep future citation labels in the appended corrigendum only". The
live work performs the in-place edit (`git diff HEAD -- corpus/lessons/round-32.md` shows M32-2
`QM34`, M32-3 `none`) and logs it in the Migrations table, but the live lesson's Self-evaluation
still says "no in-place corpus rewrite". The edit itself is the R32-2 fix and is correct; the
record contradicts itself. The smallest fix: the lesson's Self-evaluation should name the R32-2
cell edit as the single reviewed metadata migration, or the edit should be recorded in an
appended corrigendum per R32-5; do not leave both statements standing.

**Sourced claim check:** the frontier step's "Sourced claim: C2" is real in the live record:
the ten URLs were re-opened 2026-11-04, the live S076/S077 rows quote `Withdrawn on May 23,
2019` and `Withdrawn on January 22, 2015`, and the staged headline "the CSRC pages do not say
so" was corrected to "their CSRC pages still print '(Final)'". No unsourced claim was found in
the live Gate or entries. The *unsourced number* is the plan's `captures=101/111`, handled by
M33-3.

**VERDICT: BROKEN: reframe the frontier step's mined mistake as M33-3 (the plan's own
`captures=101/111` arithmetic, caught by the live census) with M33-1/M33-2 as the R32-2
closure; fix the R32-4 prose (29 → 33) and the R32-5/R32-2 record contradiction (name the
single reviewed metadata edit).**

## Routed items — status against the plan

| item | plan handling | result |
|---|---|---|
| R32-1 no planner seat | deviation recorded at freeze (§Routed items) | HOLDS — the plan records the standing topology; no planner seat is claimed |
| R32-2 Mistakes-row shape | QM34 lands; M32-2/M32-3 `captured-by` → QM34/none | partly: live edit + QM34 landed, but the R32-5 "no in-place rewrite" statement contradicts the edit (see (d)) |
| R32-3 S072 scope cell | narrow to `op --version`'s version token, log old→new | HOLDS — live S072 row reads "the version token `op --version` prints; the article's build number `#2410101` is not printed by the binary"; the migration is logged |
| R32-4 stale capabilities prose | repair in the round-33 SCORECARD section | BROKEN — repaired 25 → 29 while the table's last row is 33 (see (d)) |
| R32-5 note only | no in-place corpus rewrite this round | contradicted by the R32-2 cell edit; record or scope the exception (see (d)) |

## The two claims, cold

- **C1** is a real capability with a genuine M32-2 red witness and a valid do-nothing control. Its
  controls set is not exhaustive: the round's own C2 `captures=101` sits outside it, and the
  live `c1-captures-red.txt` shows the gate would have caught it. The C1 target readings are met.
- **C2** is real coverage — ten new source documents, two entries, a correct family-status
  refusal — but the frozen target's `captures=111` is unreachable (measured BASE 72, after 82),
  so the plan's own kill rule makes it **not admitted**; the live lesson says so, and the
  SCORECARD/lesson must not substitute 82 for the frozen 111. The frontier move is also
  incomplete in `SOURCES.md §Leads` and in the `PROVINCE.md` stale clause.
- **Separability** is conditional on the C1 entry being own-work (`legacy` 21 → 22, not
  `entries_sourced` 13); the plan does not pin that classification.
- **The frontier step's fix is able to fail**, but its `M33-1` re-mines round 32; the round's new
  mine is `M33-3`, and the routed R32-4/R32-5 records are inconsistent.

**BROKEN items: (b), (c), (d).** The smallest fixes above are ordered to be applied before the
L1's final report; none changes a frozen predicate or counter, and none re-scopes a claim. The
plan's `captures=111` stays on the record as the unmet target it is.

*Seat note: no tools installed or upgraded; no vault/`op` reference/account/handler contact; the
ten NIST URLs were the only network reads; scratch removed after the review; this report is the
seat's only lane write.*
