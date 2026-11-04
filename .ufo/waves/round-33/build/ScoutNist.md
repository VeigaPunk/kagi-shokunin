# ScoutNist — round 33 C2 source re-open (ten NIST ids)

Seat: `ScoutNist` (scout 1 of 2). Lane: `kagi-shokunin`. Frozen BASE
`76f4eeae7aa9af4dbb9423f5632b55791824253a`. Access date for every row: **2026-11-04** (UTC).
No lane-tracked file was read-modified, created or staged; this seat wrote only
`.ufo/waves/round-33/build/` and its scratch dir.

Companion artifacts, all under `.ufo/waves/round-33/build/`:

- `nist-captures.tsv` — 10 data lines, 14 tab-separated columns, keyed by **staged** id.
- `src-open/` — the ten raw bodies (`S061.html` … `S087.html`, `S083.pdf`, `S084.pdf`),
  the refetch proof `S079.refetch.html`, response headers `*.headers.txt` / `hdr-*.txt`,
  `fetch.log`, and `normalize.py` (the `rendered-text-v1` implementation).

## Result in one line

All ten URLs opened, HTTP 200, no redirect. **8 agree, 2 differ** (S079, S080 — see §4).
Three findings change what the admitted entries may say; two are numeric errors in prose
that the capture data now contradicts.

## 1. Method (reproducible)

Fetch, per id, exactly as the seat spec fixes it:

```sh
curl -fsSL --compressed -o <scratch body> -w '%{http_code} %{url_effective}' --max-time 90 <url>
```

`final_url` equals `registry_url` for all ten: no redirects, no trailing-slash change.
`bytes` and `sha256` are measured on the saved body (curl `--compressed`, so the bytes are
the **decoded** HTTP body; representation label `decoded-http-body-v1`). PDF text is
`pdftotext -layout -enc UTF-8` (poppler present at `/usr/bin/pdftotext`, version in §9).

`normalized_sha256` is the sha256 of `rendered-text-v1` as implemented by
`src-open/normalize.py`: HTML → drop `<script>`/`<style>` with contents, replace every
remaining tag with one space, resolve HTML entities; PDF → `pdftotext -layout`; then
collapse every whitespace run to one U+0020 and strip. The script recomputes the whole
TSV; nothing in `nist-captures.tsv` is hand-typed.

Every quote was verified as an **exact substring of the normalized text** and counted at
≤25 whitespace-separated words before the TSV was written (emitter asserts, then writes;
a failure aborts with no file). Counts: 5–21 words.

## 2. Fetch evidence

| staged id | http | final url | bytes | sha256 (decoded body) | normalized_sha256 |
|---|---|---|---|---|---|
| S061 | 200 | `csrc.nist.gov/pubs/sp/800/57/pt1/r5/final` | 47 203 | `e49ef52267ea3c566c157fb782c6908c2ee9519ea7bf171cd113898aded33942` | `950ae8a8ad88da31fa82856e9f8db0306e8422b3c175300c4eb18fa3d08c562e` |
| S062 | 200 | `csrc.nist.gov/pubs/sp/800/133/r3/ipd` | 45 351 | `389177cee332fad618606d6f3ed8c385a96c04dcd14ccb65648213f4fe54418d` | `955dd8665388946280b67fdcbd9e9c7cfa3d5343b54f223daf5cba40ebeb7fab` |
| S063 | 200 | `csrc.nist.gov/pubs/sp/800/133/r2/final` | 42 741 | `7bf12d6d21b86988b844448a51568b58fae08bf0d5653b2e23dd3132c18864cf` | `bb1cce593095f6c1b4b17b2f0bcd7c10d508e39ccf095326d46bdcc6dbf58bdb` |
| S079 | 200 | `csrc.nist.gov/pubs/sp/800/57/pt2/final` | 44 782 | `f95e0ce152a7a9deadb3e88de617156cfdafaf524437823bdc85c439580838a3` | `a4dad4f29c355b74d40b2b7e9f9ecc40c2839527dc0e23c724ea447e05fb1950` |
| S080 | 200 | `csrc.nist.gov/pubs/sp/800/57/pt3/final` | 44 903 | `bf132165d6db37cbc6569112f125845fcce130e9deaac3d602c507d70e42a1b3` | `1047a8228fc6392ab03fefef01c9e0f5da7af9289fe6c249a75e61aea124e7a8` |
| S083 | 200 | `nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf` | 622 785 | `68266cb10868a1fee83fb8bcebbee9573fc738cee9141ee94d03649bad8538d5` | `00bae3f7bf9dc182616913b2831136b040e2f3e93c19c8552e869e4aabb4b758` |
| S084 | 200 | `nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p3.pdf` | 663 635 | `52b9a7d321ab0f8173032869290b3b4620dd1ced57e36c42e65e7e50ff38c3a3` | `36ce8fed8df840282a6042fd72a80a5854e53413ab3a878dcbee9fbb1d70929a` |
| S085 | 200 | `csrc.nist.gov/pubs/sp/800/57/pt2/r1/final` | 49 598 | `bbcb087ca2c012d4af9ec77f0cf4ec000df0d9a8393e8124d287c13f9552e6f6` | `810b05568ddcea5206c5a0fe4040345b2f50c29ab55ba2af1e9846e1fde06cd9` |
| S086 | 200 | `csrc.nist.gov/pubs/sp/800/57/pt3/r1/final` | 45 934 | `e3eb3b911beae51afeb3f85c5f7419faf2cad545486e414aadf62de290e8774c` | `c504bce605fd09aba772f888b9ff185506c2f429c682123c7d221691384e8ad1` |
| S087 | 200 | `csrc.nist.gov/pubs/sp/800/131/a/r2/final` | 45 595 | `2d62fd992cbca3b62f157285f33587b0c2f6868059380a1de9d15a95df607322` | `ff257649b6da6458d998f25b35d62cfbd1c1bf102b5367124f0d3e5b2b35ea39` |

**Ids I could not open: none.** No fetch was blocked, rate-limited or redirected.

### 2a. Staged pins vs today's bodies — and why raw sha is the wrong pin for CSRC

| staged id | staged pin (2026-10-23) | today | matches? |
|---|---|---|---|
| S061 | `5199fba3d8cbc781` | `e49ef52267ea3c56` | no |
| S062 | `80b2d35f39b23d62` | `389177cee332fad6` | no |
| S063 | `7d93079e311413e9` | `7bf12d6d21b86988` | no |
| S079 | `9f626bdf180b1e92` | `f95e0ce152a7a9de` | no |
| S080 | `e4353c8830a06536` | `bf132165d6db37cb` | no |
| S083 | `68266cb10868a1fe` | `68266cb10868a1fe` | **yes, byte-identical** |
| S084 | `52b9a7d321ab0f81` | `52b9a7d321ab0f81` | **yes, byte-identical** |
| S085 | `faa71d41bd5a12b9` | `bbcb087ca2c012d4` | no |
| S086 | `2a5f1f28a8f21e6d` | `e3eb3b911beae51a` | no |
| S087 | `d8143ef050529f41` | `2d62fd992cbca3b6` | no |

The eight HTML mismatches are **not** evidence of a content change. I fetched S079 twice,
back to back, and the raw bodies differ while the rendered text is identical:

```
S079.html        f95e0ce152a7a9deadb3e88de617156cfdafaf524437823bdc85c439580838a3
S079.refetch.html 4dab5b8390ff3fc67d147b8666ea3a995d1078ade8fbcf87fb4712de325fbb5b
normalized (both) a4dad4f29c355b74d40b2b7e9f9ecc40c2839527dc0e23c724ea447e05fb1950
```

The differing bytes are a Cloudflare email-obfuscation token,
`/cdn-cgi/l/email-protection#<rotating-hex>` — a fresh value per response. Every CSRC page
carries one, so a raw-byte sha256 of a CSRC page can never be reproduced; no ETag or
Last-Modified is served either (`hdr-S06*.txt`, `hdr-S07*.txt`, `hdr-S08*.txt` contain only
`content-type: text/html; charset=utf-8`). **Consequence for the capture rows:** pin
`rendered_text_sha` for the eight CSRC pages, and label their body representation
`decoded-http-body-volatile-v1` (house label) rather than a stable-body label. The two PDFs
are byte-stable — their sha256 still equals the 2026-10-23 pin exactly, and they serve
`last-modified: Thu, 23 May 2019 13:52:47 GMT` (S083) and `Wed, 18 Nov 2015 17:38:21 GMT`
(S084).

I also cannot date a page change from CSRC: with no validator header, a differing pin
proves nothing about *content*. Where §4 says a page contradicts a staged cell, the claim
is about the page as fetched **today**, not about what it said on 2026-10-23.

## 3. Per-id findings

Each block: URL · anchor · quote (the TSV's `quote`) · the staged `teaches` claim · verdict.
The TSV carries the same four values with the full anchor text.

### S061 — SP 800-57 Part 1 Rev. 5 (final)
- **URL** `https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final`
- **Anchor** Documentation block, field *Document History* (same block: `Date Published: May 2020`;
  `Publication Parts: SP 800-57 Part 2 Rev. 1 SP 800-57 Part 3 Rev. 1`).
- **Quote** `05/04/20: SP 800-57 Part 1 Rev. 5 (Final)`
- **Staged claim** "As of 2026-10-23 the final NIST key-management Part 1 is Rev. 5 of May 2020,
  so a control must cite Rev. 5 and must not cite the Rev. 6 draft"
- **Verdict: agree.** "May 2020" and the `(Final)` history entry are verbatim. **Over-claim
  flag:** the trailing clause *must not cite the Rev. 6 draft* is not on this page — it names
  no Rev. 6. It is the lane's S049 inference riding on this row; keep it in the entry but do
  not put it in S061's `teaches` as though the page said it.

### S062 — SP 800-133 Rev. 3 (Initial Public Draft)
- **URL** `https://csrc.nist.gov/pubs/sp/800/133/r3/ipd`
- **Anchor** Documentation header; page title `NIST SP 800-133 Rev. 3 (Initial Public Draft)`;
  Document History `04/17/26: SP 800-133 Rev. 3 (Draft)`; Planning Note `(06/30/2026)`.
- **Quote** `Comments Due: June 16, 2026 (public comment period is CLOSED)`
- **Staged claim** "Key-generation guidance newer than Rev. 2 exists only as a closed-comment
  draft, so Rev. 2 remains the citable final as of 2026-10-23"
- **Verdict: agree.** `Date Published: April 17, 2026`, the `CLOSED` comment field, the
  `(Initial Public Draft)` title and the `(Draft)` history entry all appear verbatim; the
  history contains no Final entry. The Planning Note is about comments, not adoption.

### S063 — SP 800-133 Rev. 2 (final)
- **URL** `https://csrc.nist.gov/pubs/sp/800/133/r2/final`
- **Anchor** Documentation block, field *Document History* (same block:
  `Date Published: June 2020 Supersedes: SP 800-133 Rev. 1 (07/23/2019)`;
  `Publication: https://doi.org/10.6028/NIST.SP.800-133r2`).
- **Quote** `06/04/20: SP 800-133 Rev. 2 (Final)`
- **Staged claim** "SP 800-133 Rev. 2 of June 2020 is the current final key-generation
  guidance and is what a control must cite today"
- **Verdict: agree.** June 2020, `Supersedes: … Rev. 1 (07/23/2019)`, the Final entry and a
  DOI all verbatim.

### S079 — SP 800-57 Part 2 (2005), CSRC page
- **URL** `https://csrc.nist.gov/pubs/sp/800/57/pt2/final`
- **Anchor** the red alert block `id="pub-withdrawn-message"` between the breadcrumb and the
  page title (icon `id="pub-withdrawn"`, `title="This publication has been withdrawn. See details
  below."`), which reads `Withdrawn on <span id='pub-withdrawn-date'>May 23, 2019</span>.
  Superseded by <span id='pub-superseded-container'>SP 800-57 Part 2 Rev. 1</span>`. The
  Dublin Core meta title also reads `NIST Special Publication (SP) 800-57 Part 2 (Withdrawn)`.
  The Documentation block *below* still prints `Date Published: August 2005` and
  Document History `08/25/05: SP 800-57 Part 2 (Final)`.
- **Quote** `Withdrawn on May 23, 2019`
- **Staged claim** "Part 2 was finalised in 2005 and sits outside the Part 1 revision cycle, so
  a control citing policy planning cites a document twenty years older than the Part 1 it sits
  beside"
- **Verdict: differs.** Two defects. (a) The page says the document is **withdrawn and
  superseded**; the cell says only "finalised in 2005", which reads as currency. (b) The
  arithmetic is wrong: August 2005 to Part 1 Rev. 5 (May 2020) is **14.7 years**, not "twenty".
- Also: this row's `used-by` is `nist-key-management-family-status.md`, the entry the plan
  **refuses as staged** — see §6.

### S080 — SP 800-57 Part 3 (2009), CSRC page
- **URL** `https://csrc.nist.gov/pubs/sp/800/57/pt3/final`
- **Anchor** the same `pub-withdrawn-message` alert block, reading
  `Withdrawn on <span id='pub-withdrawn-date'>January 22, 2015</span>. Superseded by
  <span id='pub-superseded-container'>SP 800-57 Part 3 Rev. 1</span>`; dcterms title
  `… Part 3 (Withdrawn)`. The Documentation block below still prints
  `Date Published: December 2009` and `12/28/09: SP 800-57 Part 3 (Final)`.
- **Quote** `Withdrawn on January 22, 2015`
- **Staged claim** "Part 3 was finalised in 2009, so the three parts of SP 800-57 carry three
  different vintages and a control that cites \"SP 800-57\" must name the part"
- **Verdict: differs.** Same defect as S079: withdrawal omitted. The page also gives an
  exact withdrawal date (2015-01-22) where the PDF wrapper (S084) says only "January 2015".
  The second half is right and worth keeping: the three vintages are 2020 (Part 1 Rev. 5),
  2019 (Part 2 Rev. 1), 2015 (Part 3 Rev. 1) — corroborated independently by each page's
  `Publication Parts` line.
- Same `used-by` defect as S079.

### S083 — SP 800-57 Part 2 (2005), PDF
- **URL** `https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf`
- **Anchor** PDF p.1 "Warning Notice" wrapper: banner `Withdrawn NIST Technical Series
  Publication`; notice line `The attached publication has been withdrawn (archived), and is
  provided solely for historical purposes.`; the quote is the **Withdrawal Note** field, under
  `Withdrawal Date  May 23, 2019`.
- **Quote** `SP 800-57 Part 2 is superseded in its entirety by the publication of SP 800-57 Part 2 Revision 1.`
- **Staged claim** "The 2005 Part 2 is a withdrawn document: a control citing \"SP 800-57 Part
  2\" without a revision cites a superseded one"
- **Verdict: agree.** Banner, notice, withdrawal date and note all verbatim; the wrapper names
  the successor and its DOI (`10.6028/NIST.SP.800-57pt2r1`). Bytes identical to the staged
  pin. The PDF's own `Last-Modified` (2019-05-23) is the withdrawal date.

### S084 — SP 800-57 Part 3 (2009), PDF
- **URL** `https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p3.pdf`
- **Anchor** PDF p.1 "Archived NIST Technical Series Publication" wrapper; notice line
  `The attached publication has been archived (withdrawn), and is provided solely for
  historical purposes.`; the quote is the **Withdrawal Note:** field, under
  `Withdrawal Date:  January 2015`.
- **Quote** `SP 800-57 Part 3 is superseded in its entirety by the publication of SP 800-57 Part 3 Revision 1 (January 2015).`
- **Staged claim** "Part 3 has been withdrawn since January 2015, so the application's own
  guidance must come from Part 3 Rev. 1"
- **Verdict: agree.** `archived (withdrawn)`, the date and the note verbatim; bytes identical
  to the staged pin. Caution for later greps: the wrapper's *Latest revision of the attached
  publication* line renders as `SP 800-53 Part 3 Revision 1 (as of July 15, 2015)` — a wrong
  series number in NIST's own wrapper (or an extraction artifact of the layout engine). Do not
  use that line as evidence about Part 3; the Withdrawal Note is the reliable field.

### S085 — SP 800-57 Part 2 Rev. 1 (final)
- **URL** `https://csrc.nist.gov/pubs/sp/800/57/pt2/r1/final`
- **Anchor** Documentation block, field *Document History* (same block:
  `Date Published: May 2019 Supersedes: SP 800-57 Part 2 (08/25/2005)`;
  `Publication: https://doi.org/10.6028/NIST.SP.800-57pt2r1`;
  `Publication Parts: SP 800-57 Part 1 Rev. 5 SP 800-57 Part 3 Rev. 1`).
- **Quote** `05/23/19: SP 800-57 Part 2 Rev. 1 (Final)`
- **Staged claim** "The citable Part 2 is Rev. 1 of May 2019, with a stable DOI, and it is what
  a control must name"
- **Verdict: agree**, with an **omission flag**. Every stated fact is verbatim. But the page
  carries `Planning Note (07/01/2025): This publication is currently being reviewed. Monitor
  progress on the Crypto Publication Review Project.` (raw markup: `id='pub-planning-note'`).
  The row does not record it, which over-states stability — "stable DOI" is true, "stable
  document" is not, and the capture row is the place a reader would check.

### S086 — SP 800-57 Part 3 Rev. 1 (final)
- **URL** `https://csrc.nist.gov/pubs/sp/800/57/pt3/r1/final`
- **Anchor** Documentation block, field *Document History* (same block:
  `Date Published: January 2015 Supersedes: SP 800-57 Part 3 (12/28/2009)`;
  `Publication: https://doi.org/10.6028/NIST.SP.800-57pt3r1`;
  `Publication Parts: SP 800-57 Part 1 Rev. 5 SP 800-57 Part 2 Rev. 1`).
- **Quote** `01/22/15: SP 800-57 Part 3 Rev. 1 (Final)`
- **Staged claim** "The citable Part 3 is Rev. 1 of January 2015, with a stable DOI, and its
  revision history is the record a control cites"
- **Verdict: agree**, with the **same omission flag** as S085: `Planning Note (07/01/2025):
  This publication is currently being reviewed.` is on the page and absent from the row.

### S087 — SP 800-131A Rev. 2 (final)
- **URL** `https://csrc.nist.gov/pubs/sp/800/131/a/r2/final`
- **Anchor** Documentation block, `Planning Note (10/21/2024)` (same block:
  `Date Published: March 2019 Supersedes: SP 800-131A Rev. 1 (11/06/2015)`;
  Document History `03/21/19: SP 800-131A Rev. 2 (Final)`;
  `Publication: https://doi.org/10.6028/NIST.SP.800-131Ar2`).
- **Quote** `An initial public draft of Revision 3 has been posted for public comment through December 4, 2024.`
- **Staged claim** "Rev. 2 of March 2019 is the current final transition guidance, and Rev. 3
  exists only as a closed-comment draft, so a control that needs an algorithm's approval
  horizon cites Rev. 2"
- **Verdict: agree.** All fields verbatim, and the Document History ends at
  `03/21/19 … (Final)`, so Rev. 2 is still the newest final on this page. **Minor flag:**
  "closed-comment" is date arithmetic here (the window ended 2024-12-04); the literal word
  `CLOSED` is printed on the Rev. 3 IPD page (lane S110), not on this one.

## 4. Findings ranked by consequence

1. **The admitted entry's headline is falsified (blocking for the entry's title/lede).**
   `nist-key-management-parts-withdrawal.md` is titled *"… and the CSRC pages do not say so"*
   and its table column is labelled *"CSRC page says"* with only the `(Final)` history line.
   As fetched today, the CSRC pages for both 2005 Part 2 and 2009 Part 3 carry a red alert
   block (`#pub-withdrawn-message`) that states the withdrawal date and the superseding
   revision, and their dcterms metadata titles contain `(Withdrawn)`. The *observation* the
   entry teaches survives and gets stronger (a revision history reading "(Final)" is not a
   currency check), but "the CSRC pages do not say so" must go. Suggested replacement lede,
   evidence-accurate: *"the revision-history block still ends at '(Final)', while a separate
   alert block states the withdrawal"* — i.e. the trap is that the two places on one page
   disagree, not that CSRC is silent. I cannot date the change (no validator header); I state
   only what the pages say on 2026-11-04.
2. **The admitted entry's duration range is wrong (numeric).** It says a revision-less citation
   "is citing a document that has been withdrawn for between eleven and twenty years". Measured
   against the withdrawal dates this seat captured: Part 2 → 7.45 years (2 722 days), Part 3 →
   11.78 years (4 304 days). Correct range: **between seven and twelve years**. The "twenty"
   is inherited from the same bad arithmetic as S079's `teaches` cell.
3. **S079/S080 `teaches` cells omit the withdrawal** and S079 also asserts "twenty years older
   than the Part 1 it sits beside" (14.7 years measured). Both cells must be re-pointed or
   rewritten at append; the plan already refuses the entry they route to (§6).
4. **S085/S086 omit a live review signal** (`Planning Note 07/01/2025`, "currently being
   reviewed"). Not fatal — both are still the citable finals — but the entry's rule 1 is about
   currency, so a reader is owed the note. One clause each in the entry suffices; the capture
   row is where it belongs.
5. **S061's `teaches` carries an inference** ("must not cite the Rev. 6 draft") the page does
   not support. Harmless in the entry (S049 holds the Rev. 6 status), wrong in the registry
   cell.
6. **Raw-byte sha256 is not a usable pin for the eight CSRC pages** (§2a). Two back-to-back
   fetches differ; the rendered text does not. The staged pins for those eight were never
   reproducible, and the two that *do* reproduce are exactly the two PDFs.

## 5. What I did not and cannot establish

- I did not open anything beyond the ten URLs; the other NIST rows in the staged file (S081,
  S082, S096–S098, S108–S110) are out of this seat's scope and were not fetched.
- I cannot tell whether the withdrawal banners existed on 2026-10-23. CSRC serves no
  `Last-Modified`, `ETag` or `Age` on these pages, and the body pin is provably volatile, so
  the pinned 2026-10-23 sha cannot be compared for content. The banner's element ids and the
  `(Withdrawn)` dcterms title look like a long-standing CMS flag rather than a 12-day edit —
  **inference, not proof**.
- I did not read the substantive text of any SP 800-57 part beyond the wrapper page and the
  publication-page metadata. Nothing here supports a claim about what any part *requires*.
- `pdftotext` was present; no fallback extraction was needed and no quote was reconstructed
  from `strings`.

## 6. Handoff to the L1 (mechanical, do not skip)

1. **`used-by` re-pointing.** The staged rows for **S079 and S080** carry
   `used-by: corpus/knowledge/nist-key-management-family-status.md` — the entry the plan
   refuses as staged. Appending them as-is leaves two registry rows pointing at a file that
   will not exist, which is exactly the `used-by`/`entries_sourced` handshake the census
   checks. Re-point both to `corpus/knowledge/nist-key-management-parts-withdrawal.md`. The
   other eight already point at the two admitted entries (S061/S062/S063 →
   `…-guidance-status.md`; S083/S084/S085/S086/S087 → `…-parts-withdrawal.md`).
2. **Staged → lane id mapping is yours.** My TSV is keyed by staged id, as the seat spec
   requires. The plan renumbers by *document* onto S073–S082; I deliberately did not invent
   that mapping.
3. **Column shape.** `nist-captures.tsv` has the 14 columns the seat spec fixes, no header
   line, 10 data lines. The house `corpus/source-fetches.tsv` row is 16 columns
   (`id · status · wire-sha · registry_url · final_url · http · curl-mode · fetched ·
   representation · decoded-sha · bytes · "-" · text/quote · rendered-text-v1 ·
   rendered-sha · location`). Map: my `sha256` → the decoded-body sha column; my
   `normalized_sha256` → the rendered-text column; my `quote` → the text column; my `location`
   → the location column; `status` is the L1's `mined`.
4. **Volatility label.** Use `decoded-http-body-volatile-v1` for the eight CSRC rows and a
   stable-body label for S083/S084 (proved byte-identical across 12 days). My
   `decoded-http-body-v1` label is the seat's fixed label, not the house one.
5. **Quotes are verified against `rendered-text-v1`.** Re-check with
   `python3 .ufo/waves/round-33/build/src-open/normalize.py --text <body>` and a substring
   test, not against the raw HTML: the S079/S080 quotes span elements
   (`Withdrawn on <span …>May 23, 2019</span>`), so they are contiguous only after
   normalization. The two short quotes end before the `</span>.` boundary deliberately, which
   is why they read cleanly; do not "fix" them by joining the following sentence, because the
   normalizer renders that boundary as ` . `.
6. **Entry edits implied by §4** (content, not mechanics): (a) drop "the CSRC pages do not say
   so" and the `(Final)`-only reading of the "CSRC page says" column; (b) change "between
   eleven and twenty years" to "between seven and twelve years"; (c) either add a clause about
   the 07/01/2025 review note on Part 2 Rev. 1 / Part 3 Rev. 1, or accept that the entry's
   currency rule reads stronger than the pages support.

## 7. Tooling and scratch

- No tool was installed or upgraded; no package manager ran (pacman is paused host-wide and
  was not touched). Used only preinstalled `curl`, `pdftotext`, `python3`, `sha256sum`,
  `stat`, `cmp`.
- Scratch: `/fast/scratch/hyaku/kagi-r33/ScoutNist/` (bodies, manifests, emitter). It is
  removed before this seat yields; everything kept was copied into
  `.ufo/waves/round-33/build/` first. `src-open/S079.refetch.html` is the volatility proof and
  is the only body kept twice.
- No lane-tracked file, no `considerthese/`, no sibling `*-shokunin`, no fleet-root path was
  written. Git was not mutated; no repository was cloned (no clone was needed — no
  `git archive` of BASE either, since this seat measures live URLs, not the tree).
- Vault contact: none. No `op` subcommand was run at all; the handler's absence is expected
  and is not a defect.
