# K46CriticClaims — attack on the framing of round-46 claims (pre-candidate)

Seat: `K46CriticClaims` (leaf, no dispatch). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`,
BASE `f5977284a8ce5bab09252be8196ee5dc18489926`, predeclaration `44808ced56359c98f35995178fb24a6482899263`.
Read-only everywhere except `.ufo/waves/round-46/build/K46CriticClaims*` and
`/fast/scratch/hyaku/kagi-r46/K46CriticClaims/`. No lane counter, no `claim-ledger.sh verify`, no network, no
candidate exists. Every number below is either a file:line pointer or a command I ran; commands and their last
lines are in §7 and the copied receipts.

**Subject of the attack.** Not the work (none exists) but the *framing*: axis names, causal separability, cheap
and do-nothing controls, whether C2 is drift detection or bookkeeping, S098's binding semantics, the
stagnation-nudge reading, and the held instruments C2 will land on top of.

**Verdicts in one line each.**

| # | attacked | verdict |
|---|---|---|
| 1a | C1 = `operability` (not calibration) | **HOLDS** on the §9 surface test; the plan's own gloss ("instrument move") is the defect (D-1) |
| 1b | C2 = `freshness` (not calibration) | **HOLDS**; the surface with the mass is 29 clock rows re-observed, and freshness is the axis *defined* as re-verification |
| 2 | C1/C2 causally separable | **HOLDS at the counter level** (disjoint reads, receipts in §7); the written separability sentence is materially false about scope (D-2) |
| 3 | cheap control reaches either target | C1: **no** — value 3 needs the leg executed; the declared ceiling is mis-sized in the safe direction (D-4). C2: **yes, at the target** — a date-shifted replay of the round-36 receipt scores 29 and survives the covering leg for 10 of 29 rows (D-3) |
| 4 | C2 freshness or bookkeeping | **both, and the predicate only sees the bookkeeping half**: `DEFAULT` and `PINNED` are one computation over one candidate-authored file, and the gate has no recency rule at all (D-5) |
| 5 | S098 binding semantics | feasible and offline-checkable, but it makes the headline 29 include a REJECTED row with no teaching to drift, and the freeze forbids the structural fix (D-7) |
| 6 | stagnation-nudge reading | facts check out; the *use* of the waiver is wrong — it is unnecessary and its directive is declined (D-9) |

---

## 1. Axis naming (§9 / AXES.md)

Rule text. `scripts/hyaku/lane-addendum.md:425`: "Name the axis by the surface the round changes, not by the
number it produces (kaidoku r29)"; `.ufo/waves/hyaku/PHASE4.md:78` carries the same rule with "re-scoring a held
rule or counting rows a sourceless fixture counts is quality, never coverage or depth". `AXES.md` operability =
"Runnable artifacts: checklists that are executable, commands that exist, scripts that run | A checklist item can
be run and produces the stated outcome"; freshness = "Drift detection — skill claims re-verified against live
surfaces; stale items flagged or fixed | Each round LOG entry includes a re-verification result"; calibration =
"Self-assessment quality: gaps named honestly, confidence graded, overreach caught".

**C1 — operability holds.** Surface changed = the `--run-selftest` block of `corpus/claims-declared.sh`, i.e. a
runnable artifact whose stated outcome is a kill verdict. Precedent is the lane's own: round-40 C3 graded gate
self-tests operability and the capability row "gate self-testing with committed expected findings" (first working
round 40) is the instrument; round-43 C3 graded selftest plumbing operability (`SCORECARD.md:1614-1630`). The
competing reading (calibration, because the *fixture's subject* is a false declaration) loses on §9's surface
test: the bytes changed are the selftest block, not the gate's claim-checking logic — which is what round 45's
C1 changed and correctly called calibration.

**C2 — freshness holds.** The surface with the mass is `corpus/release-clocks.tsv` (29 rows re-dated and
re-versioned from a live receipt) plus the receipt itself: re-verification against live surfaces, the AXES
sentence for freshness. The counter's `DEFAULT`/`PINNED` conjuncts are instrument repair (operability-flavoured),
but they are two of five fields in the predicate, not the measured surface; naming freshness by them would be
naming the axis by the instrument rather than the surface.

### D-1 — C1's own gloss contradicts its label, and the label is the one under test

Evidence. `plans/round-46.md` §Axes: "C2 works the lane's owned freshness axis; C1 is an instrument move on a
gate the lane already holds." "Instrument move" is the calibration vocabulary this lane used in round 45 for the
*same file* (`SCORECARD.md:1676-1687`, "[C1] calibration"), so a reader of the plan sees the same bytes labelled
calibration last round and operability this round with only a phrase to separate them.
Rule. `lane-addendum.md:425` (surface, not function); `AXES.md` operability's second column.
Remedy (no frozen target touched). Replace the clause in the round **report** with the surface sentence: "the
surface changed is `corpus/claims-declared.sh`'s `--run-selftest` block; the gate's claim-checking logic is
untouched, so this is a runnable-artifact move (operability), not a re-score of the round-45 calibration move."
The frozen plan is not edited; the report carries the clarifying sentence and the lesson records it.

---

## 2. Causal separability

Measured. `grep -cE 'release' plans/round-46-c1.sh` → 0; `grep -cE 'claims' plans/round-46-c2.sh` → 0 (§7). C1
reads the claims manifest, plans and SCORECARD under `--run-selftest`/`--root`; C2 reads
`release-clocks.tsv`, `release-clock.py`, `source-fetches.tsv`, `SOURCES.md` and the receipt. Neither counter
reads the other claim's files, and both reach their targets from BASE + own change (K1-P / K2-P in
`.ufo/waves/round-46/controls/controls-prefreeze.txt`). Separability **holds** as AXES.md requires.

### D-2 — "C2 touches only the release-clock surface" is false as written, and the omissions are the expensive ones

Evidence. `plans/round-46.md` §Causal separability: "C1 touches only `corpus/claims-declared.sh` ...; C2 touches
only the release-clock surface (`corpus/release-clock.py` default receipt binding and help text,
`corpus/release-clocks.tsv`, the round-46 receipt, and SKILL.md lines that describe the default receipt)."
Two edits outside that list are forced: (a) `SKILL.md` is stamped — `corpus/stamps.tsv` pins it (1 row), so the
SKILL edit demands a `claim-ledger.sh stamp` re-pin or `STAMP_DRIFT` goes red (round 45 needed the same, 6
re-pinned rows); (b) M46-1's own fix adds a `corpus/claim-ledger.tsv` row. `SKILL.md:48` and `SKILL.md:787` both
name the round-36 default, so the SKILL edit is two table rows, not a phrase.
Rule. AXES.md "claims must be causally separable"; the round's own surface sentence is the register a closure
diffs against.
Remedy. Restate in the report: "claim surface = the four named release-clock artifacts; round bookkeeping the
claim forces = `corpus/stamps.tsv` (SKILL re-pin) and one `corpus/claim-ledger.tsv` row (M46-1)." Then the harm
check sees an expected diff instead of an unreported one. §5/D-10 shows the same sentence's ledger consequences
are not merely cosmetic.

---

## 3. Cheap and do-nothing controls

### D-3 — C2's target is reachable with no fetch, and for 10 of 29 rows the declared covering leg cannot see it

Evidence. The plan names the ceiling: "K2-F4 hand-written receipt with fake digests → 29 (**ceiling**)" and
"the non-author live re-observation is the leg that can; **feed clocks only** (page digests are volatile)"
(`plans/round-46.md` §C2, §Declared ceilings). Two facts make that ceiling wider than stated:
(a) `corpus/release-clock.py:475-506` (`receipt_matches`) compares the receipt *to the tsv*, both
candidate-authored, on `verdict`, `observed_at` date and, for feed clocks, `parsed_version`; the receipt's
`sha256` only has to be 64 hex — it is bound to no committed body. So a receipt that **copies the round-36
records and rewrites only `observed_at`** to 2026-11-06 passes the gate (`receipt_date == tsv observed_at`) and
`FRESH` (`http_status` 200, 64-hex, date ≥ 2026-11-06, date == tsv date) → **value 29, zero network**, and it is
strictly harder to spot than K2-F4 because every digest and version is a real one. The covering leg compares
**parsed versions** on feed clocks and therefore *agrees* whenever no release happened in the interval — the
leg cannot see a date-only forgery.
(b) `plans/round-46-c2.sh` ON29 decomposes as **18 feed + 10 rendered-quote among S005–S032**, plus S098
(quote clock by the plan's preference) → **19 feed / 10 quote** (measured: `awk -F'\t' '$2=="rendered-quote"'` →
S005 S006 S007 S017 S018 S019 S020 S030 S031 S032). A rendered-quote clock has no version at all
(`receipt_matches`, render branch: `parsed_version is None`, `located` bool), so the feed-only covering leg
leaves 10 of the 29 rows with **no independent witness of any kind** — not a weaker one.
Rule. AXES.md "Each round LOG entry includes a re-verification result" (the 10 quote rows' result is
self-attested); the plan's own ceiling sentence.
Remedy (no frozen predicate changed). (i) The report states the composition — 19 version-bearing rows, 10
quote-only rows — and names the date-shift replay explicitly as a *control that was run and scored 29*, so the
number is read with its width. (ii) The existing non-author leg is widened in the record, not in the counter:
for the 10 quote rows the reviewer re-opens the page and locates the declared capture quote (`LOCATE_PROFILES`,
`release-clock.py:376`), and for S098 it compares the receipt `sha256` to the committed body
`.ufo/waves/round-41/capture/S098.body` (sha256 `68e34b8a…8c70d`, 199607 bytes — verified equal to the
`source-fetches.tsv` cell). (iii) Route "bind receipt digests to committed captures" to round 47 with its own
counter.

### D-4 — C1's declared ceiling is mis-sized: byte-keying reaches 2, not 3; and the numerator `3` is one test case

Evidence. Ceiling text: "a self-test that recognises the mutants by some other byte property than the lines
E2–E4 rewrite is not refused by the counter". Measured against `corpus/claims-declared.sh` and the counter's sed
programs (`plans/round-46-c1.sh:66-73`): a byte test that greps `no-manifest-row` survives E3 (`${rname}
${hclaim}` keeps the token) and kills M1; a byte test that greps `if ! awk -v want=` survives E4 and kills M3; a
byte test that survives E2 (`-lt 39` → `-le 38`) cannot distinguish M2 (`-lt 99`) from base without executing
the leg — the only byte forms that match base and M2 both also match E2 or kill nothing. So a pure byte
candidate reads **2**, never 3, and a candidate that reaches 3 has executed the leg. Conversely, one planted-
omission fixture at round 90 kills **all three**: the selftest fixture already carries `## Round 90 — post-move`
in its SCORECARD (`claims-declared.sh` `mfix`), 90 < 99 kills M2, the post-move section present kills M3, and the
missing-row token kills M1.
Rule. §9 "name the axis by the surface" applies to the number here: the surface is *one case*, and the plan
reads "0 → 3" as three instrument increments.
Remedy. Report sentence: "one planted-omission case (round 90 fixture) kills three mutations of one leg; the
diff review's byte-key ceiling is reachable only to 2/3 (M1, M3) — M2 requires the leg to run." No target change;
it stops the closure from both over-crediting and needlessly discounting a legitimate 3.

---

## 4. C2: freshness or bookkeeping

### D-5 — `DEFAULT` and `PINNED` are one computation over one candidate-authored file; the gate has no recency rule

Evidence. `corpus/release-clock.py:545-547` (`receipt_path` default), `:28` (`DEFAULT_RECEIPT_SHA256 =
3f611eec…`), `:2136-2140` (default path + default digest when `--receipt` is absent). The candidate is required
to repoint both to `.ufo/waves/round-46/final/observe-r46.json`; `plans/round-46-c2.sh` then runs `DEFAULT` as
`gate` (no args) and `PINNED` as `gate --receipt "$RECEIPT" --receipt-sha "$RSHA"` where `RSHA` is the sha256 of
that same tree file. Post-candidate the two legs are the identical `evaluate()` call on the identical bytes, and
`PINNED` cannot fail while the file is well-formed because the counter computes the digest it then supplies.
More: `evaluate()` (`release-clock.py:552-713`) has **no age term** — `receipt_matches` compares `observed_at`
for equality with the tsv, nothing else; the selftest's "stale receipt recapture" case (`:1865-1920`) tests
"observe writes a new file and never rewrites the TSV", not recency. Therefore at BASE the gate's redness was
purely structural: `observed=28` of 28 bound rows already matched a **two-day-old** receipt
(`.ufo/waves/round-46/controls/gates-base.txt`: `FAILED (on_release=29 bound=28 unbound=1 observed=28 fired=13
derived=15)`, errors `ORPHAN S040/S041`, `RECEIPT-MISMATCH S040/S041`, `UNBOUND S098`).
Rule. Frozen predicate `C2_FRESH_CLOCKS: DEFAULT = CLEAN and PINNED = CLEAN and KEPT = 1` reads as three
independent requirements; AXES.md freshness requires *re-verification*, not a consistency repair.
Remedy. Report sentence: "`DEFAULT` ⟺ `PINNED` once the default path/digest is repointed (same file, same
digest), and neither leg tests recency; `CLEAN` certifies that registry rows, clock rows and one receipt agree
with each other. The freshness content of this claim is `FRESH` (29 re-observed rows) plus the live observation
itself — not the CLEAN token." Keep both legs (they are the frozen predicate) but do not present them as two
checks.

### D-6 — "Fired clocks stay fired" has no measuring leg; a fired clock can be rearmed by hand and the counter still reads 29 + CLEAN

Evidence. `plans/round-46.md` candidate work: "Fired clocks stay fired: the observation reports them, it does not
rearm them." Nothing in `plans/round-46-c2.sh` tests a verdict, an anchor or a note: `FRESH` requires only
(on-release, one tsv row, one receipt record with 200 / 64-hex / date). `KEPT` is `all(i in cur for i in base)` —
**id presence only**, so in-place cell rewrites pass. The counterexample is mechanical: `observe_one`
(`release-clock.py:855-918`) derives the verdict from the row's own `anchored_version`/`observed_version` floors,
and `--observe` never writes the TSV (selftest asserts TSV immutability), so the ordering *edit tsv → observe*
produces a self-consistent `not-fired` receipt. Concretely S012 (`anchored v1.21.x`, `observed 2.2.1`, `fired`,
note `derived:`): set `anchored_version` and `observed_version` to `2.2.1`, and rewrite the one cell the gate
consults — `SOURCES.md` S034's anchor cell, whose located anchor must name exactly the derived version
(`derived_anchor_bound`, `release-clock.py:349`; S034 currently reads "Entry titled v2.2.0 …") — then observe;
gate: `verdict not-fired` + `anchor_ok` + no `REGRESSION`/`DERIVATION`; counter: `fresh=29, CLEAN`. Two real
fired clocks disappear from `fired=13` and nothing red appears anywhere.
Rule. The plan's own frozen candidate-work sentence (Fired clocks stay fired) and AXES.md freshness "stale items
flagged or fixed" — a rearm is a silent un-flag.
Remedy (no predicate change). The round's `measured-at-candidate` receipt must include
`git diff BASE..candidate -- corpus/release-clocks.tsv corpus/SOURCES.md` and the reviewer must refuse any
change to a `fired` row's `anchored_version`/`verdict` and any cell rewrite on the 29 ids (additions allowed).
Route the automated form — pin `anchored_version` for fired rows at BASE and extend `KEPT` to "cells unchanged" —
to round 47 with its own counter.

### D-7 — S098: the freeze forces a live clock on a REJECTED row and forbids the structural fix

Evidence. `corpus/SOURCES.md:105` S098 has 11 cells with `status = rejected`, a stated rejection ("UTS #18
defines \s as the Unicode White_Space set, which excludes U+001C-U+001F that `str.isspace()` accepts"), a flip
condition, and `recheck = on-release`. `plans/round-46-c2.sh` ON29 contains `S098`, and the frozen kill rule is
"any ON29 row's recheck leaves `on-release`" → C2 is killed. So the candidate **must** manufacture a clock for a
source the lane refused, and `FRESH` then counts it among the 29 "clocks re-observed live". The structurally
right fix (a rejected row has no taught claim, so its recheck cadence should not be `on-release`; the gate's own
`UNBOUND` finding is the symptom) is exactly what the freeze forbids.
Positive finding for the binding itself: the plan's preferred form is reachable and offline-checkable. The
committed body `.ufo/waves/round-41/capture/S098.body` sha256 `68e34b8ba02dac859bfabac7f8d1ecbd08fbc9ec00aa003f239fe3ca7198c70d`
= 199607 bytes = the `source-fetches.tsv` S098 row, and it contains **`Revision 25` exactly once** (offsets
195583/195628 region, `Revision 25</b>`), so a revision-naming quote locates under `raw-literal-v1`
(`release-clock.py:376`). A fallback to the row's current capture quote (`<title>UTS #18: Unicode Regular
Expressions</title>`, unique in the body) would be a *chosen* weakening, not a necessity — the title is stable
across revisions, so such a clock cannot detect a revision change.
Rule. AXES.md freshness = re-verification of *claims*; the plan's ceiling sentence "C2 re-observes; it does not
re-verify …" plus the frozen kill rule.
Remedy. Bind S098 with the revision quote (`Revision 25`), not the title. Report sentence: "29 = 28 rows carrying
taught claims + S098, a conformance binding on a REJECTED row that has no teaching to drift; no claim in this
round rests on S098." Route "`on-release` on a REJECTED row" to round 47 as a gate rule with its own counter
(the frozen ON29 cannot be corrected this round, so it is named, not worked).

### D-8 — Retiring the S040/S041 clock rows deletes two *fired* records from the register

Evidence. Both rows carry `verdict = fired` (`anchored 3.15.1` → `observed 3.15.2`, python feed, note "rearmed
successor to S027/S028", `corpus/release-clocks.tsv` lines 30-31). `ORPHAN` is raised because their registry
recheck moved to an ISO date in round 39 (`release-clock.py:566-570`); deleting the clock rows is the only path
the gate allows, since restoring `on-release` on their registry rows is forbidden by the counter's `KEPT`/
`ON29` shape and would be a claim-set change. The drift fact survives in S027/S028, but the register loses the
record that S040/S041 existed and fired — and the lane's own round-36 rule is "superseded, never rewritten".
Rule. `corpus/lessons/round-36.md:41` ("the round-26 receipt is retained byte-identical … superseded, never
rewritten"); AXES.md freshness (a stale item is *flagged*, not erased).
Remedy. Report/lesson record the two deleted rows verbatim (id, anchored, observed, verdict, note) so the
register's history is not only in git; state the reason (round-39 recheck move) and the ordering (they are
`ORPHAN`, so the gate's only consistent state is deletion). No frozen change.

### D-9 — the stagnation nudge is invoked unnecessarily, and its directive is declined

Evidence. `plans/round-46.md` §Axes: "All six axes sit at the saturation line 9 (tied lowest). Stagnation: the
last capability row's first-working round is 40; rounds 41–45 entered none, so the window N=3 is exhausted and
the nudge waives the lowest-axis duty." Facts check out: `SCORECARD.md` capabilities table's last row is round 40
(`SCORECARD.md:712`, statement at `:714`) and no `capabilit*` row appears in the round 41–45 post-move sections (§7). But AXES.md's duty is
"at least one claim works the lane's **lowest-scoring** non-retired axis" — with all six at 9 the tied-lowest set
*contains* freshness (C2) and operability (C1), so the duty is satisfied without a waiver. AXES.md's nudge also
has a positive directive: "the round should be a frontier/capability move — grow the repertoire or move
`PROVINCE.md` frontier ground into core". Round 46 does neither: C1 is a repo-internal selftest, C2 a
re-observation of held clocks. So the plan invokes a waiver it does not need, and declines the directive the
waiver comes with — the sentence reads as a licence that was not issued.
Rule. AXES.md §The stagnation nudge, first and last sentences.
Remedy. Report sentence: "the lowest-axis duty is satisfied directly — all six axes are tied at the line, C1
works operability and C2 freshness; the nudge's condition also holds (last capability round 40), and its
capability/frontier directive is **declined for this round**, with the capability move planned for round 47."
No frozen change; the nudge stops being cited as the round's justification.

---

## 5. Held instruments C2 lands on (the strongest counterexample available locally)

### D-10 — R36-03 is already red and its expect is unreachable, so the M46-1 "fix" would add a duplicate authority and leave a standing red

Evidence, measured (receipt `K46CriticClaims/r36-c3-at-base.txt`):

```
$ bash plans/round-36-c3.sh          # execs python3 corpus/release-clock.py  (default mode)
ORPHAN S040 / ORPHAN S041 / RECEIPT-MISMATCH S040 / RECEIPT-MISMATCH S041 / UNBOUND S098
RELEASE_CLOCK: FAILED (on_release=29 bound=28 unbound=1 observed=28 fired=13 derived=15)
rc=1
```

`plans/round-36-c3.sh` is `exec python3 corpus/release-clock.py` with no arguments — i.e. **exactly the default
mode M46-1 says no round ran**. `corpus/claim-ledger.tsv:100` (R36-03) expects
`^RELEASE_CLOCK: CLEAN \(on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15\)$` with exit 0. That
expect cannot be met now or at the candidate: S040/S041 are retired (their clock rows deleted) and S098 joins, so
the candidate line is `CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)` `[INFERENCE from
the frozen plan's candidate work]` — 30/15 is unreachable in every future tree. The red is on the record, not
silent: the round-40 closure grepped the verify receipt and found `R36-03` among the FAIL lines ("all outside
the frozen set", `corpus/lessons/round-40-verifier-spotcheck.md` §2). So two framings are false: M46-1's class
"instrument-drift (**a held gate silently red**)" and its "Captured-by: none" — the captured-by is R36-03, and
the fact that a red ledger row was read as out-of-scope is a *calibration/review* failure, not silent drift.
M46-1's prescribed fix ("a claim-ledger row that runs the default gate …") adds a **second** row measuring the
same surface while the first stays red forever → duplicate authority plus a permanent red.
Rule. AXES.md calibration ("overreach caught" — a mistake's class must match what happened);
`corpus/knowledge/claim-ledger.md:503` (append-only old→new migration evidence belongs in the round lesson);
rounds 28/41/44's migration-plus-journal precedent.
Remedy (no frozen target; ledger rows are not the frozen predicate). Migrate **R36-03** in place — new expect
`^RELEASE_CLOCK: CLEAN \(on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15\)$`, old→new recorded
in `.ufo/waves/round-46/expectation-migrations.json` — with the red witness the plan already asks for (run the
row's command at BASE → rc 1, FAILED) and its green reading at the candidate. Do **not** add a second row unless
it measures a different property (e.g. a pinned 29/13 count rather than the verdict string). Add an erratum to
M46-1 in the round lesson: class `ledger-row-dismissed`, captured-by `R36-03` (red at round 40, dismissed as
out-of-scope).

### D-11 — R36-02 goes red the moment any feed version/verdict changes, and the plan does not name it

Evidence, measured: `bash plans/round-36-c2.sh` → `0`, rc 0 at BASE (receipt `r36-c2-at-base.txt`); the script
hardcodes `.ufo/waves/round-36/controls/observe-live.json` and compares, per feed row,
`record["parsed_version"] != row["observed_version"] or record["verdict"] != row["verdict"]`
(`plans/round-36-c2.sh:30-39`) — dates are ignored, versions are not. The plan's candidate work says "the clock
rows take the receipt's version, date and verdict", so a release in the 2026-11-04 → 2026-11-06 window (or a
verdict flip from the `regressed` floor rule, `release-clock.py:877-890`) makes R36-02 non-zero — a held row
that was green turns red as a *side effect* of the claim. The counter and kill rules do not mention the ledger.
Rule. AXES.md "a round is admitted only if every claim verifies and no axis is harmed"; the ledger row is a held
instrument of the lane's own calibration surface.
Remedy. The report must state the outcome either way: if the observation changes no feed version/verdict, say so
with the measured `bash plans/round-36-c2.sh` → `0` at the candidate; if it changes any, migrate R36-02's expect
with the journal (or re-point the row at the round-46 receipt while the round-36 receipt stays citable via
`--receipt/--receipt-sha`), and name the drift in the lesson. No frozen change.

---

## 6. Two structural traps inside C1 (not defects of the claim, defects of the round's sequencing)

### D-12 — C1's `REAL` leg dies on bookkeeping if the post-move section lands before the manifest rows

Evidence. `REAL` in `plans/round-46-c1.sh` runs `bash corpus/claims-declared.sh` on the tree; that gate's
round-45 leg checks every round R ≥ 39 that has `## Round R — post-move` in SCORECARD and demands a manifest row
per `## Ck — axis:` heading (`claims-declared.sh`, plan-to-manifest block: `if [ "$((10#$rname))" -lt 39 ]`).
`plans/round-46.md` already carries `## C1 — operability:` and `## C2 — freshness:` (predeclaration `44808ce`).
Round 45's own practice was to write the post-move section *before* the candidate hash was known — so a candidate
tree with the section but without both manifest rows reads `MISMATCH 46 Cx no-manifest-row`, `REAL=0`, and C1 is
killed for a reason that has nothing to do with its predicate.
Rule. The frozen kill rule is "C1 is killed if value < 3 at the candidate"; `REAL=0` triggers it regardless of
cause.
Remedy. Report/lesson states the ordering: the SCORECARD post-move section and the two manifest rows
(`46 C1 operability`, `46 C2 freshness`) land in the same commit, or C1's `REAL` is read on a tree without the
round-46 post-move section. Round-43/44 practice (manifest rows with the section) is the model.

---

## 7. Commands run, exit codes, last lines

All read-only, none host-heavy; no lane counter, no `claim-ledger.sh verify`, no network. Receipts copied to
`.ufo/waves/round-46/build/K46CriticClaims/`.

| command | rc | last line |
|---|---|---|
| `bash plans/round-36-c3.sh` (lane tree; default-mode gate, the R36-03 command body) | 1 | `RELEASE_CLOCK: FAILED (on_release=29 bound=28 unbound=1 observed=28 fired=13 derived=15)` |
| `bash plans/round-36-c2.sh` (the R36-02 command body) | 0 | `0` |
| `grep -cE 'release' plans/round-46-c1.sh` / `grep -cE 'claims' plans/round-46-c2.sh` | 0 / 0 | `0` / `0` |
| `python3 -B` ON29 reachability over `git show f5977284:corpus/SOURCES.md` | 0 | `ON29 rows not 1x11+on-release: none` / `rows total: 102` |
| `sha256sum .ufo/waves/round-41/capture/S098.body` | 0 | `68e34b8ba02dac859bfabac7f8d1ecbd08fbc9ec00aa003f239fe3ca7198c70d` (199607 bytes) |
| `grep -o 'Revision 25' …/S098.body \| wc -l` | 0 | `1` |
| `awk` kind-split of `corpus/release-clocks.tsv` (excluding S040/S041) | 0 | `18 feed` / `10 rendered-quote` |

Pointers used, by item: `plans/round-46.md`; `plans/round-46-c1.sh:44-109`; `plans/round-46-c2.sh:1-132`;
`corpus/claims-declared.sh` (usage/selftest block, `mfix`, plan-to-manifest block); `corpus/release-clock.py:28,
349, 376, 475-506, 545-547, 552-713, 855-918, 919-951, 1865-1920, 2136-2140`; `corpus/release-clocks.tsv`
(30 data rows; S040/S041 lines 30-31); `corpus/SOURCES.md:105` (S098), S034 anchor cell; `corpus/source-fetches.tsv`
S098; `corpus/claim-ledger.tsv:99-100`; `plans/round-36-c2.sh`, `plans/round-36-c3.sh`; `SCORECARD.md:696-714`
(capabilities), `:1614-1630` (r43), `:1676-1687` (r45); `corpus/lessons/round-45-verifier-spotcheck.md`,
`round-40-verifier-spotcheck.md`, `round-36.md:39-41`; `AXES.md` table + §Capabilities + §The stagnation nudge;
`scripts/hyaku/lane-addendum.md:425`; `.ufo/waves/hyaku/PHASE4.md:78`; `.ufo/waves/round-46/controls/`
(`c1-base.txt`, `c2-base.txt`, `gates-base.txt`, `controls-prefreeze.txt`, `instrument-sha256.txt`).

## 8. What I did not do

No candidate exists, so nothing was measured at a candidate and no verdict here is a score. I did not run the
lane's counters, `claims-declared.sh`, `release-clock.py --observe`, `claim-ledger.sh verify` or the self-counts;
I did not re-fetch any page (C2's observation is the round's work, not mine) and did not touch a secret, a vault
or any remote. D-11's conditional is a *rule-of-the-script* finding, not a prediction that a feed released.

SEAT-STATUS: complete
