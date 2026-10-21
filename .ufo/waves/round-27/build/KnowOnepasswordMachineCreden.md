# KnowOnepasswordMachineCreden — C1 inventory: `corpus/knowledge/onepassword-machine-credentials.md`

Seat: `KagiR26.KnowOnepasswordMachineCreden-17`. BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`.
Target: `corpus/knowledge/onepassword-machine-credentials.md`, 91 lines / 9653 bytes, sha256
`8380b35927e96b89fc0da7832516ecaff2a8e097660b47c599f560344709cf48` — byte-identical at BASE
(`git diff --stat BASE -- <path>` empty) and to `corpus/stamps.tsv:42` (hash / 91 / 9653).

## Result

**0 bindable current-tense numbers.** Two statements survive the topic/tense filter — a freshness
bound (`90d`, one of the 107 digit lexemes) and a structural item count (the word `Four`, outside
the digit census) — and neither can enter `corpus/self-counts.tsv` with the three existing source
kinds: one has no expressible source, the other is a word the binder's integer grammar cannot
capture. Neither is stale, so no correction and no QM21 history clause is owed. The other 106
digit lexemes (301 of 301 digit characters covered) are identifiers, dates, positional references
or brand numerals; word quantifiers `six`, `two` and `both` are excluded too. All exclusions are
listed below.

Corroboration that this entry is outside L1's bound set:
- `corpus/self-counts.tsv` has **0** rows whose doc column is this file (`awk | wc -l` = 0; the
  round-27 `KN-*` block is lines 53-75 of the uncommitted after table, BASE's table has 0 `KN-*`
  rows).
- `corpus/lessons/round-27.md:49` — "18 bindings over 7 entries"; this is not one of the seven.
- `.ufo/waves/round-27/knowledge-migrations.json` and `expectation-migrations.json` mention this
  file 0 times (no correction, no history clause, no pin migration).

## 1. Current-tense inventory (by rule, before bindability)

Population: a number is CURRENT when it states an artifact's present size with no newer value in
the same clause; dated measurements, dated verification parentheticals, Erratum/Round-N history
and positional indexes are out (`corpus/QUALITY.md:118` QM21, `:133` QM26;
`corpus/lessons/round-25.md:49-58` R25-C6). Two statements survive that filter.

| # | line | exact text | kind | defining live source | live value | verdict | Python locator (1 group) |
|---|---|---|---|---|---|---|---|
| 1 | 4 | `recheck: 90d for S001–S004; on-release for S006–S007 — …` | freshness bound | `corpus/SOURCES.md:7-10` — the recheck cells of S001, S002, S003, S004, each `90d` | `90d` (×4) | **OK** (90 = 90) but **UNBOUND**: no `rows:`/`ledger:`/`expect:` source emits `90` | `^recheck: ([0-9]+)d for ` → matches line 4 only, captures `90` |
| 2 | 8 | `## Four custody boundaries` | structural count of the entry's own four items (lines 10, 12, 14, 16) | none beyond the entry itself; no lane data file or ledger output counts these items | 4 numbered items | **OK** (Four = 4) but **UNBOUND**: word numeral; the binder's capture must be `[0-9]+` (`corpus/self-counts.py:8-9`, `:122`) | none expressible as an integer capture; `^## ([A-Za-z]+) custody boundaries$` matches once but `integer()` fails by construction |

Bindings that can honestly be added now: **none**. `rows:<file>` counts every nonblank,
non-comment line (`corpus/self-counts.py:88,142`), so `rows:corpus/SOURCES.md` yields 130 lines in
the round-27 working tree (126 at BASE) — the registry's 43 source rows (41 at BASE) are a
table-row count, not the `rows:` count — and neither equals 90;
`ledger:`/`expect:` need some existing row whose committed expectation or live output contains
`90` and none does (`corpus/claim-ledger.tsv`; R21-02's `SOURCES_CENSUS` line carries
`entries_sourced=4`, not a cadence). `Four` cannot be captured at all. Adding a `KN-*` row for
either would be a false population member, not calibration.

## 2. Numbers excluded, with reason (complete lexeme census)

Method: one ordered span classifier over the exact BASE bytes (dates, source/ledger/quality ids,
round tags, vendor step locators, list markers, item refs, section refs, the `90d` bound, brand
numeral), then every remaining `\d+` run reported. Result: **301 digit characters, 301 covered,
0 unclassified**; 107 lexemes:

`DATE 10, SOURCE_ID 55, ROUND_TAG 6, ITEM_REF 7, STEP_LOCATOR 5, LIST_MARKER 4, LEDGER_ID 2,
BRAND 15, QUALITY_ID 1, SECTION_REF 1, BOUND 1`.

| line(s) | lexeme | class | why out of population |
|---|---|---|---|
| 2, 4, 10, 12, 14, 16, 24, 25, 26, 30, 34, 35, 41, 42, 43, 48, 49, 51, 52, 55, 58, 63, 75, 84, 85, 89 | `S001`…`S004`, `S006`, `S007`, `S017`…`S020` (55 occurrences incl. range endpoints; no `S005`, no `S032`) | source-row ids | identifiers, not quantities; ranges (`S001–S004`, `S006–S007`) are membership endpoints, never stated counts |
| 5, 6 | `R21-02` (2) | ledger row id | identifier; the entry names it as the citation-chain checker |
| 34 | `QA2` (1) | QUALITY criterion id | identifier |
| 2, 3, 16, 35, 41 | `2026-10-19` (×7: line 2 ×5, lines 3 and 35), `2026-07-28` (×2: lines 2 and 16), `2026-10-20` (×1: line 41) | dates | vendor publication dates and dated capture/verification observations; QM21/QM26 date exclusion. The `2026-07-28` on line 16 is a vendor announcement date, not a lane fact |
| 32, 37, 40, 45, 70, 82 | `round 21`, `round 22` (×2), `round-21`, `round-22` (×2, one inside `round-22.md`) | round/history tags | history labels on Erratum/Round-22 sections |
| 2, 42, 54 | `Step 1 and Step 3`, `Steps 1/3`, `Step 1 … Step 3` (5) | vendor positional anchors | vendor-document step numbers, not lane artifacts; QM26 positional exclusion |
| 10, 12, 14, 16 | `1.`–`4.` (4) | list markers | positional |
| 34 (twice), 35, 39, 74, 84, 87 | `item 4`, `item 3` (7) | cross-references to numbered items | positional index, QM26 exclusion; they point at sections, they do not count anything |
| 20 | `§1` (1) | section reference into `corpus/knowledge/op-ref-consumption.md` | positional; resolves (`## 1.` at `op-ref-consumption.md:25`), not a quantity |
| 2 (×10), 16, 24, 34 (×2), 48 | `1Password` / `1password` in URLs and prose (15) | brand numeral | not a quantity |
| 3 | `six` in "reopened the **six** cited public documentation pages" | word quantifier over the six ids on line 2 | past-tense action inside `verified-at: 2026-10-19 (…)` — a dated verification observation, not a present size. Live value is nevertheless 6 = 6 unique ids on line 2 (checked), so the historical claim is true; no correction is owed. A seventh id added later would not falsify it |
| 8 | `Four` in the heading | word quantifier (inventory row 2) | in population by topic; unbindable (see §1) |
| 34 | `Four` in "§Four custody boundaries" | quotation of the heading inside the round-21 Erratum | section is Erratum history; not a restatement of the count |
| 65 | `two` in "reopen the **two** feature pages separately" | word quantifier over S017/S018 | round-22 Erratum/Recheck-trigger section — excluded as Erratum history by QM26; also a word, not a digit, and it counts vendor pages |
| 87 | `both` in "a teaching of both pages" | word quantifier | same section; no digit |

Near-misses deliberately not bound, so absence is not read as omission:
- Line 3's `six` is the only stated count of this entry's own `source:` ids. Could it be bound?
  It would need a ledger row whose output prints the count of unique ids on this entry's
  `source:` line; `R21-02` prints `entries_sourced=4` (entries, not ids) and `R14-01` prints
  `entries=25 row_linked=22 by_hand=3`. None exists, and the clause is dated, so it stays out by
  rule, not by missing machinery.
- Lines 26 and 30 restate the membership as `S001–S004, S006–S007`; mutating an endpoint (e.g.
  `S001–S003`) is invisible to every gate: `sources-census` derives ids only from the `source:`
  field (`corpus/sources-census.sh:344-356`), not from the body. This is a membership blind spot,
  not a number candidate (no count is stated).
- The round-21 and round-22 errata concede *status, eligibility and attribution*, not quantities:
  their only numeric tokens are `item 3`/`item 4` positional references, dates, source ids and the
  vendor step locators. The `CritC1Population` class (a body number that an erratum concedes as
  stale, e.g. `op-ref-consumption.md:296`) therefore has no member in this entry.

## 3. Freshness (C2) — the ordered rule cannot reach this entry

- **No numeric version anchor exists in the entry.** `(?<![\d.])\d+\.\d+\.\d+(?![\d.])` returns
  0 matches; the file has no `X.Y.Z`. QM25's numeric comparison therefore has nothing to order,
  and this entry cannot produce a `REGRESSED` finding. That is inapplicable by construction, not
  merely unexercised. C2's comparison population is the clock table
  (`corpus/release-clocks.tsv`), not knowledge prose; this entry owns no clock row of its own —
  its only clocked sources are S006/S007 via their registry rows.
- **Its two `on-release` sources are quote clocks with no anchor.** S006 (`corpus/SOURCES.md:12`)
  and S007 (`:13`) are `on-release`; their rows are `rendered-quote` with `anchored_version = "-"`,
  `observed_at 2026-10-21`, `quote-located` (`corpus/release-clocks.tsv:3-4`). The rendered-quote
  branch requires `anchored == "-"` and admits only `quote-located|quote-missing` (BASE
  `corpus/release-clock.py:532-543`; same guard in the worktree's `elif clock == "rendered-quote"`
  branch). The numeric-ordering guard is a round-27 worktree addition (`numeric_version` /
  `is_regression`, absent at BASE: `git show BASE:corpus/release-clock.py | grep -c is_regression`
  = 0) and is reached only from the `feed` branch of `evaluate` (and from `observe`), never from
  `rendered-quote`; a quote-clock row cannot carry an ordered anchor.
  A stale or cropped vendor page here yields `quote-missing`, never a numeric regression event.
- **Its four `90d` sources are outside the clock population entirely.** `on_release` filters
  `source["recheck"] == "on-release"` (BASE `corpus/release-clock.py:462-465`); S001–S004 are `90d`.
  `sources-census` only asserts that a `^recheck:` line exists (`corpus/sources-census.sh:340`);
  `claim-ledger.sh docs` parses only `Reverify:` declarations, row ids and stamps
  (`corpus/claim-ledger.sh:1135,1150,1196,1201`). No lane gate I found reads the cadence value,
  its grouping, or its due date. By arithmetic the four are due **2027-01-17** (2026-10-19 + 90d),
  human-tracked.
- **Coupling direction that does exist:** if S001–S004 were reclassified to `on-release` without a
  clock row, `release-clock` would print `UNBOUND` (BASE `corpus/release-clock.py:481-486`; worktree
  `:529-534`). The entry's prose would still be unread, and `90d` would silently contradict the
  registry.
- **After-state line numbers are unstable by construction:** `corpus/release-clock.py` is L1's live
  working-tree file and changed under this seat (diff vs BASE grew from +84 to +148 lines; the
  `numeric_version`/`is_regression` block moved from `:382` to `:383` and gained a feed-floor call
  at `:567-568` while this report was being written). The C2 claims above are structural (no
  `X.Y.Z` in the entry; quote clocks require `anchored == "-"`; the 90d rows are not in the
  `on-release` population) and do not depend on those lines. BASE anchors are cited where the
  fact exists at BASE.
- Consequence for L1's C2 counting command: this entry contributes **0** numeric anchors. It must
  not be counted among entries with anchor/observation pairs, and its rendered-quote rows should
  not gain feed clocks for pages that publish no release identity.

## 4. Mutation exposure (concrete counterexamples; not executed)

Each mutation below changes a current-tense lane-artifact number and leaves every gate green. The
claim is [INFERENCE] from the static code paths cited, not from a run — I executed no gate.

1. `90d` → `180d` on line 4. No claim row names this doc, so `self-counts` never opens the file
   (`corpus/self-counts.py:306-325`; claims are read first, docs only per claim at `:324-325`);
   `sources-census` greps presence only (`:340`); `docs` audit never reads the line. The only
   lane-local detector I found is the stamp hash/line/byte pin (`corpus/stamps.tsv:42`) while a
   restamp has not happened.
2. `Four` → `Five` on line 8. Same non-readers; additionally the word cannot be a binder locator
   because `integer()` requires `[0-9]+` (`corpus/self-counts.py:122`) — the mutation is not even
   expressible as a stale binding.
3. `six` → `five` on line 3. Dated historical clause; no reader; the six ids on line 2 are
   unchanged.
4. Line 4 `on-release for S006–S007` → `90d for S006–S007`. Registry rows stay `on-release`, their
   clock rows stay bound and `quote-located`, census green; the entry now contradicts the registry
   with no failure.
5. `S001–S004` → `S001–S003` on line 4 or 26. Body ranges are never resolved by any gate, and
   S004's `used-by` still lists this entry, so the census stays green.

## 5. Reproduce

```bash
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
git rev-parse HEAD                       # 0a47dd189356ea66ec83c3891eed54526e95b89b
git diff --stat 0a47dd18 -- corpus/knowledge/onepassword-machine-credentials.md   # empty
git show 0a47dd18:corpus/knowledge/onepassword-machine-credentials.md | sha256sum
sha256sum corpus/knowledge/onepassword-machine-credentials.md
# both 8380b35927e96b89fc0da7832516ecaff2a8e097660b47c599f560344709cf48
grep -n 'onepassword-machine-credentials' corpus/stamps.tsv          # :42, 91 lines, 9653 bytes
awk -F'\t' '!/^#/ && $2=="corpus/knowledge/onepassword-machine-credentials.md"' \
  corpus/self-counts.tsv | wc -l                                     # 0
git show 0a47dd18:corpus/self-counts.tsv | grep -c '^KN-'            # 0 (grep exits 1)
grep -n '^recheck: 90d for S001' corpus/knowledge/onepassword-machine-credentials.md  # :4
awk -F'|' '$2 ~ " S00[1-4] " {gsub(/^ +| +$/,"",$11); print $2, $11}' corpus/SOURCES.md
# S001 90d / S002 90d / S003 90d / S004 90d   (SOURCES.md:7-10)
grep -n 'S006\|S007' corpus/release-clocks.tsv                        # :3,:4 rendered-quote, anchor -
grep -c 'onepassword-machine' .ufo/waves/round-27/knowledge-migrations.json  # 0
python3 -c "import datetime;print(datetime.date(2026,10,19)+datetime.timedelta(days=90))"  # 2027-01-17
# locator uniqueness (1 group, 1 line, captures 90)
python3 - <<'PY'
import re
L=open('corpus/knowledge/onepassword-machine-credentials.md',encoding='utf-8').read().splitlines()
print([(i,re.search(r'^recheck: ([0-9]+)d for ',l).group(1)) for i,l in enumerate(L,1)
       if re.search(r'^recheck: ([0-9]+)d for ',l)])   # [(4, '90')]
PY
```

## 6. What I did NOT check

- No vendor page, blog, guide or feed was opened or fetched; the entry's vendor claims (process
  delivery, token rotation, Connect token split, Broker status) are not re-verified, and neither
  are S001–S004/S006/S007's served bytes.
- I did not run `corpus/self-counts.py`, `.ufo/waves/round-27/tools/c1-measure.py`,
  `corpus/release-clock.py`, `corpus/claim-ledger.sh`, `corpus/sources-census.sh` or any selftest,
  per the wave contract. Every gate-behaviour statement in §3-§4 is a static read of the cited
  lines; mutation outcomes are [INFERENCE], not observed.
- I did not run `claim-ledger.sh verify`; the stamp was compared by reading `corpus/stamps.tsv:42`
  at BASE, not by executing the stamp check.
- `.ufo/waves/round-27/c1-before.json` is absent from the wave directory, so I could not compare
  the L1's before-measurement for this entry; `knowledge-migrations.json` has 0 mentions.
- I did not audit the other 24 knowledge entries, and did not check body citations S017–S020
  against their pages (their registry `used-by` cells list the round-22 lesson and
  `feature-bound-credential-review.md`, not this entry).
- Adjacent, outside the target and therefore not judged: `corpus/README.md:76` labels this entry
  "SOURCES.md S001–S007", while the entry cites S001–S004, S006 and S007 and never mentions S005
  (`grep -n S005` → exit 1). That is an index-range overstatement in another file, not a number in
  this entry; I did not audit the rest of the README row.
- No tools were installed or updated.

## 7. Advisory for L1 integration

1. Record this entry in the C1 exclusion accounting as **reviewed, 0 bindable current-tense
   numbers** (one unwatched bound `90d`, one word-form structural count `Four`), so a later reader
   does not read the missing `KN-*` row as omission. No table row, no correction, no history
   clause is owed; both live values currently match.
2. Do not convert `## Four custody boundaries` to `4` purely to make it bindable: there is no
   independent source for the item count, so the binding would be self-referential, and QM21
   binds documents to live sources, not to themselves.
3. If the `90d` bound is to be machine-watched, that is **new machinery**, not a `KN-*` row: an
   entry-`recheck:`-versus-`SOURCES.md`-recheck-cell consistency check (with its own selftest
   cases, QM9), or a ledger mode that prints `cadence=90` from the four registry cells. Flag it as
   named debt; binding `90` with today's `rows:/ledger:/expect:` kinds is not expressible.
4. C2: keep S006/S007 as `rendered-quote` clocks (`corpus/release-clocks.tsv:3-4`); they publish
   no release identity, so a feed clock would need a fabricated numeric anchor and would put a
   false `REGRESSED`/`FIRED` candidate into the population.
5. S006/S007 are superseded in the registry (S020 supersedes S006, `corpus/SOURCES.md:26`; S032
   supersedes S007, `:38`; S019 also supersedes S007, `:25`); the entry's own round-22 section says
   the active table moved to `corpus/knowledge/feature-bound-credential-review.md` (exists, 60
   lines). None of that changes the zero-bindable result; it is context for why no count here
   should be treated as a current membership statement.

Confidence: high on the zero-bindable result and the lexeme census (digit-complete over exact BASE
bytes, 301/301 covered, 0 unclassified); high on the live values (registry cells read, entry bytes
hashed); high on C2 inapplicability (no `X.Y.Z`, two `rendered-quote` rows, static code read);
canonical-binding unavailability is a static reading of `self-counts.py`, not an executed negative.
