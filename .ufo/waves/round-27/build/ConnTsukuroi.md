# ConnTsukuroi — bounded sibling-overlap scan: version comparison and package-version tracking

Snapshot: 2026-10-21T15:26:31Z; re-checked 15:29Z after L1 rewrote the lesson and
regenerated the migration record during the scan. Lane BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`.
Sibling read at `tsukuroi-shokunin` HEAD `9a5e523cdbd791e5ce02930cee15577e7aa71136`
(the cited tsukuroi files have an empty `git diff --stat` against that HEAD; its
worktree has unrelated modifications to `tools/check-boundary-contract.py`,
`tools/check-review-cohort.py`, `tools/check-seat-bindings.py` only).

Scope: 21 lane-root `*/PROVINCE.md` and 18 lane-root `*/SKILL.md` were name-grepped
for `vercmp|SemVer|semver|release-clock|REGRESSED`; the two named tsukuroi
implementations were read in full at the cited ranges. Nothing else of the
siblings' `corpus/` or `.ufo/` trees was scanned. No gate, selftest, measure
script, linter or formatter was executed (contract); every count below is static.

## 1. Boundary evidence: two version domains, opposite operational meaning

| | tsukuroi (host package state) | kagi (vendor release identity) |
|---|---|---|
| Ownership | `tsukuroi-shokunin/PROVINCE.md:8-14` owns pacman state (`pacman -Qkk`, foreign/AUR census, update-safety: what an `-Syu` would touch) | `kagi-shokunin/PROVINCE.md:54` (BASE) binds every `on-release` row to a feed or rendered-quote clock; the same line: "No installed-runtime or system-package management is claimed" |
| Comparator | external `vercmp`: `tools/tsukuroi-census.sh:384` (`VERCMP=${TSUKUROI_VERCMP:-vercmp}`), direction at `:1609-1618` (`-1` behind, `1` ahead, anything else `diff_unk`) | in-tree strict `X.Y.Z`: in-flight `corpus/release-clock.py:369-387` (`numeric_version`/`is_regression`), applied at `:567-568`, receipt typing at `:615`, observe typing at `:793` |
| Input grammar | ALPM versions with pkgrel/epoch: `41.1-1`, `1.31.0-1.1`, `8.12.42_32.BETA-1` (`tsukuroi-shokunin/corpus/knowledge/initramfs-v42-sysroot-recovery.md:9`, `.../census-closeout-receipt-r10.md:60`) | vendor feed tags: `3.13.3`, `2.2.0`, `2.7.1`, `3.15.0/3.15.1`, `8.23.0` (`corpus/release-clocks.tsv:2-31`) |
| Join/equality | `version_join` compares installed vs repo by **string equality** (`tools/tsukuroi-census.sh:1410-1429`), first occurrence wins; `vercmp` is only consulted for differently-spelled values | equality/inequality on normalized text plus the new numeric regression rule; `norm_version` strips a leading `v` (BASE `corpus/release-clock.py:362-363`) |
| Meaning of "older" | installed older than repo = an update is available → `behind`, which degrades to `REQUIRES-PREP` (`tools/tsukuroi-census.sh:277`) — normal, actionable | observed newest-stable older than the anchor = stale/cropped/withdrawn feed evidence → `REGRESSED` exit 1 — a finding, never a release (`plans/round-27.md` C2; QM25) |

The two implementations agree on nothing reusable beyond "compare the numeric
components". `vercmp` is wrong for kagi on three counts:

1. Version grammar: ALPM ordering includes pkgrel/epoch and `_`-suffixed
   pre-releases. kagi's contract explicitly excludes prerelease/build ordering
   and non-strict anchors (in-flight `corpus/release-clock.py:372-375`); the
   round-27 C2 selftest requires `1.2.3-rc1` above `1.2.2` to be **ignored**
   (`corpus/release-clock.py:1428-1443`). A `vercmp` call would import the
   opposite grammar.
2. Lane boundary: kagi's `PROVINCE.md:54` disclaims installed-runtime and
   system-package management; tsukuroi's `PROVINCE.md:25-28` refuses to install,
   upgrade or remove packages and `PROVINCE.md:47` (ADJ-02) makes package
   owner/version a **handoff** from tsukuroi to kagi, with "no secret values …
   helper invocation". A kagi gate that shelled out to pacman/vercmp would
   silently absorb the host surface that ADJ-02 deliberately mediates.
3. Failure mode: tsukuroi treats an absent `vercmp` as `dir='?'` and counts
   `diff_unclassifiable` (`tools/tsukuroi-census.sh:1609-1617`), i.e. it keeps
   the reading visible but unclassified. kagi's binder would map non-strict
   values to `None` → inequality only → **CLEAN** on a downgrade, the exact
   class C2 exists to refuse.

Observed live-table pre-check (static, not executed): no feed row has a strict
numeric observation below its own numeric anchor; per-feed floors are python
`3.15.1`, vault `2.2.0`, openbao `2.7.1`, sops `3.13.3`, curl `8.23.0`
(`corpus/release-clocks.tsv:2-31`). `S012`'s non-numeric `v1.21.x` observes
`2.2.0`, equal to the vault floor (`:9`); `S029` is `8.23.0/8.23.0` (`:26`).
So the plan's "live default receipt still CLEAN30" is statically plausible — but
unrun, therefore not a pass.

## 2. Do C1 and C2 stay in-lane?

**C2: yes.** Its production surface is kagi-owned `corpus/release-clock.py` and
`corpus/release-clocks.tsv`; the working-tree file contains no `pacman`,
`vercmp` or `subprocess` reference (grep: zero hits in `release-clock.py`;
`self-counts.py` alone imports `subprocess`, for ledger rows). Inputs are public
HTTPS feeds already registered as S033–S037/S039 (`corpus/SOURCES.md:42,43,46`) and
the two ordering specs S042/S043 (`corpus/SOURCES.md:49-50`, working tree). No
installed/sync-DB package version is observed, so no tsukuroi ground is touched.

**C1: yes.** It extends kagi's own round-25 binder with `KN-*` rows
(`corpus/self-counts.tsv:58-79`, working tree) and does not modify
`corpus/self-counts.py` (absent from `git status`). The sibling convention is
not a substitute: tsukuroi's freshness gate cannot compute a number from its
source; it only proves an old quote was noticed.

## 3. Sibling precedent that is genuinely reusable — and what C1 still lacks

tsukuroi solved "a stale number in a knowledge entry must carry a dated notice"
with a per-correction record:
`tools/check-freshness-r17.py:13-24` (registry contract),
`:201-220` (`baseline_quote` must remain an exact substring; notice heading
appended after the baseline boundary), `:288-297` (`STALE-UNFLAGGED` when the
old literal is present and the notice heading is absent), registry shape in
`corpus/knowledge/freshness-recheck-r17.json:1-30`.

Two limits on reuse:

- The append-only prefix rule (`:202-204`, "bytes before the appended notice
  differ from baseline") cannot be imported: kagi corrects numbers in place and
  its locator regexes require exactly one current line per number.
- The reusable part is the **record shape plus the old-literal presence
  assertion**, not the gate.

C1 does not yet have that assertion. `corpus/self-counts.py` captures one
integer from one line (`corpus/self-counts.py:1-20`), and
`.ufo/waves/round-27/tools/c1-measure.py:40-64` only proves that bumping the
captured digit turns exactly that id STALE. Nothing checks QM21's "old value
retained in an explicit history clause". Concrete: deleting
`; 72 at round-13 close` from `corpus/knowledge/claim-ledger.md:304` would leave
`KN-LEDGER-REPRO-SELFTEST` (`corpus/self-counts.tsv:68`) green, because the
locator binds only `170`. [INFERENCE from the static binder code; not executed.]

## 4. Concrete counterexamples observed at the snapshot (a and b repaired by L1 at 15:28-15:29Z; retained as class evidence; c and d are checks/drift notes)

**(a) The round-27 lesson's own case count contradicted the ledger and the code at 15:26Z.**
`corpus/lessons/round-27.md:77-79` and `:85` then said "Six new selftest cases" /
"REGGRESSED rule + six selftest cases". The working-tree diff added **nine**
increments: seven `run_case` calls at `corpus/release-clock.py:1059-1090` plus
two top-level `cases += 1` blocks at `:1439` and `:1454` (no removed cases;
static `git diff` count 7 + 2). `corpus/claim-ledger.tsv:82` already pinned
`RELEASE_CLOCK_SELFTEST: PASS (76 cases)` and said "+ nine"; `PROVINCE.md:54`
and `SKILL.md:48` said 76. The lesson was rewritten at 15:28:26Z; it now says
"Nine new selftest cases (67→76)" and M27-3 records the first-draft mislabel.
The class remains: the lesson and the wave evidence file are outside every
binder's population (`self-counts` covers SKILL/PROVINCE/README and now
`knowledge/*.md`, not `lessons/` or `.ufo/`), so this needed a human reviewer.

**(b) The C1 evidence record disagreed with landed bytes at 15:26Z.**
`.ufo/waves/round-27/knowledge-migrations.json` (then mtime 12:16 local) recorded
the `new` text of `corpus/knowledge/claim-ledger.md:81,301-304` as `round-10`
and without the landed wording; the file said `round-13-close` and
`(the 16th case when written)`. Five of fourteen recorded new lines differed
(`:81`, `:301`, `:302`, `:303`, `:304`). The `old` strings matched BASE exactly,
and `corpus/lessons/round-13.md:123,127` confirms `claims=17 stamped=33` and
`SELFTEST: PASS (72 cases)` at round 13 — the file was right and the record a
superseded draft. At 15:28:51Z the record was regenerated (11 changes, 0 byte
mismatches, labels now round-13); M27-3 now records this as an overclaim in the
first draft. The check is still manual: nothing gates record↔tree equality.

**(c) Checked, not a defect, but a trap worth naming.** `corpus/release-clocks.tsv:26`
(S029) notes "anchor names 8.23.1" while its clock anchor is `8.23.0`;
`corpus/SOURCES.md:43` explains that 8.23.1 is curl's unreleased dev label, so
the clock anchors on the released 8.23.0. A reader "fixing" the row to match the
note would make it `REGRESSED` under the new rule. Similarly, `feed_floors`
groups by the literal `feed_url` string (`corpus/release-clock.py:390-410`), so
two spellings of one feed would evade the floor; the lesson's limits name
non-numeric anchors, equal-to-floor observations and prereleases, but neither of
these.

**(d) The meta-count moved three times during the scan.** At 15:20Z
`corpus/self-counts.tsv` held 16 `KN-*` rows (38+16=54 expected claims) while the
ledger still said 56; by 15:25Z the table held 22 `KN-*` rows over 8 docs and
the ledger said `claims=60` (`corpus/claim-ledger.tsv:81-82`). The current pair
agrees (60/60), but any prose that copies the intermediate number is stale. This
is the same drift class as (a) and (b), one layer up.

## 5. Proposed move (one, bounded)

Make the C1 corrections carry a machine-checked old-value record, reusing
tsukuroi's freshness shape **wave-locally** (the record is byte-clean again as
of 15:28:51Z; what is missing is the check that keeps it so):

1. Keep the regenerated `.ufo/waves/round-27/knowledge-migrations.json` and add
   `old_literal` / `history_clause` fields per corrected entry.
2. Add a `--history` step to `.ufo/waves/round-27/tools/c1-measure.py` that
   byte-compares each `new` line to the landed line and asserts each
   `old_literal` still occurs in the doc (or in the named clause), emitting a
   typed `HISTORY-MISSING`. This mirrors
   `check-freshness-r17.py:205-209` (old quote still present) and the
   `STALE-UNFLAGGED` direction `:288-293`, without importing the append-only
   prefix rule kagi cannot satisfy.
3. Bind the lesson's case count or make it count-free. It currently says "Nine
   new selftest cases (67→76)" and agrees; the point is that `lessons/` is
   outside every binder, so the next edit has the same exposure.

Affected axes: **calibration (C1) improves** — QM21's history clause becomes
executable and the evidence record stays byte-equal to the artifact;
**freshness (C2) is unchanged** — no release-clock code or table edit, only the
lesson/record text. Risks: the record is post-hoc evidence, so label any
regenerated copy with its timestamp and retain the draft diff rather than
silently overwriting; substring presence is a weak assertion (the old value can
survive in an unrelated context), so name it presence, not provenance; the new
step is one more wave-local run, no production surface change.

Verification (L1, once): migration record vs tree → 0 mismatched lines (holds at
15:29Z; currently manual); scratch deletion of the line-304 history clause →
`HISTORY-MISSING`, not CLEAN; `c1-measure.py` BASE/after results unchanged by
the history step (22 `KN-*` rows over 8 docs, 60 claim rows at 15:29Z; the
lesson's five-stale-at-BASE count comes from `c1-before.json` and was not
re-derived here); `corpus/claim-ledger.tsv:82` 76 cases equals executed
`RELEASE_CLOCK_SELFTEST` output; lesson count absent or 76.

## 6. What I did not check (unrun is not a pass)

- Did not execute `release-clock.py`, `self-counts.py`, `c1-measure.py`,
  `c2-measure.py`, or any tsukuroi gate/selftest; all counts are static reads.
- Did not open or verify S042/S043 (SemVer/PyPA) pages or quotes; only their
  working-tree `corpus/SOURCES.md:49-50` text.
- Did not run `vercmp` or any pacman query, and did not verify ALPM ordering
  edge cases; the grammar claim rests on tsukuroi's own comments and observed
  version shapes.
- Did not scan sibling `corpus/` or `.ufo/` trees beyond the named tsukuroi
  files (one recursive grep over sibling `.ufo/` timed out and was abandoned; it
  had returned only tsukuroi SKILL snapshots).
- Did not verify the full body of `corpus/knowledge/freshness-recheck-r17.json`
  record by record, nor re-run tsukuroi's `--registry-from`.
- The kagi worktree moved during this scan: `release-clock.py` 15:22Z,
  `PROVINCE.md`/`claim-ledger.tsv` 15:25Z, `corpus/lessons/round-27.md` and
  `knowledge-migrations.json` 15:28-15:29Z. Ledger R25-03 changed 73→76, the
  `KN-*` rows 16→22, claims 56→60. Findings (a) and (b) were observed pre-fix
  and repaired during the scan; they are retained as class evidence, not as open
  defects. Any later edit supersedes this snapshot.
- No tool installs or upgrades. No host-private reads, no vault/account/handler/
  CDP contact, no sibling writes, no Git/jj mutation.

This is lane-authored advisory evidence, not non-author closure.
