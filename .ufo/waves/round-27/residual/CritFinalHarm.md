# CritFinalHarm — round-27 residual harm review (candidate 144babcb vs BASE 0a47dd18)

Seat: KagiR26.CritFinalHarm-27-t3 (critic; lane-authored advice, not non-author closure).
Candidate `144babcb892f0a30154880a9f94aa59ca8ddf9c5`, BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`.
Axes examined: calibration, freshness, depth, coverage, operability, adjacency.

## Verdict

Executed instruments are green, and the default release clock stays at CLEAN30. I found
no executable regression on any axis. Two findings are real and fixable before closure:
the round-27 SCORECARD misstates its own candidate (H1), and the committed lesson cites an
uncommitted measurement file (H2). One wording-vs-code gap in `--observe` is latent (H3).
The remaining items are minor.

## Commands run (scratch clone only; nothing executed in the lane checkout)

Clone: `git clone -q /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/CritFinalHarm/clone && git checkout -q 144babcb892f0a30154880a9f94aa59ca8ddf9c5` → HEAD `144babcb…`, host `python3 --version` = Python 3.14.8.

1. `cd /fast/scratch/CritFinalHarm/clone && python3 -I -B corpus/release-clock.py` → exit 0, wall about 0 s, last line:
   `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` (equals the R25-04 pin).
2. `cd /fast/scratch/CritFinalHarm/clone && python3 -I -B corpus/self-counts.py` → exit 0, wall 18 s, last line:
   `SELF_COUNTS: CLEAN (claims=60 stale=0)`. All 22 `KN-*` rows are OK, and so are the 38 SC/PV/RD rows (SC-CLOCK-SELFTEST and PV-CLOCK-SELFTEST live=76, so the R25-03 selftest printed `PASS (76 cases)` inside this run).
   (An earlier attempt wrapped each tool in `/usr/bin/time`. The wrapper is not installed, so it exited 127 with `command not found` and neither tool started. No tool run was consumed by that attempt.)

Static helpers (read-only, plus checksums and counts in the clone): recomputed `sha256/lines/bytes` for every `corpus/stamps.tsv` row, replicated the `row-identity.sh` projections for `stamps` and `scorecard-rounds`, counted the pins, and checked `git ls-files` / `git status --untracked-files=all` on the lane's round-27 wave directory.

## Findings

### H1: The SCORECARD round-27 table contradicts the candidate (calibration; medium; fixable)

These are the `SCORECARD.md` round-27 rows at 144babcb:
- calibration: "R25-02 population extended to **18** reviewed `knowledge/*.md` numbers (`KN-*`)". The live value is **22**: `self-counts.tsv` has 22 `KN-*` rows, R25-02 moved from claims=38 to claims=60, and LOG, README and lesson all say 22.
- freshness: "R25-03 selftest **67 → 73**". The ledger R25-03 pin is `PASS \(76 cases\)`, my run shows live=76, and LOG and the lesson say 67→76.
- freshness: "numeric downgrade fixtures accepted CLEAN at BASE **2/2** → after 0/2". The committed `.ufo/waves/round-27/c2-before.json` has `downgrade_fixtures: 4` and `downgrades_accepted_clean: 4`, and lesson M27-1 and LOG both say "all four".
- The same block says "no unrun result is stated here", yet it states the after value "0/2". It also says the measured revision "is appended below after the measured revision lands", but nothing is appended in the candidate.

No gate catches these. SCORECARD is outside the self-counts population (SKILL, PROVINCE, README, and knowledge since round 27). `claim-ledger.sh cells` audits row and stamp pointers, not stated values.

Smallest safe correction: change 18→22 and 73→76, and change BASE 2/2 to 4/4. State the after value (0/4) only together with the measured-revision appendix, otherwise drop it.

### H2: The committed lesson cites an untracked measurement file (calibration/provenance, ledger R11-08; medium; fixable)

- `corpus/lessons/round-27.md:105` (M27-2 evidence) cites `.ufo/waves/round-27/c1-before.json`. At 144babcb that file is **untracked**: lane `git status` shows `?? .ufo/waves/round-27/c1-before.json`, `git ls-files --error-unmatch` fails, its mtime is 12:32:16 while the commit is 12:31:36, and it is absent from the scratch clone and from the fleet root `.ufo/waves/round-27/`. It is the only non-`.ufo` citation of an untracked file (`git grep` over 144babcb).
- Gate semantics, read from code and not executed by me:
  - `cite_target` checks the lane first and then the fleet; both miss.
  - In a lone layout, `fleet_only_token` returns 1 because `.ufo/waves/round-27/` exists in the tree. The token is therefore UNRESOLVED, not FLEET-ABSENT. Selftest case `cite-lone-owned-ufo-miss` pins exactly this behaviour.
  - Line 105 matches none of the `MARK_RE` labels (checked: NO-MARK).

  Inference: R11-08 (`claim-ledger.sh citations`) passes in the dirty lane checkout only because of the untracked file. A fresh checkout of the pushed candidate would print `UNRESOLVED corpus/lessons/round-27.md:105 .ufo/waves/round-27/c1-before.json (ufo)` and fail.
- The M27-1 and M27-2 "fix (shown able to fail)" cells both point at a "final Gate below". The candidate lesson has only `## Gate — sources opened and decided this round` (line 16, above the table). The after-evidence (`c1-after.json`, `c2-after.json`, `separability.json`, `measurement-invocations.json`, `candidate-landing.json`, `receipts/c1-mutate-*.json`) is all untracked. Both claims' "able to fail" evidence is therefore absent from the committed candidate, which is premature saturation in provenance terms.

Smallest safe correction: commit `c1-before.json` and the after receipts together with the measured-revision Gate section that M27-1/M27-2 promise, or label the line. L1's final checks should run in a clean clone of the exact revision, not in the lane checkout with untracked files.

### H3: `--observe` ignores the feed floor that SKILL/PROVINCE describe (freshness; low; latent)

- SKILL says `REGRESSED` covers an observation "below its own numeric anchor, below any numeric anchor on the same feed, or (when observing) below the row's previous observation". PROVINCE says the same.
- Code: `run_observe` (`release-clock.py:860-893`) never calls `feed_floors`. `observe_one` (`:793-799`) sets `regressed` only from `values["anchored_version"]` and `values.get("observed_version")`. The floor applies only in `evaluate` (`:567-575`), and only to the **table** row.
- Counterexample (synthetic table). Feed F has row X (anchor 1.0.0, observed 1.0.0, not-fired) and row Y (anchor 1.2.0, observed 1.2.0, not-fired). The feed now serves a newest stable of 1.1.0.
  - `--observe` writes X with `verdict: "fired"` and prints `fired=1 regressed=1`. That records an older-than-recorded stream as a fired release, which contradicts QM25's "never a fired release".
  - The exit is still 1 (X gets RECEIPT-MISMATCH, Y gets REGRESSED). If the table were later migrated to X fired@1.1.0, the replay floor would make X REGRESSED. So I found **no false CLEAN**.
- It is not reachable with the current table: on every feed, each row's anchor or previous observation already equals the floor (python 3.15.1, vault 2.2.0, openbao 2.7.1, sops 3.13.3, curl has a single row).
- Smallest safe correction: compute `feed_floors(rows)` in `run_observe` and pass the row's floor into `observe_one`'s regression test, with one selftest case. Alternatively, narrow the SKILL/PROVINCE wording to "feed floor on replay; observe types own-anchor/previous-observation regressions".

### H4: Ledger note text (calibration wording; low)

- The R25-02 and R25-03 notes have their round-27 clause appended without a separator ("…corpus/self-counts.tsv Round 27 (C1)…", "…no network Round 27 (C2)…").
- R25-02's note still opens "the 38 reviewed current-tense numbers of SKILL.md, PROVINCE.md and corpus/README.md" while its expectation is claims=60.

This is not executable harm. The fix is ". Round 27 …" and a reworded lead.

### H5: New unbound numbers (calibration; tradeoff, not a defect)

- `corpus/README.md` "Round-27 active contracts" says "22 reviewed … in eight entries; five stale ones were corrected". No lane-local source isolates the KN rows (R25-02 gives 60).
- "Five" is ambiguous. LOG and the lesson enumerate four value corrections (72→170, 29→36, 21→36, 19→20) plus one per-round pointer rewrite.
- `knowledge/surface-census.md:76` "9 of 15 rows" is true today (`drift-baseline.tsv` has 6 of 15 rows with `-`). Its numerator, like drift-gate's "6 of 15", has no binding source.

All of these fall under QM26's "no lane-local pinned source" exclusion. My recommendation is to make "five" match the enumerated list.

### H6: Lane tool drift after commit (operability/provenance; low)

`.ufo/waves/round-27/tools/c2-measure.py` was modified in the lane working tree after 144babcb (mtime 12:35:36; `git diff` shows the docstring changing from "three fixtures" to "five fixtures"). The committed docstring is stale against its own `FIXTURES` dict, which has five keys: lie, rollback, unfire, nonnumeric, control. Running the lane-path tool therefore runs an uncommitted file, though only the docstring differs.

## Checked and clean

- **Stamps:** all 90 `corpus/stamps.tsv` rows recompute exactly in the clone (stamps_bad=0). The R24-05 digest replicates (`LC_ALL=C sort` of the path column gives `b88b27f4…bcf2`), and so does R24-06 (`grep '^## Round ' SCORECARD.md` gives `cb0f57e0…bac`).
- **Count pins:** R12-03=90, R13-01=33, R21-04=65, and SOURCES has 43 rows (R21-02 rows=43).
- **Migration journal:** `.ufo/waves/round-27/expectation-migrations.json` names all nine changed ledger rows (R12-03, R13-01, R21-02, R22-03, R24-05, R24-06, R24-15, R25-02, R25-03).
- **R25-04 default CLEAN30:** unchanged expectation, executed result matches, `DEFAULT_RECEIPT_SHA256` and `receipt_path` are untouched by the diff, and the pinned receipt has no `regressed` verdict.
- **Selftest growth only by new cases:** the diff adds seven `run_case` and two `observe_one` cases (9, so 67→76). No existing case is removed or edited; only the `run_case` signature changed, with default `extra_sources=()`.
- **Knowledge corrections are true:**
  - Case names `verdict-not-final` (`claim-ledger.sh:1610`) and `defer-substrate-absent/-present/-line` (`:1715-1717`) exist.
  - `state-shape.tsv` has 8 json (9+8+3+1+1=22).
  - `drift-baseline.tsv` has 9 hashed of 15 rows.
  - `drift-symbols.tsv` has 20 rows (KN-CENSUS-DRIFT-SYMBOLS live=20).
- **Citations in added doc lines:** 28 class-shaped tokens resolve. The only miss is H2's `c1-before.json`.
- **Adjacency:**
  - `corpus/adjacency.tsv` is unchanged, and no host path is touched.
  - `rg -i 'semver|version precedence|version-specifiers'` over sibling `*-shokunin/{SKILL,PROVINCE}.md`, `corpus/SOURCES.md` and `corpus/knowledge/*.md` gives zero hits, so there is no duplicate authority across lanes.
  - Inside the file, `parse_latest_version`'s max key and `numeric_version` are two orderings that agree on strict X.Y.Z. That is a maintainability nit, not harm.
- **REGRESSED precedence:** the REGRESSED branch runs before the INCONSISTENT checks, so it can mask an anchor_ok, date or verdict defect behind REGRESSED. The exit is 1 either way, so this only affects diagnostics.

## Not checked

- I did not run `claim-ledger.sh verify/citations/cells/docs`, `sources-census.sh`, `revision-audit.py`, `row-identity.sh`, `scope-gate.sh`, `c1-measure.py`, `c2-measure.py` or `separability.py`. H2's citation failure is inferred from code and the pinned selftest case, not executed.
- No `--observe`, no network, no host or substrate rows, and no re-fetch of S042/S043 page content or quote location.
- I did not inventory the 17 knowledge entries the lesson says hold no in-population number.
- I did not judge the exclusion classes themselves.

## Tooling

Nothing installed or updated. `/usr/bin/time` is absent; I used shell `date` arithmetic instead.
