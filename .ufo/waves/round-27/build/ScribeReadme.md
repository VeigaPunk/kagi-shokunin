# ScribeReadme — round-27 corpus/README.md draft (calibration, freshness)

Lane: kagi-shokunin. Base: `0a47dd189356ea66ec83c3891eed54526e95b89b` (verified `git rev-parse HEAD`).
Author seat: KagiR26.ScribeReadme-17 (leaf, read-only). Production files untouched; no gate, selftest, build or linter run.
Tools installed: none.

Base discipline: the working tree is dirty with in-flight round-27 edits (`git status`: PROVINCE.md, SKILL.md, corpus/release-clock.py, corpus/self-counts.tsv, corpus/knowledge/{claim-ledger,op-ref-consumption,surface-census}.md, corpus/SOURCES.md, corpus/QUALITY.md, corpus/source-fetches.tsv). Every citation below is to BASE, read via `git show 0a47dd1:<path>` or a `git archive` export. `corpus/README.md` is clean in the tree and identical to BASE. BASE snapshots are at `.ufo/waves/round-27/sandboxes/ScribeReadme/` (`README.BASE.md`, `release-clock.BASE.py`, `self-counts.BASE.tsv`).

## 1. Draft text for `corpus/README.md`

Edit 1. Append after the last line of `## Round-26 bounded drift response` (BASE line 215):

```
## Round-27 active contracts

Round 27 is calibration and freshness, not new coverage: it adds no knowledge
entry, no source, and no frontier path.

- **Knowledge-number binding (C1).** `corpus/self-counts.tsv` binds the reviewed
  current-tense knowledge-entry numbers (`KN-*` rows) to a live source: `rows:`
  for data-file counts, a non-host `ledger:` verdict, or a host `expect:` pin.
  The population and its exclusions (dated measurements, round-dated history
  clauses, positional case indexes) are stated in that table's header. A bound
  number that changes turns `self-counts.py` STALE, exit 1. This is not a
  complete digit census. A corrected number keeps its superseded value in an
  explicit history clause.
- **Release-clock regression refusal (C2).** `corpus/release-clock.py` reads an
  observed stable release that is numerically older than a strict `X.Y.Z` anchor
  as a typed `REGRESSED` finding: exit 1, never CLEAN, never a release event.
  Non-numeric anchors keep the inequality rule as a declared limit. The rule is
  sourced by the round-27 version-precedence rows (IDs to be cited at
  integration). It changes what a stale feed can report, not which feeds are
  watched. The live default receipt is a dated observation, not continuous
  monitoring.
```

Edit 2. Replace the `## Frontier` bullet at BASE line 108 (`- **Observable release clocks** …`) with:

```
- **Observable release clocks** — entered in round25 (S033–S037; S038 empty-feed
  reject). Round 27 adds a regression refusal for strict `X.Y.Z` anchors only; it
  adds no feed and no monitoring. On-demand observation of declared identities,
  not continuous vendor-truth monitoring. Open: non-numeric anchors (S029's
  development-label row, whose note names 8.23.1 while its anchored cell reads
  8.23.0) and the multi-claim second locator (ClockS017/S020).
```

Edit 3. Round-26 section, BASE lines 197–205: version tokens are glued to the
preceding word. Insert a space in each: `is3.15.1`→`is 3.15.1` (L197),
`served3.15.1`→`served 3.15.1` (L198), `original3.15.0`→`original 3.15.0` (L204),
`fired at3.15.1`→`fired at 3.15.1` (L204), and `named3.15.1`→`named 3.15.1` (L205).
No meaning changes.

## 2. Findings with BASE citations

Ordered by weight. "Counterexample" means a concrete BASE line that a binder or
reader would wrongly accept.

**F1 — stale knowledge number (C1).** `corpus/knowledge/surface-census.md:32`:
"(15 files, 19 symbol pins)". `corpus/drift-symbols.tsv` has 20 data rows at BASE
(count of non-comment lines). `corpus/README.md:38` already says 20. The sentence is
in the undated "Why this gate exists" section, so it is not a history clause.
Live-state check: the working-tree `self-counts.tsv` already adds a `KN-CENSUS-DRIFT-SYMBOLS`
row noting "said 19 at BASE"; a BASE binder would have returned STALE on this line.
Correction needed: `19`→`20`, or a history clause if the 19 is meant as dated.

**F2 — present-tense sentence and erratum scope refuted by the corpus (calibration, not a count).**
`corpus/knowledge/sops-age-key-rotation.md:68–70` says "kagi does not run SOPS today:
`grep -rliE 'sops|openbao|hashicorp' corpus/knowledge --exclude=sops-age-key-rotation.md
--exclude=vault-openbao-token-lease-lifecycle.md` → no file, exit 1 (2026-10-19)".
Its erratum at `:99` extends the sweep to "no *other corpus knowledge entry* mentions
SOPS, OpenBao or HashiCorp". `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:76–78`
repeats the grep, and its erratum at `:111` says the sweep "covers corpus mentions only".
Run on a `git archive` of BASE (a grep, not a gate), the same command prints
`corpus/knowledge/feature-bound-credential-review.md` and exits 0. That file mentions
OpenBao at `:9` and `:19` (`| OpenBao service tokens |`). Counterexample: the dated
"exit 1 (2026-10-19)" tag covers a measurement, but the present-tense "does not run SOPS
today" and the erratum's "no other entry mentions" scope are refuted at BASE. This is
the round-25 debt item "sops-age-key-rotation.md:68-70 (grep now exits 0)", confirmed.
Not a count, so the C1 binder cannot bind it. It needs a correction (re-scope the
exclusion list or cite the feature-bound hit) or a history clause.

**F3 — undated reproduction numbers, live values differ (C1, covered in part).**
- `corpus/knowledge/op-ref-consumption.md:276` (§9 Reproduction, undated):
  `OP_REF_SELFTEST: PASS (29 cases)`. Ledger `R12-02` (`corpus/claim-ledger.tsv`) expects
  `PASS (36 cases)`. The explicit correction at `:373–374` already supersedes it
  ("the selftest now proves 36 cases"). This is covered by a history clause, but a binder
  must bind to `R12-02`, not to §9.
- `corpus/knowledge/claim-ledger.md:298–306` (undated "## Reproduction"): "--selftest # 72
  scratch cases → PASS (72 cases)", "claims=17 stamped=33". Live pins at BASE: `R11-09`
  expects 170 cases; `R21-04` expects 65 claim rows; `R12-03` expects 89 stamps. The
  section is covered only by the generic erratum at `:491–497` ("historical round-13
  outputs, not current … totals"). That clause is not per-number. Counterexample: a
  reader trusting §Reproduction gets 72 and 17 against live 170 and 65. A binder on these
  lines would turn STALE unless each number gets its own clause.
- `corpus/knowledge/claim-ledger.md:81`: "selftest case 16 pins it". The round-25 debt
  pairs this with "27". `27` does not appear on BASE line 81. A positional index is outside
  the population by rule, so this is not bound, but the round-25 debt pointer does not
  reproduce at BASE.

**F4 — named-debt pointers that no longer resolve at BASE.**
- `corpus/knowledge/credential-isolation.md:120–122` (round-25 debt): BASE file has
  78 lines (`git show … | wc -l`). The pointer is dangling; the debt must be re-located.
- `corpus/knowledge/surface-census.md` "SelfInvKnowledge1/2" (round-25 debt): zero
  occurrences at BASE (`grep -c SelfInv` → 0). Unlocatable at BASE.
- `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:78` and `sops-age-key-rotation.md:68–70`
  do match the round-25 pointers (F2).

**F5 — release-clock: the BASE gate has no regression path (C2 baseline).**
`corpus/release-clock.py` at BASE has no `REGRESS` string (grep count 0) and no numeric
comparison. The verdict branch is `corpus/release-clock.py:524–527`:
- `verdict == "fired" and observed != anchored` → `row_fired = True` (L524–525). No
  ordering check.
- `verdict == "not-fired" and observed == anchored` → accepted (L527).
- every other combination → `INCONSISTENT` (L530).

Counterexample (by code reading, NOT executed): a row with `verdict=fired`, anchor `3.15.0`,
observed `3.14.9` passes L524, so `fired` is counted and no error is raised. The result is
CLEAN with `fired=1`. The plan's "un-fires an already fired predecessor" variant is
**not** reproduced by BASE: a stale observation with `verdict=not-fired` and observed≠anchor
hits L530 (`INCONSISTENT`), not CLEAN. The plan wording needs a fixture to confirm which
variant the refusal must cover. I have not run one.

**F6 — version-token glue in the round-26 section (defect, README only).** `corpus/README.md:197–208`
(`is3.15.1`, `served3.15.1`, `original3.15.0`, `at3.15.1`, `named3.15.1`). Fixed by Edit 3 above.

**F7 — frontier/open-item inconsistency (freshness).** `corpus/release-clocks.tsv` (BASE)
row S029: `anchored_version=8.23.0`, `observed_version=8.23.0`, note "anchor names 8.23.1,
curl's unreleased development label (curlver.h 8.23.1-DEV)". The note and the cell disagree.
The README round-25 frontier (`corpus/README.md:189–192`) lists this as a next step. The
draft frontier note (Edit 2) keeps it open and does not claim it closed.

**F8 — numbers that hold at BASE (no action; the draft may keep them).**
- Knowledge entries: 25 files; `Reverify:` lines 25 (22 row-linked + 3 `by-hand`);
  `R14-01` expects `entries=25 row_linked=22 by_hand=3`. Matches `corpus/README.md:67`.
- `grep -L '^source:' corpus/knowledge/*.md` → 21 files. Matches `corpus/README.md:118`.
- Data rows: `surface-census.tsv` 35, `state-shape.tsv` 22, `drift-baseline.tsv` 15,
  `drift-symbols.tsv` 20, `claim-ledger.tsv` 65 (`R21-04` pins 65), `stamps.tsv` 89
  (`R12-03` pins 89), `checklist.tsv` 16, `release-clocks.tsv` 30 data rows.
- `self-counts.tsv` at BASE: 38 data rows (matches the round-25 README claim, `:172–176`).
  BASE has no `KN-*` rows; they exist only in the working tree.
- Selftest pins: `R15-02` 34 (checklist), `R16-02` 61 (scope).

**F9 — historical counts that are not current claims (no action).** `corpus/README.md:182`
"the 28 `on-release` registry rows" is inside `## Round-25 contracts (historical…)`. At BASE
`release-clocks.tsv` has 30 rows (20 feed + 10 rendered-quote). The round-25 count of 28 is
consistent with the round-25 state, because S040/S041 were added in round 26.

## 3. Verification status

- Ran: `git rev-parse`, `git status`, `git show <BASE>:…`, `git archive` export into the
  sandbox, `grep`, `sed`, `wc`. All are reads, not gates.
- NOT run: `self-counts.py` (any mode), `release-clock.py` (any mode, incl. `--selftest`),
  `claim-ledger.sh`, `checklist-run.sh`, `scope-gate.sh`, `op-ref-probe.sh`, any `--selftest`.
  Every "live pin" above is a value read from the BASE ledger `expect` column, NOT an executed result.
- Not checked: the working-tree `self-counts.tsv` KN rows and their bindings (in-flight, not
  BASE); round-27 `SOURCES.md` version-precedence row IDs (the README draft leaves them to
  L1); the full knowledge population beyond the named debt (I did not census all digits in
  25 entries); `drift-baseline.tsv` mode/hash column counts; `state-shape.tsv` kind breakdown;
  whether `release-clock.py` at BASE matches the plan's stated fired/CLEAN30 behavior;
  whether the S029 development-label row is correct (only read its cells and note).
- Unrun checks are not passes. No check in this report is a pass.

## 4. Recommendations to L1 (integrator)

1. Correct F1 (`surface-census.md:32` 19→20) and F2 (add a history clause or re-scope the sops/vault sweep; cite `feature-bound-credential-review.md`) in the knowledge pass.
2. For F3, bind `op-ref-consumption.md` §9 to `R12-02`, and give `claim-ledger.md` §Reproduction a per-number history clause, or leave the section explicitly historical.
3. Replace or re-locate F4's dangling debt pointers (credential-isolation `:120–122`, `SelfInvKnowledge1/2`).
4. Have the C2 fixture cover the `fired`+older-observation path (F5). Do not describe the un-fire variant as covered unless a fixture shows it.
5. Apply Edit 1–3 to `corpus/README.md` once the round-27 gate counts are measured. This draft carries no round-27 numbers on purpose.
