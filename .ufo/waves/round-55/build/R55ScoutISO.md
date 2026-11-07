# R55ScoutISO — independent live re-opening of the C2 sources and the two rejections

Seat: R55ScoutISO (scout). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch master.
Measured revision (40-hex, from `git rev-parse`): `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f` (the landed CANDIDATE).
Predeclaration `f2b986fadd8f8551e760cc89f59e0ae0edb0d499`; BASE `ebe095857a734caf5efdd7bd776feb22b4e23972`.
Scratch: `/fast/scratch/hyaku/kagi-r55/R55ScoutISO`. Receipts: `.ufo/waves/round-55/build/R55ScoutISO.d/`.

Scope note: the lane working tree carries post-candidate edits (`git status`: `M corpus/lessons/round-55.md`,
`M corpus/knowledge/iso-11770-3-edition-status.md`, `M corpus/sources-census.sh`, `M corpus/QUALITY.md`, `M LOG.md`,
`M .ufo/waves/round-55/capture/S11{3,4}.headers`). Where a finding differs between the candidate commit and the
working tree, both are stated. I edited nothing in the lane.

## Verdict summary

| # | Question | Verdict |
|---|---|---|
| 1 | Are the three ISO pages still what the captures say? | **YES** — all three live bodies byte-identical to the committed captures (S113, S114, S101). |
| 2 | Are the registry quotes at their declared offsets? | **YES** — all three exact at the declared byte offset. |
| 3 | Does the entry's new section read true against the bodies? | **YES**, sentence by sentence — with one *candidate-commit* wording defect (below) that the working tree already fixes. |
| 4 | Is any newer amendment / corrigendum / stage change live today? | **NO** — Amd 1:2025 is still the only amendment; the 90.xx codes are the page's stage legend, not reached stages. |
| 5 | Do the two rejections hold? | **YES, both** — with one over-general wording in the RSS rejection. |

**No defect in the C2 claim itself.** The entry names the right amendment, the right stage and the right date, and
the live records support every statement. Two defects live in the *lesson prose* of the candidate commit
(`348aa3b8`), both already corrected in the lane working tree: a wrong quote word count and a wrong quote locator.
One real freshness weakness is named in §5 below: the entry's S113 clock would not move if a **successor**
amendment appeared.

---

## 1. Per-URL live re-opening

All fetched with `curl -sSL --compressed -A '<browser UA from the entry recheck line>'`, UA =
`Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36`.

| URL | HTTP | content-type | decoded bytes | sha256 | identical to committed capture | quote offset located |
|---|---|---|---|---|---|---|
| `https://www.iso.org/standard/82709.html` (S113) | 200 | `text/html;charset=UTF-8` | 90 604 | `d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357` | **YES** (`capture/S113.body`) | **YES** @ 53493 |
| `https://www.iso.org/standard/85929.html` (S114) | 200 | `text/html;charset=UTF-8` | 85 138 | `8bb88d88ff21d4488cf2205d9655a7fcbdeb3601616bdf4f5767dce13c449bdf` | **YES** (`capture/S114.body`) | **YES** @ 541 |
| `https://www.iso.org/standard/60237.html` (S101) | 200 | `text/html;charset=UTF-8` | 85 615 | `2e4c1524ec05865536f819db68c56494d97fc67cb490df4f5d4b1ca85b7b0c80` | **YES** (`round-45/.../S101.raw`) | **YES** @ 45752 |

All three digests equal the digests recorded in `corpus/source-fetches.tsv` rows S101/S113/S114 and in the
registry rows, and equal the lesson's recorded digests. Receipt 1.

**Default user agent: HTTP 403 on both ISO URLs** re-measured today (Cloudflare `Just a moment...` interstitial):
`60237` and `82709` and `85929` all 403 with the default agent. The candidate lesson records the default-UA 403
receipt only for the S114 URL (`default-ua_85929.meta`); the working-tree lesson now says so explicitly. My
measurement extends the 403 to the S113 URL as well, which the candidate lesson did not claim.

**403 caveat, operationally important.** iso.org answers **403 even with the browser UA** under load: one of a
3-way parallel burst on `60237` returned 403 (`live-S101.body`, sha256 `23cdf311f970ed105…`, title `Just a
moment...`), while 6 sequential retries all returned 200 with the expected digest. With the entry's command shape
(`curl -fsSL … | grep -c '<Q>'`), a 403 makes curl exit 22 with empty stdout, so `grep -c` prints **`0`** — the
clock would report a false "the page changed". Note the direction: a challenge produces a **false change**, not a
false "unchanged", so the clock fails *safe* (it wakes the lane) rather than silently passing. The rate is low —
**1 occurrence in 43 browser-UA fetches** observed (receipts 1 and 7) — so the practical cost is occasional false
alarms, not missed changes.

Mitigation options, measured (receipt 7): `curl --retry 3 --retry-all-errors -fsSL -A '<UA>' '<URL>' | grep -c '<Q>'`
**keeps the counter's own command-shape regex matching** (`plans/round-55-c2.sh` replays the command's query and
URL, not its flags) and curl does retry a 403 (three attempts observed). A status-guard rewrite
(`-o file -w '%{http_code}'` then grep the file) breaks that regex and would need a counter change. I did **not**
observe a retry converting a real 403 into a 200, so the retry's effectiveness against the transient challenge is
[INFERENCE], not a measured fix. This is a *clock robustness* gap, not a claim defect.

## 2. Registry quotes at their declared offsets, and word counts

`corpus/quote-bodies.tsv` rows (all three exact at the declared offset, byte-exact):

| id | body path | declared offset | quote | exact match | word count (`printf '%s' … \| wc -w`) |
|---|---|---|---|---|---|
| S101 | `.ufo/waves/round-45/controls/capture-r45/S101.raw` | 45752 | `Withdrawal of International Standard` | YES | 4 |
| S113 | `.ufo/waves/round-55/capture/S113.body` | 53493 | `ISO/IEC 11770-3:2021/Amd 1:2025` | YES | **3** |
| S114 | `.ufo/waves/round-55/capture/S114.body` | 541 | `ISO/IEC 11770-3:2021/Amd 1:2025` | YES | **3** |

All occurrences: S101 → [45752, 62765]; S113 → [53493, 53739, 69404]; S114 → 13 occurrences.

**Defect D1 (candidate commit, already fixed in the working tree): wrong quote word count.**
The candidate lesson `348aa3b8` says, for **both** S113 and S114, `Quote (4 words, printf '%s' … | wc -w)`. By the
lane's own counting rule (the lesson's "Counting rule (E49-1)") the quote `ISO/IEC 11770-3:2021/Amd 1:2025` is
**3** words (`ISO/IEC` `11770-3:2021/Amd` `1:2025`). `printf '%s' 'ISO/IEC 11770-3:2021/Amd 1:2025' | wc -w` → 3.
The lane's ≤25-word rule is unaffected (3 ≤ 25), so this is a prose inaccuracy, not a gate failure. The working-tree
lesson already reads `Quote (3 words …)` in both places.

**Defect D2 (candidate commit, already fixed in the working tree): wrong quote locator for S113.**
The candidate lesson says the S113 quote sits `at byte offset 53493 (life-cycle list)`. Byte 53493 is **not** in the
life-cycle section: `id="lifecycle"` starts at byte 57926, and the life-cycle-list occurrence of the quote is at
byte **69404**. Byte 53493 is inside the `data-index` attribute value of a visually-hidden span in the product
card (`<span class="visually-hidden" id="indexReference_cs85929" data-index="85929 - ISO/IEC 11770-3:2021/Amd 1:2025 …">`).
The offset itself is correct (the quote does start there) — only the *parenthetical locator* is wrong. The
working-tree lesson now reads `(its first occurrence, a hidden item-reference span in the product card; the
life-cycle link is at 69404 — R55ReviewerLanding F6)`.

**Defect D3 (candidate commit, already fixed in the working tree): S101 offsets are line-starts, not quote offsets.**
The candidate lesson says `grep -c 'Withdrawal of International Standard'` gives 2 `at byte offsets 45705 stage line,
62733 life-cycle list`. The quote itself starts at **45752** and **62765**; 45705 and 62733 are the *line-start*
offsets of the containing lines. The working-tree lesson states both correctly.

**Note on the S114 locator.** The candidate lesson calls byte 541 the `(title)`. It is the *reference-number prefix*
of the `<title>` element (which opens at byte 533): the full title is `ISO/IEC 11770-3:2021/Amd 1:2025 - Information
security — Key management — Part 3: Mechanisms using asymmetric techniques — Amendment 1: TFNS identity-based key
agreement`. The body also carries the string as the catalogue's `Reference number` field (byte 34898) and in the
`standard-number` div (byte 37389), so the entry's phrase "its ISO catalogue record is titled …" is supported by
the body's own Reference-number block, not only by the title prefix.

## 3. The entry section, sentence by sentence

Section: `## The 2021 edition carries Amendment 1:2025 (round 55)` in
`corpus/knowledge/iso-11770-3-edition-status.md`.

| # | Statement | Verdict | Evidence |
|---|---|---|---|
| 1 | "The newer amendment the IEC record points to [S100] is ISO/IEC 11770-3:2021/Amd 1:2025 [S114]." | **SUPPORTED** | S100 (`capture-r45/S100.raw`, byte 256615): `A more recent version of this publication exists: <a title="ISO/IEC 11770-3:2021/AMD1:2025" href="https://webstore.iec.ch/en/publication/107179">`. IEC spells it `AMD1:2025`, ISO spells it `Amd 1:2025` — the same publication. The working-tree entry adds the `[S100]` citation the candidate commit lacked; the candidate's sentence pointed at "the IEC record" without citing which one. |
| 2 | "Its ISO catalogue record is titled "ISO/IEC 11770-3:2021/Amd 1:2025" [S114]" | **SUPPORTED** | S114 `<title>` opens at byte 533, reference string at 541; the catalogue's own `Reference number` block at byte 35212 reads `Reference number<br/> ISO/IEC 11770-3:2021/Amd 1:2025`; `standard-number` div at byte 34859. |
| 3 | "with the subtitle "Amendment 1: TFNS identity-based key agreement"" | **SUPPORTED** | S114 byte 670, exact string (also the `og:description` / `<meta name="description">` and the h1). |
| 4 | "the stage "International Standard published" (60.60)" | **SUPPORTED** | S114 byte 49061: `Stage : International Standard published [<a …>60.60</a>]`; the life-cycle list repeats it at byte 60840 (`grep -c 'International Standard published'` = 2). |
| 5 | "and a 2025-04 publication date [S114]" | **SUPPORTED** | S114 byte 48944: `Publication date : <span itemprop="releaseDate">2025-04</span>`. |
| 6 | "The ISO catalogue record of the 2021 edition lists the same amendment in its life cycle" | **SUPPORTED** | S113: `>Amendments</h4>` at byte 69000, then `Published` at 69287 and the link `<a href="/standard/85929.html" class="text-success">ISO/IEC 11770-3:2021/Amd 1:2025</a>` at byte 69352 (the quote itself at 69404). |
| 7 | "and still gives the 2021 edition as a published International Standard (stage 60.60) [S113]" | **SUPPORTED** | S113: `Stage : International Standard published [ 60.60 ]` at byte 51194 (publication date `2021-10` at 51077) and the life-cycle `Published` block at byte 59169 with stage 60.60 dated 2021-10-22. |
| 8 | "the amendment is published against the 2021 edition, so a reader holding the 2021 edition should read it with Amendment 1:2025, not the 2021 text alone." | **SUPPORTED AS AN INFERENCE, correctly labelled** | The bodies state title, stage and date, not applicability. The working-tree entry says exactly that ("Read together (the lane's reading: the catalogue states title, stage and date, not applicability)"). |
| 9 | "Both records were opened 2026-11-07 with the browser user agent (the default user agent still receives HTTP 403)" | **SUPPORTED** | Default-UA 403 re-measured today on both URLs. |

**Defect D4 (candidate commit, already fixed in the working tree): the candidate asserted applicability as fact.**
At `348aa3b8` the sentence read "the text that applies is the 2021 edition together with Amendment 1:2025, not the
2021 text alone" — no qualifier. No cited body says what text *applies*; they give title, stage and date. The
working-tree entry adds the reading qualifier.

**`verified-at:` not refreshed.** The entry's `verified-at:` line still reads `2026-11-05` although the round added
two 2026-11-07 records and the recheck line says `(ran 2026-11-07)`. Other entries in the corpus put the
verification date in that field. This is in the candidate commit **and** in the working tree — not yet fixed.

## 4. Freshness: is there any newer amendment, corrigendum or stage change today?

**No.** Four independent live primary sources agree.

1. **S113 (the 2021 edition's record, live == capture).** The `>Amendments</h4>` list holds exactly **one** entry:
   `/standard/85929.html ISO/IEC 11770-3:2021/Amd 1:2025`. Every `ISO/IEC 11770-3` reference on the page is
   `…:2015`, `…:2015/Amd 1:2017`, `…:2015/Cor 1:2016`, `…:2021`, `…:2021/Amd 1:2025`. No Amd 2, no Cor for the 2021
   edition.
2. **S114 (the amendment's own record, live == capture).** Only `ISO/IEC 11770-3:2021` and
   `ISO/IEC 11770-3:2021/Amd 1:2025` appear. No sibling or successor.
3. **ISO/IEC JTC 1/SC 27 committee catalogue** (`https://committee.iso.org/committee/45306/x/catalogue/p/0/u/1/w/0/d/0`,
   HTTP 200, fetched twice, 11770-3 count reproducible at **8**): `1999` [Withdrawn], `2008` [Withdrawn],
   `2008/Cor 1:2009` [Withdrawn], `2015` [Withdrawn], `2015/Amd 1:2017` [Withdrawn], `2015/Cor 1:2016` [Withdrawn],
   `2021` (published), `2021/Amd 1:2025` (published). The newest 11770-3 document is Amd 1:2025.
4. **IEC record of the 2021 edition** (`webstore.iec.ch/en/publication/71650`, live): its lifecycle names only
   `11770-3:2021` (published 2021-10-22, ed 4.0) and the older editions; no successor amendment.

**The 90.xx stage codes are the page's stage legend, not reached stages.** Both S113 and S114 render the full ISO
stage ladder; the 90.xx rows (`90.20` under systematic review, `90.60` close of review, `90.92` to be revised,
`90.93` confirmed, `90.99` withdrawal proposed) and `95.99` carry **no date**, while the stages this document
actually reached do (`10.99` 2021-03-05, `40.99` 2021-03-05, `50.00` 2021-04-26, `50.20` 2021-06-14, `50.60`
2021-08-10, `60.00` 2021-08-10, `60.60` 2021-10-22). The document's own ladder stops at 60.60. **No systematic
review (90.xx) and no stage change for ISO/IEC 11770-3:2021.** (A public web search agrees that no Amd 2 / Cor 2
exists; the primary catalogue and committee records above are the evidence relied on.)

## 5. Freshness defect named: the S113 clock would not move for a *successor* amendment

> **STATUS UPDATE (late in my run).** Another seat read this finding and **adopted the fix**: the working tree's
> `recheck:` line now reads `grep -c 'ISO/IEC 11770-3:2021/Amd'` (the prefix, not the Amd-1-specific string) with
> the note *"counts every amendment of the 2021 edition on the record lists, so a new amendment moves it — R55ScoutISO;
> the Amd-1-specific string, the first form of this command, would stay 3"*. Both counters still read
> `C2_ISO_CURRENT: value=2 amd=1 recheck=1 guard=1 (bad=none)` on that tree. The defect is therefore **closed in the
> working tree**; it stands only in the candidate commit `348aa3b8`. §5 below is kept as the measurement that
> justifies it.

The entry's S113 clock is `grep -c 'ISO/IEC 11770-3:2021/Amd 1:2025'` → 3. Its three occurrences are:

| byte | element |
|---|---|
| 53493 | `<span class="visually-hidden" id="indexReference_cs85929" data-index="85929 - ISO/IEC 11770-3:2021/Amd 1:2025 …">` |
| 53739 | `<span class="visually-hidden" id="itemReference_cs85929">ISO/IEC 11770-3:2021/Amd 1:2025</span>` |
| 69404 | `<a href="/standard/85929.html" class="text-success">ISO/IEC 11770-3:2021/Amd 1:2025</a>` (the life-cycle link) |

**Why it is blind.** Each document on this page gets its **own card**: on the same S113 page the two other
sibling documents occur exactly once each (`ISO/IEC 11770-3:2015/Amd 1:2017` → 1, `ISO/IEC 11770-3:2015/Cor 1:2016`
→ 1). A *new* amendment would therefore be rendered as a new card with a **new** reference string, and would leave
the Amd-1-specific count at 3. The clock's count is pinned to the amendment it already names, so it is a clock for
"Amd 1:2025 is still mentioned", not for "no newer amendment exists" — the exact question the entry answers.

**Discriminating clocks that exist on the same pages today** (all reproducible on a second fetch):

| clock | today | would move when |
|---|---|---|
| S113 `grep -c 'ISO/IEC 11770-3:2021/Amd'` (prefix) | 3 | a new amendment card appears |
| S113 `grep -c 'class="section-head">Published'` | 2 | the life-cycle gains a Published amendment entry |
| SC27 committee catalogue `grep -c 'ISO/IEC 11770-3:2021/Amd'` | 1 | a new 11770-3:2021 amendment is listed |
| SC27 committee catalogue 11770-3 document count | 8 | a new 11770-3 document is listed |
| S113 `grep -c 'class="section-head">Withdrawn'` | 3 | a withdrawn sibling changes |

The working tree already adds a third entry-clock command — `curl … 'https://www.iso.org/standard/85929.html' |
grep -c 'International Standard published'` → 2 — which watches the **amendment's own stage** (bytes 49075 and
60840 of S114). That is a genuine improvement over the candidate's two commands (it is what the candidate's C2
"names the amendment in force" claim needs), and it is true live today (2 on the live body). It still would not
detect a *successor* amendment, so the successor-blindness remains. I am not able to land a change (read-only
seat); this is named for the integrator.

Also note the counter's own header already concedes the general shape of this ceiling: *"a recheck command whose
quote is true of the capture but not discriminating (e.g. a common word with its true count) scores RECHECK; the
live re-fetch by a non-author is the check of currency on the day."* My measurement sharpens it: for this entry the
non-discriminating quote is not a common word but the **specific string of the amendment being watched**.

## 6. The two rejections

### Rejection A — `https://www.iso.org/contents/data/standard/08/27/82709.detail.rss` (per-standard RSS)

Live today: HTTP 200, `application/rss+xml;charset=UTF-8`, 1371 B decoded, sha256
`d17018559e7eb539576647995a41a3555f71917ce8a4eec9795154f4db152475` — **byte-identical to the committed rejection
body**. It still carries **one** item, about the 2021 edition (`reached stage 60.60 on 2021-10-22`), and **no item
for Amendment 1:2025**.

**REJECTION REASON HOLDS.** The feed has not moved and cannot watch this entry's currency; the stated flip ("the
feed gains an item per amendment or stage change") is still unmet.

**One wording over-generalisation (informational, not a defect in the rejection).** The lesson's stated reason is
"a per-standard feed that does not record amendments cannot watch this entry's currency". As a general claim about
ISO's per-standard feeds it is false: ISO publishes one feed per **standard id**, and the *amendment's own* feed
`https://www.iso.org/contents/data/standard/08/59/85929.detail.rss` (HTTP 200, `application/rss+xml`, 1455 B)
**does** carry it — `<title><![CDATA[ISO/IEC 11770-3:2021/Amd 1:2025]]>` and
`This document reached stage 60.60 on 2025-04-28`, `pubDate 2025-04-28`. What was rejected is the *2021 edition's*
feed, a different address, and rejecting it is right. The generalisation would misfire on a future round that meets
a per-standard feed that does carry the amendment. A tightened reason: "the 2021 edition's per-standard feed
carries only that edition's own stage item and did not move when its amendment appeared; the amendment's own
per-standard feed (…/08/59/85929.detail.rss) does carry it and is the address a per-standard-feed clock should use."

### Rejection B — `https://webstore.iec.ch/en/publication/107179` (IEC co-publisher record)

Live today: HTTP 200, `text/html; charset=UTF-8`, 429 695 B decoded, sha256
`ac54a1a0e0b883fb7f4946058755220a18bfd0b69a42cf4e2f4cd88a446f4a20`. The committed rejection body is 429 695 B,
sha256 `6a557e1d8c4eab3d0af3b75265457feb9edab272b06047247efbfed9e68cc6b9`.

**Not byte-identical, and the difference is benign.** The two bodies differ in exactly **18 byte positions**
(50117–50125 and 103095–103103), all inside two Alpine.js component ids
(`initMenuMobile_6aeed888dcf91()` live vs `initMenuMobile_6aeeca775e2a7()` committed) — per-request nonce noise in
the page's nav markup. Same length, same document, same content.

The captured quote still holds live: byte 187 = `ISO/IEC 11770-3:2021/AMD1:2025 | IEC"/>`, and the live body
carries `"reference":"ISO/IEC 11770-3:2021/AMD1:2025"`, `publication_date":"2025-04-28"`, `"status":"PUBLISHED"`.

**REJECTION REASON HOLDS.** S114 is ISO's own record of the same publication with stage (60.60) and date (2025-04).
The IEC record is the same publication under the IEC spelling, `publication_date 2025-04-28`, status `PUBLISHED`.
The two records **do not disagree** on stage or date — the flip condition ("the ISO record becomes unreachable or the
two records disagree on stage or date") is unmet. (ISO gives the month, IEC the exact day; that is refinement, not
disagreement.) The rejection stands.

## 7. Counters and census (independent measurement)

| command | revision | result | exit |
|---|---|---|---|
| `bash plans/round-55-c1.sh 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f` | candidate | `C1_USEDBY_GAP: value=0 gap=0 citations=90 entries=37 guard=1 (bad=none)` | 0 |
| `bash plans/round-55-c2.sh 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f` | candidate | `C2_ISO_CURRENT: value=2 amd=1 recheck=1 guard=1 (bad=none)` | 0 |
| `bash plans/round-55-c1.sh ebe095857a734caf5efdd7bd776feb22b4e23972` | BASE | `value=25 gap=25 …` (25 GAP pairs listed) | 0 |
| `bash plans/round-55-c2.sh ebe095857a734caf5efdd7bd776feb22b4e23972` | BASE | `C2_ISO_CURRENT: value=0 amd=0 recheck=0 guard=1 (bad=amd:a-rows=0,recheck:S101-count-2-stated-1)` | 0 |
| `bash plans/round-55-c1.sh --tree <lane working tree>` | working tree | `value=0 gap=0 …` | 0 |
| `bash plans/round-55-c2.sh --tree <lane working tree>` | working tree | `value=2 amd=1 recheck=1 guard=1 (bad=none)` | 0 |
| `bash corpus/sources-census.sh` | working tree | `SOURCES_CENSUS: CLEAN (rows=114 A=110 B=2 C=2 queued=1 mined=109 rejected=4 entries_sourced=16 legacy=21 captures=114 inrow=16 inrow_only=0 inrow_nonreproducing=12)` | 0 |
| `bash corpus/sources-census.sh --selftest` | working tree | `SOURCES_CENSUS_SELFTEST: PASS (78 cases)` | 0 |

The C2 value 2 = AMD 1 + RECHECK 1, matching the frozen predicate
`C2_ISO_CURRENT: value = AMD + RECHECK when GUARD = 1, else FAIL; target 2 (BASE 0)`. BASE reads 0 with the
recorded reason `recheck:S101-count-2-stated-1` — the round-45 `-> 1` that M55-2 names, and the live S101 body
today still gives 2 (the same body as the round-45 capture, byte-identical). The C1 gap 25 → 0 and the census
selftest 70 → 78 both reproduce.

The working tree's extra third `recheck:` command (`85929 … grep -c 'International Standard published'` → 2) is
true on the live body and on the committed S114 capture, and the counter accepts it (`recheck=1` on `--tree`).

## 8. Findings list

| id | class | where | evidence | status |
|---|---|---|---|---|
| D1 | wrong quote word count (4 vs 3) | candidate `corpus/lessons/round-55.md` (S113 and S114 bullets) | `printf '%s' 'ISO/IEC 11770-3:2021/Amd 1:2025' \| wc -w` → 3 | **fixed in the working tree** |
| D2 | wrong quote locator (53493 called "life-cycle list") | candidate lesson, S113 bullet | `id="lifecycle"` at byte 57926; life-cycle occurrence at 69404; 53493 is a `data-index` attribute value | **fixed in the working tree** |
| D3 | S101 offsets are line-starts, not quote offsets (45705/62733 vs 45752/62765) | candidate lesson, S101 bullet | quote occurrences at 45752 and 62765 | **fixed in the working tree** |
| D4 | applicability asserted as fact, not labelled as a reading | candidate `corpus/knowledge/iso-11770-3-edition-status.md` | no body states applicability; the working tree adds the qualifier | **fixed in the working tree** |
| D5 | freshness: the S113 clock is blind to a **successor** amendment | entry `recheck:` (candidate) | S113 occurrences [53493, 53739, 69404]; siblings each occur once; discriminating clocks measured (§5) | **CLOSED in the working tree** — the prefix form `grep -c 'ISO/IEC 11770-3:2021/Amd'` is now the command (credited R55ScoutISO); C2 still `value=2` |
| D6 | freshness: the recheck command has no HTTP-status guard; a 403 reads as `0` (a **false change**, failing safe) | entry `recheck:` (candidate and working tree) | 1 403 in 43 browser-UA fetches; `curl -fsSL … \| grep -c` printed `0` against a 403 body; `curl --retry 3 --retry-all-errors` keeps the counter's CMD regex matching (receipt 7) | **OPEN** — for the integrator; fails safe, low rate |
| D7 | `verified-at:` did not record the 2026-11-07 fetches | entry header | at the candidate the line read a bare `2026-11-05` | **CLOSED in the working tree** — now `verified-at: 2026-11-05 (S100–S102); 2026-11-07 for S113 and S114 (opened) and S101 (re-fetched byte-identical to its round-45 capture)` |
| D8 | wording over-generalisation in the RSS rejection | candidate lesson, rejection A | the amendment's own per-standard feed `…/08/59/85929.detail.rss` **does** carry the amendment (stage 60.60 on 2025-04-28) | informational — the rejection of that address still holds |

**Nothing in the C2 claim is wrong.** D1–D5 and D7 are candidate-commit prose/clock inaccuracies that the working
tree already corrects (D5 was closed in direct response to this seat's finding, and the entry credits R55ScoutISO);
D6 is the one item still open, and it fails safe; D8 is a wording note on a rejection that stands.

**Live leg, independent of the committed captures.** Every URL the entry rests on was re-fetched today with the
browser UA the entry declares, and all three ISO catalogue bodies came back **byte-identical to the committed
captures** (`cmp` exit 0). The counter values were reproduced independently at the candidate
(`C1 value=0`, `C2 value=2`), at BASE (`C1 value=25`, `C2 value=0` with the recorded reason
`recheck:S101-count-2-stated-1`) and on the working tree (`C1 value=0`, `C2 value=2`), with the census
`SOURCES_CENSUS: CLEAN` and the selftest `PASS (78 cases)`.

## 9. Receipts

All in `.ufo/waves/round-55/build/R55ScoutISO.d/`; each header names the measured revision as the 40-hex hash
`348aa3b8ea7298aeb2f4d69db321fe827a92ae4f` obtained with `git -C … rev-parse`.

| file | content |
|---|---|
| `receipt-01-live-iso-pages.txt` | the three ISO pages live: status, type, decoded bytes, sha256, byte-compare with each committed capture, the default-UA 403 on both URLs, the burst 403 and the six 200 retries |
| `receipt-02-quote-offsets.txt` | `quote-bodies.tsv` rows; exact-match test at each declared offset; all occurrences; word counts by the lane rule; `grep -c` counts on the captures; the element containing S113 byte 53493 and the life-cycle boundary |
| `receipt-03-entry-sentence-verdicts.txt` | the nine entry statements with the supporting body bytes and a verdict each |
| `receipt-04-rejection-verdicts.txt` | both rejected addresses re-opened live: RSS byte-identical, item inventory; IEC 18-byte nonce diff, quote and JSON fields, verdict |
| `receipt-05-freshness.txt` | the four live sources for "no newer amendment"; the 90.xx legend-vs-reached analysis; the clock-discrimination measurement and the discriminating alternatives |
| `receipt-06-counters-and-robustness.txt` | both counters at candidate / BASE / working tree, census and selftest, and the 403-reads-as-0 measurement |
| `receipt-07-mitigation-options.txt` | the counter's command-shape regex against a retry flag vs a status-guard rewrite; curl's actual retry behaviour on a 403; the measured 403 rate (1 in 43 browser-UA fetches) |

Scratch `/fast/scratch/hyaku/kagi-r55/R55ScoutISO/` holds every fetched body and scratch fixture; it is removed on
exit. No lane file was modified by this seat.

**Late-run note (state at hand-off).** While I was finishing, other seats continued to edit the lane working tree
(`corpus/lessons/round-55.md`, `corpus/knowledge/iso-11770-3-edition-status.md`, `corpus/sources-census.sh`,
`corpus/QUALITY.md`, `corpus/stamps.tsv`, `LOG.md`, `SCORECARD.md`). Every finding above is stated against the
**candidate commit `348aa3b8`** (the measured revision) and, where it differs, against the working tree as it stood
at the end of my run. I re-read the working tree at hand-off and confirmed: D1–D5 and D7 are corrected there, the
C2 counter still reads `value=2 amd=1 recheck=1 guard=1 (bad=none)` on it, and D6 remains open. I did not write to
any lane file; my only writes are `build/R55ScoutISO.md` and `build/R55ScoutISO.d/`.
