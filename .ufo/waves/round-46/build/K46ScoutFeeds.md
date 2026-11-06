# K46ScoutFeeds — release-clock surface recon (round 46, seat K46ScoutFeeds)

Scope: independent live re-observation of the five bound feed rows + the UTS #18 page, and the
registry-curation questions for S040/S041/S095/S096 and S098. Read-only against the lane except for
this report and its receipt bundle. No candidate was built here; no lane file was edited.

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` · BASE `f5977284a8ce5bab09252be8196ee5dc18489926`
Receipts: `.ufo/waves/round-46/build/K46ScoutFeeds-receipts/` (RECEIPTS.txt + the 9 captured bodies)
Scratch: `/fast/scratch/hyaku/kagi-r46/K46ScoutFeeds/` (no /tmp writes)

---

## 1. Live feed readings vs the pre-freeze positive receipt

Every feed was fetched by me, live, with the same public-HTTPS profile the lane's gate uses
(`curl -sS -L --max-time 60 -A 'kagi-r46-scout/1.0'`), and parsed with the lane's own
`corpus/release-clock.py::parse_latest_version` (imported read-only). The comparison column is
`.ufo/waves/round-46/controls/c2-positive-observe.json` → `parsed_version` for each clock id that
binds that feed.

| id | url | newest stable | date | quote (≤25 words, located) | agrees-with-positive-receipt |
|---|---|---|---|---|---|
| S033 (sops; clocks S008–S011) | https://github.com/getsops/sops/releases.atom | **3.13.3** | entry `<updated>` 2026-07-23T05:29:11Z | `<title>v3.13.3</title>` — first stable entry title (raw byte offset 715 of the live body; count 1) | **yes** — receipt `parsed_version` 3.13.3, sha256 `47a224ad…72ff6`; my body sha256 identical |
| S034 (vault; clocks S012, S013, S022–S024) | https://github.com/hashicorp/vault/releases.atom | **2.2.1** | entry `<updated>` 2026-10-23T17:34:44Z | `<title>v2.2.1</title>` — first stable entry title (raw byte offset 726; count 1) | **yes** — receipt 2.2.1, sha256 `3cbfdd86…5f7ce`; identical |
| S035 (openbao; clocks S014–S016, S021, S025, S026) | https://github.com/openbao/openbao/releases.atom | **2.7.2** | entry `<updated>` 2026-10-26T20:24:37Z | `<title>v2.7.2</title>` — first stable entry title (raw byte offset 729; count 1) | **yes** — receipt 2.7.2, sha256 `a54d1a53…2e0e`; identical |
| S036 (python RSS; clocks S027, S028) | https://www.python.org/downloads/feed.rss | **3.15.2** | `pubDate` Sun, 25 Oct 2026 04:15:38 +0000 | `<title>Python 3.15.2</title>` — newest stable item title (raw byte offset 1583; count 1) | **yes** — receipt 3.15.2, sha256 `9ba8856e…cea1e`; identical |
| S037 (curl; clock S029) | https://curl.se/info | **8.23.0** | `Date: 2026-10-14` (file also carries `Next release: 2026-12-09`) | `Version: 8.23.0` — line 1 of the info file (count 1) | **yes** — receipt 8.23.0, sha256 `788e97f8…92675`; identical |
| S098 (rendered-quote clock) | https://www.unicode.org/reports/tr18/ | n/a (no version token; `parsed_version` is null by design for a rendered-quote clock) | Revision 25, `Date 2025-01-16` | `Revision 25` — Modifications heading, raw byte offset 197172 of the live body (count 1) | **yes** — receipt `parsed_version` null, `located` true, `verdict` quote-located, sha256 `68e34b8b…9c70d`; my body sha256 identical |

Access times: 2026-11-06T19:10:51Z (S033), 19:10:52Z (S034), 19:10:53Z (S035), 19:10:54Z (S036, S037),
18:51:39Z (tr18), 18:55:05Z (tr18-23.html), 18:55:06Z (proposed.html), 19:09:19Z (PropList.txt).
Every fetch returned HTTP 200 with curl exit code 0.

**Stronger than the parsed_version comparison:** all six body digests are byte-identical to the
digests recorded in the pre-freeze positive receipt (`c2-positive-observe.json`) and to the working
tree's round-46 receipt (`final/observe-r46.json`). No feed moved between the pre-freeze observation
(18:45Z), the candidate's observation (19:01Z) and my re-observation (19:10–19:11Z). The kill rule
"a non-author live re-observation disagrees with the candidate receipt's parsed version on any feed
clock that has not released in between" is therefore **not** tripped for any of the five feed rows:
my independent values are 3.13.3 / 2.2.1 / 2.7.2 / 3.15.2 / 8.23.0, equal to the receipt values on
S008–S011, S012, S013, S014–S016, S021–S026, S027, S028, S029.

Parser notes (the gate's own extractor, `STABLE_TITLE_RE` / `STABLE_TAG_HREF_RE` / `TEXT_VERSION_RE`):
- vault feed also carries `v2.2.0-rc1` and `sdk/v0.26.0`; openbao carries `api/v2.7.1: …`,
  `sdk/v2.7.1: …`, `sdk/v2.6.3: …`, `v2.7.0-beta20260909`; python RSS carries `Python 3.16.0a1`
  (prerelease) and `Python install manager 26.4`. All are excluded by the stable-token rules, so
  "newest stable" is 2.2.1 / 2.7.2 / 3.15.2 and not a first-entry or any-version read.
- python RSS order is *not* newest-first (`Python 3.11.18`, `3.13.18`, `3.12.16`, `3.14.10`, then
  `3.15.2`), so only the version-ordered max gives the right answer.

---

## 2. Unicode UTS #18 — revision / version line and date (item 3)

Live read of https://www.unicode.org/reports/tr18/ on 2026-11-06T18:51:39Z, HTTP 200,
199607 bytes, sha256 `68e34b8ba02dac859bfabac7f8d1ecbd08fbc9ec00aa003f239fe3ca7198c70d` — byte-identical
to the committed round-41 capture `.ufo/waves/round-41/capture/S098.body` (same sha, same 199607
bytes, "Revision 25" at raw offset 197172 in both).

Header table (rendered text, `rendered-text-v1` normalization, count 1 each):

> "Unicode® Technical Standard #18 Unicode Regular Expressions Version 25 Editors Mark Davis Date 2025-01-16 This Version https://www.unicode.org/reports/tr18/tr18-25.html Previous Version https://www.unicode.org/reports/tr18/tr18-23.html"

Located quote (raw-literal, count 1, byte offset 197172):

> "Revision 25"

Supporting facts:
- The Modifications section reads `<b >Revision 25</b>`; the page carries no other `Revision NN`
  token (raw `Revision` occurrences: offset 2442 = the header-table `Revision` cell label, offset
  197172 = `Revision 25</b>`).
- The previous published revision is `tr18-23.html` ("Revision 23", 2022-02-08) — fetched live,
  HTTP 200, 205106 bytes; it contains no `Revision 25` (count 0), so `Revision 25` is a
  revision-specific token and is a proper release witness for this page.
- `https://www.unicode.org/reports/tr18/proposed.html` fetched live (HTTP 200, 2578 bytes) serves
  `<title>Proposed Update Not Available</title>` — no pending proposed update.
- Copyright line renders "Copyright © 2025 Unicode, Inc." (rendered count 1).
- Re-derived rejection ground (independent, live): `PropList.txt` (sha256 `f438f532e8737bb8a…d955d6`,
  the same digest the round-41 lesson recorded) gives White_Space = 25 code points; Python
  `str.isspace()` = 29; `isspace − White_Space` = {U+001C, U+001D, U+001E, U+001F}; `White_Space − isspace`
  = ∅. The served page does **not** contain the literal `\p{White_Space}` (raw count 0), while
  `White_Space` occurs 7 times and the Annex-C quote `space (\s) \p{Whitespace} See PropList for the
  definition of Whitespace.` locates under rendered-text-v1 (count 1, raw count 0). So S098's two
  rejection grounds still hold as of this fetch.

---

## 3. Registry curation: S040 / S041 (overdue `2026-11-05`) vs successors S095 / S096

All four rows, read from `corpus/SOURCES.md` at BASE (`f5977284`):

| id | status | opened | recheck | used-by | teaches opens |
|---|---|---|---|---|---|
| S040 | mined | 2026-10-21 | **2026-11-05** | corpus/lessons/round-26.md | `supersedes S027 —` |
| S041 | mined | 2026-10-21 | **2026-11-05** | corpus/lessons/round-26.md | `supersedes S028 —` |
| S095 | mined | 2026-11-05 | **90d** | corpus/lessons/round-40.md | `supersedes S040 —` |
| S096 | mined | 2026-11-05 | **90d** | corpus/lessons/round-40.md | `supersedes S041 —` |

**Quoted contract rules** (`/home/vgpnk/Projects/shokunin/CORPUS.md`, §SOURCES.md):

> Line 105-106 — "`opened` — ISO date the row's author opened the source. `recheck` — ISO date or cadence (`90d`, `180d`, `on-release`)."

> Line 116-118 — "2. **Append-only.** Only `status`, `recheck` and `used-by` change in place, and each change is logged old→new in the round lesson. A correction is a new row whose `teaches` opens `supersedes S0NN —`."

> Line 101-102 — "`teaches` — one grounded learner benefit. Rejected rows read `REJECTED: <reason>; flip: <what would change the verdict>`."

> Line 112-115 — "1. **A row is a claim.** Write it only after opening the source in the round that writes the row. The round lesson's `## Gate` records, for every new row, the URL, the access date, and a ≤25-word quote with its location grounding `teaches`. Non-author verification re-opens a sample."

**What the contract allows / requires for S040 and S041.**

1. *The recheck cell is the only cell that may carry the staleness, and it may be changed in place.*
   `recheck` is one of the three in-place-changeable cells (`status`, `recheck`, `used-by`). The
   permitted values are an ISO date or a cadence (`90d`, `180d`, `on-release`). A past ISO date
   (`2026-11-05`, i.e. overdue on 2026-11-06) is a legal value; it means "re-open by this date".
   So the required curation is a **logged old→new re-point of `recheck`**, in one of two shapes:
   - `2026-11-05` → `90d` (the value the successors S095/S096 carry), or
   - `2026-11-05` → a fresh ISO date (the "re-open by" form, re-dated).
   Both are permitted by the shape line and both must be logged old→new in the round lesson per
   rule 2. Which one is *right* is a curation choice the contract does not decide; but leaving
   `2026-11-05` untouched while the *successor* rows carry the current claim is the one option the
   contract disfavours, because the row would keep advertising an overdue re-open obligation for a
   teaching that now lives in S095/S096.

2. *The teaching itself may not be re-verified in place — a correction is a new row.*
   Rule 2's second sentence: "A correction is a new row whose `teaches` opens `supersedes S0NN —`".
   That has already been done: S095/S096 exist, opened 2026-11-05, `teaches` opening
   `supersedes S040 —` / `supersedes S041 —`, and both carry `90d`. So the round-26 rows' *teaches*
   and *anchor* cells are frozen history (rule 2: "Corrections are new entries, never rewrites",
   CORPUS.md line ~155). The lane's own precedent for exactly this pair is in
   `corpus/lessons/round-40.md`: "Rows touched old→new: `recheck` S095 and S096 `on-release` → `90d`
   … S040/S041/S027/S028 untouched." and `corpus/lessons/round-39.md` §Registry change: "`recheck`
   `on-release` → `2026-11-05`. `status` (`mined`), `used-by` (`corpus/lessons/round-26.md`) and every
   other cell unchanged." — i.e. the lane already used the in-place `recheck` cell for exactly this
   purpose, which is the precedent this round follows.

3. *`status` must stay `mined` and `used-by` must stay a real path.* `status` has three legal
   values (queued/mined/rejected); `rejected` is wrong here (S040/S041 are not rejections, and
   `rejected` rows must carry `REJECTED: …; flip: …` in `teaches`, which these do not). `mined`
   requires a used-by path that exists and cites the row id on its `source:` line — the census
   check `SC_USEDBY_NOCITE` in `corpus/sources-census.sh` requires the id in the cited file's
   `source:` line; `corpus/lessons/round-26.md` line 1 is `source: S039, S040, S041`, so the cite
   holds. Retiring the pair's *clock rows* (see below) does not touch the registry rows, so
   `used-by` remains valid and `status` remains `mined`.

4. *What C2 actually needs from S040/S041 is not a registry edit at all.* The frozen C2 kill rules
   forbid deleting any BASE registry row ("C2 is killed … if any BASE registry row is deleted") and
   require every ON29 row to keep `recheck` `on-release` ("if any ON29 row's recheck leaves
   `on-release`"). S040/S041 are **not** in ON29 (ON29 = S005–S032 and S098, exactly the 29 rows
   whose `recheck` is `on-release` at BASE — verified by counting the `on-release` cells in
   `corpus/SOURCES.md`: 29, and that set is exactly S005…S032 + S098). So the pair's overdue
   `recheck` does not affect the counter's ON29 set, and the counter's `KEPT` leg requires the rows to
   stay. The BASE red (`ORPHAN S040`, `ORPHAN S041`, `RECEIPT-MISMATCH S040`, `RECEIPT-MISMATCH
   S041`) is a **clock-table** defect, not a registry defect: `corpus/release-clocks.tsv` at BASE has
   30 rows including S040 and S041, while the registry rows no longer carry `on-release`, so
   `corpus/release-clock.py::evaluate` raises ORPHAN for a table row whose source row is not
   on-release (lines 566-572) and RECEIPT-MISMATCH for the pinned round-36 receipt records that no
   longer bind (lines 699-703). The contract-permitted cure is to retire the two *clock rows* and
   keep the registry rows — which is what the working tree's candidate draft does (its
   `release-clocks.tsv` has 29 rows, no S040/S041) and what the plan names
   ("the S040/S041 clock rows are retired (their registry rows are superseded by S095/S096 and no
   longer `on-release`)").
   **One thing to name:** the registry rows still carry `recheck 2026-11-05` while the clock rows
   are gone, so from the registry's point of view the pair reads as *overdue but no longer
   release-driven*. A curation-consistent candidate would log the re-point old→new
   (`2026-11-05` → `90d`, matching S095/S096) in the round lesson, so the superseded rows stop
   advertising an unmeetable obligation. If the candidate leaves `2026-11-05` as is, the report must
   say so explicitly — it is contract-legal (rule 2 only governs *changes*), but it leaves a
   permanently overdue cell on two superseded rows.

---

## 4. Registry curation: S098 (REJECTED, `recheck on-release`) — is a release clock the right recheck?

Row at BASE: `| S098 | UTS #18: Unicode Regular Expressions — https://www.unicode.org/reports/tr18/ |
spec | A | Unicode White_Space as a candidate rendered-text-v1 whitespace class | Annex C:
Compatibility Properties, space (\s) entry; UTS #18, fetched 2026-11-05 | REJECTED: as the
rendered-text-v1 whitespace class, UTS #18 defines \s as the Unicode White_Space set, which excludes
U+001C-U+001F that str.isspace() accepts, so it cannot ground the normalizer class; quote "space
(\s) \p{Whitespace} See PropList for the definition of Whitespace."; flip: the normalizer class is
redefined to White_Space. | rejected | 2026-11-05 | on-release | — |`

**Quoted rule text.** `CORPUS.md` §SOURCES.md line 101-102: "`teaches` — one grounded learner
benefit. **Rejected rows read `REJECTED: <reason>; flip: <what would change the verdict>`**." Line
103-104: "`status` — `queued` (opened, worth mining) · `mined` (cited by ≥1 path in `used-by`) ·
`rejected` (kept — a rejection is evidence of taste)." Line 105-106: "`recheck` — ISO date or cadence
(`90d`, `180d`, `on-release`)." Line 116-118 (rule 2) as quoted above.
`corpus/QUALITY.md` QM23 (line 120): "an `on-release` recheck names one observable release identity —
an official feed that is itself a registry row, **or the declared capture quote of an unversioned
page** — and is observed; a derived anchor says `derived:`, a fired clock is re-verified in the
lesson, never silently re-pinned." QM24 (line 126): "a successor to an on-release teaching retains
release-driven rechecking and is bound at its named current release; preserving an already-fired
predecessor is not rearming. … **A missing-successor binding must fail UNBOUND**".

**Answer: yes — a release clock is the right recheck for S098, and the QM23 second branch is exactly
the shape that fits it.** S098's source is a *versioned* spec, not an unversioned page: it carries a
`Revision`/`Version`/`Date` identity in its own body ("Revision 25", `Version 25`, `Date
2025-01-16`), and each published revision gets its own URL (`tr18-25.html` current,
`tr18-23.html` previous, `proposed.html` empty). Its flip condition is "the normalizer class is
redefined to White_Space" — a change *in the lane's own normalizer*, not in the page. A clock on the
page's revision token is therefore the right external witness for "re-open this rejection and
re-read the page": if UTS #18 publishes Revision 26 at the same URL, the declared quote `Revision 25`
stops locating and the clock fires (quote-missing), which is precisely a re-open trigger.

Concretely, this is what the working-tree candidate does, and it is consistent with my live
measurement:
- `corpus/source-fetches.tsv` S098 capture quote changed from the page title to **`Revision 25`**,
  normalization `raw-literal-v1`, location "document header table, Revision cell (raw byte offset
  197172 of the round-41 capture body); round-46 clock quote, was the page title". My live body
  confirms offset 197172 / count 1 — the quote is exact and unambiguous.
- `corpus/release-clocks.tsv` gains `S098 rendered-quote - - - - 2026-11-06 quote-located`, and the
  BASE `UNBOUND S098` disappears (the working-tree gate reads
  `RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)`, rc 0;
  the BASE archive reads FAILED, rc 1 — both in `RECEIPTS.txt`).
- The gate's own consistency rule (line 662) requires a rendered-quote clock to have
  `feed_source_id == "-"`, `feed_url == "-"`, `anchored == "-"`, `observed_version == "-"`, a valid
  ISO `observed_at`, `verdict ∈ {quote-located, quote-missing}`, and a declared capture quote whose
  profile is one of `rendered-text-v1` / `raw-literal-v1`. The candidate row satisfies all of these,
  and `capture` comes from `corpus/source-fetches.tsv` (S098 now supplies one).

**Caveats and one real defect to name.**
1. *The capture quote moved but the registry row's `teaches` cell did not.* CORPUS.md rule 1 requires
   that the ≤25-word quote recorded in the lesson's Gate ground `teaches`. The S098 `teaches` cell
   still carries the Annex-C quote ("space (\s) \p{Whitespace} See PropList for the definition of
   Whitespace."), while the capture quote is now `Revision 25`. The capture quote is what the clock
   observes; the `teaches` quote is what grounds the rejection. They are different strings, and the
   registry has no cell for "the clock's quote" — the shape puts the clock quote in
   `corpus/source-fetches.tsv` (column 13) and the teaching quote in the registry `teaches` cell.
   The lane's own census check `SC_FETCH` requires only that the capture quote be ≤25 ASCII words
   (`corpus/sources-census.sh:277-278`); it does not require it to equal the registry `teaches`
   quote. **But** `corpus/quote-locate.py` (the round-38 instrument) requires the declared quote to
   "occur verbatim in that id's registry row in corpus/SOURCES.md" for every row in
   `corpus/quote-bodies.tsv` — S098 is **not** in that manifest (9 rows: S089–S093, S100–S102), so
   this gate does not bite S098 either way. The honest reading: the change is admissible under the
   written contract, but the row's teaching quote and its clock quote have parted company, and a
   reviewer should confirm that is intended rather than accidental. If it is intended, the lesson
   should say so explicitly.
2. *`used-by` for a rejected row.* S098 is `rejected` with `used-by` `—`. That is consistent with the
   shape (only `mined` rows need a citing path), and the census's `SC_MINED_UNUSED` check does not
   apply to rejected rows. The rejected row's evidence lives in the round-41 lesson and the
   capture, not in a knowledge entry.
3. *A rejected row may not carry `on-release` without a bound clock — that is precisely the BASE
   `UNBOUND S098` red, and it is what the candidate fixes.* QM24 states the failure mode directly:
   "A missing-successor binding must fail UNBOUND". Binding S098 is therefore required, not optional,
   once the row carries `on-release`.
4. *Is `on-release` the right cadence at all for a rejected row?* Consider the alternative:
   `recheck` could be `90d` (as the other superseded/refreshed rows carry) or a dated ISO value.
   The contract permits any of the three. But the *purpose* of an `on-release` recheck here is a
   re-open trigger, and UTS #18 has no release feed — its release identity is the document's own
   revision line, exactly what QM23's "declared capture quote of an unversioned page" branch provides
   for a page with no feed. So `on-release` + a revision-quote clock is the coherent pairing, and
   `90d` would lose the specific "the spec revised" signal (and would also have to be justified
   against the C2 kill rule "if any ON29 row's recheck leaves `on-release`" — S098 **is** in ON29, so
   dropping `on-release` from S098 is a C2 kill regardless of the curation argument). Conclusion:
   keep `on-release`, bind the clock, as the candidate does.

---

## 5. Findings summary (numbered, for the closure)

1. All five bound feeds re-fetched live on 2026-11-06 at 19:10:51–19:10:54Z: newest stable
   3.13.3 (sops, 2026-07-23), 2.2.1 (vault, 2026-10-23), 2.7.2 (openbao, 2026-10-26), 3.15.2 (python,
   2026-10-25), 8.23.0 (curl, 2026-10-14). Every value equals the pre-freeze positive receipt's
   `parsed_version`, and every body sha256 is byte-identical to the receipt's. No feed moved.
2. UTS #18 live: Revision 25, Version 25, Date 2025-01-16 (`Revision 25` located at raw offset
   197172, count 1). No proposed update (`proposed.html` → "Proposed Update Not Available"). The
   previous revision (tr18-23.html) does not contain `Revision 25`, so the token is
   revision-specific. The two S098 rejection grounds re-derive independently from live
   PropList.txt (same digest as round 41): `isspace − White_Space` = {U+001C..U+001F}, and the
   served page lacks the literal `\p{White_Space}`.
3. S040/S041 curation: `recheck` is the only in-place-changeable cell that can carry the staleness
   (CORPUS.md rule 2, lines 116-118); a permitted logged old→new re-point is `2026-11-05` → `90d`
   (matching S095/S096) or to a fresh ISO date. The teaching may not be re-verified in place —
   S095/S096 already are the contract's required new rows (`teaches` opens `supersedes S040 —` /
   `supersedes S041 —`). The BASE red is a clock-table defect (30 tsv rows vs 29 on-release sources),
   cured by retiring the two clock rows, not by editing the registry rows. **Open item:** the
   candidate's registry rows still read `recheck 2026-11-05`; if that is deliberate the lesson must
   say so, otherwise log the re-point.
4. S098 curation: `on-release` is the right recheck (the page's revision line is its release
   identity; QM23's "declared capture quote" branch), the row may not be dropped from `on-release`
   (it is an ON29 row; C2 kill rule), and QM24 requires the binding to exist — binding it is what
   clears the BASE `UNBOUND S098`. **Defect to name:** the capture quote moved from the page title
   to `Revision 25` while the registry `teaches` cell still carries the Annex-C quote; the two
   quotes now differ and no instrument in the lane cross-checks them for S098 (S098 is absent from
   `corpus/quote-bodies.tsv`). Intended or accidental should be stated in the lesson.
5. Gate state, measured both ways: BASE archive (`git archive f5977284` into scratch) →
   `ORPHAN S040 / ORPHAN S041 / RECEIPT-MISMATCH S040 / RECEIPT-MISMATCH S041 / UNBOUND S098`,
   `RELEASE_CLOCK: FAILED (on_release=29 bound=28 unbound=1 observed=28 fired=13 derived=15)`, rc 1.
   Working tree (candidate draft already present in the lane) → `RELEASE_CLOCK: CLEAN (on_release=29
   bound=29 unbound=0 observed=29 fired=13 derived=15)`, rc 0.
6. The working tree's round-46 receipt `final/observe-r46.json` (sha256
   `6091c5291849b54cfd0ecd7a39b2e2e7223da3fbbbe2d9bef19e0f2eb8765fa7`, matching the
   `DEFAULT_RECEIPT_SHA256` pinned in `corpus/release-clock.py`) contains exactly the 29 ON29 ids,
   each with `http_status` 200, a 64-hex sha256 and an `observed_at` date of 2026-11-06 equal to the
   `observed_at` column of its `corpus/release-clocks.tsv` row — the shape C2's FRESH leg requires.

## 6. Limits of this recon

- I did not run the lane's full claim-ledger verify, the census, or the counters `plans/round-46-c1.sh`
  / `plans/round-46-c2.sh` (out of scope for this seat: "Run only the scripts your item names"). I ran
  `corpus/release-clock.py` (the gate under recon) read-only in two trees, and imported its
  `parse_latest_version` read-only from the lane tree.
- The five feed readings establish the current newest stable versions and that no feed moved since
  the pre-freeze observation; they do not independently verify the anchored claims of each clock row
  (the fired verdicts' re-verification is a different leg).
- The S098 flip condition turns on the lane's own normalizer, not on the page: a fired S098 clock is
  a re-open trigger, not evidence that the flip occurred.
- No tool was installed, upgraded or removed this round; nothing was written outside
  `.ufo/waves/round-46/build/K46ScoutFeeds.md`,
  `.ufo/waves/round-46/build/K46ScoutFeeds-receipts/` and the seat scratch directory.
