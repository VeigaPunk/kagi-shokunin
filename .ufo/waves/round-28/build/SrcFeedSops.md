# SrcFeedSops — SOPS release feed re-open (S033), round-28 curation

BASE `3553d499577084a6c98d7078906017840bbf7b28`. `git diff --stat BASE -- corpus/SOURCES.md corpus/release-clocks.tsv corpus/release-clock.py` printed nothing (exit 0), so every `corpus/` line cited is BASE-identical. Worktree HEAD was `b9a42c0`; `.ufo/waves/round-28/tools/` is empty at HEAD, so neither frozen measure script existed to inspect.

## Access receipt

| field | value |
|---|---|
| URL / access date (UTC) | `https://github.com/getsops/sops/releases.atom` / 2026-10-21T17:06:39Z |
| HTTP / final URL | **200**, unchanged (no redirect) |
| bytes | **253037** |
| sha256 (raw body) | **`47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6`** |
| `ETag` | `W/"47a224ad71435b7f5cae863bc96c0146"` (weak; sha256 prefix) |
| second fetch / saved body | byte-identical, same sha (`cmp` → `BODY_STABLE=yes`); `.ufo/waves/round-28/sandboxes/SrcFeedSops/sops-releases-2026-10-21.atom` |

## Findings

**F1 — the feed still equals S033's located anchor; C2's binding holds today for S008–S011.**
Newest stable entry: title `v3.13.3`, id `tag:github.com,2008:Repository/40684033/v3.13.3`, link
`.../releases/tag/v3.13.3`, `<updated>2026-07-23T05:29:11Z</updated>` — all three sub-claims of S033's
anchor cell at `corpus/SOURCES.md:39` (title, tag link, updated). BASE `parse_latest_version`
(`corpus/release-clock.py:715`) over the saved body returns `3.13.3` (max over 10 entries = first entry).
Cross-checks: `HEAD /releases/latest` → **302 → /releases/tag/v3.13.3**; the releases HTML page lists
`v3.10.0`…`v3.13.3` and nothing newer. BASE `observe_one` (`:767`), replayed offline on the saved body
through `request_body` with a fake opener + pinned resolver, returns `parsed_version=3.13.3,
verdict=not-fired, http_status=200`, same sha, for **S008, S009, S010, S011** (`corpus/release-clocks.tsv:5-8`,
each `anchored=3.13.3`). `version_is_named(S033.anchor, "3.13.3") == True` (`:341`). The recorded receipt
`corpus/source-fetches.tsv:76` already holds sha `47a224ad…`, 253037 B, status 200
(`curl-fsSL-compressed-v1`): my independent fetch reproduces both, so the feed is unchanged since capture.

**F2 — concrete C2 counterexample on this group: BASE is blind to a lowered SOPS anchor.**
In-memory BASE `evaluate` (`:502`) on the BASE tree vs the G1 mutation (S008–S011
`anchored_version`/`observed_version` → `3.13.0`, verdict `not-fired`) gives **symmetric error
difference ∅** — the mutation is invisible. The proposed C2 predicate
(`version_is_named(sources[feed_source_id]["anchor"], anchored)`) flags **exactly S008–S011** on the
mutation and **none** on the BASE tree: non-vacuous here, no false accusation today.

**F3 — implementation hazard A: bind to `sources[feed_source_id]`, not `sources[source_id]`.**
BASE `:566` is `anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)`.
The row's own anchor cell names no version: `version_is_named(S008.anchor,"3.13.3") = False`
(`§Documentation; upstream main snapshot…`), and S009–S011 = False (`…docs commit 9b7b84e…`, last
modified 2026-05-15). Dropping `is_derived or` without switching to the **feed** row's anchor would
type four false findings; C2 as specified uses S033's cell, so the swap is mandatory.

**F4 — implementation hazard B: `version_is_named` tolerates a suffix after the version.**
Measured: `version_is_named("Entry titled v3.13.3-rc1, tag link /releases/tag/v3.13.3-rc1; feed fetched
2026-10-21", "3.13.3") == True`, because `-` is not in `(?![A-Za-z0-9.])` at `:345`. A feed row whose
located anchor were a prerelease would spuriously satisfy a `3.13.3` binding. Recommend binding the
exact stable token (`^v?X.Y.Z$` on the located title, or `parse_latest_version` over the row's saved
capture). The same helper correctly refuses `3.13.30` and `3.13.03` (both False).

**F5 — C1 is live-reachable through this registry row's feed.** `STABLE_TITLE_RE` (`:710`) accepts
`v3.13.03`. Isolated first-entry mutation (title **and** tag href `v3.13.3`→`v3.13.03`, no residual
`v3.13.3` in that entry) yields `parse_latest_version = 3.13.03`, `norm_version` unequal to `3.13.3`,
`is_regression("3.13.3", parsed) = False`, so the observe branch at `:801` returns `fired` for a row
`v3.13.3` — the exact C1 defect, reached through SOURCES row S033. Evidence only; the plan's frozen
F1–F4 fixtures are untouched and I propose no change to them.

**F6 — feed shape a parser must respect.** Atom is a **10-entry** window (oldest `v3.10.1`; the HTML
page still lists `v3.10.0`). Entries carry `<updated>` and **no `<published>`** (saved body lines 8–14).
Feed-level `<updated>` is `2026-07-23T04:56:54Z`, *earlier* than the newest entry's `05:29:11Z`. All ten
titles are plain `vX.Y.Z` — no prerelease or module tags today, so this feed does not exercise the
exclusion logic S034/S035 need.

**F7 — duplicate check: no W04.** The URL occurs in exactly one registry row (`corpus/SOURCES.md:39`,
S033); START census (`.ufo/waves/round-28/census-start.txt:2-12`) lists 11 W04 and **none** names S033.
A second row for this URL would itself create a W04 duplicate.

**F8 — recheck boundary, not a defect.** The newest entry is exactly **90 days** old today
(2026-07-23 → 2026-10-21), S033's `recheck` is `90d`, and the next re-open from `opened` is
**2027-01-19**: zero slack if entry age is measured, but the clock is on-release, so nothing fires.

## Tier and recommendation

**Tier A** (primary maintainer-published release metadata; affirms the existing `A` at
`corpus/SOURCES.md:39`). **Retain S033 unchanged — do not add a row**: its `opened` date is already
2026-10-21, its anchor already states `v3.13.3 … updated 2026-07-23T05:29:11Z`, and its fetch receipt
pins today's bytes. Only optional wording that names the C2 role is defensible:

- `scope` (cell 4) append: `…; its located anchor is the binding target for those rows' derived anchors`.
- `teaches` (cell 6) append: `The registry anchor names v3.13.3, the value every derived SOPS row must equal.`

**No REJECT**: the source grounds the stated purpose (release identity for the S008–S011 clocks). The
only rejectable act is a duplicate row for the same URL, which I recommend against.

## Located quote

> `<title>v3.13.3</title>`

- Locator: Atom entry **1 of 10**, id `tag:github.com,2008:Repository/40684033/v3.13.3`; byte offset
  **715**, line 12; `raw-literal-v1` (occurs exactly once); verbatim 1 token, paired with
  `<updated>2026-07-23T05:29:11Z</updated>` (line 10).

## Commands run (no tool installs or upgrades were needed)

| command | exit | result |
|---|---|---|
| `curl -sS -L -o sops-releases-2026-10-21.atom -w …` | 0 | 200, final URL unchanged, 253037 B, sha `47a224ad…` |
| same URL again + `cmp` | 0 | identical bytes, `BODY_STABLE=yes` |
| `curl -sSI …/releases/latest` | 0 | 302 → `/releases/tag/v3.13.3` |
| `curl -sS -L -o …/releases` | 0 | 200, 775958 B, tags `v3.10.0`…`v3.13.3` |
| `grep -n 'sops/releases.atom' corpus/SOURCES.md` | 0 | 1 hit, line 39 (S033); recursive `corpus/` scan adds only fetch receipt, clock rows, lesson-25 quote |
| `git archive BASE \| tar -x -C sandboxes/SrcFeedSops/base` | 0 | BASE tree for line-accurate citations |
| `git diff --stat BASE -- corpus/{SOURCES.md,release-clocks.tsv,release-clock.py}` | 0 | no output (identical) |
| python3 BASE `parse_sources`/`parse_latest_version`/`version_is_named`/`observe_one`/`evaluate` replays (offline, sandbox) | 0 | F1–F5 measurements |
| `grep -n 'S033' .ufo/waves/round-28/census-start.txt` | 1 | no matches (no W04 for S033) |

## Not checked

- Did not run any lane gate, selftest, census or `release-clock.py` command in the lane checkout; all
  code execution was BASE code imported in my sandbox against sandbox copies plus the saved body. My
  `evaluate` replay lacked the retained observation receipt (`derived=0`, `NOT OBSERVED` rows); I
  compared error sets, not the full `CLEAN (… derived=15 …)` control line.
- Did not inspect `corpus/lessons/round-28.md` (absent at HEAD) or the not-yet-written
  `c1-measure.py`/`c2-measure.py`; the C2 predicate is the plan's wording applied to BASE helpers.
- Did not open the Vault, OpenBao, curl or python.org feeds live (other seats); the statement that all
  15 derived rows are named by their feed anchors is a static spot-check of BASE cells, not a live re-open.
- Did not read v3.13.3 release notes (this row is release metadata only), nor mirrors, API rate limits,
  or tag listings beyond `/releases/latest`.
