# CritC1Population — round 27 C1 population / current-vs-historical attack

Seat: KagiR26.CritC1Population-17 (critic, leaf). BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`
(`git rev-parse HEAD` observed equal). Working tree observed carrying L1's uncommitted C1 draft
(`git status`: `corpus/self-counts.tsv`, `corpus/knowledge/{claim-ledger,op-ref-consumption,surface-census}.md`,
`corpus/QUALITY.md` QM25/QM26, untracked `corpus/lessons/round-27.md`,
`.ufo/waves/round-27/knowledge-migrations.json`). Lane-authored advice, not closure. Read-only: only
`git show/log/grep`, `awk` counts over committed TSVs; no gate, binder, selftest or ledger row executed.
Scratch diff: `.ufo/waves/round-27/sandboxes/CritC1Population/kn.diff`.

Axes: calibration (primary), freshness (history-clause truth). Verdict: **fixable defects, not a
tradeoff the judge must reject** — but the "five stale at BASE" count and one history clause are wrong as drafted.

## Attack — "Erratum/dated ⇒ historical" lets erratum-conceded, never-true body numbers stand as current

The draft rule (self-counts.tsv draft header lines 53–57; lesson draft `corpus/lessons/round-27.md:38-47`)
excludes "Evidence/Erratum/Round-N findings history" and dated sections. The excluded object is the
erratum *text*; the numbers an erratum concedes live in the *body* and stay current-tense. Which conceded
numbers got fixed was decided by bindability, not by the concession: the draft fixed the one conceded number
`rows:` can bind (surface-census `:32`) and left the rest. QM26's own weak signal ("a correction note elsewhere
instead of a history clause beside the number", draft `corpus/QUALITY.md` QM26) describes exactly the survivors.

### CE1 — `op-ref-consumption.md:296` (BASE): in population, stale, unbound, missed
- BASE `corpus/knowledge/op-ref-consumption.md:296`, §10 Falsification (undated, not Evidence/Erratum, not host):
  "`--selftest` proves the comparator on 21 / cases".
- Defining source: ledger `R12-02` pin `^OP_REF_SELFTEST: PASS \(36 cases\)` (`corpus/claim-ledger.tsv:27`).
- Conceded stale by the round-22 erratum, BASE `:377-381`: "The §10 “21 cases” comparator sentence is an
  intermediate historical count … The existing §11 correction to “36” also supersedes that §10 count".
- Draft binds §9 `:276` and §11 `:374` only (KN-OPREF-REPRO-SELFTEST, KN-OPREF-CORRECTION-SELFTEST) and its new
  round-27 erratum says "both §9 and the §11 “36” are bound" — §10 silently left at 21. Under the draft's own
  rule this is a **sixth stale bindable number at BASE**; the lesson's "Five were stale" (`round-27.md:49`) and
  the M27-2 "five STALE" (`:86`) undercount, and a 21→22 mutation of `:296` is undetected after.

### CE2 — `surface-census.md:76` (BASE): present-tense, lane artifact, never true at any revision
- BASE `corpus/knowledge/surface-census.md:75-76`, §Schemas (undated): "the baseline keeps the / 16 published hashes".
- `corpus/drift-baseline.tsv` has exactly one revision (`e64e81b`); rows with a non-`-` hash column = **9 of 15**
  (awk over `git show`). 16 was never true; no history clause can honestly preserve it.
- Conceded by BASE `:295-297` ("'16 published hashes' phrase … superseded … the hash phrase unsupported").
- Draft leaves it. Not bindable by existing source kinds (`rows:` counts all 15 lines; no ledger row counts
  hashed rows — `grep drift corpus/claim-ledger.tsv` shows only R11-04/R11-05/R18-01), so QM26's
  "unbindable stale output is labelled … not restated as current" applies and is unmet.

### CE3 — `surface-census.md:5` (BASE): "9 json" never true, sits in a dated Source basis
- BASE `:5`: "`corpus/state-shape.tsv` (22 rows: 9 sqlite / 9 json / 3 log / 1 lock / 1 marker)" — sums to 23.
- Both revisions of `state-shape.tsv` (`03477c0` round 10, `8ada17a` round 22): `json=8 total=22`.
- Conceded at BASE `:295-297` ("JSON subtotal … internally inconsistent"). The paragraph is dated
  ("run on 2026-09-28", `:3`), so the draft rule excludes it as a measurement — but a committed-file subtotal
  that was false on that date is a misstatement, not a measurement. Misclassified by the dated-section rule.

### CE4 — false provenance in a drafted QM21 history clause (`claim-ledger.md:301-304`)
- Draft text: "round-10 output read claims=17 stamped=33 …", "…cites=700 docs=43…", "…cells=60…", "72 at round 10";
  same in `knowledge-migrations.json:4,42-45` and lesson `:53-55`.
- Counter-evidence: `corpus/claim-ledger.sh` first added at `301b9ec` (round 11) — no round-10 output exists.
  Pickaxe `-S'claims=17 stamped=33'`, `-S'72 scratch cases'`, `-S'cites=700 docs=43'`, `-S'cells=60 row_pointed=25'`
  all first appear at `4b8c018` (round 13); its parent read `claims=11 stamped=28` / `39 cases`. The entry's own
  BASE Source basis `claim-ledger.md:3-7` says "17 at round-13 close". The clause is a fabricated round label;
  this is the freshness axis (a history clause is a dated claim).
- Contrast, verified correct: surface-census draft `:32` "19 when this entry was written" — `drift-symbols.tsv`
  at `03477c0` has 19 rows; op-ref "29 when §9 was written" — 29 present from `4b8c018` (§9's origin).

## Smallest safe correction (for L1; I edited nothing)
1. `claim-ledger.md:301-304`, `knowledge-migrations.json`, lesson `:53-55`: "round-10" → "round-13 close"
   (both the claims/stamps/cites/cells clauses and "72 at round 13").
2. `op-ref-consumption.md:296`: "proves the comparator on 36 cases (21 when §10 was written; round-22 erratum)"
   + row `KN-OPREF-FALSIFY-SELFTEST	corpus/knowledge/op-ref-consumption.md	proves the comparator on ([0-9]+)\b	expect:R12-02	\(([0-9]+) cases	§10 Falsification; R12-02 pin (said 21 at BASE)`.
   Locator matches only `:296` at BASE [INFERENCE from grep, not from running the binder]. Extend the round-27
   erratum sentence to name §10.
3. `surface-census.md:76`: "the 9 published hashes (6 of 15 rows withheld as `-`; first written as 16, which no
   revision of `drift-baseline.tsv` carried — round-22 erratum)"; list as hand-corrected/unbindable in the lesson.
4. `surface-census.md:5`: "8 json" with "(first written as 9 json, never summing to 22 — round-22 erratum)".
5. QM26 / self-counts header: add "a body number an Erratum concedes is in population regardless of section
   dating or Erratum exclusion; a history clause records a once-true value at a verified round; a never-true
   value is marked misstated, not historicised." Recount: BASE stale bindable = 6, plus 2 unbindable hand fixes.
   The C1 counting command's "stale N" must be re-executed by L1 after this; I did not run it.

Rejected overclaim: the plan's "a one-digit knowledge mutation turns the binder STALE" (`plans/round-27.md:19-20`)
holds per bound locator, not per digit on a bound line — e.g. draft `claim-ledger.md:304` repeats 170 in
`SELFTEST: PASS (170 cases)` but only the comment's 170 is captured; `adjacency-scope.md:17`'s `/18`
denominator is unbound. Tradeoff, already bounded by "No claim of complete digit census"; state it in Limits.

## Not checked (unrun ≠ pass)
- Did not run `corpus/self-counts.py`, `.ufo/waves/round-27/tools/c1-measure.py`, the ledger, or any selftest;
  regex uniqueness of the 18 KN rows and of my proposed row is inferred from grep, not executed.
- `.ufo/waves/round-27/c1-before.json`, cited by lesson `:86`, was **absent** from `.ufo/waves/round-27/` when listed
  (only `c2-before.json`); possibly pending from another seat — not verified either way.
- Did not read all 25 entries end to end; non-erratum bodies only sampled (adjacency-scope, adjacency-breadth,
  checklist-execution, drift-gate headers). Word-numbers ("fifteen seeded mutations", `op-ref:297`) not audited.
- Host/substrate values (children counts, line counts of `~/.local/bin/*`, DB rows) not remeasured; no host-private read.
- No tools installed or updated.
