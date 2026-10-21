# ScribeLog — round-27 LOG.md entry skeleton (draft, uncommitted)

Lane: kagi-shokunin, round 27 BUILD. Seat: KagiR26.ScribeLog-17 (leaf scribe, no dispatch).
Frozen BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b` (`git rev-parse HEAD` = BASE; LOG.md at BASE is 1494 lines, last line `…HONEN stays author [~].`).
Axes judged: calibration (C1), freshness (C2). Working tree is dirty (15 files changed, all round-27 in-flight; see §4); every BASE citation below was read with `git show 0a47dd18:<path>`, not the working tree.

Writes by this seat: this file only. LOG.md, plans, lessons, corpus, stamps: untouched. No gate, selftest, measurement or linter was run. No installs (tooling directive reviewed; nothing needed).

---

## 1. Skeleton (to append after BASE `LOG.md:1494`, one blank line first)

Placeholder convention: every value L1 must replace is written `@@L1:<name>@@`. Nothing in this section is a measured result unless it is cited to a BASE path or a named wave file. Before commit run:
`grep -n '@@L1' LOG.md` → must print nothing; `grep -nE 'TODO|FILL|<LINES>|<FILL' LOG.md` → must print nothing (QM7; see §3 CE2 for why no gate does this for you).

```
## Round 27 — knowledge-entry numbers bound; release clocks refuse silent regression (2026-10-21)

Two declared claims: calibration 9→9 (C1) and freshness 9→9 (C2). BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b` (round-26 admitted). Frozen claims:
`plans/round-27.md`; lesson `corpus/lessons/round-27.md`; wave evidence
`.ufo/waves/round-27/`. Axis values after landing are the scorecard's decision;
this entry restates them only as @@L1:axis-after-confirmed@@.

Motivation: round-25 named debt D2 (`corpus/lessons/round-25.md:158-165`:
current-tense knowledge numbers outside the R25-02 binder) and round-26
FinalRearm's inherited limit (`corpus/lessons/round-26.md:230-236`: fired means
observed ≠ anchor, so a stale or cropped feed could un-fire an older anchor).

Motivating evidence (before, at BASE):
- C2: `.ufo/waves/round-27/c2-before.json` (revision BASE, format
  kagi-round27-c2-measure-v1). A lie fixture (S040 at 3.15.0 under the 3.15.1
  anchor) and a whole-feed rollback (S027/S028 un-fired) each end
  `RELEASE_CLOCK: CLEAN`, exit 0; `downgrades_accepted_clean` 2 of 2; control
  CLEAN fired=3. BASE `corpus/release-clock.py` contains no `REGRESSED` token.
- C1: BASE `corpus/self-counts.tsv` has 0 `KN-` rows (binder covers SKILL.md,
  PROVINCE.md and corpus/README.md only; QM21). Five current-tense numbers in
  four `corpus/knowledge/*.md` lines disagreed with their live pins at BASE:
  `claim-ledger.md:301` claims 17 (live 65: `corpus/claim-ledger.tsv` has 65
  data rows) and stamped 33 (live 89: `corpus/stamps.tsv` has 89 rows);
  `claim-ledger.md:304` 72 scratch cases (live 170: `corpus/claim-ledger.tsv:23`
  R11-09, `:50` R18-03); `op-ref-consumption.md:276` 29 cases (live 36:
  `corpus/claim-ledger.tsv:27` R12-02); `surface-census.md:32` 19 symbol pins
  (live 20: `corpus/claim-ledger.tsv:48` R18-01 `symbols_bad=20`).

Changes:
- C1 `corpus/self-counts.tsv`: @@L1:C1-KN-binding-count@@ `KN-*` bindings over
  @@L1:C1-KN-entry-count@@ knowledge entries (scout-measured working tree: 18
  rows over 7 entries; L1 recounts). Corrected numbers keep the old value in an
  explicit history clause (QM21). Population and exclusions:
  `corpus/lessons/round-27.md` §C1.
- C2 `corpus/release-clock.py`: strict X.Y.Z cores compared numerically
  (SemVer 2.0.0 §11.2; PyPA release-segment ordering). An observation numerically
  below its numeric anchor is `REGRESSED` (exit 1, never CLEAN, never a release
  event). Non-numeric anchors keep the inequality rule as a declared limit.
  Sources: S042, S043 (`corpus/SOURCES.md`, `corpus/source-fetches.tsv`).

Measured after (executed by L1 once, final revision @@L1:measured-revision@@):
- C1 binder over BASE docs: @@L1:C1-before-exit@@ (`@@L1:C1-before-stale@@` stale).
  Binder over after docs: @@L1:C1-after-line@@, exit @@L1:C1-after-exit@@.
  One-digit mutation `c1-measure.py --mutate KN-LEDGER-REPRO-SELFTEST`:
  @@L1:C1-mutation-line@@.
- C2 downgrade fixtures at after revision: @@L1:C2-lie-line@@ (exit
  @@L1:C2-lie-exit@@); rollback @@L1:C2-rollback-line@@ (exit
  @@L1:C2-rollback-exit@@). Live default receipt: @@L1:C2-live-line@@.
- Selftests: `RELEASE_CLOCK_SELFTEST` BASE 67 cases (`corpus/claim-ledger.tsv:82`
  R25-03); after @@L1:clock-selftest-after@@ cases — the delta must equal the new
  cases named in the lesson, nothing else.
- Full safe ledger: @@L1:ledger-line@@; self-counts: @@L1:selfcounts-line@@.

Mistakes (lesson `corpus/lessons/round-27.md` §Mistakes):
- M27-1 survivor: inequality accepted as a release (QM25).
- M27-2 number drift outside the binder (QM26).

Limits, not closed here:
- C1 binds a reviewed population, not every digit in the knowledge entries.
  Excluded by rule: dated measurement sections, Evidence/Erratum history,
  positional case indexes, host/substrate observations.
- C1 named debt still open: @@L1:C1-debt-list@@.
- C2 orders numbers only. It does not detect a feed that silently drops its
  newest release while showing an equal or newer version, nor prerelease
  regressions. A REGRESSED finding needs human re-verification of the feed.
- C2 lone clone stays INCOMPLETE/48 (not a round-27 target).
- Outside spot-check of this round's admits/rejects: pending parent closure;
  lane authors cannot supply it.

Wave: build67 registry snapshot @@L1:wave-composition@@ (67 spawned at
`.ufo/waves/round-27/build-dispatch.json`); seat reports landed @@L1:reports-landed@@;
provider deaths @@L1:provider-deaths@@ (all terminal notices in
`.ufo/waves/round-27/terminal-error-notices.json` at snapshot were reviewers,
rate limit); job-cap refusals @@L1:refusals@@. No replacements unless recorded.
Installs: @@L1:installs@@.

Migration record: `.ufo/waves/round-27/knowledge-migrations.json` (@@L1:migration-file-status@@);
counting replay outputs under `.ufo/waves/round-27/`. Final immutable outputs
are appended after integration, never invented here.

Outside admission remains the parent's duty and SHONEN stays author [~]. (Scribe
writes no SHONEN marks; L1 confirms this sentence.)
```

---

## 2. Placeholder register (what L1 must fill, from where)

| Placeholder | Fill from | Status at this snapshot |
|---|---|---|
| `@@L1:axis-after-confirmed@@` | scorecard decision | not decided by scribe |
| `@@L1:C1-KN-binding-count@@`, `@@L1:C1-KN-entry-count@@` | `grep -c '^KN-' corpus/self-counts.tsv`; distinct docs of those rows | working tree shows 18 rows, 7 docs (not re-verified by count tool) |
| `@@L1:C1-before-exit@@`, `@@L1:C1-before-stale@@` | `.ufo/waves/round-27/c1-before.json` | **FILE ABSENT** (see CE1) |
| `@@L1:C1-after-*@@`, `@@L1:C1-mutation-line@@` | `python3 -I -B corpus/self-counts.py`; `python3 -I -B .ufo/waves/round-27/tools/c1-measure.py …` | not run (instruction: no gate runs mid-flight) |
| `@@L1:C2-lie-*@@`, `@@L1:C2-rollback-*@@`, `@@L1:C2-live-line@@` | fresh `c2-measure.py` run on after revision; `release-clock.py` default | not run |
| `@@L1:clock-selftest-after@@`, `@@L1:ledger-line@@`, `@@L1:selfcounts-line@@` | executed selftests / verify at final revision | not run |
| `@@L1:measured-revision@@` | pushed SHA of landed revision | not known |
| `@@L1:C1-debt-list@@` | lesson §C1 plus CE5 items | see CE5 |
| `@@L1:wave-composition@@`, `@@L1:reports-landed@@`, `@@L1:provider-deaths@@`, `@@L1:refusals@@` | `swarm-registry.json`, `terminal-error-notices.json`, `build-refusals.json`, `build/*.md` at landing time | snapshot only (see CE8) |
| `@@L1:installs@@` | recorded tool installs | none by this seat |
| `@@L1:migration-file-status@@` | does `knowledge-migrations.json` exist when LOG lands | ABSENT now |

Snapshot composition for the wave line, from `swarm-registry.json` (67 members, `updatedAt 2026-10-21T15:15:43.274Z`): scout 29, reviewer 9, critic 8, scribe 6, connector 5, executor 4, mutation-tester 2, revenger 2, simplifier 1, sentinel 1. L1 recounts at landing.

---

## 3. Concrete counterexamples (things the entry must not copy, or must check)

CE1 — cited evidence does not exist. `corpus/lessons/round-27.md` §Mistakes row M27-2 cites `.ufo/waves/round-27/c1-before.json`, and §C1 cites `.ufo/waves/round-27/knowledge-migrations.json` (“Old/new text”). `ls` of `.ufo/waves/round-27/` shows only `c2-before.json`, `build*`, `captures/`, `sandboxes/`, `terminal-error-notices.json`, `tools/` (with `c1-measure.py`, `c2-measure.py`). Neither cited file exists. The "five stale at BASE" claim therefore has no artifact behind it in the tree. My own BASE recount (§1 "Motivating evidence") supports the same five numbers, but that is my reading, not a receipt. The LOG must not cite the missing files.

CE2 — QM7 is a rule with no mechanical enforcement. QM7 (`corpus/QUALITY.md:45`, BASE) says a placeholder "fails the stamp". The stamp hashes only: `corpus/claim-ledger.sh:382` (`stamp()`), `:433-434` (`sha256sum` and `wc -l`, plus bytes). A grep of every BASE `corpus/*.sh|*.py|*.tsv` for `FILL|TODO|<LINES>` returns no gate code (only prose hits). Precedent: `corpus/lessons/round-13.md:9-10` shipped `<FILL ON STAMP>` / `<LINES>`; `corpus/lessons/round-19-recensus.md:40` records it never filled; QM7 was written afterward (`corpus/lessons/round-21.md:17`, M7). So re-stamping LOG.md with a placeholder passes. Only the grep in §1 protects the commit.

CE3 — copy-forward composition. Round-26 `LOG.md:1451` reads `BUILD64:28 scouts/3 executors/12 reviewers/8 critics/5 connectors/8 scribes`. The round-27 registry has 29 scouts, 4 executors, 9 reviewers, 6 scribes, and also 2 mutation-testers, 2 revengers, 1 simplifier, 1 sentinel. Copying the round-26 line would be false.

CE4 — round-27 sources are not BASE facts. `plans/round-27.md` and `corpus/lessons/round-27.md` are untracked (`git status`), absent at BASE (`git ls-tree` of `plans/` lists round-21..26 only). QM25 and QM26 are absent from `corpus/QUALITY.md` at BASE (the QM rows stop at QM24, `:126`) and exist only in the working tree. The entry must describe them as landing with this commit, and must not write "BASE QM25".

CE5 — named debt not fully dispositioned. `corpus/lessons/round-25.md:158-165` names `knowledge/op-ref-consumption.md:276,283,296` as stale-number debt. The round-27 lesson's C1 section addresses only `:276`. At BASE, `:296` reads "`--selftest` proves the comparator on 21 cases" (a current-tense count about this lane's probe, not in the 18 KN bindings, not in the lesson's exclusion list). `:283` reads "`edge.env` (10 classes …)" (fixture description; disposition unrecorded). Also `knowledge/claim-ledger.md:81` (round-25 named "case 16 vs 27"; lesson says renamed) and `surface-census.md:226` (lesson: left as debt). The LOG must list `:283`/`:296` as open unless L1 binds or excludes them with a reason.

CE6 — "five" counts numbers, not lines. The lesson says "Five were stale at BASE". My recount: five numbers on four lines (`claim-ledger.md:301` carries two, claims and stamped; `:304`, `op-ref-consumption.md:276`, `surface-census.md:32`). The LOG must say "five numbers in four lines", or the reader will count lines and find four.

CE7 — stamp bookkeeping is not trivial. `corpus/stamps.tsv:1` pins `LOG.md` at sha `237dfe48…`, 1494 lines, 102671 bytes (BASE). Appending the entry changes that row, so `claim-ledger.sh verify` reports STALE for LOG.md until re-pinned. The re-pin is `claim-ledger.sh stamp`, which "regenerates the WHOLE row set from the paths given" (`claim-ledger.sh:19`, `:394`): every stamped path must be named again or rows are lost (round-12 lost 18 rows, per the script's own comment at `:22`). The working tree already has `corpus/stamps.tsv` modified (29 lines changed); L1 must confirm the final row set has 89 + any new rows and that `LOG.md` is re-pinned in that same invocation.

CE8 — wave counts cannot be read off disk yet. `.ufo/waves/round-27/build/` at snapshot holds `SimplifyRegression.md` (one seat report), `SrcPythonVersions.{body,headers,text}`, and `swarm-registry.json`. The registry lists 67 members; `terminal-error-notices.json` lists 9 terminal deaths, all reviewers (`ClockCurl`, `ClockOpenbao`, `ClockSops`, `ClockQuotes`, `ClockPython`, `ClockVault`, `RevwBookkeeping`, `RevwDocsAudit`, `RevwLocator`, "Devin stream error resource_exhausted … free model rate limit"); `build-refusals.json` holds 17 records, the first `Background job limit reached (100)` with `failed_jobs: 67`. "Reports N" must wait for landing.

CE9 — quote-check naive grep. The lesson says S042/S043 quotes are "located once". A raw `grep -c` on `.ufo/waves/round-27/captures/S042.body` returns 0 because the sentence is wrapped across a line break in the HTML; with tag-stripping and whitespace normalization it returns 1 for both S042 and S043. The claim holds, but any verifier using raw grep will report a false mismatch. The LOG should cite the rendered-text check, not a raw grep.

CE10 — C2 at BASE has no REGRESSED path at all. `grep -c REGRESSED corpus/release-clock.py` at BASE = 0. The entry's "REGRESSED never CLEAN" claim is entirely new code; nothing at BASE can be cited for it. Working-tree lines (`corpus/release-clock.py:369`, `:382`, `:546`, `:588`) are in-flight, not BASE.

CE11 — stale-by-default in the lesson's own history. `corpus/lessons/round-27.md` says C1 "bound 18 bindings over 7 entries". My count of working-tree KN rows is 18 across 7 docs, consistent. But the lesson also says the round-25 debt pointer `credential-isolation.md:120-122` "does not resolve (the entry has 78 lines)". BASE `corpus/knowledge/credential-isolation.md` has 78 lines (`wc -l`), so that statement is correct; the LOG should keep it as debt, not as "fixed".

---

## 4. Working-tree vs BASE facts used

- `git rev-parse HEAD` = BASE `0a47dd1…`.
- `git status`: M PROVINCE.md, SKILL.md, corpus/QUALITY.md, corpus/SOURCES.md, corpus/knowledge/{claim-ledger,op-ref-consumption,surface-census}.md, corpus/release-clock.py, corpus/self-counts.tsv, corpus/source-fetches.tsv, corpus/stamps.tsv, corpus/claim-ledger.tsv; untracked `.ufo/waves/round-27/`, `corpus/lessons/round-27.md`, `plans/round-27.md`. `git diff --stat`: 15 files, 215 insertions, 46 deletions. LOG.md is not modified.
- The working-tree `corpus/claim-ledger.tsv` modification: I did not diff it; any row change there changes the R-row pins cited in §1.

## 5. Checked at BASE (exact paths:lines)

- `LOG.md:1358` (R25 heading), `:1420` (R26 heading), `:1451` (BUILD composition), `:1482` (CLEAN65/89), `:1494` (last line). Heading convention: `## Round N — title (2026-10-21)`; header block `Base \`<sha>\`. Frozen claims: …; lesson …; wave evidence …`.
- `corpus/QUALITY.md:45` (QM7), `:118` (QM21), `:126` (QM24); no QM25/QM26 at BASE.
- `corpus/stamps.tsv:1` (LOG.md row); 89 non-comment rows.
- `corpus/claim-ledger.tsv:23` (R11-09 170), `:27` (R12-02 36), `:48` (R18-01 symbols_bad=20), `:50` (R18-03 170), `:80` (R25-01 48), `:81` (R25-02 38), `:82` (R25-03 67). Data rows: 65.
- `corpus/knowledge/claim-ledger.md:301` (claims=17 stamped=33), `:304` (72 scratch cases); `corpus/knowledge/op-ref-consumption.md:276` (29 cases), `:296` (21 cases); `corpus/knowledge/surface-census.md:32` (15 files, 19 symbol pins); `corpus/knowledge/credential-isolation.md` 78 lines.
- `corpus/self-counts.tsv`: 52 lines, 0 `KN-` rows.
- `corpus/drift-symbols.tsv`: 20 non-`#` rows.
- `corpus/claim-ledger.sh:19`, `:22`, `:382`, `:394`, `:433-434`.
- `corpus/release-clock.py`: 0 `REGRESSED` tokens.
- `corpus/lessons/round-13.md:9-10`, `round-19-recensus.md:40`, `round-21.md:17`, `round-25.md:158-165`, `round-26.md:230-236`: all present at BASE.
- `corpus/SOURCES.md`: 41 `| S0` rows (lesson says 41→43 once S042/S043 land).
- `plans/round-27.md` and `corpus/lessons/round-27.md`: NOT at BASE.

## 6. What I did NOT check

- No gate, selftest, measurement or linter was executed (`self-counts.py`, `c1-measure.py`, `c2-measure.py`, `release-clock.py`, `claim-ledger.sh`). All "after" values are placeholders. The before/after counts in §1 come from reading BASE files, not from running tools.
- I did not verify the 18 KN bindings resolve or that each reproduces its live source; I did not check the working-tree `knowledge/*.md` diffs line by line.
- I did not check whether the S042/S043 quotes match `rendered-text-v1.py` output; my check was tag-strip plus whitespace normalization.
- I did not read the 67 seat reports (only one is on disk) or the registry beyond member counts and notice names.
- I did not check `SKILL.md`, `PROVINCE.md`, `corpus/README.md`, `SCORECARD.md` numbers for round-27 movement, nor whether they agree with the new KN rows.
- I did not check `corpus/knowledge/sops-age-key-rotation.md:68-70`, `vault-openbao-token-lease-lifecycle.md:76-78`, `claim-ledger.md:81`, or `surface-census.md:226` beyond the lesson's description.
- I did not check whether `op-ref-consumption.md:296` "21 cases" maps to any pinned selftest subcount; I only observed it is not in the KN list.
- I did not verify the mixed-outcome counts in `.ufo/waves/round-27/build-record.txt` (21.5 KB, grew during this read; not parsed).
- No host-private, vault, account, handler or CDP surface was read. No commits, pushes, Git/jj mutations, or LOG.md writes were made by this seat.
- Tooling: none installed or upgraded; no RULES.md read was needed.

Unrun checks are not passes. Everything in §1 marked as measured is either a BASE file read cited by path:line, or a wave artifact cited by name; everything else is a placeholder.
