# K45ScoutSources — C2 assimilation inventory, collision guard and quarantine check (round 45, attempt 1)

Seat: scout (read-only). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
BASE `0d0192f63eb5e49826d75af1e5293004dc691a18`; predeclaration `307fb50da825d6e6f2b5c7981c71556d35611142`
(lane HEAD at read time = `307fb50da825d6e6f2b5c7981c71556d35611142`).
Staged package: `/home/vgpnk/Projects/shokuknow/merge/kagi/` (READ-ONLY, never written).
Scratch: `$HYAKU_SCRATCH/kagi-r45/K45ScoutSources` (`/fast/scratch/hyaku/kagi-r45/K45ScoutSources`),
created with `mkdir -p`, removed with `trap 'rm -rf -- "$S"' EXIT`; all receipts copied into this
directory before exit. **No repository file was created, edited or deleted; no registry row was appended.**

Receipts: `./receipts.txt`, `./reg-ids`, `./staged-ids`, `./collisions`,
`./red-witness-w1-collisions`, `./red-witness-w1-control-collisions`, `./red-witness-w2-collisions`.

---

## 1. Collision guard (exact command from the seat spec, unmodified)

```
$ grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}' <lane>/corpus/SOURCES.md      | grep -oE 'S[0-9]+' | sort > reg-ids
$ grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}' <pkg>/SOURCES.append.md      | grep -oE 'S[0-9]+' | sort > staged-ids
$ comm -12 reg-ids staged-ids > collisions
```

Both greps rc=0, `comm` rc=0.

| id list | lines | range | shape |
|---|---|---|---|
| `reg-ids` (lane registry) | **99** | S001–S099 | contiguous, **no gaps** → next free lane id is **S100** |
| `staged-ids` (campaign package) | **172** | S052–S223 | contiguous, no gaps |
| `collisions` | **48** | S052–S099 | contiguous |

**Collision count = 48** (`collisions` file: S052 … S099, one per line, last line `S099`).

Composition of the 48 (measured by URL join against the lane registry):
* **29** of the 48 colliding staged ids denote a document the lane **already holds under a different id**
  (e.g. staged `S052` = AWS OIDC identity-provider page = lane `S061`; staged `S061` = NIST SP 800-57
  Pt1 r5 = lane `S073`; staged `S066` = Gitleaks README = lane `S053`). These are id-space clashes on
  documents already admitted — appending them would duplicate a row.
* **19** of the 48 denote a document the lane does **not** hold at all (staged S058, S059, S060,
  S074–S078, S081, S082, S088–S091, S094, S096–S099).
* **None** of the five ids cited by the two staged entries (S159, S170, S171, S172, S173) and none of
  the prose-referenced S148 is in the collision set: the cited ids all sit above the lane's S099 ceiling.

### 1b. Red witness (required before any append) — **PASS, guard is alive**

Witness = a scratch registry copy carrying one row `  | S052 |` (two-space indent) that the staged set
collides with.

| # | fixture | guard pattern | ids extracted | `collisions` | verdict |
|---|---|---|---|---|---|
| W1 | scratch registry: header + separator + one indented row `  | S052 |` | `^ {0,3}\|` | 1 (`S052`) | **1 line — NONEMPTY** |
| W1c | same fixture, **negative control**: column-zero pattern `^\|` | `^\|` | 0 | 0 | control empty ⇒ the 0–3 leading-space tolerance is exactly what makes the witness fire |
| W2 | scratch registry = real `corpus/SOURCES.md` + appended `  | S052 |` row | `^ {0,3}\|` | 99 | **48 lines — NONEMPTY** (≥48 expected, unchanged from base) | 

Command, exit code and last output line for each run are in `receipts.txt` §(1b). The red witness
requirement ("a scratch registry copy with one row ` | S052 |` (indented 2 spaces) must yield a
non-empty collisions file") is **met**; the guard is not broken.

---

## 2. Quarantine check (read-only slice, exact awk from the seat spec)

```
$ awk -F'|' -v l='kagi' '$2 ~ ("`" l "`") && $3 ~ /round[0-9]+/ && $4 ~ /S[0-9]+/ {print $4, $5}' \
    /home/vgpnk/Projects/shokuknow/.ufo/waves/corpus-expansion-1/absent-defect-register.md
```

rc=0, **8 data rows**, all class `payload-absent`:

`S053  S071  S081  S090  S091  S093  S108  S113`

This derived slice is **identical to the frozen plan's list** (plan §C2: "register rows for kagi,
staged ids S053, S071, S081, S090, S091, S093, S108, S113") — 8 of 8, no extra and no missing row.
The register's own summary row (`| kagi | 8 |`) is correctly excluded by the `round[0-9]+` filter.

### 2a. Verdict per cited id

| cited id | cited by | in kagi quarantine slice? | verdict |
|---|---|---|---|
| **S159** | r39 `iso-11770-3-2015-supersession-chain-r39.md`, `source:` line | **no** | **not quarantined** — admissible after re-grounding (see §3/§4) |
| **S170** | r41 `iso-11770-3-catalogue-record-and-lifecycle-r41.md`, `source:` line | **no** | **not quarantined** — but its staged recheck command is currently unreachable (§4, S170 row) |
| **S171** | r41, `source:` line | **no** | **not quarantined** |
| **S172** | r41, `source:` line | **no** | **not quarantined** |
| **S173** | r41, `source:` line | **no** | **not quarantined** |
| **S148** | r39, **prose only** ("round 8's S148") — not a `source:` id of either entry | **no** | **not quarantined**, but **not an append candidate either** (see §5) |

**Intersection of the cited set {S148, S159, S170, S171, S172, S173} with the kagi quarantine slice
{S053, S071, S081, S090, S091, S093, S108, S113} = ∅ (empty).**

Trap avoided: the register also carries rows with the same *numbers* under other lanes —
`kake round1 S148`, `tabi round3 S148`, `kotoba round5 S172`, `tabi round5 S171` — describing
*different* documents. An id-only grep across the whole register would false-positive on
S148/S171/S172; the lane-scoped slice above is the correct filter, and the `tabi round5 S171` row is
the register's prose-class family (unfetchable), not a kagi row.

---

## 3. The staged rows of the cited ids — what cannot be appended as-is

Measured with the lane's own tools:

* `awk -F'|' NF` on the staged rows: **S148, S159, S170, S171, S172, S173 all give NF=14**, but the
  contract requires **NF=13** (11 columns). **107 of the 172** staged rows are NF≠13.
  Cause: every one of these rows carries an **escaped `\|`** inside the `recheck` cell (the `curl … | grep -c` command).
* The lane's own `corpus/SOURCES.md`: 99 rows, **0** with NF≠13, **0** rows containing an escaped or
  literal pipe in any cell.
* Lane `recheck`-cell census (99 rows): 67 bare `Nd`, 29 `on-release`, 2 ISO dates, 1 `on-change`,
  **0 rows carry a command** — i.e. the lane's schema keeps commands *out* of the cell.
* Fleet `scripts/sources-census.sh` E09 accepts only an ISO date, `NNd`, or a symbolic cadence, so the
  staged prose cell fails E09 as well as the shape check.

**Flag (literal or escaped pipe) — the offending cell for all six rows is the `recheck` cell, not the
`anchor` cell.** No `anchor` cell of these six rows contains a pipe. The fix is therefore: rewrite the
`recheck` cell to a bare cadence and move the command + expected count + run date into the round
lesson's `## Gate` block (addendum rule), and rewrite the `anchor` in my own located words as proposed
below.

### 3a. Normalized recheck table (proposal — L1 applies)

| id | staged `recheck` cell (verbatim) | normalized recheck (proposal) | stripped prose → lesson `## Gate` block |
|---|---|---|---|
| S148 | `180d — \`curl -fsSL 'https://std.samr.gov.cn/gb/search/gbDetailed?id=BD89DE8E07D83D08E05397BE0A0A4FAD' \| grep -c 'ISO/IEC 11770-3:2015'\` -> 1 (ran 2026-10-24)` | `180d` (or `2027-04-22` if an ISO date is wanted) | re-verify condition: the GB/T 17901.3-2021 catalogue record still names ISO/IEC 11770-3:2015; command + `grep -c` result + run date recorded in the Gate block, rendered with a plain `|` in prose (never inside a table cell) |
| S159 | `180d — \`curl -fsSL 'https://webstore.iec.ch/en/publication/62160' \| grep -c 'A more recent version of this publication exists'\` -> 1 (ran 2026-10-24)` | `180d` (or `2027-04-22`) | re-verify condition: the IEC record for the 2015 edition's Amendment 1 still shows a more recent version; command + result + run date → Gate block |
| S170 | `180d — \`curl -fsSL 'https://web.archive.org/web/20260212133408id_/https://www.iso.org/standard/60237.html' \| grep -c 'Withdrawal of International Standard'\` -> 2 (ran 2026-10-24)` | `180d` (or `2027-04-22`) | re-verify condition: the ISO catalogue record still shows status *Withdrawal of International Standard*. **Re-point the command to the live catalogue URL** — the archive snapshot returned `curl: (28) Connection timed out` on 2026-11-05 (§4) |
| S171 | `180d — \`curl -fsSL 'https://webstore.iec.ch/en/publication/71650' \| grep -c '2021-10-22'\` -> 2 (ran 2026-10-24)` | `180d` (or `2027-04-22`) | re-verify condition: the IEC record for the 2021 edition still carries its publication date 2021-10-22; command + result + run date → Gate block |
| S172 | `180d — \`curl -fsSL 'https://webstore.iec.ch/en/publication/107179' \| grep -c '2025-04-28'\` -> 2 (ran 2026-10-24)` | `180d` (or `2027-04-22`) | re-verify condition: the IEC record for the 2025 amendment still carries its publication date 2025-04-28; command + result + run date → Gate block |
| S173 | `180d — \`curl -fsSL 'https://webstore.iec.ch/en/publication/21094' \| grep -c '2008-07-02'\` -> 2 (ran 2026-10-24)` | `180d` (or `2027-04-22`) | re-verify condition: the IEC record for the 1999 edition still carries its withdrawal date 2008-07-02; command + result + run date → Gate block |

Cadence arithmetic (measured with `date -u -d`): `2026-11-05 + 180 days = 2027-05-04`;
`2026-10-24 + 180 days = 2027-04-22`. If the L1 opens the rows today (2026-11-05, per CORPUS rule 1 the
row's `opened` must be the date *this lane* opened the source), the ISO-date form is `2027-05-04`.
The bare `180d` form matches 67 of the lane's 99 existing rows and is the safer default.

### 3b. Anchor rewrite proposals (my own located words) + the ≤25-word quote each row must contain

`corpus/quote-locate.py` requires the manifest quote to appear **verbatim in that id's registry row**,
so the quote has to live inside the row text (anchor and/or teaches). It must also be ≤25 words
(lane `SC_FETCH`) and pipe-free (shape check). The quotes below are the ones I located in the bodies;
byte offsets are into the **fetched raw bodies** whose sha256/byte counts are recorded in
`build/K45ExecISO/captures/fetch-log.tsv`, so they can be used as `raw-literal-v1` manifest entries.

| id | proposed anchor (my own words) | quote the row must contain verbatim (≤25 words, pipe-free) | located in body | body sha256 / bytes / byte offset |
|---|---|---|---|---|
| S159 | IEC webstore record for the 2015 edition's Amendment 1: product-detail block (`Publication type` International Standard, `Publication date` 2017-11-28, `Edition` 3.0, `ICS` 35.030, `Withdrawal date` 2021-10-22, `Pages` 7) and the pointer to the later version; fetched 2026-11-05 | `A more recent version of this publication exists` | `S159.raw` | `8bd6e969…` / 430686 / 256615 (1 occurrence) |
| S170 | ISO catalogue record for the withdrawn 2015 third edition, status block (`Stage` *Withdrawal of International Standard* 95.99, `Publication date` 2015-08, `Edition` 3, `Number of pages` 81) plus the catalogue abstract's closing exclusion sentence; fetched 2026-11-05 | `does not cover certain aspects of key management` | `S170-live.raw` | `2e4c1524…` / 85615 / 44314 (1 occurrence) |
| S171 | IEC webstore record for the edition in force: product-detail block (`Publication type` International Standard, `Publication date` 2021-10-22, `Edition` 4.0, `ICS` 35.030, `Pages` 90); fetched 2026-11-05 | `2021-10-22` | `S171.raw` | `f3d4813a…` / 434303 / 263676 (as `Publication date</strong></td><td>2021-10-22`, 1 occurrence) |
| S172 | IEC webstore record for the 2021 edition's 2025 amendment: product-detail block (`Publication date` 2025-04-28, `Edition` 4.0, `Pages` 2); fetched 2026-11-05 | `2025-04-28` | `S172.raw` | `1079585f…` / 429695 / 259021 (1 occurrence) |
| S173 | IEC webstore record for the part's first edition: product-detail block (`Publication date` 1999-11-11, `Edition` 1.0, `Withdrawal date` 2008-07-02, `Pages` 35) and the pointer to the later version; fetched 2026-11-05 | `2008-07-02` | `S173.raw` | `34a9c4a3…` / 432311 / 261614 (1 occurrence) |
| S148 | 全国标准信息公共服务平台 record for GB/T 17901.3-2021, `采标情况` block naming the adopted international standard and its edition, with `标准状态` / `发布日期` / `实施日期`; fetched 2026-11-05 | `ISO/IEC 11770-3:2015` | live page (2026-11-05, HTTP 200, 81775 bytes, 1 occurrence) — body sha256 to be pinned by the L1's own capture | — |

---

## 4. Independent re-opens (freshness, 2026-11-05)

Public reads only; no forms, no writes, no account or vault contact. `curl -fsSL --compressed -A
'kagi-shokunin-round45/1.0 (documentation verification)' --max-time 25`.

| id | URL | http | bytes | staged `grep -c` expectation | measured today | agreement |
|---|---|---|---|---|---|---|
| S148 | `std.samr.gov.cn/gb/search/gbDetailed?id=BD89DE8E07D83D08E05397BE0A0A4FAD` | 200 | 81775 | 1 | 1 | ✔ |
| S159 | `webstore.iec.ch/en/publication/62160` | 200 | 429686\* | 1 | 1 | ✔ |
| S170 | `web.archive.org/web/20260212133408id_/https://www.iso.org/standard/60237.html` | **000 — curl: (28) Connection timed out** | 0 | 2 | not reachable | ✘ |
| S170 (live fallback) | `www.iso.org/standard/60237.html` | **200** | 85615 | 2 | 2 | ✔ |
| S171 | `webstore.iec.ch/en/publication/71650` | 200 | 434303\* | 2 | 2 | ✔ |
| S172 | `webstore.iec.ch/en/publication/107179` | 200 | 429695\* | 2 | 2 | ✔ |
| S173 | `webstore.iec.ch/en/publication/21094` | 200 | 432311\* | 2 | 2 | ✔ |

\* byte counts of the committed decoded bodies, matching `build/K45ExecISO/captures/fetch-log.tsv`.

Two findings the L1 must not inherit silently:

1. **S170's staged anchor claim is stale.** The staged anchor says "The live original at
   `https://www.iso.org/standard/60237.html` is behind a Cloudflare challenge and is kept visible here
   as the withdrawn original", and the r41 entry repeats that the ISO catalogue entry returns HTTP 403
   "Just a moment". On 2026-11-05 the live page returned **HTTP 200 with zero Cloudflare challenge
   markers** (`grep -ci 'just a moment\|cf-browser-verification\|challenge-platform'` → 0) and carried
   `Withdrawal of International Standard` (2 lines), `New version available: ISO/IEC 11770-3:2021`,
   `95.99`, `Number of pages: 81`, `Publication date 2015-08`, `Edition 3`. The *archive snapshot* URL is
   the one that timed out — twice, independently (ExecISO's fetch-log: `curl: (28) Connection timed out
   after 30001 ms; http 000`; my own 20 s attempt: `curl: (28)`, `http=000 bytes=0`).
   → the S170 row's recheck command and anchor should point at the **live** catalogue URL, and the
   "behind a Cloudflare challenge" clause must not be copied into the lane's row or entry.
2. **S170's capture has no fetch-log row of its own.** `fetch-log.tsv` records the S170 *archive* fetch
   as failed (empty sha256/bytes) and mentions `S170-live.raw` only inside the error text. The live body
   (`2e4c1524…`, 85615 bytes) therefore has no provenance row yet; the L1 needs one (and a 16-column
   `corpus/source-fetches.tsv` row — ExecISO's `fetch-log.tsv` is a 9-column scratch log, a different
   schema).

**Offsets are byte offsets, not character offsets.** `build/K45ExecISO/captures/located-quotes.tsv`
records *character* offsets into the `.txt` renders; `corpus/quote-locate.py` compares **bytes** of the
committed body (`data[int(offset):int(offset)+len(needle)] != needle`). For the multibyte-bearing rows
the two differ, so copying that file's offsets into `corpus/quote-bodies.tsv` would yield
`NOT-LOCATED … quote-not-at-offset`:

| id | quote | char offset in `located-quotes.tsv` | true **byte** offset | byte-offset check |
|---|---|---|---|---|
| S159 | `ISO/IEC 11770-3:2015/AMD1:2017 \| IEC` | 0 | 0 | ✔ (byte == char here) |
| S159 | `A more recent version of this publication exists` | 1825 | **1827** | ✘ at 1825 |
| S170 | `Withdrawal of International Standard` | 3418 | **3446** | ✘ at 3418 |
| S170 | `New version available: ISO/IEC 11770-3:2021` | 1247 | **1273** | ✘ at 1247 |
| S170 | `does not cover certain aspects of key management, such as key lifecycle management, mechanisms to generate or validate asymmetric key pairs` | 2534 | **2562** | ✘ at 2534 |

Additionally the two `.txt` renders are **not** the committed capture bodies: `corpus/rendered-text-v1.py
digest` on `S159.raw` gives `normalized_bytes=4567` while `S159.txt` is 3603 bytes, and on
`S170-live.raw` gives `7513` while `S170.txt` is 7468 (the `.txt` files additionally collapse
`management Part` → `managementPart`, i.e. they are not the committed normalizer's output).
`corpus/quote-bodies.tsv` must point at committed **raw** bodies under the lane's capture convention
(`round-37` precedent: `.ufo/waves/round-37/capture/S089-vault.body`), not at
`.ufo/waves/round-45/build/K45ExecISO/captures/*.txt`.

---

## 5. Renumber map (BY DOCUMENT) — **proposal; the L1 applies it**

Rule applied (plan §C2 + addendum): the id follows the **document** (its URL/anchor), never arithmetic.
The lane registry's ids are contiguous S001–S099 with no gaps, so the next free lane id is **S100** and
the adopted rows continue the lane's registry (append-only, CORPUS rule 2).

Order of first citation: the r39 entry (`iso-11770-3-2015-supersession-chain-r39.md`) is cited first in
the plan's C2 problem statement and first in `MERGE-REPORT.md`; within r41 the `source:` lines run
S170, S171, S172, S173.

| staged id | document (evidence) | proposed lane id | note |
|---|---|---|---|
| S159 | IEC webstore record, `webstore.iec.ch/en/publication/62160` (2015 Amendment 1) | **S100** | r39 `source:` id #1 |
| S170 | ISO catalogue record for the withdrawn 2015 third edition, `www.iso.org/standard/60237.html` (**live** URL; the staged archive-snapshot URL timed out) | **S101** | r41 `source:` id #1 |
| S171 | IEC webstore record, `webstore.iec.ch/en/publication/71650` (2021 edition) | **S102** | r41 `source:` id #2 |
| S172 | IEC webstore record, `webstore.iec.ch/en/publication/107179` (2025 amendment) | **S103** | r41 `source:` id #3 |
| S173 | IEC webstore record, `webstore.iec.ch/en/publication/21094` (1999 first edition) | **S104** | r41 `source:` id #4 |
| S148 | GB/T 17901.3-2021 catalogue record, `std.samr.gov.cn/…?id=BD89DE8E07D83D08E05397BE0A0A4FAD` | **S105** — *conditional* | **not an append candidate**: it is referenced only in r39's prose ("round 8's S148"), it is not a `source:` id of either entry, and the staged row's `used-by` names a different entry (`corpus/knowledge/gbt-17901-3-adoption-degree-r38.md`). The addendum says append only rows the admitted entries cite (`source:` ids). If the L1 keeps the S148 reference in the admitted text, it must either re-point that prose reference to the new id or drop it — and then S148's row would have to be appended with the correct `used-by` |

No two staged ids map to the same lane id; the mapping is a bijection on the six cited documents, and
none of the proposed ids (S100–S105) exists in the lane registry today.

Row-identity digests (`sha256("id\tstatus\turl\n")`, the `corpus/source-fetches.tsv` column 3), for the
proposed map with `status=mined`:

| proposed id | url | row_identity_sha256 |
|---|---|---|
| S100 | `https://webstore.iec.ch/en/publication/62160` | `c76c54ebdf849e680a9cacdb7adac9b42bbede2e4b1d145bae8a0346b6287676` |
| S101 | `https://std.samr.gov.cn/gb/search/gbDetailed?id=BD89DE8E07D83D08E05397BE0A0A4FAD` | `08ffddc217949eb15e31d3c81202e08e7c862d48935d775a8c28137a93c09927` |
| S102 | `https://www.iso.org/standard/60237.html` | `caa6b3cea6bd1d6824e4815d2da7576c9f91929429c4f71912069762e07c93fa` |
| S103 | `https://webstore.iec.ch/en/publication/71650` | `37bf7366ffe4169a18468cdb17de0cbf106ae3747f1d02e048466661ec39ea47` |
| S104 | `https://webstore.iec.ch/en/publication/107179` | `3f29a40f4a7f8bc451e0e8df3a9af34f708a6222fba2b7380f8538d5bd3009f7` |
| S105 | `https://webstore.iec.ch/en/publication/21094` | `01b491e8044243f778ce19a44e8d139102166dabb7f5fcac76087b3ea4f41532` |

(If the L1 decides against S148, the map compresses to S159→S100, S170→S101, S171→S102, S172→S103,
S173→S104 and the digests must be recomputed for the shifted ids — never shifted by hand.)

---

## 6. Named defects for the L1 (every surviving defect I measured)

1. **Staged rows are campaign-schema, not lane-schema.** All six cited rows have NF=14 (contract
   NF=13) because of the escaped `\|` inside the `recheck` cell; 107 of 172 staged rows are affected.
   A byte-exact append of any staged row therefore fails the lane's own census.
2. **`recheck` cells carry commands.** The lane's 99 rows never do (67 `Nd`, 29 `on-release`, 2 ISO
   dates, 1 `on-change`); the fleet census E09 also rejects the prose form. Strip the command into the
   lesson `## Gate` block.
3. **S170's staged recheck target is unreachable** and its staged anchor's "behind a Cloudflare
   challenge" clause is contradicted by a same-day HTTP 200. Re-point to the live catalogue URL.
4. **S170's live body has no provenance row**; `fetch-log.tsv` records the archive fetch as failed and
   mentions the live body only inside the error text. A `corpus/source-fetches.tsv` row (16 columns) is
   required, with `row_identity_sha256` from the table above.
5. **`located-quotes.tsv` offsets are character offsets** into the `.txt` renders; `quote-locate.py`
   wants byte offsets into the committed raw body — 4 of the 5 recorded offsets would fail
   `quote-not-at-offset` (§4 table). The `.txt` renders are also not the committed normalizer's output
   (`rendered-text-v1.py` digests differ: 4567 vs 3603 bytes for S159; 7513 vs 7468 for S170).
6. **The r41 staged entry has 4 column-1 `source:` lines.** The lane census requires at most one
   (`corpus/sources-census.sh`, `nsrc=$(grep -c '^source:' "$f")`, `[[ $nsrc -le 1 ]]`), and its
   `src_field()` (line 151) stops at the first non-indented continuation, so only `S170` would be read
   as the entry's cited id. The four ids must be merged into one `source:` line before landing.
7. **S148 is prose-referenced, not source-cited** (§5) — appending it would breach the addendum's
   "append only the rows the admitted entries cite" and the lane's `SC_USEDBY_NOCITE` /
   `used-by lists exactly the admitted entries citing the row` rule.
8. **The 48-id collision set is real but out of scope for these two entries** (29 of them are documents
   the lane already holds under another id). Any future adoption from this package must renumber by
   document; a bulk append would duplicate rows and trip E03/E04.

## 7. Scope kept

Read-only throughout: lane, `corpus/`, `plans/`, `SCORECARD.md`, `LOG.md`, `SHONEN.md`, `QUALITY`,
`SOURCES.md`, registries and sibling repos were read but never written; the staged package
`/home/vgpnk/Projects/shokuknow/merge/kagi/` was never written; no campaign tool was run there; no
registry row was appended; no git/jj mutating command was run; no secret, token, cookie or vault field
was read, printed or copied; no `op://` reference was written anywhere. Writes are confined to
`.ufo/waves/round-45/build/K45ScoutSources/` and to the scratch dir, which was deleted on exit.
