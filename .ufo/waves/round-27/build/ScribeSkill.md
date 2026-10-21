# ScribeSkill — SKILL.md decision-table wording for C1/C2

Frozen BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b` (verified: `git rev-parse HEAD`).
Lane is dirty in the working tree (`M SKILL.md`, `M corpus/self-counts.tsv`,
`M corpus/release-clock.py`, ...). BASE citations below use `git show 0a47dd18:<path>`;
working-tree (WT) citations are marked `WT`.

Scope: decision-table rows 47 (self-counts, knowledge population) and 48 (release clock,
REGRESSED). Draft rows: `.ufo/waves/round-27/sandboxes/ScribeSkill/draft-rows.md`.
No gate, selftest, ledger verify, build or lint was executed. Locator checks below are a
Python `re` simulation of the binder's per-line `search` (`corpus/self-counts.py` check loop),
run on draft text only. They are not a gate pass.

## Binding facts (what the locators require)

- `corpus/self-counts.tsv:21` (BASE and WT, unchanged) — `SC-SELFCOUNTS-SELFTEST`, locator
  `^\| Check a number the corpus states about itself .*?\`--selftest\` ([0-9]+) cases\b`,
  live source `ledger:R25-01` (`claim-ledger.tsv:80` pins `(48 cases)`).
- `corpus/self-counts.tsv:22` (BASE and WT) — `SC-CLOCK-SELFTEST`, locator
  `^\| Judge whether a source's \`on-release\` recheck fired .*?\`--selftest\` ([0-9]+) cases\b`,
  live source `ledger:R25-03` (`claim-ledger.tsv:82` pins `(67 cases)` at BASE).
- Binder rule (`corpus/self-counts.py` check loop, BASE lines 306-374): the locator runs per
  line; exactly one line must match, else `UNLOCATED`/`AMBIGUOUS`. The captured integer is the
  FIRST `--selftest` N cases on that line (lazy `.*?`).
- Literal prefixes that must survive an edit: `| Check a number the corpus states about itself `
  (the space after `itself` is literal) and `| Judge whether a source's \`on-release\` recheck fired `
  (the straight apostrophe, the backticks, and the space after `fired` are literal).
- BASE `SKILL.md:47` and `SKILL.md:48` each contain exactly one `--selftest` N cases; BASE says
  48 and 67. WT says 48 and 73 (`SKILL.md:47-48`).

## Findings

**F1 — the title may take an appended qualifier only after the literal prefix.**
`fired ` followed by anything still matches, so `recheck fired or regressed |` is safe.
Counterexample (simulated): `recheck fired, regressed |` → SC-CLOCK-SELFTEST UNLOCATED (exit 1).
Same for `states about itself, |` → SC-SELFCOUNTS-SELFTEST UNLOCATED. Also `recheck fires or regresses |` → UNLOCATED.

**F2 — a history clause written as `--selftest` N cases before the current number steals the binding.**
Counterexample (simulated): `...; \`--selftest\` 67 cases at round 25; \`--selftest\` 73 cases`
→ SC-CLOCK-SELFTEST captures 67 → STALE against live 73. Same shape on row 47 (`47 ... 48`).
QM21 (`corpus/QUALITY.md:118`, BASE line 118) requires an explicit history clause, but the
history must not use the bound pattern. Draft writes history as `dated history clause`, with no
`--selftest` N cases form.

**F3 — row 48 WT says `a stale, cropped or rolled-back feed` as what REGRESSED is.** That is a
diagnosis. Round-27 lesson `corpus/lessons/round-27.md:27` REJECTs "a release-ordering spec proves a
vendor's feed is complete or monotonic": "A REGRESSED finding is ... a typed stop for re-verification,
not a claim that the vendor rolled back." Draft wording follows the lesson.

**F4 — row 48 WT omits the numeric-only limit.** `corpus/lessons/round-27.md:92-94` (Limits): C2 orders
numbers only; a feed silently dropping its newest release while still showing an equal or newer
version stays CLEAN; prerelease regressions are not detected. The draft states the first limit in one
sentence (no new digits).

**F5 — row 48 WT "keep the inequality rule" is opaque.** Draft names the rule `observed != anchor`
(BASE `release-clock.py` fired predicate; WT `release-clock.py:545-546` sets REGRESSED only on
numeric ordering).

**F6 — row 47 WT is already correct on the knowledge population.** WT `SKILL.md:47` adds
`a reviewed corpus/knowledge/*.md line`, `binding a positional case index or a dated measurement
section`, and the history clause. Simulation: SC-SELFCOUNTS-SELFTEST still matches row 47 with
captured 48. Draft keeps all WT wording, adds the `--selftest` N cases history rule (F2), and drops
the unobserved claim that a mutation "turns the binder STALE".

**F7 — live count dependency (not verified).** WT `SKILL.md:48` says `--selftest 73 cases`. The
static count supports it: BASE `release-clock.py` has 32 `run_case(` call sites, WT has 37 (+5),
plus one new explicit `cases += 1` in the live downgraded-feed block (WT diff around the
`downgrade_observation` case). That is +6, matching the round-27 lesson's "six new selftest cases"
(`corpus/lessons/round-27.md:77-79`). This is static arithmetic, NOT a run. If the live output is
not 73, SC-CLOCK-SELFTEST goes STALE.

**F8 — knock-on ledger pin (inference).** `corpus/claim-ledger.tsv:82` (R25-03) still pins
`^RELEASE_CLOCK_SELFTEST: PASS \(67 cases\)$`. Once the live output is 73, `claim-ledger.sh verify`
would be expected to fail on that row until the pin moves. SC-CLOCK-SELFTEST binds the live output
via `ledger:` so the binding itself stays correct; the pin migration is a separate bookkeeping edit
for the planner. Not observed.

**F9 — BASE typo kept.** `SKILL.md:48` (BASE) reads `demoting on-release successors to90d`. Draft keeps
it verbatim (no locator depends on it). Optional fix: `to 90d`.

**F10 — out of my rows, observed in WT diff.** `SKILL.md:46` changed `89 stamps` → `90 stamps`
(SC-SKILL-STAMPS, `ledger:R12-03`). Not drafted; the planner should check it live.

## Draft rows (also in the sandbox file)

Row 47 (self-counts):

```
| Check a number the corpus states about itself | `python3 corpus/self-counts.py` (each row of `corpus/self-counts.tsv` locates ONE current-tense number in SKILL.md / PROVINCE.md / `corpus/README.md` / a reviewed `corpus/knowledge/*.md` line and binds it to `rows:<file>`, a non-host ledger row's live output `ledger:<ID>`, or a host row's committed pin `expect:<ID>`, which is never executed); `--selftest` 48 cases | hand-editing a number "to match"; binding to a second definition of the quantity; dropping a binding to go green; treating an explicitly round-dated history line as current; binding a positional case index or a dated measurement section; writing a history value in `--selftest` N cases form before the current number | exit 0 `SELF_COUNTS: CLEAN (claims=N stale=0)`; 1 `STALE id doc:line claimed=X live=Y` / `UNLOCATED` / `AMBIGUOUS`; 2 `POLICY` (host row under `ledger:`, recursion, unknown id) / `SETUP`. A knowledge correction keeps the old value in a dated history clause beside the new one (QM21), phrased without the `--selftest` N cases form |
```

Row 48 (release clock, REGRESSED): full text in the sandbox file. Its changes against WT `SKILL.md:48`:
- Never column adds `reading a numeric downgrade as an un-fire or as a release event`.
- Exit column: `REGRESSED` is defined as a typed stop for human re-verification of the feed, "never a
  release event, an un-fire, or a claim that the vendor rolled back" (F3); non-numeric anchors keep
  the `observed != anchor` rule (F5); numeric-only limit (F4).
- Title prefix, the single `--selftest` 73 cases, and every other token order preserved.

Simulation output (Python `re`, per line, same semantics as the binder's `search`):

| Input | SC-SELFCOUNTS-SELFTEST | SC-CLOCK-SELFTEST |
|---|---|---|
| BASE SKILL.md | line 47 → 48 | line 48 → 67 |
| WT SKILL.md | line 47 → 48 | line 48 → 73 |
| Draft rows | line 1 → 48 | line 2 → 73 |
| Control: `recheck fired, regressed` | — | none (UNLOCATED) |
| Control: `recheck fired or regressed` | — | line 1 → 73 |
| Control: `recheck fires or regresses` | — | none |
| Control: `states about itself, |` | none |
| Control: history `67 cases at round 25; ... 73` before current | — | line 1 → 67 (STALE) |
| Control: history `47 ... ; 48` before current | line 1 → 47 (STALE) | — |
| Control: row split across two lines | none | none |

## Did NOT check

- No gate run: `self-counts.py` (incl. `--selftest`), `release-clock.py` (incl. `--selftest`, `--observe`),
  `claim-ledger.sh verify`, `c1-measure.py`, `c2-measure.py` were not executed. The live 73 and 48 values are
  unverified (F7).
- The working-tree release-clock.py behaviour (REGRESSED printing, exit 1) was read statically only; the
  wording in row 48 is therefore a claim to be checked by L1.
- PROVINCE.md:54, corpus/README.md:181-184 and SKILL.md:787 carry the same release-clock wording. Not drafted.
- The KN-* locators in `self-counts.tsv` (`:58-75`) were not audited.
- SKILL.md:46 stamp/claim count (`89` → `90`) was not audited (F10).
- `corpus/sources-census.sh`, `corpus/QUALITY.md` QM25/QM26 text, and whether S042 wording is checked by any census: not checked.
- The `claim-ledger.tsv` R25-03 pin move (F8) was not verified against `claim-ledger.sh verify`.

## Tooling

None installed or updated. Regex simulation used the system `python3` standard library only.
