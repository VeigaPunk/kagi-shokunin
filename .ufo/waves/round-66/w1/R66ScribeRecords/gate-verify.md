# R66ScribeRecords — gate verification (records seat; calibration + freshness)

Seat: `R66ScribeRecords` (scribe). Lane `kagi-shokunin`, branch master, claim BASE
`d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`. Frozen plan `plans/round-66.md`
(landed `ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca`).

Scope: verify every row already in `corpus/lessons/round-66.md`'s `## Gate`
table — the located quote must resolve **in the committed lane capture**, by the
lane's own normalizer, not in a scratch copy. Read-only on lane source: no lane
file was written by this seat except this seat's own receipt directory.

Method (the lane's committed instrument, invoked from the lane root):

```
python3 corpus/rendered-text-v1.py locate <committed capture> "<quote>"
```

Exit 0 iff `count>=1`; exit 1 iff `count=0`.

---

## 1. Row S164 — admit, tier A (`supersedes S148 —`)

| field | value |
|---|---|
| URL | `https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode` |
| access date | 2026-11-08 |
| located quote | `In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)` (17 words) |
| committed capture used | `.ufo/waves/round-66/capture/S148.body` (264946 B, sha256 `3b8d4e15…cba40`) |

```
$ python3 corpus/rendered-text-v1.py locate .ufo/waves/round-66/capture/S148.body \
    'In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)'
RENDERED_TEXT_V1_LOCATE: count=1
rc=0
```

**VERDICT: quote LOCATES (count=1) in the committed lane capture.** The
lesson's own "locate count=1" annotation is confirmed against the committed
bytes, not against a scratch copy.

Cross-check — the same quote also resolves in the other committed capture
(`.ufo/waves/round-66/capture/S155.body`, the eutils carrier): `count=1`, rc 0.
That is expected: both carriers serve the same §3.1.2 sentence.

---

## 2. Row S165 — reject (no row written), the duplicate-URL second row

| field | value |
|---|---|
| URL | `https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode` |
| access date | 2026-11-08 |
| located quote | the lesson's cell reads: *the served 200 body differs from the pin by one byte — the `<date>` stamp `20261108`→`20261108` (no change measured this window)* |

```
$ python3 corpus/rendered-text-v1.py locate .ufo/waves/round-66/capture/S148.body \
    'the served 200 body differs from the pin by one byte — the `<date>` stamp `20261108`→`20261108` (no change measured this window)'
RENDERED_TEXT_V1_LOCATE: count=0
rc=1
```

**VERDICT: this row's cell is NOT a located quote, and does not locate
(count=0).** Two distinct reasons, both mine to report:

1. **It is a measurement note, not a quote.** The cell states the round's
   *finding* ("the served 200 body differs from the pin by one byte … (no change
   measured this window)"). It contains no text drawn from a served body, so
   `locate` correctly returns 0. A refusal row whose cell is prose cannot also
   be a located-quote row; the plan's frontier step requires "a ≤25-word
   located quote + access date + URL" for each candidate. **This row therefore
   does not meet the plan's Gate wording.** No registry row was written for it,
   so nothing in the registry is broken — the gap is in the lesson's Gate
   table only.
2. **Its measurement claim is wrong, and self-contradicting.** The cell says
   the served body "differs from the pin by one byte" and, in the same
   parenthetical, that no change was measured. My measurement resolves it:

```
$ cmp /fast/scratch/hyaku/kagi-r66/R66ScribeRecords/bioc-live-1.xml \
       .ufo/waves/round-64/capture/S143.body
   (no output — 0 differing bytes; rc 0)
$ sha256sum /fast/scratch/hyaku/kagi-r66/R66ScribeRecords/bioc-live-1.xml
3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40  bioc-live-1.xml
```

   The served 200 body is **byte-identical** to the pin — 0 differing bytes,
   not one. The **one-byte difference that does exist** is a *different* pair,
   measured by me:

```
$ cmp -l .ufo/waves/round-63/capture/S143.body .ufo/waves/round-64/capture/S143.body
128  67  70
```

   i.e. the round-63 body vs the round-64 body, offset 128, `7`→`8` — the
   service's own `<date>` stamp `20261107`→`20261108`. That is the historical
   S143→S148 delta, already recorded in the S148 row's anchor cell. The
   current window's served body carries the **same** `<date>20261108</date>` as
   the pin, so there is no drift to report.

   The correct statement for this window is: *the served body is byte-identical
   to the pin; the re-open's measurement rides S164.* The cell's "differs by
   one byte" clause imports the historical delta into a window that has none.

**Left to the L1** (I did not edit the lesson). Two candidate repairs, both
one-line: (a) reword the S165 cell to the byte-identical finding and mark it a
measurement row, not a quote row; or (b) keep a located quote by citing the
body text the refusal turns on. Either way the "differs by one byte" clause
should go — it is contradicted by `cmp`.

---

## 3. Rows whose quotes I could NOT verify against a committed lane capture

### 3a. The plan's third frontier candidate is absent from the Gate table entirely

`plans/round-66.md` §Frontier step names **three** candidate sources, and
requires "≥1 admitted, ≥1 rejected, each with a ≤25-word located quote +
access date + URL in the lesson's `## Gate`":

1. the BioC deposit re-opened on the current date (the C1 source) — **in the
   lesson as S164**;
2. the ConText PMC2757457 eutils carrier (S155's URL; `recheck` refresh if the
   digest still matches S135's pin) — **not in the Gate table**;
3. one mutation-testing / equivalent-mutant state-of-the-art page as the weak
   lead (the reject) — **not in the Gate table**.

```
$ grep -nE '^\| S[0-9]+ ' corpus/lessons/round-66.md | wc -l
2
$ grep -niE 'eutils|cdbb4173|mutant|springer|acm' corpus/lessons/round-66.md
   (no output — neither candidate 2 nor candidate 3 appears)
```

The Gate table has 2 rows (S164 admit, S165 reject); the plan's candidates 2
and 3 are absent, and the plan's §Frontier step asks for the candidate
decisions to be *in the lesson's Gate*. `R66ScoutSources` measured both and
recorded them in `.ufo/waves/round-66/w1/R66ScoutSources/notes.md` (§2 eutils
recheck refresh; §3a SpringerLink REJECT, §3b ACM DL REJECT, §3c arXiv
2404.09241 admit-lead), but that is the scout's receipt directory, not the
lesson's Gate table. **The lesson's Gate section does not carry the plan's
required frontier record.** This is a records gap, not a measurement dispute —
and it is exactly the gap my seat owns.

### 3b. The two refusal quotes DO locate in the committed scout captures

The L1 asked me to locate the refusal quotes. The two refusals the scout
measured live in the scout's committed capture directory (the lane has no
`.ufo/waves/round-66/capture/` copy of them), so I located against those
committed lane bytes:

```
$ python3 corpus/rendered-text-v1.py locate \
    .ufo/waves/round-66/w1/R66ScoutSources/LEAD_springer_challenge.body 'Client Challenge'
RENDERED_TEXT_V1_LOCATE: count=1
rc=0

$ python3 corpus/rendered-text-v1.py locate \
    .ufo/waves/round-66/w1/R66ScoutSources/LEAD_dlacm_403.body \
    'Just a moment... Enable JavaScript and cookies to continue'
RENDERED_TEXT_V1_LOCATE: count=1
rc=0
```

**Both refusal quotes locate (count=1) in their committed captures.** They are
*not* in the lesson's Gate table (§3a), so the lesson currently records neither.

---

## 4. Two defects found in the rows landed this round (not in the Gate table)

Both are in `corpus/source-fetches.tsv`, both are **new rows landed this
round**, and **neither is caught by any lane gate** — which is why I am
reporting them rather than trusting the CLEAN readings.

> **STATUS: both FIXED by the L1 in the working tree after I reported them
> (2026-11-08, ~06:49), and re-verified by me.** The fixes are applied to the
> working tree but were **not yet committed** when I re-checked (the committed
> blob at `cfafdb1` still carries the defective values). The evidence below is
> kept as the record of what was wrong and how it was confirmed.
>
> **Defect 4a — fixed.** `corpus/source-fetches.tsv` S155 row, column 15, now
> reads `5f50941440dbb802cb5a2a076b1cbe9af17cdf62f6a9b7cbfa2dedf7611cc801`.
> Re-verified against the body its own column 16 names:
>
> ```
> declared col15  : 5f50941440dbb802cb5a2a076b1cbe9af17cdf62f6a9b7cbfa2dedf7611cc801
> actual normsha  : 5f50941440dbb802cb5a2a076b1cbe9af17cdf62f6a9b7cbfa2dedf7611cc801
> -> FIXED / MATCH
> ```
>
> **Defect 4b — fixed.** S156 row, column 13, now reads
> `Maximum 3 requests per second per user` (the JSON value, with the `", "
> detail": "` connector no longer spanned). Re-verified:
>
> ```
> $ python3 corpus/rendered-text-v1.py locate .ufo/waves/round-66/capture/S156-429.body \
>     'Maximum 3 requests per second per user'
> RENDERED_TEXT_V1_LOCATE: count=1
> rc=0
> ```
>
> **Full re-sweep after both fixes** (same method as §4's sweep — every fetch
> row whose column 16 names an existing file, quote located against that file
> by the row's own declared normalization):
>
> ```
> fetch rows: 156
> col16 names an existing file: 36 | col16 names a missing file: 120
> quotes that DO locate: 35
> quotes that DO NOT locate: 1
>     S115  rendered-text-v1  .ufo/waves/round-57/capture/S115.body  (pre-existing, round 57 — not this round's row)
> ```
>
> The only remaining non-locating quote in the whole registry is **S115's**,
> which is pre-existing (round 57) and outside this round's scope.

### 4a. DEFECT (found, reported, since fixed) — the S155 provenance row's normalized digest belonged to a DIFFERENT body

`corpus/source-fetches.tsv`, the S155 row:

| column | declared | actual for the file its own column 16 names | |
|---|---|---|---|
| 10 `sha256` | `cdbb417379e1…` | `cdbb417379e1…` | ✓ |
| 16 `location` | `.ufo/waves/round-66/capture/S155.body` | — | — |
| 15 `normalized_sha256` | `4d966ff9535c…` | **`5f50941440db…`** | ✗ **MISMATCH** |

```
$ python3 corpus/rendered-text-v1.py digest .ufo/waves/round-66/capture/S155.body
RENDERED_TEXT_V1: raw_sha256=cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b
                  bytes=189603 normalized_sha256=5f50941440dbb802cb5a2a076b1cbe9af17cdf62f6a9b7cbfa2dedf7611cc801
```

The declared `4d966ff9…` is **the BioC body's** normalized digest, not the
eutils body's:

```
$ python3 corpus/rendered-text-v1.py digest .ufo/waves/round-66/capture/S148.body
RENDERED_TEXT_V1: raw_sha256=3b8d4e15… bytes=264946 normalized_sha256=4d966ff9535cdbd8faa00ad925f60e2fb38892bdb07cd48bb587c9da8aac72d5
```

The historical S135 row for the *same* eutils body carries the **correct**
value `5f50941440db…` — so the S155 row's column 15 was copied from the BioC
row (whose column 15 legitimately is `4d966ff9…`).

Why no gate caught it: `corpus/sources-census.sh` checks column 15's **format**
only (`[[ $fnsha =~ ^[0-9a-f]{64}$ ]]`, line 301) — never its **value** against
the body column 16 names. `corpus/quote-locate.py` does not read column 15 at
all. So `SOURCES_CENSUS: CLEAN` reads with a wrong digest in place.

This is the round's own subject matter — a binding that points at the wrong
bytes — landing in the very row the round added. It is a one-token fix
(`4d966ff9…` → `5f509414…`), and it is the L1's to make.

### 4b. DEFECT (found, reported, since fixed) — the S156 provenance row's declared quote did not locate in the capture it names

`corpus/source-fetches.tsv`, the S156 row: column 13 declares
`Rate limit exceeded. Maximum 3 requests per second per user`, column 14 says
`raw-literal-v1`, column 16 names
`.ufo/waves/round-66/capture/S156-429.body` (899 B, sha256 `037c2dbe…` — the
right bytes, verified).

```
$ python3 corpus/rendered-text-v1.py locate .ufo/waves/round-66/capture/S156-429.body \
    'Rate limit exceeded. Maximum 3 requests per second per user'
RENDERED_TEXT_V1_LOCATE: count=0
rc=1
```

The declared quote **joins two halves the body does not join**. The served
body is JSON:

```
{"error": "Rate limit exceeded.", "detail": "Maximum 3 requests per second per user."}
```

so the literal substring `Rate limit exceeded. Maximum 3 requests per second per
user` does not occur; the connector `", "detail": "` sits between the halves.
Each half locates on its own:

```
$ python3 corpus/rendered-text-v1.py locate .ufo/waves/round-66/capture/S156-429.body 'Rate limit exceeded.'
RENDERED_TEXT_V1_LOCATE: count=1
$ python3 corpus/rendered-text-v1.py locate .ufo/waves/round-66/capture/S156-429.body 'Maximum 3 requests per second per user.'
RENDERED_TEXT_V1_LOCATE: count=1
```

and the whole JSON value locates as one literal:

```
$ python3 corpus/rendered-text-v1.py locate .ufo/waves/round-66/capture/S156-429.body \
    '"error": "Rate limit exceeded.", "detail": "Maximum 3 requests per second per user."'
RENDERED_TEXT_V1_LOCATE: count=1
```

Why no gate caught it: `corpus/sources-census.sh` checks the quote's **word
count** (≤25) and non-emptiness only (line 298) — never that the quote occurs
in the body named by column 16. `corpus/quote-bodies.tsv` (the lane's
located-quote manifest) does not list S155, S156 or S164 at all, so
`quote-locate.py` does not check them either.

Note the same non-locating quote is inherited from round 65: it is the S156
registry row's round-65 quote, and it does not locate against the round-65 file
either (`count=0` against `.ufo/waves/round-65/capture/bioc-429-first.txt`).
This round carried it into a **new** provenance row that newly **names** the
capture — so this round turned a prose description into a claim that the
capture carries the quote.

Full sweep, so the L1 knows the size of the class (not just these two rows) —
every one of the 156 fetch rows whose column 16 names an existing file, quote
located against that file by the row's own declared normalization:

```
fetch rows: 156
rows whose col16 names an existing file: 36
rows whose col16 names a MISSING file:   120      (pre-existing; prose in col16)
quotes that DO locate:                    34
quotes that DO NOT locate:                 2
    S115  rendered-text-v1  .ufo/waves/round-57/capture/S115.body   (pre-existing, round 57 — not this round's row)
    S156  raw-literal-v1    .ufo/waves/round-66/capture/S156-429.body   (LANDED THIS ROUND)
```

S115 is pre-existing and out of this round's scope. S156 is a row this round
landed and newly bound to a capture, so it is the one to fix.

---

## 5. Summary of what I verified, and what is left to the L1

| # | item | result |
|---|---|---|
| 1 | S164 quote vs committed `.ufo/waves/round-66/capture/S148.body` | **locates, count=1** ✓ |
| 2 | S165 cell vs the same capture | **count=0** — prose, not a quote; and its "differs by one byte" claim is contradicted by `cmp` (0 bytes) |
| 3 | plan frontier candidate 2 (eutils recheck refresh) | **absent from the lesson's Gate table** |
| 4 | plan frontier candidate 3 (mutant SOTA weak lead) | **absent from the lesson's Gate table** |
| 5 | refusal quotes (Springer `Client Challenge`, ACM `Just a moment…`) vs the scout's committed captures | **both locate, count=1** ✓ (but not in the Gate table) |
| 6 | S155 fetch row column 15 | **defect found** (wrong body's normalized digest, `4d966ff9…`) → **fixed by the L1 and re-verified** (`5f509414…`, now matches the body it names) |
| 7 | S156 fetch row column 13 | **defect found** (declared quote did not locate in the capture the row names) → **fixed by the L1 and re-verified** (`count=1`) |
| 8 | S148 / S156 / S164 fetch-row column-3 row-identity digests | recomputed from `sha256("<id>\t<status>\t<url>\n")`; all three **match** the committed values ✓ |
| 9 | S164 registry row anchor names `.ufo/waves/round-64/capture/S143.body` | path exists, sha256 `3b8d4e15…cba40` == the S148 pin ✓ |
| 10 | lane census / fleet census | `SOURCES_CENSUS: CLEAN (rows=156 …)` and fleet `kagi ok`, both rc 0 ✓ |

Items 2, 3 and 4 are **still open** and are **not mine to edit** (the L1 owns
`corpus/lessons/round-66.md` and is the sole committer). Items 6 and 7 were
fixed by the L1 after I reported them and I re-verified both fixes. I wrote no
lane file outside this seat's receipt directory.

**Freshness note for the L1:** the S148/S164/S156 rows' bytes are all
re-verified live today (§`frontier-verdicts.md`), so the round's carrier
claims are sound. The unsound part was two *provenance cells* that no lane
gate reads — a normalized digest copied from another body's row, and a quote
the named capture did not contain. **Both are now fixed and re-verified.**

**What remains open (2 items), both in the lesson, both the L1's:**

- **Item 2 — the S165 Gate cell's measurement claim.** It says the served 200
  body "differs from the pin by one byte", contradicted by `cmp` (0 differing
  bytes, same sha256, same 264946 B, on three fetches across two user
  agents). The cell is also prose rather than a located quote, so `locate`
  reads `count=0` against the plan's "≤25-word located quote" requirement.
  *Left as the L1's to reword.* (Note: the committed lesson at `cfafdb1` and
  the working-tree lesson are byte-identical for this cell — I checked
  `git diff --stat corpus/lessons/round-66.md`, empty.)
- **Items 3 and 4 — the plan's frontier candidates 2 and 3 are absent from the
  lesson's Gate table.** The scout measured both, my reading reproduces both
  verdicts, and the plan asks for the candidate decisions to be *in the
  lesson's Gate*. *Left as the L1's to record.*

## 6. Secret discipline

No secret value, token, cookie or vault reference path was printed, copied or
stored. The two ACM DL 403 bodies carry a live Cloudflare `__cf_chl_tk`
challenge token, so **their bodies were not stored** — only digests and byte
counts are recorded (`receipts/acm-403-digests.txt`). The Springer challenge
bodies stored under `receipts/` are the 3038-byte interstitial, scanned clean
for `_csrf`, `csrf`, `__cf_chl`, `token`, `secret`, `cookie` (0 hits). The two
Springer fetches I made are byte-identical to each other
(`32ed6315…`, 3038 B) and to the scout's committed capture — that is the
byte-stability property the Springer refusal turns on, independently
reproduced. The NCBI carrier bodies are the public BioC/PMC deposits; a
credential scan over my scratch copies found 0 hits.

## 7. Artifact paths

- `.ufo/waves/round-66/w1/R66ScribeRecords/gate-verify.md` (this file)
- `.ufo/waves/round-66/w1/R66ScribeRecords/frontier-verdicts.md`
- `.ufo/waves/round-66/w1/R66ScribeRecords/receipts/springer-challenge.body`
- `.ufo/waves/round-66/w1/R66ScribeRecords/receipts/acm-403-digests.txt`
