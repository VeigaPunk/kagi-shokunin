# KnowHandlerTrustBoundary — C1 inventory of `corpus/knowledge/handler-trust-boundary.md`

Seat `KagiR26.KnowHandlerTrustBoundary-17` (leaf scout, round-27 BUILD wave).
Axes exercised: **calibration** (what the entry may state as current, and to what
source it binds) and **freshness** (a lane-owned pointer whose numbers moved).
No production file was written; no gate, selftest, binder or replay was run.

- Frozen BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b`; `git rev-parse HEAD`
  at read time = BASE.
- Target is **clean vs BASE**. The worktree carries the round-27 integration
  edits (LOG/PROVINCE/SKILL/QUALITY/README/SOURCES, `release-clock.py`, the
  ledger/self-counts/stamps/source-fetches tables and four knowledge entries);
  none touches `handler-trust-boundary.md`. Its bytes:
  sha256 `fa17fff38dfbed86d66acb17dcb2c931b9c31280ce4d2ce41f05269b12561eba`,
  19410 B, 316 newline-terminated lines plus an unterminated final line
  (317 logical lines). `corpus/stamps.tsv:38` carries the same full sha256
  (`fa17fff3…61eba`) with `316	19410`, unchanged at BASE and in the worktree.
  All entry line numbers below are the committed entry.
- `SCORECARD.md` is dirty in the worktree (+19 lines appended at EOF for round
  27). **Every SCORECARD line number below is read from
  `git show 0a47dd18:SCORECARD.md`, not the worktree.**
- Population rule applied: `plans/round-27.md:9-18` (round-27 working document,
  untracked at BASE); `corpus/QUALITY.md:118` (QM21, present at BASE) and the
  round-27 working-tree QM26 at `corpus/QUALITY.md:133` (added after BASE:124;
  its exclusion list names positional indexes and unpinned numbers);
  `corpus/lessons/round-25.md:49-56` (R25-C6, at BASE);
  `corpus/lessons/round-27.md:37-47` (working document); format
  `corpus/self-counts.tsv:1-12` (header unchanged at BASE; the `KN-*` rows are
  the working-tree addition after BASE:50).
- Census: **98 of 317 logical lines carry at least one numeric token**
  (decimal runs, space-grouped thousands, dotted versions; code fences included).
  The full line-level inventory is
  `.ufo/waves/round-27/build/KnowHandlerTrustBoundary.numbers.tsv`
  (27 rows; every published locator was executed against the entry: one match,
  exactly one capture group).

## 1. Verdict

**In-population current-tense numbers about lane-owned artifacts: zero.**
This entry states no selftest case count, row/stamp/claim/pin count, bound, or
file/line count of a lane-owned artifact that `rows:`, `ledger:` or `expect:`
can define. It is a host/substrate entry: its subject (`~/.local/bin/the-janitor`,
`~/.config/the-janitor/client.py`, the opencode binary) has been absent since
2026-10-15 by the entry's own erratum (`corpus/knowledge/handler-trust-boundary.md:299-303`),
and the table header already excludes "host measurements (… handler/DB counts)"
(`corpus/self-counts.tsv:8-9`). No ledger row names this entry or pins a
distinctive value from it (greps for `162`, `333`, `117` and both SCORECARD
anchors return 0 rows); the only ledger row whose execution needs the handler
binary is `corpus/claim-ledger.tsv:26` (`R12-01`, `[substrate]`, needs `op` and
`$HOME/.local/bin/the-janitor`).

**One carried defect, not a count:** the entry's two `SCORECARD.md` evidence
spans at `:306` were exact when written at `f4a8dd9` and are **+4 lines stale at
BASE**. This was already found in round 22 for a sibling entry
(`.ufo/waves/round-22/build/Entry13.md` §8) and patched with a locator note in
`handler-on-disk-state.md:280-288` and `janitor-env-contract.md:115`; this entry
never received the note. Detail in §3. It is a positional citation (QM26
exclusion class), not a bindable count, and it does not falsify the erratum.

C2/release-clock: no number here is a release anchor or observation —
`grep -n 'opencode\|janitor' corpus/release-clocks.tsv` returns no row, so the
round-27 REGRESSED rule has no purchase on this entry. The vendor version
`1.18.31` (`:8`, `:276`) is a plain version fact with an "upgrade can move this"
caveat (`:277-278`), not an on-release clock.

## 2. In-population binding table (format: `corpus/self-counts.tsv`)

| id | doc | locator | source | extract | note |
|---|---|---|---|---|---|
| — | — | — | — | — | no row: this entry contains no current lane-artifact count with a lane-local defining source |

This is not an omission. The entry's numbers fall in the table's declared
exclusions (host/substrate measurements, dated measurement sections, vendor
facts, recipe syntax) or are positional spans; §5 lists them with reasons and
§3 handles the only lane-owned file references.

## 3. The one lane-owned number class present: two SCORECARD spans, both STALE

Exact text, `corpus/knowledge/handler-trust-boundary.md:306`:

> `` `SCORECARD.md:454-466` and `SCORECARD.md:496-506`. ``

| # | claimed | exact when written (`f4a8dd9`, 2026-10-15) | at BASE `0a47dd18` | verdict |
|---|---|---|---|---|
| A | `SCORECARD.md:454-466` | `:454` = `## Round-19 correction…`, `:466` = its last line | `:458` = the same header, `:470` = its last line | **STALE pointer, +4** |
| B | `SCORECARD.md:496-506` | `:496` = `Before measurement…`, `:504` = `Observed: SOURCE_FRESHNESS…`, `:506` = last caveat line | `:500` = `Before measurement…`, `:508` = `Observed…`, `:510` = last caveat line | **STALE pointer, +4; the cited range ends before the measured line** |

Evidence at BASE (all from `git show 0a47dd18:SCORECARD.md`):

```
458  ## Round-19 correction (appended 2026-10-14) — the describe-don't-pin claim was too strong
470  historical in an append-only erratum (do not expand `af8873ca…`).
496  Target: `unqualified=4 → 0`, `historical=0 → 4`, while absent sources remain
500  Before measurement: commit `15ea78c767ec1730ff19144e5cf62c9adf54e483`,
508  Observed: `SOURCE_FRESHNESS: entries=4 historical=0 unqualified=4 absent_sources=3/3`.
510  every sentence in the entries; scoped errata require human review as well.
```

At `f4a8dd9` the same anchors were 454 (header), 466 (section end), 496 (block
start), 504 (`Observed`), 506 (block end); SCORECARD.md was 506 lines then,
1079 lines at BASE. The shift is a **pure insertion of four scorecard rows**
(one round-20 row and three round-21 rows) immediately above the correction:
`git diff f4a8dd9 0a47dd18 -- SCORECARD.md` hunk `@@ -452,0 +453,4 @@`, plus 569
lines appended at EOF; 0 deletions. The entry itself has no commit in
`f4a8dd9..0a47dd18` — the pointer was never revised, the target moved.

Why it is not a binder row: a span is not a count. `rows:SCORECARD.md` counts
data lines (835 nonblank non-`#` lines at BASE by `corpus/self-counts.py:88-90`;
893 nonblank, 1079 total) and cannot yield 466; no ledger row pins either
anchor (`grep -c 'Round-19 correction\|SOURCE_FRESHNESS' corpus/claim-ledger.tsv`
= 0); no `expect:` pin exists. This matches the sibling finding for
`handler-on-disk-state.md` (`.ufo/waves/round-27/build/KnowHandlerOnDiskState.md`
C7: "a span is not a count any allowed source can extract").

Prior art and the gap: round-22 `Entry13.md` §8 recorded the identical drift
("`454-456` are now the round-21 move-log rows; the round-19 correction block
it means is `458-470`… the **Observed** result line it promises is `508`,
outside the range") and offered an append-only pointer note. The note landed in
`handler-on-disk-state.md:280-288` and `janitor-env-contract.md:115`, but
`grep -n 'Round-22\|locator note' corpus/knowledge/handler-trust-boundary.md`
has no hits. `config-layering.md:125-126` also cites the spans without a note
(that entry belongs to another seat; flagged, not audited here).

Proposed correction (append-only; the erratum is the filed historical record):

> Pointer correction (2026-10-21): the two SCORECARD ranges above were exact at
> the 2026-10-15 write. Scorecard rows later inserted above them moved the
> Round-19 correction to `SCORECARD.md:458-470` and the SOURCE_FRESHNESS block
> to `SCORECARD.md:500-510` (`Observed:` at `:508`). The original ranges are
> retained as written.

If L1 prefers an in-place edit, QM21's history clause gives:
`` `SCORECARD.md:458-470` `` (was 454-466 at the 2026-10-15 write) and
`` `SCORECARD.md:500-510` `` (was 496-506; `Observed:` at 508). Round-22's
alternative mapping was `496-506 → 504-508` (command + result rather than the
exact span translation); either reading fixes the exclusion of line 508.
Either edit changes the entry bytes: per round-22 `Entry13.md` §7.1, re-stamp
**after** the final write (the current stamp is clean), and do not touch lines
1-90.

Optional stronger guard (not added; production is L1's): a non-host claim row
running `grep -n '^## Round-19 correction' SCORECARD.md` expects `^458:`, and
`grep -n '^Observed: `SOURCE_FRESHNESS' SCORECARD.md` expects `^508:`. Those
would pin the anchors, not the span endpoints the entry's locator captures
(466/506); binding the endpoints needs the entry's locators rewritten to
capture 470/510 after correction. This is a design choice for L1, not a C1
deliverable.

## 4. Self-positional references — verified OK

These are positions inside this same entry, not counts; the body was never
edited after the erratum was appended, so they are stable.

| line | text | value | check at BASE |
|---|---|---|---|
| 293 | "This qualifies original lines 3-11 (handler/client and opencode source" | 3-11 | `:3` starts `Source basis:`, `:11` ends "re-grep before citing." — OK |
| 294 | "basis), the verification marker at 9-10, the by-hand declaration at 17," | 9-10, 17 | `:9-10` probe-verification date; `:17` `Reverify: by-hand: control-plane-scratch` — OK |
| 295 | "and all source-dependent conclusions and recipes through line 286." | 286 | `:286` = "callers." (last body line), `:287` blank, erratum header `:288` — OK |
| 316 | "the same-uid isolation limit at original lines 284-286 remains a historical" | 284-286 | `:284-286` = the same-uid isolation bullet; pre-erratum `f4a8dd9^` had 286 logical lines with the same content — OK |

Note the contrast: the SCORECARD spans drifted because the target file grew; the
numbers into this entry did not, because this entry's body is frozen.

## 5. Excluded numeric census (and why)

The work item excludes vendor facts and host measurements of absent substrate;
QM26 additionally excludes dated measurement sections, erratum history and
positional indexes. Grouped inventory (line numbers in this entry):

| class | lines | examples | why out |
|---|---|---|---|
| Host artifact sizes / line counts | 3, 6, 148 | "333 lines" (`the-janitor`), "117 lines" (`client.py`), "14 lines" (`janitor_auth.ts`) | host files, not lane-owned; absent since 2026-10-15 (`:299-303`); body historically qualified at `:295`; no ledger pin |
| Host source line references | 4-6, 51, 59, 84, 109-111, 120-122, 176-177, 180, 184-185, 263 | `L186-226`, `L22-38`, `L130-131`, "3 sites: L131, L140, L176" | line refs into absent host files; unverifiable and not lane artifacts |
| Host runtime / probe / DB counts | 36, 55, 64, 71, 77, 81, 103, 115, 127-129, 158-159, 185, 192 | "162 paths", "26 entries", "13 tools", "20 global JSON agents", "0 hits", "51 ms", `9 240 576 B`, `session=7 message=39 part=55`, "×10", "120 × 0.5 s" | host measurements of absent substrate; explicitly excluded by `corpus/self-counts.tsv:8-9`; the body is a dated measurement (`:9`, `:30` — 2026-09-28) |
| HTTP status / ports / modes / exit codes | 32-39, 49, 54, 73, 127-133, 181-183, 214-236, 251 | 200/401/500/404; 41994-41999, 34113, 8080, 40961; 0600; exit 1 | runtime observations and recipe syntax, not artifact counts |
| Vendor facts | 8, 276, 188, 165 | opencode `1.18.31`; tmux `3.7b`; uid `1000` path | vendor/host, no lane source |
| Recipe constants / code fences | 174, 205-267 | ports, `sleep 2`, `openssl rand -hex 32`, `kill %1 %2` | unexecuted reproduction recipe (anti-claims `:268-287` say so) |
| Dates and round tags | 9, 30, 291, 158-159, 288, 299 | 2026-09-28, 2026-08-29→2026-09-21, 2026-10-15, round-6/round-16 | history; QM21/QM26 |
| Structural / spelled-out counts | 19, 62, 79, 145, 171, 139 | "three verified routes", "two disabled ones", "two completed `janitor_auth` parts", "Both halves", "at most once per request" (non-numeric bound) | counts/bounds of host objects or recipe parts, not lane artifacts |
| Lane-owned positions | 306 (stale, §3), 293-295/316 (OK, §4) | SCORECARD spans; "original lines …" | spans are QM26 positional citations, not counts |

Judgment calls a non-author may dispute: (a) treating the two SCORECARD spans
as reviewable at all (QM26 excludes positional indexes; round-22 and the sibling
round-27 report both still record the drift); (b) leaving "three verified
routes" out — it is a self-consistent count of the entry's own findings, but the
findings are host-route observations, not lane artifacts; (c) the erratum's
blanket "source-status: historical" does **not** by itself make the body's
numbers historical under QM21's strict wording ("only an explicit history
clause with a newer value beside it"), and the round-27 QM26 draft goes further:
"a number an erratum concedes stays in scope where the body states it." I
therefore rested the ruling on the host/substrate and dated-source-basis
exclusions first, not on the erratum; the erratum is corroboration, not the
reason these numbers are out.

## 6. Reproducible evidence (read-only)

```bash
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
git rev-parse HEAD                                   # 0a47dd189356ea66ec83c3891eed54526e95b89b
git status --porcelain -- corpus/knowledge/handler-trust-boundary.md   # empty
sha256sum corpus/knowledge/handler-trust-boundary.md; wc -l -c corpus/knowledge/handler-trust-boundary.md
git show 0a47dd18:corpus/stamps.tsv | grep handler-trust-boundary
# pointer drift
git log -S 'SCORECARD.md:454-466' --format='%h %ad %s' --date=short -- corpus/knowledge/handler-trust-boundary.md   # f4a8dd9 2026-10-15
git show f4a8dd9:SCORECARD.md | grep -n '^## Round-19 correction\|^Observed: `SOURCE_FRESHNESS'   # 454, 504
git show 0a47dd18:SCORECARD.md | grep -n '^## Round-19 correction\|^historical in an append-only erratum\|^Before measurement: commit\|^Observed: `SOURCE_FRESHNESS\|^every sentence in the entries'   # 458,470,500,508,510
git diff --stat f4a8dd9 0a47dd18 -- SCORECARD.md      # 573 insertions, 0 deletions
git diff -U0 f4a8dd9 0a47dd18 -- SCORECARD.md | head  # @@ -452,0 +453,4 @@ (round-20/21 rows)
# no pins
grep -c '162' corpus/claim-ledger.tsv; grep -c '333' corpus/claim-ledger.tsv; grep -c '117' corpus/claim-ledger.tsv
grep -c 'Round-19 correction\|SOURCE_FRESHNESS' corpus/claim-ledger.tsv
grep -c 'handler-trust-boundary' corpus/self-counts.tsv
grep -n 'Round-22\|locator note' corpus/knowledge/handler-trust-boundary.md   # no hits
```

Observed outputs: entry clean and stamped; `f4a8dd9` 506-line SCORECARD with
anchors 454/504; BASE 1079-line SCORECARD with anchors 458/508 and section
458-470; 573 insertions/0 deletions; all pin greps 0; no locator note.

## 7. What I did NOT check

- No host contact of any kind: `~/.local/bin/the-janitor`,
  `~/.config/the-janitor/*`, `~/.config/opencode/*`, the opencode binary, the
  SQLite DB, tmux, ports and `op` were not read, hashed or exercised. The
  abbreviated hashes (`2408b0c9…`, `8179b241…`) and every host line reference
  remain unverified; the entry's ENOENT claim is cited, not re-measured.
- No gate, selftest, binder or replay was run: not `corpus/self-counts.py`,
  not `c1-measure.py`, not `claim-ledger.sh`, not `release-clock.py`. Absence of
  a row in this report is a population ruling, not a test result.
- I did not audit the other three errata that cite the same SCORECARD spans
  (`config-layering.md:125-126`, `handler-on-disk-state.md:265-266`,
  `janitor-env-contract.md:105-106`) beyond noting the two that carry locator
  notes; the `config-layering.md` one is another seat's target.
- I did not verify the semantic correctness of SCORECARD:454-470/500-510, only
  that the cited ranges no longer bound the cited sections.
- I did not test whether a host row could be re-measured (substrate absent by
  the entry's own record; `R12-01` is `[substrate]` and was not executed).
- QM21's strict "newer value beside it" reading vs the blanket erratum is a
  judgment call recorded in §5(c), not resolved here.

## 8. Tooling

No tools installed or upgraded (nothing was needed; read-only `git`, `grep`,
`awk`, `sha256sum`, Python re). No pacman/uv/npm action.

## 9. Advice to L1 (integration, one line each)

1. Do **not** add `self-counts.tsv` rows for this entry's host numbers: no
   allowed source can define them and the substrate is absent. Name the entry in
   the exclusion note (host/substrate) so zero bindings is not read as omission.
2. Record the two stale SCORECARD spans as carried debt (round-22 precedent) and
   either append the pointer-correction sentence in §3 (re-stamp last) or leave
   the entry untouched and put the drift in the round report; the entry currently
   has no locator note, unlike its two siblings.
3. If a pointer guard is wanted, prefer an anchor `grep -n` claim row over a
   never-checked prose number; the entry's span locators would then need
   rewriting to capture the corrected endpoints (470/510).
