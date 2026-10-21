# ScribeQuality — round-27 build: QM25 (regression is a finding) and QM26 (knowledge-entry numbers bound)

Lane: kagi-shokunin (read only). Frozen BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`.
Scope: review and draft QUALITY.md rows QM25 and QM26, each citing its lesson, with
supersession wording per QUALITY.md conventions. Judged on calibration and freshness.

Evidence convention: `BASE:path:line` = the committed BASE tree (`git show`). `WT:` = the
live working tree as read during this session. The working tree was moving while I read
it (`corpus/claim-ledger.tsv` and `corpus/stamps.tsv` changed from clean to modified
between two of my reads), so every WT claim is a snapshot, not a settled state.
`[INFERENCE]` = read from code or regex, not executed.

## 0. Execution and tooling

- Ran no release-clock, self-counts, claim-ledger, selftest, c1/c2 measurement, build, or gate
  (assignment rule: no gate verification mid-flight). Every "live" number below is either a
  committed pin read from a file, a plain row or byte count, or an `[INFERENCE]`.
- Read-only commands used: `git show`, `git diff`, `git log`, `git status`, `git check-ignore`,
  `sha256sum`, `wc`, and `grep -c` / `awk` line counts for fact counting only.
- Sandbox: BASE copies of the reviewed files written to
  `.ufo/waves/round-27/sandboxes/ScribeQuality/base/` (lane-permitted write).
- Installs/updates: none. No tool was installed or upgraded.

## 1. Draft rows

Both rows are already present in WT `corpus/QUALITY.md:130-133` (uncommitted; BASE has
no QM25/QM26 — `git diff --stat` shows `corpus/QUALITY.md | 7 +++++++`, BASE ends at QM24,
`BASE:corpus/QUALITY.md:126`). Supersession: neither row replaces another. Both use the
file's "Supplements QMx" form and leave QM1–QM24 unchanged, as the append-only rule requires.

### QM25 — review verdict: adequate with two additions (see §4)

Current WT text (`corpus/QUALITY.md:132`) is kept. Proposed wording, with the two limits
from §4 added:

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QM25 | Supplements QM23/QM24: a release clock orders strict X.Y.Z versions numerically (SemVer §11.2, S042; PEP 440 release-segment ordering, S043). An observation numerically older than its numeric anchor is a typed `REGRESSED` finding that fails the run (exit 1), never a fired release and never an un-fire of an earlier anchor. Anchors or observations that cannot be ordered (non-numeric, two-part, prerelease) keep the inequality rule as a declared limit, named in the lesson. An un-fire is caught only through a successor row on the same feed; a missing successor is UNBOUND, never CLEAN. | `observed != anchor` treated as a release; a rollback fixture that still ends CLEAN; fired count unchanged across a downgrade; a non-numeric anchor presented as order-proven | `corpus/lessons/round-27.md` M27-1 and §C2 |

### QM26 — review verdict: incomplete as drafted (see §3–§4)

Current WT text (`corpus/QUALITY.md:133`) names three exclusion classes only: dated
measurement section, Evidence/Erratum history, positional case index. The lesson's
population rule (`corpus/lessons/round-27.md` §C1, lines 39–47) also excludes host/substrate
observations and numbers with no lane-local pinned source. The draft does not name the
second class, and the lesson's "unbindable output is labelled with its round" rule has
no counterpart in the draft's exclusions. Proposed wording:

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QM26 | Supplements QM21: current-tense numbers about lane artifacts inside `corpus/knowledge/*.md` are bound like SKILL/PROVINCE/README numbers (`rows:`, a non-host `ledger:` verdict, or a host/substrate `expect:` pin). Four classes are excluded by name: a section dated as a measurement (`Reproduction (YYYY-MM-DD)`, `Source basis: measured …`), Evidence/Erratum/Round-N history, host or substrate observations, and positional case indexes. A lane-artifact number with no pinned value (for example a pin that is a shape regex such as `checks=[1-9][0-9]*`) is unbindable: it is labelled `unbound:` with its round beside it, never restated as current. A round tag alone does not make a number historical (QM21). | a knowledge reproduction block quoting a selftest count stale across several rounds; a current-voice count with no pin, no date and no label; a correction note elsewhere instead of a history clause beside the number | `corpus/lessons/round-27.md` M27-2 and §C1 (population rule) |

## 2. Confirmed findings at BASE (calibration)

The five stale numbers the lesson corrects are real at BASE, each checked against its pin
or a row count:

| Doc location (BASE) | BASE text | Live source | Verdict |
|---|---|---|---|
| `BASE:corpus/knowledge/claim-ledger.md:301` | `claims=17 stamped=33` | R21-04 `^65$` (`BASE:corpus/claim-ledger.tsv`); 65 `R…` rows counted at BASE; `BASE:corpus/stamps.tsv` 89 non-blank rows | stale (17→65, 33→89) |
| `BASE:corpus/knowledge/claim-ledger.md:304` | `--selftest  # 72 scratch cases` | R11-09 pin `^SELFTEST: PASS \(170 cases\)` | stale per pin (72→170); live output not run |
| `BASE:corpus/knowledge/op-ref-consumption.md:276` | `--selftest … PASS (29 cases)` | R12-02 pin `^OP_REF_SELFTEST: PASS \(36 cases\)` | stale per pin (29→36) |
| `BASE:corpus/knowledge/surface-census.md:32` | `(15 files, 19 symbol pins)` | `BASE:corpus/drift-symbols.tsv` 20 data rows | stale (19→20) |

Correct at BASE and unchanged: `BASE:corpus/knowledge/drift-gate.md:4` `(15 rows)` and
`(20 rows)` match `drift-baseline.tsv` 15 and `drift-symbols.tsv` 20 (counted at BASE), but
they are not bound (see §3 item B2).

**Working-tree correction that does not hold (after-state defect).** `WT:corpus/knowledge/claim-ledger.md:301`
now reads `stamped=89`. The WT `corpus/stamps.tsv` has 90 non-blank rows, including
`corpus/lessons/round-27.md`, and WT R12-03 (`corpus/claim-ledger.tsv`, note "Round 27: +
corpus/lessons/round-27.md -> 90") pins `^90$`. The binding `KN-LEDGER-REPRO-STAMPS`
(`WT:corpus/self-counts.tsv` line 69) reads `ledger:R12-03` live and extracts `stamped=`
from line 301. [INFERENCE] The binder would print `STALE corpus/knowledge/claim-ledger.md`
for KN-LEDGER-REPRO-STAMPS after the round-27 stamp lands. The lesson's "after: stale0"
claim is therefore false for the WT tree as it stands. Fix: re-bind line 301 to 90 with the
89 history clause beside it, after the stamp is final.

## 3. Population gaps in the C1 binding (BASE citations; each is a counterexample to "no digit census" in the lesson's own rule)

A. **Undated current-tense lane counts with no binding.**
  - A1. `BASE:corpus/knowledge/adjacency-scope.md:46-52` (section `## The partition (measured, not asserted)`, `BASE:…:42`, undated): `census rows 35`, `owned … 27`, `shared 8`, `group rows 4`, `# no-enumerate 8`. Live: BASE `corpus/adjacency.tsv` has 5 `# own` and 4 group rows (counted); R16-01 and R16-06 pin the rest. No KN row in WT `self-counts.tsv` locates these lines (the WT adjacency-scope KN rows are lines 7/16/17-style selftest/falsify clauses only). Mutation `| census rows | 35 |` → 36 is not caught. [INFERENCE: regex and table inspected; binder not run.]
  - A2. `BASE:corpus/knowledge/adjacency-scope.md:3-4` (`Source basis: … (5 # own prefixes, 4 group rows covering the 8 census …`). Not "measured …"; not dated. Not excluded by the lesson's rule text; not bound.
  - A3. `BASE:corpus/knowledge/surface-census.md:4-5` (`data files … (35 rows: 20 asset / 15 runtime) and state-shape.tsv (22 rows …`) under `Source basis: … run on 2026-09-28`. Live: R11-11 `^35$`, R11-10 `^22$`. The lesson's exclusion names `Source basis: measured …`, which this header does not literally match. The exclusion is therefore disputable, and the lesson's rule needs to say which one it means.

B. **Header and block counts with no binding.**
  - B1. `BASE:corpus/knowledge/drift-gate.md:4` `(15 rows)` / `(20 rows)`: undated `Sources:` header; not in the 18 KN rows.
  - B2. `BASE:corpus/knowledge/drift-gate.md:143` `6 of 15 files are content-unhashed`: only the `15` is bound (KN-DRIFT-BOUND-FILES captures the second number); the `6` has no source row.
  - B3. `BASE:corpus/knowledge/adjacency-breadth.md:102-105` (`## Output contract`, undated): `required=4 pins=4 checked=4 ok=4` are lane-local (R17-01 pins the whole line, substrate); `children=182 … undeclared=174` are host observations and may be excluded. The lane-local part is unbound.
  - B4. `BASE:corpus/knowledge/adjacency-breadth.md:148` `# 4 ADJACENCY_BREADTH lines` (undated `## Reproduction`, `:139`): lane count (R17-02 `^4$`), unbound.

C. **Correctly excluded (kept as examples of the rule working).**
  - `BASE:corpus/knowledge/drift-gate.md:167-170` under `## Reproduction (2026-09-28)`: dated; excluded.
  - `BASE:corpus/knowledge/adjacency-scope.md:249-260` `## Reproduction (2026-09-29)`, including `grep -vc … # 35` and `--breadth # 4 rows; 182/8/174`: dated; excluded.
  - `BASE:corpus/knowledge/surface-census.md:245-252` `## Reproduction (2026-09-28)`, `SELFTEST: PASS (16 cases)`: dated; excluded. Note the substrate pin R11-03 (`corpus/claim-ledger.tsv`) would also allow `expect:` binding; the lesson names this as "named debt" instead.
  - `BASE:corpus/knowledge/checklist-execution.md:3-4` (`Source basis: measured 2026-09-28 (round 15)`) and `:82` (`runnable=9/16 floor=8 by_hand=7`): excluded by the lesson's rule. The value matches R15-05's pin `^CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 …`, so it is current and only unbound. Disputable exclusion.

## 4. Counterexamples to the draft rows themselves

**QM26 (draft text fails its own lesson).**
  - `BASE:corpus/knowledge/op-ref-consumption.md:275` (`## 9. Reproduction`, undated) `OP_REF_PROBE: CLEAN (checks=44 …)` and `:291` (`## 10`, `CLEAN (checks=44 …)`). `checks` has no pinned value: R12-01 in `BASE:corpus/claim-ledger.tsv` pins `checks=[1-9][0-9]*`, and the `expect:` binder reads a committed pin without executing it, so no value can be extracted. The number is undated, not round-labelled, and not in the draft's named exclusions. The lesson excludes it ("no lane-local pinned source"; §C1 excluded list), but the WT QM26 draft (`corpus/QUALITY.md:133`) does not carry that class. Under the draft text, `checks=44` is a current-voice unbound count with no label, which QM26's own weak-signal sentence describes as a violation. Fix: add the unbindable class in §1 (done in the proposed row).
  - The WT edit at `op-ref-consumption.md:276` (29→36) is correct and labelled; the WT Erratum (`WT:corpus/knowledge/op-ref-consumption.md` end) keeps the history clause beside it. That part satisfies QM21.

**QM25 (draft row is right, its implementation has three limits the row must name).**
  - (a) **Non-numeric anchor is a declared limit, and it is exploitable.** `BASE:corpus/release-clocks.tsv:9` (S012, anchor `v1.21.x`, observed `2.2.0`, fired). WT `is_regression` returns False for `v1.21.x` (`WT:corpus/release-clock.py:382-386`, `numeric_version` at `:369-379`). A feed whose newest stable is `1.20.9` would read `fired` and be accepted CLEAN. [INFERENCE: code path; not executed.] This is the declared limit, not a silent pass, but the lesson's §Limits does not name this row.
  - (b) **An un-fire is detected only through a successor row.** WT `evaluate` compares each row's observation to its own anchor only (`WT:corpus/release-clock.py:542-557`); it holds no prior verdict. A feed observed at exactly `3.15.0` makes S027/S028 (anchor `3.15.0`, `BASE:corpus/release-clocks.tsv:24-25`) read `not-fired` with no finding on those rows. The downgrade is caught only by S040/S041 (anchor `3.15.1`, `BASE:corpus/release-clocks.tsv:30-31`) as REGRESSED. Removing the successor rows gives UNBOUND (exit 1), which is a failure, not CLEAN. So QM25's "never an un-fire" holds only through successor coupling. [INFERENCE.] The draft row (§1) says so.
  - (c) **Behaviour change for derived anchors above the newest stable.** BASE `evaluate` at `BASE:corpus/release-clock.py:524-527` treated an anchor above the feed as `fired`; WT now types it `REGRESSED` (`WT:…:542-547`). The derived rows avoid this today: S029 anchors `8.23.0` (`BASE:corpus/release-clocks.tsv:26`) even though its note names `8.23.1`. Any future derived row naming an unreleased version now fails the run. This is intended by QM25 but must be disclosed in the lesson.

Evidence for the QM25 claim itself (counted from committed-or-lane artifacts, not re-run):
`.ufo/waves/round-27/c2-before.json` at BASE: lie `RELEASE_CLOCK: CLEAN … fired=4`, exit 0; rollback `RELEASE_CLOCK: CLEAN … fired=3`, exit 0; control CLEAN. This supports M27-1 as written. The file is untracked (`git ls-files .ufo/waves/round-27` is empty).

## 5. Evidence trail gaps (QM14 and QM21 hygiene)

- `.ufo/waves/round-27/knowledge-migrations.json` is cited by `corpus/lessons/round-27.md` (§C1 "Old/new text") and by the WT Erratum at `corpus/knowledge/op-ref-consumption.md` (round-27 Erratum). It does not exist at the time of my read (`.ufo/waves/round-27/` listing). QM14 requires a committed old/new migration record. Missing.
- `.ufo/waves/round-27/c1-before.json` is cited as the "before" evidence for M27-2. It does not exist at my read. The C1 BASE measurement therefore has no artifact behind it.
- The lesson's `KN-*` rule (§C1) excludes "numbers with no lane-local pinned source", but the lesson's own Limits (§Limits, `corpus/lessons/round-27.md:90-91`) says the exclusion classes are "judgment calls a non-author may dispute". That is accurate; the population rule is not exhaustive (§3).
- The lesson's example "a knowledge reproduction block quoting a selftest count three rounds stale" (QM26 signal) is loose: `BASE:claim-ledger.md:304` `72` predates R18-03's chain (`108→121→140→151→170`, `BASE:corpus/claim-ledger.tsv` R18-03 note). It is stale by several rounds, not three. Cosmetic, but the count should be quoted exactly.

## 6. Verdict on the two rows

- QM25: adopt, with the §1 wording (adds the successor-coupling and declared-limit sentence). The row is supported by `c2-before.json` and the code path. Not yet verified by execution after the change.
- QM26: do not adopt the WT wording as is. Adopt the §1 wording, and close the population gaps in §3 (bind or exclude-by-name) before the QM26 claim "a one-digit knowledge mutation turns the binder STALE" can be made true. A1 is the largest.

## 7. What I did NOT check

- No gate or selftest was run; the binder's STALE result, the mutation test (`c1-measure.py --mutate KN-LEDGER-REPRO-SELFTEST`), and the C2 fixtures (`c2-measure.py` at the after revision) were not executed. Any "would be caught" statement above is [INFERENCE].
- Live selftest counts 170 (claim-ledger), 36 (op-ref), 73 (release-clock) and 65 (claim rows) were read from pins, not produced by running. 73 = BASE's 67 + the six WT cases (my count of `run_case` plus live `cases += 1`, not executed).
- No live value of `checks=44` (op-ref-probe) was obtained.
- The WT KN bindings were checked for regex shape by reading (e.g. `KN-LEDGER-REPRO-CLAIMS` `(claims=`, `KN-LEDGER-REPRO-STAMPS` `stamped=`); not run against the WT docs.
- SKILL.md, PROVINCE.md and corpus/README.md bindings (R25 population) were not reviewed.
- S042/S043 source pages were not re-fetched and their quotes not re-located; I read the lesson's Gate table only.
- No host-private file, vault, account, handler or CDP surface was read or contacted. No network access was made.
- No outside falsification. This is lane-authored advice, not non-author closure; no SHONEN mark written.
- The WT tree moved during the session (`corpus/claim-ledger.tsv`, `corpus/stamps.tsv`, `corpus/SOURCES.md` changed). Final integrated state must be re-read by the integrator before any WT claim here is treated as landed.
